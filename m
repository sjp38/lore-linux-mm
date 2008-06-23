Date: Mon, 23 Jun 2008 17:48:17 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <20080623155400.GH10123@sgi.com>
Message-ID: <Pine.LNX.4.64.0806231718460.16782@blonde.site>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806181944080.4968@blonde.site> <200806191307.04499.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806191154270.7324@blonde.site> <20080619133809.GC10123@sgi.com>
 <Pine.LNX.4.64.0806191441040.25832@blonde.site> <20080623155400.GH10123@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jun 2008, Robin Holt wrote:
> 
> I finally tracked this down.  I think it is a problem specific to XPMEM
> on the SLES10 kernel and will not be a problem once Andrea's mmu_notifier
> is in the kernel.  It is a problem, as far as I can tell, specific to
> the way XPMEM works.
> 
> I will open a SuSE bugzilla to work the issue directly with them.
> 
> Prior to the transition event, we have a page of memory that was
> pre-faulted by a process.  The process has exported (via XPMEM) a
> window of its own address space.  A remote process has attached and
> touched the page of memory.  The fault will call into XPMEM which does
> the get_user_pages.
> 
> At this point, both processes have a writable PTE entry to the same
> page and XPMEM has one additional reference count (_count) on the page
> acquired via get_user_pages().
> 
> Memory pressure causes swap_page to get called.  It clears the two
> process's page table entries, returns the _count values, etc.  The only
> thing that remains different from normal at this point is XPMEM retains
> a reference.
> 
> Both processes then read-fault the page which results in readable PTEs
> being installed.
> 
> The failure point comes when either process write faults the page.
> At that point, a COW is initiated and now the two processes are looking
> at seperate pages.

A COW is initiated because memory pressure happens to have the page
locked at the instant do_wp_page is looking to reuse it?  That's the
scenario we were assuming before (once Nick had swept away my page
count mismemories), but it's not specific to XPMEM.  Well, I suppose
it is specific to a small proportion of get_user_pages callers, and it
might be that all the rest have by now worked around the issue somehow.

> 
> The scenario would be different in the case of mmu_notifiers.
> The notifier callout when the readable PTE was being replaced with a
> writable PTE would result in the remote page table getting cleared and
> XPMEM releasing the _count.

But XPMEM's contribution to the _count shouldn't matter.

> 
> All that said, I think the race we discussed earlier in the thread is
> a legitimate one and believe Hugh's fix is correct.

My fix?  Would that be the get_user_pages VM_WRITE test before clearing
FOLL_WRITE - which I believe didn't fix you at all?  Or the grand new
reuse test in do_wp_page that I'm still working on - of which Nick sent
a lock_page approximation for you to try?  Would you still be able to
try mine when I'm ready, or does it now appear irrelevant to you?

(Nick questioned the page_swapcount test in the lines I sent out, and
he was absolutely right: at the time I thought that once I looked at
the page_swapcount end of the patch, I'd find it taking page_mapcount
into account under swap_lock; but when I got there, found I had moved
away to other work before actually completing that end of it.  Probably
got stalled on deciding function names, that's taken most of my time!)

> 
> Thank you for all your patience,
> Robin

Not at all, thank you for raising a real issue: all the better
if you can get around it without a targeted fix for now.

If you're interested, by the way, in the earlier discussion
I mentioned, a window into it can be found at

	http://lkml.org/lkml/2006/9/14/384

but it's a broken thread, with misunderstanding on all sides,
so rather hard to get a grasp of it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
