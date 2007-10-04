Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l944JDbD022830
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 14:19:13 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l944KH3g251174
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 14:20:17 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l944GgMU006378
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 14:16:42 +1000
Message-ID: <47046922.4030709@linux.vnet.ibm.com>
Date: Thu, 04 Oct 2007 09:46:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Memory controller merge (was Re: -mm merge plans for 2.6.24)
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org> <4701C737.8070906@linux.vnet.ibm.com> <Pine.LNX.4.64.0710021604260.4916@blonde.wat.veritas.com> <47034F12.8020505@linux.vnet.ibm.com> <Pine.LNX.4.64.0710031918470.9414@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0710031918470.9414@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 3 Oct 2007, Balbir Singh wrote:
>> Hugh Dickins wrote:
>>> Sorry, Balbir, I've failed to get back to you, still attending to
>>> priorities.  Let me briefly summarize my issue with the mem controller:
>>> you've not yet given enough attention to swap.
>> I am open to suggestions and ways and means of making swap control
>> complete and more usable.
> 
> Well, swap control is another subject.  I guess for that you'll need
> to track which cgroup each swap page belongs to (rather more expensive
> than the current swap_map of unsigned shorts).  And I doubt it'll be
> swap control as such that's required, but control of rss+swap.
> 

I see what you mean now, other people have recommending a per cgroup
swap file/device.

> But here I'm just worrying about how the existence of swap makes
> something of a nonsense of your rss control.
> 

Ideally, pages would not reside for too long in swap cache (unless
I've misunderstood swap cache or there are special cases for tmpfs/
ramfs). Once pages have been swapped back in, they get assigned
back to their respective cgroup's in do_swap_page() (where we charge
them back to the cgroup).

The swap cache pages will be the first ones to go, once the cgroup
exceeds its limit.

There might be gaps in my understanding or I might be missing a use
case scenario, where things work differently.

>>> I accept that full swap control is something you're intending to add
>>> incrementally later; but the current state doesn't make sense to me.
>>>
>>> The problems are swapoff and swapin readahead.  These pull pages into
>>> the swap cache, which are assigned to the cgroup (or the whatever-we-
>>> call-the-remainder-outside-all-the-cgroups) which is running swapoff
>          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> I'd appreciate it if you'd teach me the right name for that!
> 

In the past people have used names like default cgroup, we could use
the root cgroup as the default cgroup.

>>> or faulting in its own page; yet they very clearly don't (in general)
>>> belong to that cgroup, but to other cgroups which will be discovered
>>> later.
>> I understand what your trying to say, but with several approaches that
>> we tried in the past, we found caches the hardest to most accurately
>> account. IIRC, with readahead, we don't even know if all the pages
>> readahead will be used, that's why we charge everything to the cgroup
>> that added the page to the cache.
> 
> Yes, readahead is anyway problematic.  My guess is that in the file
> cache case, you'll tend not to go too far wrong by charging to the
> one that added - though we're all aware that's fairly unsatisfactory.
> 
> My point is that in the swap cache case, it's badly wrong: there's
> no page more obviously owned by a cgroup than its anonymous pages
> (forgetting for a moment that minority shared between cgroups
> until copy-on-write), so it's very wrong for swapin readahead
> or swapoff to go charging those to another or to no cgroup.
> 
> Imagine a cgroup at its rss limit, with more out on swap.  Then
> another cgroup does some swap readahead, bringing pages private
> to the first into cache.  Or runs swapoff which actually plugs
> them into the rss of the first cgroup, so it goes over limit.
> 
> Those are pages we'd want to swap out when the first cgroup
> faults to go further over its limit; but they're now not even
> identified as belonging to the right cgroup, so won't be found.
> 

Won't the right cgroup assignment happen as discussed above?

>>> I did try removing the cgroup mods to mm/swap_state.c, so swap pages
>>> get assigned to a cgroup only once it's really known; but that's not
>>> enough by itself, because cgroup RSS reclaim doesn't touch those
>>> pages, so the cgroup can easily OOM much too soon.  I was thinking
>>> that you need a "limbo" cgroup for these pages, which can be attacked
>>> for reclaim along with any cgroup being reclaimed, but from which
>>> pages are readily migrated to their real cgroup once that's known.
>>>
>> Is migrating the charge to the real cgroup really required?
> 
> My answer is definitely yes.  I'm not suggesting that you need
> general migration between cgroups at this stage (something for
> later quite likely); but I am suggesting you need one pseudo-cgroup
> to hold these cases temporarily, and that you cannot properly track
> rss without it (if there is any swap).
> 

If what I understand and discussed earlier is, then we don't need
to go this route. But I think the idea of having a pseduo cgroup
is interesting (needs more thought).

>>> So in the current memory controller, that unuse_pte mem charge I was
>>> originally worried about failing (I hadn't at that point delved in
>>> to see how it tries to reclaim) actually never fails (and never
>>> does anything): the page is already assigned to some cgroup-or-
>>> whatever and is never charged to vma->vm_mm at that point.
>>>
>> Excellent!
> 
> Umm, please explain what's excellent about that.
> 

Nothing really, I was glad that we dont fail, even though we might
assign pages to some other cgroup. Not really exciting, but not
failing was a relief :-) In summary, there's nothing excellent
about it.

> Hugh


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
