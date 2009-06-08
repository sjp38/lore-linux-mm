Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 625696B0055
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 18:47:33 -0400 (EDT)
Date: Tue, 9 Jun 2009 00:57:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/4] RFC - ksm api change into madvise
Message-ID: <20090608225756.GB8642@random.random>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com> <Pine.LNX.4.64.0906081555360.22943@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906081555360.22943@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh!

On Mon, Jun 08, 2009 at 05:18:57PM +0100, Hugh Dickins wrote:
> I notice that you chose to integrate fully (though not fully enough)
> with vmas, adding a VM_MERGEABLE flag.  Fine, that's probably going
> to be safest in the end, and I'll follow you; but it is further than

After we decided to switch to madvise, I suggested to take the
approach in the RFC in this thread so with a rmap_item list ordered by
address that is scanned nested in the core-vma loop that searches for
vma with VM_MERGEABLE set, so that madvise has only to set the
VM_MERGEABLE bit, and it still avoids to alter the VM at
all. Replacing the ksm slots (kind of out of sync ksm vmas) with the
nested loop, allows to provide madvise semantics while still being out
of sync with rmap_item and tree_item.

> You've resisted putting in the callbacks you need.  I think they were
> always (i.e. even when using /dev/ksm) necessary, but should become
> more obvious now we have this tighter integration with mm's vmas.

There is no need of littering the VM with new callbacks, KSM only has
to register in the mmu notifier to teardown rmap_items (and tree_item
when the last rmap_item of the tree_item list is gone) synchronously
when the mappings are invalidated during munmap/mremap or swapping
(anon pages can already be swapped while it's tracked by the unstable
tree, and later we hope stable tree ksm pages can be swapped too, and
we get rid of those from the rbtree as we walk it with
is_present_pte and gup).

After that we can also have tree_item store the kernel-vaddr (or
struct page *) to avoid calling gup() during the walk of the rbtree.
However such a change involves huge complexities and little gain, and
the part of getting rid of orphaned rmap_item/tree_item synchronously
doesn't provide practical advantages. It takes a single pass to get
rid of all orphaned rmap_items/tree_items, and shutting down ksm gets
rid of everything releasing any memory allocated by KSM (or at least
it should, especially if we don't allow it to be a module anymore
because it might not be worth it, the =N option is still useful for
the embedded that are sure they won't get great benefit from KSM in
their apps).

Izik has been brave enough to try having rmap_item/tree_item in sync
with mmu notifier already, but one of the complexities were in the
locking, we can't schedule anywhere in the mmu notifier methods (this
could be relaxed but it makes no sense to depend on this just to get
rid of orphaned rmap_item/tree_item synchronously). Other complexities
were in the fact replace_page when it does set_pte_at_notify will
recurse in KSM itself if KSM registers in MMU notifier.

Admittedly I didn't spend much time thinking about how everything is
supposed to work with mmu notifer and in-sync rmap_item/tree_item with
tree_item pointing to a physical page address without any struct page
pinning whatsoever (the very cool thing that is all about mmu
notifier, no pinning and full swapping) yet, but because I doubt it
will provide any significant advantage and I think being simpler has
some value too at least until there are more users of the
feature. Hence the current implementation still has an out of sync
scan and garbage collect rmap_item/tree_item lazily. This is not KVM
that without mmu notifier can't swap at all. We can do all our work
here in KSM out of sync by just garbage collecting the orphaned
entries out of sync, KSM works with virtual addresses it only does
temporary gup pins so it's not forced to use mmu notifier to give good
behavior.

So my suggestion is to go with out of sync, and then once this is all
solid and finished, we can try to use mmu notifier to make it in sync
and benchmark to see if it is worth it. With the primary benefit of
being able to remove gup from the tree lookup (collecting orphaned
rmap_item/tree_item a bit sooner doesn't matter so much IMHO, at least
for KVM).

> And a question on your page_wrprotect() addition to mm/rmap.c: though
> it may contain some important checks (I'm thinking of the get_user_pages
> protection), isn't it essentially redundant, and should be removed from
> the patchset?  If we have a private page which is mapped into more than
> the one address space by which we arrive at it, then, quite independent
> of KSM, it needs to be write-protected already to prevent mods in one
> address space leaking into another - doesn't it?  So I see no need for
> the rmap'ped write-protection there, just make the checks and write
> protect the pte you have in ksm.c.  Or am I missing something?

Makes sense, basically if pte is already wrprotected we've to do
nothing, and if it's writable we only need to care about the current
pte because mapcount is guaranteed 1. That probably can provide a
minor optimization to the ksm performance. OTOH if we'll ever decide
to merge more than anon pages this won't hold. Let's say anon pages
are by orders of magnitude simpler to merge than anything else because
they don't belong to all other data structures like pagecache, I guess
we'll never merge pagecache given the significant additional
complexities involved, so I'm not against keeping replace_page local
and without walking the anon_vma list at all.

So let us know what you think about the rmap_item/tree_item out of
sync, or in sync with mmu notifier. As said Izik already did a
preliminary patch with mmu notifier registration. I doubt we want to
invest in that direction unless there's 100% agreement that it is
definitely the way to go, and the expectation that it will make a
substantial difference to the KSM users. Minor optimizations that
increase complexity a lot, can be left for later.

Thanks for looking into KSM!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
