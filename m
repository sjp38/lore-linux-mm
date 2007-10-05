Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9537ew0031309
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 13:07:40 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9537fLR4718836
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 13:07:41 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9537fLn010612
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 13:07:41 +1000
Message-ID: <4705AA79.9080008@linux.vnet.ibm.com>
Date: Fri, 05 Oct 2007 08:37:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Memory controller merge (was Re: -mm merge plans for 2.6.24)
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org> <4701C737.8070906@linux.vnet.ibm.com> <Pine.LNX.4.64.0710021604260.4916@blonde.wat.veritas.com> <47034F12.8020505@linux.vnet.ibm.com> <Pine.LNX.4.64.0710031918470.9414@blonde.wat.veritas.com> <47046922.4030709@linux.vnet.ibm.com> <Pine.LNX.4.64.0710041258530.3485@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0710041258530.3485@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Thu, 4 Oct 2007, Balbir Singh wrote:
>> Hugh Dickins wrote:
>>> Well, swap control is another subject.  I guess for that you'll need
>>> to track which cgroup each swap page belongs to (rather more expensive
>>> than the current swap_map of unsigned shorts).  And I doubt it'll be
>>> swap control as such that's required, but control of rss+swap.
>> I see what you mean now, other people have recommending a per cgroup
>> swap file/device.
> 
> Sounds too inflexible, and too many swap areas to me.  Perhaps the
> right answer will fall in between: assign clusters of swap pages to
> different cgroups as needed.  But worry about that some other time.
> 

Yes, depending on the number of cgroups, we'll need to share swap
areas between them. It requires more work and thought process.

>>> But here I'm just worrying about how the existence of swap makes
>>> something of a nonsense of your rss control.
>>>
>> Ideally, pages would not reside for too long in swap cache (unless
> 
> Thinking particularly of those brought in by swapoff or swap readahead:
> some will get attached to mms once accessed, others will simply get
> freed when tasks exit or munmap, others will hang around until they
> reach the bottom of the LRU and are reclaimed again by memory pressure.
> 
> But as your code stands, that'll be total memory pressure: in-cgroup
> memory pressure will tend to miss them, since typically they're
> assigned to the wrong cgroup; until then their presence is liable
> to cause other pages to be reclaimed which ideally should not be.
> 

in-cgroup pressure will not affect them, since they are in different
cgroups. If there is pressure in the cgroup to which they are wrongly
assigned, they would get reclaimed first.

>> I've misunderstood swap cache or there are special cases for tmpfs/
>> ramfs).
> 
> ramfs pages are always in RAM, never go out to swap, no need to
> worry about them in this regard.  But tmpfs pages can indeed go
> out to swap, so whatever we come up with needs to make sense
> with them too, yes.  I don't think its swapoff/readahead issues
> are any harder to handle than the anonymous mapped page case,
> but it will need its own code to handle them.
> 
>> Once pages have been swapped back in, they get assigned
>> back to their respective cgroup's in do_swap_page() (where we charge
>> them back to the cgroup).
>>
> 
> That's where it should happen, yes; but my point is that it very
> often does not.  Because the swap cache page (read in as part of
> the readaround cluster of some other cgroup, or in swapoff by some
> other cgroup) is already assigned to that other cgroup (by the
> mem_cgroup_cache_charge in __add_to_swap_cache), and so goes "The
> page_cgroup exists and the page has already been accounted" route
> when mem_cgroup_charge is called from do_swap_page.  Doesn't it?
> 

You are right, at this point I am beginning to wonder if I should
account for the swap cache at all? We account for the pages in RSS
and when the page comes back into the page table(s) via do_swap_page.
If we believe that the swap cache is transitional and the current
expected working behaviour does not seem right or hard to fix,
it might be easy to ignore unuse_pte() and add/remove_from_swap_cache()
for accounting and control.

The expected working behaviour of the memory controller is that
currently, as you point out several pages get accounted to the
cgroup that initiates swapin readahead or swapoff. On
cgroup pressure (the one that initiated swapin or swapoff), the
cgroup would discard these pages first. These pages are discarded
from the cgroup, but still live on the global LRU.

When the original cgroup is under pressure, these pages might not
be effected as they belong to a different cgroup, which might not
be under any sort of pressure.

> Are we misunderstanding each other, because I'm assuming
> MEM_CGROUP_TYPE_ALL and you're assuming MEM_CGROUP_TYPE_MAPPED?
> though I can't see that _MAPPED and _CACHED are actually supported,
> there being no reference to them outside the enum that defines them.
> 

I am also assuming MEM_CGROUP_TYPE_ALL for the purpose of our
discussion. The accounting is split into mem_cgroup_charge() and
mem_cgroup_cache_charge(). While charging the caches is when we
check for the control_type.

> Or are you deceived by that ifdef NUMA code in swapin_readahead,
> which propagates the fantasy that swap allocation follows vma layout?
> That nonsense has been around too long, I'll soon be sending a patch
> to remove it.
> 

The swapin readahead code under #ifdef NUMA is very confusing. I also
noticed another confusing thing during my test, swap cache does not
drop to 0, even though I've disabled all swap using swapoff. May be
those are tmpfs pages. The other interesting thing I tried was running
swapoff after a cgroup went over it's limit, the swapoff succeeded,
but I see strange numbers for free swap. I'll start another thread
after investigating a bit more.

>> The swap cache pages will be the first ones to go, once the cgroup
>> exceeds its limit.
> 
> No, because they're (in general) booked to the wrong cgroup.
> 

I meant for the wrong cgroup, in the wrong cgroup, these will be the
first set of pages to be reclaimed.

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
