Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8HKmTC5018504
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 06:48:29 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HKmSU84653058
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 06:48:28 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HKmSLN008155
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 06:48:28 +1000
Message-ID: <46EEE81A.1010404@linux.vnet.ibm.com>
Date: Tue, 18 Sep 2007 02:18:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH mm] fix swapoff breakage; however...
References: <Pine.LNX.4.64.0709171947130.15413@blonde.wat.veritas.com> <46EED1A7.5080606@linux.vnet.ibm.com> <Pine.LNX.4.64.0709172038090.25512@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0709172038090.25512@blonde.wat.veritas.com>
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
>>> More fundamentally, it looks like any container brought over its limit in
>>> unuse_pte will abort swapoff: that doesn't doesn't seem "contained" to me.
>>> Maybe unuse_pte should just let containers go over their limits without
>>> error?  Or swap should be counted along with RSS?  Needs reconsideration.
>> Thanks, for the catching this. There are three possible solutions
>>
>> 1. Account each RSS page with a probable swap cache page, double
>>    the RSS accounting to ensure that swapoff will not fail.
>> 2. Account for the RSS page just once, do not account swap cache
>>    pages
> 
> Neither of those makes sense to me, but I may be misunderstanding.
> 
> What would make sense is (what I meant when I said swap counted
> along with RSS) not to count pages out and back in as they are
> go out to swap and back in, just keep count of instantiated pages
> 

I am not sure how you define instantiated pages. I suspect that
you mean RSS + pages swapped out (swap_pte)?

> I say "make sense" meaning that the numbers could be properly
> accounted; but it may well be unpalatable to treat fast RAM as
> equal to slow swap.
> 
>> 3. Follow your suggestion and let containers go over their limits
>>    without error
>>
>> With the current approach, a container over it's limit will not
>> be able to call swapoff successfully, is that bad?
> 
> That's not so bad.  What's bad is that anyone else with the
> CAP_SYS_ADMIN to swapoff is liable to be prevented by containers
> going over their limits.
> 

If a swapoff is going to push a container over it's limit, then
we break the container and the isolation it provides. Upon swapoff
failure, may be we could get the container to print a nice
little warning so that anyone else with CAP_SYS_ADMIN can fix the
container limit and retry swapoff.

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
