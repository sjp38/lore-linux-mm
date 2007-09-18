Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8I4NcTS030906
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 14:23:38 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8I4NcgT4800756
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 14:23:38 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8I4M8pM013030
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 14:22:08 +1000
Message-ID: <46EF52A8.4000209@linux.vnet.ibm.com>
Date: Tue, 18 Sep 2007 09:53:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH mm] fix swapoff breakage; however...
References: <Pine.LNX.4.64.0709171947130.15413@blonde.wat.veritas.com> <46EED1A7.5080606@linux.vnet.ibm.com> <Pine.LNX.4.64.0709172038090.25512@blonde.wat.veritas.com> <46EEE81A.1010404@linux.vnet.ibm.com> <Pine.LNX.4.64.0709172312390.19506@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0709172312390.19506@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 18 Sep 2007, Balbir Singh wrote:
>> Hugh Dickins wrote:
>>> What would make sense is (what I meant when I said swap counted
>>> along with RSS) not to count pages out and back in as they are
>>> go out to swap and back in, just keep count of instantiated pages
>>>
>> I am not sure how you define instantiated pages. I suspect that
>> you mean RSS + pages swapped out (swap_pte)?
> 
> That's it.  (Whereas file pages counted out when paged out,
> then counted back in when paged back in.)
> 
>> If a swapoff is going to push a container over it's limit, then
>> we break the container and the isolation it provides.
> 
> Is it just my traditional bias, that makes me prefer you break
> your container than my swapoff?  I'm not sure.
>


:-) Please see my response below

>> Upon swapoff
>> failure, may be we could get the container to print a nice
>> little warning so that anyone else with CAP_SYS_ADMIN can fix the
>> container limit and retry swapoff.
> 
> And then they hit the next one... rather like trying to work out
> the dependencies of packages for oneself: a very tedious process.
> 

Yes, but here's the overall picture of what is happening

1. The system administrator setup a memory container to contain
   a group of applications.
2. The administrator tried to swapoff one/a group of swap files/
   devices
3. Operation 2, failed due to a container being above it's limit.
   Which implies that at some point a container went over it's
   limit and some of it's pages were swapped out

During swapoff, we try to account for pages coming back into the
container, our charging routine does try to reclaim pages,
which in turn implies -- it will use another swap device or
reclaim page cache, if both fails, we return -ENOMEM.

Given that the system administrator has setup the container and
the swap devices, I feel that he is in better control of what
to do with the system when swapoff fails.

In the future we plan to implement per container swap (a feature
desired by several people), assuming that administrators use
per container swap in the future, failing on limit sounds
like the right way to go forward.

> If the swapoff succeeds, that does mean there was actually room
> in memory (+ other swap) for everyone, even if some have gone over
> their nominal limits.  (But if the swapoff runs out of memory in
> the middle, yes, it might well have assigned the memory unfairly.)
> 

Yes, precisely my point, the administrator is the best person
to decide how to assign memory to containers. Would it help
to add a container tunable that says, it's ok to go overlimit
with this container during a swapoff.

> The appropriate answer may depend on what you do when a container
> tries to fault in one more page than its limit.  Apparently just
> fail it (no attempt to page out another page from that container).
> 

The problem with that approach is that applications will fail
in the middle of their task. They will never get a chance
to run at all, they will always get killed in the middle.
We want to be able to reclaim pages from the container and
let the application continue.

> So, if the whole system is under memory pressure, kswapd will
> be keeping the RSS of all tasks low, and they won't reach their
> limits; whereas if the system is not under memory pressure,
> tasks will easily approach their limits and so fail.
> 

Tasks failing on limit does not sound good unless we are out
of all backup memory (slow storage). We still let the application
run, although slowly.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
