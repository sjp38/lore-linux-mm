Date: Thu, 4 Oct 2007 14:16:02 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Memory controller merge (was Re: -mm merge plans for 2.6.24)
In-Reply-To: <47046922.4030709@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0710041258530.3485@blonde.wat.veritas.com>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
 <4701C737.8070906@linux.vnet.ibm.com> <Pine.LNX.4.64.0710021604260.4916@blonde.wat.veritas.com>
 <47034F12.8020505@linux.vnet.ibm.com> <Pine.LNX.4.64.0710031918470.9414@blonde.wat.veritas.com>
 <47046922.4030709@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Oct 2007, Balbir Singh wrote:
> Hugh Dickins wrote:
> > Well, swap control is another subject.  I guess for that you'll need
> > to track which cgroup each swap page belongs to (rather more expensive
> > than the current swap_map of unsigned shorts).  And I doubt it'll be
> > swap control as such that's required, but control of rss+swap.
> 
> I see what you mean now, other people have recommending a per cgroup
> swap file/device.

Sounds too inflexible, and too many swap areas to me.  Perhaps the
right answer will fall in between: assign clusters of swap pages to
different cgroups as needed.  But worry about that some other time.

> 
> > But here I'm just worrying about how the existence of swap makes
> > something of a nonsense of your rss control.
> > 
> 
> Ideally, pages would not reside for too long in swap cache (unless

Thinking particularly of those brought in by swapoff or swap readahead:
some will get attached to mms once accessed, others will simply get
freed when tasks exit or munmap, others will hang around until they
reach the bottom of the LRU and are reclaimed again by memory pressure.

But as your code stands, that'll be total memory pressure: in-cgroup
memory pressure will tend to miss them, since typically they're
assigned to the wrong cgroup; until then their presence is liable
to cause other pages to be reclaimed which ideally should not be.

> I've misunderstood swap cache or there are special cases for tmpfs/
> ramfs).

ramfs pages are always in RAM, never go out to swap, no need to
worry about them in this regard.  But tmpfs pages can indeed go
out to swap, so whatever we come up with needs to make sense
with them too, yes.  I don't think its swapoff/readahead issues
are any harder to handle than the anonymous mapped page case,
but it will need its own code to handle them.

> Once pages have been swapped back in, they get assigned
> back to their respective cgroup's in do_swap_page() (where we charge
> them back to the cgroup).
> 

That's where it should happen, yes; but my point is that it very
often does not.  Because the swap cache page (read in as part of
the readaround cluster of some other cgroup, or in swapoff by some
other cgroup) is already assigned to that other cgroup (by the
mem_cgroup_cache_charge in __add_to_swap_cache), and so goes "The
page_cgroup exists and the page has already been accounted" route
when mem_cgroup_charge is called from do_swap_page.  Doesn't it?

Are we misunderstanding each other, because I'm assuming
MEM_CGROUP_TYPE_ALL and you're assuming MEM_CGROUP_TYPE_MAPPED?
though I can't see that _MAPPED and _CACHED are actually supported,
there being no reference to them outside the enum that defines them.

Or are you deceived by that ifdef NUMA code in swapin_readahead,
which propagates the fantasy that swap allocation follows vma layout?
That nonsense has been around too long, I'll soon be sending a patch
to remove it.

> The swap cache pages will be the first ones to go, once the cgroup
> exceeds its limit.

No, because they're (in general) booked to the wrong cgroup.

> 
> There might be gaps in my understanding or I might be missing a use
> case scenario, where things work differently.
> 
> >>> I accept that full swap control is something you're intending to add
> >>> incrementally later; but the current state doesn't make sense to me.
> >>>
> >>> The problems are swapoff and swapin readahead.  These pull pages into
> >>> the swap cache, which are assigned to the cgroup (or the whatever-we-
> >>> call-the-remainder-outside-all-the-cgroups) which is running swapoff
> >          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > I'd appreciate it if you'd teach me the right name for that!
> > 
> 
> In the past people have used names like default cgroup, we could use
> the root cgroup as the default cgroup.

Okay, thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
