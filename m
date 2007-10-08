Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l982sqnh027196
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 12:54:52 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l982wSvX190348
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 12:58:28 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l982sbWI006339
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 12:54:37 +1000
Message-ID: <47099BDC.7080701@linux.vnet.ibm.com>
Date: Mon, 08 Oct 2007 08:24:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Memory controller merge (was Re: -mm merge plans for 2.6.24)
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org> <4701C737.8070906@linux.vnet.ibm.com> <Pine.LNX.4.64.0710021604260.4916@blonde.wat.veritas.com> <47034F12.8020505@linux.vnet.ibm.com> <Pine.LNX.4.64.0710031918470.9414@blonde.wat.veritas.com> <47046922.4030709@linux.vnet.ibm.com> <Pine.LNX.4.64.0710041258530.3485@blonde.wat.veritas.com> <4705AA79.9080008@linux.vnet.ibm.com> <Pine.LNX.4.64.0710071758210.13172@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0710071758210.13172@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Fri, 5 Oct 2007, Balbir Singh wrote:
>> Hugh Dickins wrote:
>>> That's where it should happen, yes; but my point is that it very
>>> often does not.  Because the swap cache page (read in as part of
>>> the readaround cluster of some other cgroup, or in swapoff by some
>>> other cgroup) is already assigned to that other cgroup (by the
>>> mem_cgroup_cache_charge in __add_to_swap_cache), and so goes "The
>>> page_cgroup exists and the page has already been accounted" route
>>> when mem_cgroup_charge is called from do_swap_page.  Doesn't it?
>>>
>> You are right, at this point I am beginning to wonder if I should
>> account for the swap cache at all? We account for the pages in RSS
>> and when the page comes back into the page table(s) via do_swap_page.
>> If we believe that the swap cache is transitional and the current
>> expected working behaviour does not seem right or hard to fix,
>> it might be easy to ignore unuse_pte() and add/remove_from_swap_cache()
>> for accounting and control.
> 
> It would be wrong to ignore the unuse_pte() case: what it's intending
> to do is correct, it's just being prevented by the swapcache issue
> from doing what it intends at present.
> 

OK

> (Though I'm not thrilled with the idea of it causing an admin's
> swapoff to fail because of a cgroup reaching mem limit there, I do
> agree with your earlier argument that that's the right thing to happen,
> and it's up to the admin to fix things up - my original objection came
> from not realizing that normally the cgroup will reclaim from itself
> to free its mem. 

I'm glad we have that sorted out.

Hmm, would the charge fail or the mm get OOM'ed?)
> 

Right now, we OOM if charging and reclaim fails.


> Ignoring add_to/remove_from swap cache is what I've tried before,
> and again today.  It's not enough: if you trying run a memhog
> (something that allocates and touches more memory than the cgroup
> is allowed, relying on pushing out to swap to complete), then that
> works well with the present accounting in add_to/remove_from swap
> cache, but it OOMs once I remove the memcontrol mods from
> mm/swap_state.c.  I keep going back to investigate why, keep on
> thinking I understand it, then later realize I don't.  Please
> give it a try, I hope you've got better mental models than I have.
> 

I will try it. Another way to try it, is to set memory.control_type
to 1, that removes charging of cache pages (both swap cache
and page cache). I just did a quick small test on the memory
controller with swap cache changes disabled and it worked fine
for me on my UML image (without OOMing). I'll try the same test
on a bigger box. Disabling swap does usually cause an
OOM for workloads using anonymous pages if the cgroup goes
over it's limit (since the cgroup cannot pushout memory).

> And I don't think it will be enough to handle shmem/tmpfs either;
> but won't worry about that until we've properly understood why
> exempting swapcache leads to those OOMs, and fixed that up.
> 

Sure.


>>> Are we misunderstanding each other, because I'm assuming
>>> MEM_CGROUP_TYPE_ALL and you're assuming MEM_CGROUP_TYPE_MAPPED?
>>> though I can't see that _MAPPED and _CACHED are actually supported,
>>> there being no reference to them outside the enum that defines them.
>> I am also assuming MEM_CGROUP_TYPE_ALL for the purpose of our
>> discussion. The accounting is split into mem_cgroup_charge() and
>> mem_cgroup_cache_charge(). While charging the caches is when we
>> check for the control_type.
> 
> It checks MEM_CGROUP_TYPE_ALL there, yes; but I can't find anything
> checking for either MEM_CGROUP_TYPE_MAPPED or MEM_CGROUP_TYPE_CACHED.
> (Or is it hidden in one of those preprocesor ## things which frustrate
> both my greps and me!?)
> 

MEM_CGROUP_TYPE_ALL is defined to be (MEM_CGROUP_TYPE_CACHED |
MEM_CGROUP_TYPE_MAPPED). I'll make that more explicit with a patch.
When the type is not MEM_CGROUP_TYPE_ALL, cached pages are ignored.

>>> Or are you deceived by that ifdef NUMA code in swapin_readahead,
>>> which propagates the fantasy that swap allocation follows vma layout?
>>> That nonsense has been around too long, I'll soon be sending a patch
>>> to remove it.
>> The swapin readahead code under #ifdef NUMA is very confusing.
> 
> I sent a patch to linux-mm last night, to remove that confusion.
> 

Thanks, I saw that.

>> I also
>> noticed another confusing thing during my test, swap cache does not
>> drop to 0, even though I've disabled all swap using swapoff. May be
>> those are tmpfs pages. The other interesting thing I tried was running
>> swapoff after a cgroup went over it's limit, the swapoff succeeded,
>> but I see strange numbers for free swap. I'll start another thread
>> after investigating a bit more.
> 
> Those indeed are strange behaviours (if the swapoff really has
> succeeded, rather than lying), I not seen such and don't have an
> explanation.  tmpfs doesn't add any weirdness there: when there's
> no swap, there can be no swap cache.  Or is the swapoff still in
> progress?  While it's busy, we keep /proc/meminfo looking sensible,
> but <Alt><SysRq>m can show negative free swap (IIRC).
> 
> I'll be interested to hear what your investigation shows.
> 

With the new OOM killer changes, I see negative swap. When I run swapoff
with a memory hogger workload, I see (after swapoff succeeds)

....
Swap cache: add 473215, delete 473214, find 31744/36688, race 0+0
Free swap  = 18446744073709105092kB
Total swap = 0kB
Free swap:       -446524kB
...



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
