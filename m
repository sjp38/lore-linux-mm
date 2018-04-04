Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39F1E6B000D
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:05 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a125so15479883qkd.4
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u190si6377300qka.45.2018.04.04.12.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:02 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 00/79] Generic page write protection and a solution to page waitqueue
Date: Wed,  4 Apr 2018 15:17:50 -0400
Message-Id: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tim Chen <tim.c.chen@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

https://cgit.freedesktop.org/~glisse/linux/log/?h=generic-write-protection-rfc

This is an RFC for LSF/MM discussions. It impacts the file subsystem,
the block subsystem and the mm subsystem. Hence it would benefit from
a cross sub-system discussion.

Patchset is not fully bake so take it with a graint of salt. I use it
to illustrate the fact that it is doable and now that i did it once i
believe i have a better and cleaner plan in my head on how to do this.
I intend to share and discuss it at LSF/MM (i still need to write it
down). That plan lead to quite different individual steps than this
patchset takes and his also easier to split up in more manageable
pieces.

I also want to apologize for the size and number of patches (and i am
not even sending them all).

----------------------------------------------------------------------
The Why ?

I have two objectives: duplicate memory read only accross nodes and or
devices and work around PCIE atomic limitations. More on each of those
objective below. I also want to put forward that it can solve the page
wait list issue ie having each page with its own wait list and thus
avoiding long wait list traversale latency recently reported [1].

It does allow KSM for file back pages (truely generic KSM even between
both anonymous and file back page). I am not sure how useful this can
be, this was not an objective i did pursue, this is just a for free
feature (see below).

[1] https://groups.google.com/forum/#!topic/linux.kernel/Iit1P5BNyX8

----------------------------------------------------------------------
Per page wait list, so long page_waitqueue() !

Not implemented in this RFC but below is the logic and pseudo code
at bottom of this email.

When there is a contention on struct page lock bit, the caller which
is trying to lock the page will add itself to a waitqueue. The issues
here is that multiple pages share the same wait queue and on large
system with a lot of ram this means we can quickly get to a long list
of waiters for differents pages (or for the same page) on the same
list [1].

The present patchset virtualy kills all places that need to access the
page->mapping field and only a handfull are left, namely for testing
page truncation and for vmscan. The former can be remove if we reuse
the PG_waiters flag for a new PG_truncate flag set on truncation then
we can virtualy kill all derefence of page->mapping (this patchset
proves it is doable). NOTE THIS DOES NOT MEAN THAT MAPPING is FREE TO
BE USE BY ANYONE TO STORE WHATEVER IN STRUCT PAGE. SORRY NO !

What this means whenever a thread want to spin on page until it can
lock it then it can carefully replace the page->mapping with a waiter
struct for a wait list. Thus each page under contention will have its
own wait list.

The fact that there is not many place that dereference page.mapping
is important because this means now that any dereference must be done
with preemption disabled (inside rcu read section) so that the waiter
can free the waiter struct without fear for hazard (the struct is on
the stack like today). Pseudo code at the end of this mail.

Devil is in the details but after long meditation and pondering on
this i believe this is a do-able solution. Note it does not rely on
the write protection, nor does it technically need to kill all struct
page mapping derefence. But the latter can really hurt performance if
they have to be done under rcu read lock and the corresponding grace
period needed before freeing waiter struct.

----------------------------------------------------------------------
KSM for everyone !

With generic write protection you can do KSM for file back page too
(even if they have different offset, mapping or buffer_head). While i
believe page sharing for containers is already solve with overlayfs,
this might still be an interesting feature for some.

Oh and crazy to crazy you can merge private anonymous page and file
back page together ... Probably totaly useless but cool like crazy.

----------------------------------------------------------------------
KDM (Kernel Duplicate Memory)

Most kernel development, especialy in mm sub-system, is about how to
save resources, how to share as much of them as possible so that we
maximize their availabilities for all the processes.

Objective here is slightly different. Some user favor performances and
already have properly sized system (ie they have enough resources for
the task at hand). For performance it is sometimes better to use more
resources to improve other parameters of the performance equation.

This is especialy true for big system that either use several devices
or spread accross several nodes or both. For those, sharing memory
means peer to peer traffic. This can become a bottleneck and saturate
the interconnect between those peers.

If some data set under consideration is access read only then we can
duplicate memory backing it on multiple nodes/devices. Access is then
local to each nodes/devices which greatly improves both latency and
bandwidth while also saving inter-connect bandwidth for other uses.

Note that KDM accross NUMA nodes means that we need to duplicate the
CPU page table and have special copy for each node. So in honesty,
here i am focusing on device, i am not sure the amount of work to do
that for CPU page table is sane ...

----------------------------------------------------------------------
PCIE atomic limitation

PCIE atomic only have tree atomic operations Fetch and Add (32, 64
bits), Swap (32, 64 bits), Compare And Swap aka CAS (32, 64 and 128
bits). The address must align on type (32, 64 or 128 bits alignment),
it can not cross 4KBytes boundary ie it must be inside a single page.
Note that the alignment constraint gives the boundary crossing for
free (but those are two distinct constraint in the specification).

PCIE atomic operation have a lower throughput than regular PCIE memory
write operation. Regular PCIE memory transaction has a maximum payload
which depends on the CPU/chipset and is often a multiple of cacheline
size. So one regular PCIE memory write can write multiple bytes while
a PCIE atomic operation can write only 4, 8 or 16 bytes (32, 64 or 128
bits). Note that each PCIE transaction involve an acknowledge answer
packet from receiver to transceiver.

If we write protect a page on the CPU then the device can cache and
write combine as much bytes as possible and improve its throughut for
atomic and regular write. The write protection on the CPU allow us to
ascertain that any write by the device behave as if it was atomic from
CPU point of view. So generic write protection allow to improve the
overal performances for atomic operation to system memory while it is
only updated by a device.


There is another PCIE limitation which generic write protection would
help to work around. If device offers more atomic operations than the
above (FetchAdd, Swap, CAS) to program it runs (like GPU for instance
that have same list of atomic operations as CPU roughly), then it has
to emulate those using a CAS loop:

  AtomicOpEmulate64(void *dst, u64 src, u64 (*op)(u64 val, u64 src))
  {
    u64 val, tmp;
    do {
        val = PCIE_Read64(dst);
        tmp = op(val, src);
    } while (!PCIE_AtomicCompareAndSwap(dst, val, tmp));
  }

The hardware have to implement this as part of its mmu or of its PCIE
bridge. Not only this can require quite a bit of die space (ie having
to implement each of the atomic operation the hardware support) but it
is also prone to starvation by the host CPU. If the host CPU is also
modifying the same address in a tight loop than the device which has
a higher latency (as it is on the PCIE bus) it unlikely to win the CAS
race. CPU interrupts and others CPU latency likely means this can not
turn into an infinite loop for the hardware. It can however quickly
monopolize the PCIE bandwidth for the device and severly impact its
performances (device might have to stop multiple of its threads each
waiting on atomic operation completion).

With generic write protection device can force serialization with CPU.
This does however slow down the overall process as the generic write
protection might require expensive CPU TLB flush and be prone to lock
contention. But sometime forward progress is more important than
maximizing throughput for one or another component in the system (here
the CPU or the device).

----------------------------------------------------------------------
The What ?

Aim of this patch serie is to introduce generic page write protection
for any kind of regular page in a process (private anonymous or back
by regular file). This feature already exist, in one form, for private
anonymous page, as part of KSM (Kernel Share Memory).

So this patch serie is two fold. First it factors out the page write
protection of KSM into a generic write protection mechanim which KSM
becomes the first user of. Then it add support for regular file back
page memory (regular file or share memory aka shmem). To achieve this
i need to cut the dependency lot of code have on page->mapping so i
can set page->mapping to point to special structure when write
protected.

----------------------------------------------------------------------
The How ?

The corner stone assumption in this patch serie is that page->mapping
is always the same as vma->vm_file->f_mapping (modulo when a page is
truncated). The one exception is in respect to swaping with nfs file.

Am i fundamentaly wrong in my assumption ?

I believe this is a do-able plan because virtually all place do know
the address_space a page belongs to, or someone in the callchain do.
Hence this patchset is all about passing down that information. The
only exception i am aware of is page reclamation (vmscan) but this can
be handled as a special case as there we not interested in the page
mapping per say but in reclaiming memory.

Once you have both struct page and mapping (without relying on the
struct page to get the latter) you can use mapping that as a unique
key to lookup page->private/page->index value. So all dereference of
those fields become:
    page_offset(page) -> page_offset(page, mapping)
    page_buffers(page) -> page_buffers(page, mapping)

Note than this only need special handling for write protected page ie
it is the same as before if page is not write protected so it just add
a test each time code call either helper.

Sinful function (all existing usage are remove in this patchset):
    page_mapping(page)

You can also use the page buffer head as a unique key. So following
helpers are added (thought i do not use them):
    page_mapping_with_buffers(page, (struct buffer_head *)bh)
    page_offset_with_buffers(page, (struct buffer_head *)bh)

A write protected page has page->mapping pointing to a structure like
struct rmap_item for KSM. So this structure has a list for each unique
combination:
    struct write_protect {
        struct list_head *mappings; /* write_protect_mapping list */
        ...
    };

    struct write_protect_mapping {
        struct list_head list
        struct address_space *mapping;
        unsigned long offset;
        unsigned long private;
        ...
    };

----------------------------------------------------------------------
Methodoly:

I have try to avoid any functional change within patches that add new
argument to function, simply by never using the new argument. So only
function signature changes. Doing so means that each individual file-
system maintainer should not need to pay too much attention to the big
patches that touch everything, they can focus on the individual patches
to their particular filesystem.

WHAT MUST BE CAREFULLY REVIEWED IS CALL SITE OF ADDRESS SPACE CALLBACK
TO ASCERTAIN THAT I AM USING THE RIGHT MAPPING WHICH THE PAGE BELONGS
TO (in some code path like pipe, splice, compression, encryption or
symlink this is not always obvious).

Conversion of common helpers have been done in the same way, i add the
argument but for all call site i use page->mapping so that each patch
do not change behavior for all filesystem. Removing page->mapping is
left to individual filesystem patch.

As this is an RFC i am not posting individual filesystem changes (some
are in the git repository).

----------------------------------------------------------------------
Patch grouping

Patch 1 to 3 are change to individual fs to simplify the rest of the
patchset and especialy help when i re-order thing. They literaly can
not regress (i would amaze if they do). They are just shuffling thing
around a bit in each fs. Getting those early in would probably help.

Patch 4 deal with pipe, just need to keep the inode|mapping when data
are pipe (to|from|to and from a file).

Patch 5 to 8 add helpers used latter

Patch 9 to 19 each patch add struct address_space to one of the call-
back (address_space_operation). As per methodology this does not make
use of the new argument and modify call site conservatively.

Patch 20 to 27 each patch add struct address_space or struct inode to
various fs and block sub-system helpers/generics implementation. As
per methodology this does not make use of the new argument and modify
call site conservatively.

Patch 29 to 32 add either address_space, inode or buffer_head to block
sub-system helpers.

Patch 35 to 49 deal with buffer_head infrastructure (again adding new
argument so that each function either know the mapping or buffer_head
pointer without relying on struct page).

Patch 53 to 62 each patch update a single filesystem in one chunk to
remove all usage of page->mapping, page->private, page->offset and
use helpers or contextual informations to get those value. REGRESSIONS
IF ANY ARE THERE !

Patch 65 to 68 deal with the swap code path (page_swap_info()).

Patch 76 to 79 factor out KSM write protection into a generic write
protection mechanism turning KSM into its first user. This is mostly
shuffling code around, renaming struct and constant and updating any
existing mm code to use write protection callback instead of calling
into KSM. I have try to be careful but if it regress then it should
only regress for KSM users.

----------------------------------------------------------------------

Thank you for reaching that point, feel free to throw electrons at me.


ANNEX (seriously there is more)
----------------------------------------------------------------------
Page wait list code

So here is a braim dump with all the expected syntax error and reverse
logic and toddler mistakes. However i believe it is correct overall.

    void __lock_page(struct page *page)
    {
        struct page_waiter waiter;
        struct address_space *special_wait;
        struct address_space *mapping;
        bool again = false;

        special_wait = make_mapping_special_wait(&waiter);
        /* Store a waitqueue in task_struct ? */
        page_waiter_init(&waiter, current);
        spin_lock(&waiter.lock);

        do {
            if (trylock_page(page)) {
                spin_unlock(&waiter.lock);
                /* Our struct was never expose to outside world */
                return;
            }

            mapping = READ_ONCE(page->mapping);
            if (mapping_special_wait(mapping)) {
                struct page_waiter *tmp = mapping_to_waiter(mapping);
                if (spin_trylock(&tmp->lock)) {
                    /* MAYBE kref and spin_lock() ? */
                    again = true;
                } else {
                    list_add_tail(&waiter.list, &tmp->list);
                    waiter.mapping = tmp.mapping;
                    spin_unlock(&tmp->lock);
                }
            } else {
                void *old;
                waiter.mapping = mapping;
                old = atomic64_cmpxchg(&page->mapping, mapping,
                                       special_wait);
                again = old != special_wait;
            }
        } while (again);

        /*
         * So nightmare here is a racing unlock_page() that did not
         * see our updated mapping and another thread locking the page
         * just freshly unlocked from under us. This mean some one got
         * in front of the line before us ! That's rude, however the
         * next unlock_page() will not miss us ! So here the trylock
         * is just to avoid waiting for nothing. Rude lucky locker
         * will be ahead of us ...
         */
        if (trylock_page(page)) {
            struct page_waiter *tmp;

            mapping = READ_ONCE(page->mapping);
            if (mapping == special_mapping) {
                /*
                 * Ok we are first inline and nobody can add itself
                 * to our list.
                 */
                BUG_ON(!list_is_empty(&waiter.list));
                page->mapping = waiter.mapping;
                spin_unlock(&waiter.lock);
                goto exit;
            }
            /*
             * We got in front of line and someone else was already
             * waiting, be nice.
             */
            tmp = mapping_to_waiter(mapping);
            tmp.you_own_it_dummy = 1;
            spin_unlock(&waiter.lock);
            wake_up(tmp->queue);
        } else
            spin_unlock(&waiter.lock);

        /* Wait queue in task_struct */
        wait_event(waiter.queue, !waiter.you_own_it_dummy);

        /* Lock to serialize page->mapping update */
        spin_lock(&waiter.lock);
        if (list_empty(&waiter.list)) {
            page->mapping = waiter.mapping;
        } else {
            struct page_waiter *tmp;
            tmp = list_first_entry(waiter.list...);
            page->mapping = make_mapping_special_wait(tmp);
        }
        spin_unlock(&waiter.lock);

    exit:
        /*
         * Do need rcu quiesce ? because of a racing spin_trylock ?
         * Call to page_mapping() see below for that function.
         * Waiting for rcu grace period would be bad i think maybe
         * we can keep the waiter struct at top of stack (dunno if
         * that trick exist in kernel already, ie preallocating top
         * of stack for common struct like waiter) ?
         */
    }

    void unlock_page(struct page *page)
    {
        struct address_space *mapping;

        mapping = READ_ONCE(page->mapping);
        if (mapping_special_wait(mapping)) {
                struct page_waiter *tmp = mapping_to_waiter(mapping);
                tmp->you_own_it_dummy = 1;
                wake_up(tmp->queue);
        } else {
            /* The race is handled in in the slow path __lock_page */
            clear_bit_unlock(PG_locked, &page->flags);
        }
    }

    struct address_space *page_mapping(struct page *page)
    {
        struct address_space *mapping;

        rcu_read_lock();
        mapping = READ_ONCE(page->mapping);
        if (mapping_special_wait(mapping)) {
                struct page_waiter *tmp = mapping_to_waiter(mapping);
                mapping = tmp->mapping;
        }
        rcu_read_unlock();
        return mapping;
    }
----------------------------------------------------------------------
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org

JA(C)rA'me Glisse (79):
  fs/fscache: remove fscache_alloc_page()
  fs/ufs: add struct super_block to ubh_bforget() arguments.
  fs/ext4: prepare move_extent_per_page() for the holy crusade
  pipe: add inode field to struct pipe_inode_info
  mm/swap: add an helper to get address_space from swap_entry_t
  mm/page: add helpers to dereference struct page index field
  mm/page: add helpers to find mapping give a page and buffer head
  mm/page: add helpers to find page mapping and private given a bio
  fs: add struct address_space to read_cache_page() callback argument
  fs: add struct address_space to is_dirty_writeback() callback argument
  fs: add struct address_space to is_partially_uptodate() callback
    argument
  fs: add struct address_space to launder_page() callback argument
  fs: add struct address_space to putback_page() callback argument
  fs: add struct address_space to isolate_page() callback argument
  fs: add struct address_space to releasepage() callback argument
  fs: add struct address_space to invalidatepage() callback argument
  fs: add struct address_space to set_page_dirty() callback argument
  fs: add struct address_space to readpage() callback argument
  fs: add struct address_space to writepage() callback argument
  fs: add struct address_space to write_cache_pages() callback argument
  fs: add struct inode to block_write_full_page() arguments
  fs: add struct inode to block_read_full_page() arguments
  fs: add struct inode to map_buffer_to_page() arguments
  fs: add struct inode to nobh_writepage() arguments
  fs: add struct address_space to mpage_writepage() arguments
  fs: add struct address_space to mpage_readpage() arguments
  fs: add struct address_space to fscache_read*() callback arguments
  fs: introduce page_is_truncated() helper
  fs/block: add struct address_space to bdev_write_page() arguments
  fs/block: add struct address_space to __block_write_begin() arguments
  fs/block: add struct address_space to __block_write_begin_int() args
  fs/block: do not rely on page->mapping get it from the context
  fs/journal: add struct super_block to jbd2_journal_forget() arguments.
  fs/journal: add struct inode to jbd2_journal_revoke() arguments.
  fs/buffer: add struct address_space and struct page to end_io callback
  fs/buffer: add struct super_block to bforget() arguments
  fs/buffer: add struct super_block to __bforget() arguments
  fs/buffer: add first buffer flag for first buffer_head in a page
  fs/buffer: add struct address_space to clean_page_buffers() arguments
  fs/buffer: add helper to dereference page's buffers with given mapping
  fs/buffer: add struct address_space to init_page_buffers() args
  fs/buffer: add struct address_space to drop_buffers() args
  fs/buffer: add struct address_space to page_zero_new_buffers() args
  fs/buffer: add struct address_space to create_empty_buffers() args
  fs/buffer: add struct address_space to page_seek_hole_data() args
  fs/buffer: add struct address_space to try_to_free_buffers() args
  fs/buffer: add struct address_space to attach_nobh_buffers() args
  fs/buffer: add struct address_space to mark_buffer_write_io_error()
    args
  fs/buffer: add struct address_space to block_commit_write() arguments
  fs: stop relying on mapping field of struct page, get it from context
  fs: stop relying on mapping field of struct page, get it from context
  fs/buffer: use _page_has_buffers() instead of page_has_buffers()
  fs/lustre: do not rely on page->mapping get it from the context
  fs/nfs: do not rely on page->mapping get it from the context
  fs/ext2: do not rely on page->mapping get it from the context
  fs/ext2: convert page's index lookup to be against specific mapping
  fs/ext4: do not rely on page->mapping get it from the context
  fs/ext4: convert page's index lookup to be against specific mapping
  fs/ext4: convert page's buffers lookup to be against specific mapping
  fs/xfs: do not rely on page->mapping get it from the context
  fs/xfs: convert page's index lookup to be against specific mapping
  fs/xfs: convert page's buffers lookup to be against specific mapping
  mm/page: convert page's index lookup to be against specific mapping
  mm/buffer: use _page_has_buffers() instead of page_has_buffers()
  mm/swap: add struct swap_info_struct swap_readpage() arguments
  mm/swap: add struct address_space to __swap_writepage() arguments
  mm/swap: add struct swap_info_struct *sis to swap_slot_free_notify()
    args
  mm/vma_address: convert page's index lookup to be against specific
    mapping
  fs/journal: add struct address_space to
    jbd2_journal_try_to_free_buffers() arguments
  mm: add struct address_space to mark_buffer_dirty()
  mm: add struct address_space to set_page_dirty()
  mm: add struct address_space to set_page_dirty_lock()
  mm: pass down struct address_space to set_page_dirty()
  mm/page_ronly: add config option for generic read only page framework.
  mm/page_ronly: add page read only core structure and helpers.
  mm/ksm: have ksm select PAGE_RONLY config.
  mm/ksm: hide set_page_stable_node() and page_stable_node()
  mm/ksm: rename PAGE_MAPPING_KSM to PAGE_MAPPING_RONLY
  mm/ksm: set page->mapping to page_ronly struct instead of stable_node.

 Documentation/filesystems/caching/netfs-api.txt    |  19 --
 arch/cris/arch-v32/drivers/cryptocop.c             |   2 +-
 arch/powerpc/kvm/book3s_64_mmu_radix.c             |   2 +-
 arch/powerpc/kvm/e500_mmu.c                        |   3 +-
 arch/s390/kvm/interrupt.c                          |   4 +-
 arch/x86/kvm/svm.c                                 |   2 +-
 block/bio.c                                        |   4 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |   2 +-
 drivers/gpu/drm/drm_gem.c                          |   2 +-
 drivers/gpu/drm/exynos/exynos_drm_g2d.c            |   2 +-
 drivers/gpu/drm/i915/i915_gem.c                    |   6 +-
 drivers/gpu/drm/i915/i915_gem_fence_reg.c          |   2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c            |   2 +-
 drivers/gpu/drm/radeon/radeon_ttm.c                |   2 +-
 drivers/gpu/drm/ttm/ttm_tt.c                       |   2 +-
 drivers/infiniband/core/umem.c                     |   2 +-
 drivers/infiniband/core/umem_odp.c                 |   2 +-
 drivers/infiniband/hw/hfi1/user_pages.c            |   2 +-
 drivers/infiniband/hw/qib/qib_user_pages.c         |   2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c           |   2 +-
 drivers/md/md-bitmap.c                             |   3 +-
 .../media/common/videobuf2/videobuf2-dma-contig.c  |   2 +-
 drivers/media/common/videobuf2/videobuf2-dma-sg.c  |   2 +-
 drivers/media/common/videobuf2/videobuf2-vmalloc.c |   2 +-
 drivers/misc/genwqe/card_utils.c                   |   2 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c            |   2 +-
 drivers/mtd/devices/block2mtd.c                    |   4 +-
 drivers/platform/goldfish/goldfish_pipe.c          |   2 +-
 drivers/sbus/char/oradax.c                         |   2 +-
 .../lustre/include/lustre_patchless_compat.h       |   2 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   4 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  15 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  11 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   7 +-
 drivers/staging/lustre/lustre/llite/rw.c           |   8 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  20 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   8 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   8 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  15 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  16 +-
 drivers/staging/ncpfs/symlink.c                    |   4 +-
 .../interface/vchiq_arm/vchiq_2835_arm.c           |   2 +-
 drivers/vhost/vhost.c                              |   2 +-
 drivers/video/fbdev/core/fb_defio.c                |   3 +-
 fs/9p/cache.c                                      |   7 +-
 fs/9p/cache.h                                      |  11 +-
 fs/9p/vfs_addr.c                                   |  36 ++-
 fs/9p/vfs_file.c                                   |   2 +-
 fs/adfs/dir_f.c                                    |   2 +-
 fs/adfs/inode.c                                    |  11 +-
 fs/affs/bitmap.c                                   |   6 +-
 fs/affs/file.c                                     |  14 +-
 fs/affs/super.c                                    |   2 +-
 fs/affs/symlink.c                                  |   3 +-
 fs/afs/file.c                                      |  31 ++-
 fs/afs/internal.h                                  |   9 +-
 fs/afs/write.c                                     |  11 +-
 fs/aio.c                                           |   8 +-
 fs/befs/linuxvfs.c                                 |  16 +-
 fs/bfs/file.c                                      |  15 +-
 fs/bfs/inode.c                                     |   4 +-
 fs/block_dev.c                                     |  26 +-
 fs/btrfs/ctree.h                                   |   3 +-
 fs/btrfs/disk-io.c                                 |  20 +-
 fs/btrfs/extent_io.c                               |   9 +-
 fs/btrfs/file.c                                    |   6 +-
 fs/btrfs/free-space-cache.c                        |   2 +-
 fs/btrfs/inode.c                                   |  35 +--
 fs/btrfs/ioctl.c                                   |  12 +-
 fs/btrfs/relocation.c                              |   4 +-
 fs/btrfs/scrub.c                                   |   2 +-
 fs/btrfs/send.c                                    |   2 +-
 fs/buffer.c                                        | 267 ++++++++++++---------
 fs/cachefiles/rdwr.c                               |   6 +-
 fs/ceph/addr.c                                     |  28 ++-
 fs/ceph/cache.c                                    |  10 +-
 fs/cifs/file.c                                     |  27 ++-
 fs/cifs/fscache.c                                  |   6 +-
 fs/coda/symlink.c                                  |   3 +-
 fs/cramfs/inode.c                                  |   3 +-
 fs/direct-io.c                                     |   2 +-
 fs/ecryptfs/mmap.c                                 |   7 +-
 fs/efs/inode.c                                     |   5 +-
 fs/efs/symlink.c                                   |   4 +-
 fs/exofs/dir.c                                     |   2 +-
 fs/exofs/inode.c                                   |  30 ++-
 fs/ext2/balloc.c                                   |   6 +-
 fs/ext2/dir.c                                      |  52 ++--
 fs/ext2/ext2.h                                     |   4 +-
 fs/ext2/ialloc.c                                   |   8 +-
 fs/ext2/inode.c                                    |  21 +-
 fs/ext2/namei.c                                    |   4 +-
 fs/ext2/super.c                                    |   4 +-
 fs/ext2/xattr.c                                    |  12 +-
 fs/ext4/ext4.h                                     |   4 +-
 fs/ext4/ext4_jbd2.c                                |  10 +-
 fs/ext4/ialloc.c                                   |   3 +-
 fs/ext4/inline.c                                   |  16 +-
 fs/ext4/inode.c                                    | 234 ++++++++++--------
 fs/ext4/mballoc.c                                  |  40 +--
 fs/ext4/mballoc.h                                  |   1 +
 fs/ext4/mmp.c                                      |   2 +-
 fs/ext4/move_extent.c                              |  35 +--
 fs/ext4/page-io.c                                  |  22 +-
 fs/ext4/readpage.c                                 |  11 +-
 fs/ext4/resize.c                                   |   2 +-
 fs/ext4/super.c                                    |  14 +-
 fs/f2fs/checkpoint.c                               |  16 +-
 fs/f2fs/data.c                                     |  38 +--
 fs/f2fs/dir.c                                      |  10 +-
 fs/f2fs/f2fs.h                                     |  10 +-
 fs/f2fs/file.c                                     |  12 +-
 fs/f2fs/gc.c                                       |   6 +-
 fs/f2fs/inline.c                                   |  18 +-
 fs/f2fs/inode.c                                    |   6 +-
 fs/f2fs/node.c                                     |  28 ++-
 fs/f2fs/node.h                                     |   2 +-
 fs/f2fs/recovery.c                                 |   2 +-
 fs/f2fs/segment.c                                  |  12 +-
 fs/f2fs/super.c                                    |   2 +-
 fs/f2fs/xattr.c                                    |   6 +-
 fs/fat/dir.c                                       |   4 +-
 fs/fat/inode.c                                     |  15 +-
 fs/fat/misc.c                                      |   2 +-
 fs/freevxfs/vxfs_immed.c                           |   7 +-
 fs/freevxfs/vxfs_subr.c                            |  10 +-
 fs/fscache/page.c                                  |  94 +-------
 fs/fuse/dev.c                                      |   2 +-
 fs/fuse/file.c                                     |  20 +-
 fs/gfs2/aops.c                                     |  47 ++--
 fs/gfs2/bmap.c                                     |  10 +-
 fs/gfs2/file.c                                     |   6 +-
 fs/gfs2/inode.h                                    |   3 +-
 fs/gfs2/lops.c                                     |   8 +-
 fs/gfs2/meta_io.c                                  |   7 +-
 fs/gfs2/quota.c                                    |   2 +-
 fs/hfs/bnode.c                                     |  12 +-
 fs/hfs/btree.c                                     |   6 +-
 fs/hfs/inode.c                                     |  16 +-
 fs/hfs/mdb.c                                       |  10 +-
 fs/hfsplus/bitmap.c                                |   8 +-
 fs/hfsplus/bnode.c                                 |  30 +--
 fs/hfsplus/btree.c                                 |   6 +-
 fs/hfsplus/inode.c                                 |  17 +-
 fs/hfsplus/xattr.c                                 |   2 +-
 fs/hostfs/hostfs_kern.c                            |   8 +-
 fs/hpfs/anode.c                                    |  34 +--
 fs/hpfs/buffer.c                                   |   8 +-
 fs/hpfs/dnode.c                                    |   4 +-
 fs/hpfs/ea.c                                       |   4 +-
 fs/hpfs/file.c                                     |  11 +-
 fs/hpfs/inode.c                                    |   2 +-
 fs/hpfs/namei.c                                    |  14 +-
 fs/hpfs/super.c                                    |   6 +-
 fs/hugetlbfs/inode.c                               |   3 +-
 fs/iomap.c                                         |   6 +-
 fs/isofs/compress.c                                |   3 +-
 fs/isofs/inode.c                                   |   5 +-
 fs/isofs/rock.c                                    |   4 +-
 fs/jbd2/commit.c                                   |   5 +-
 fs/jbd2/recovery.c                                 |   2 +-
 fs/jbd2/revoke.c                                   |   4 +-
 fs/jbd2/transaction.c                              |  14 +-
 fs/jffs2/file.c                                    |  12 +-
 fs/jffs2/fs.c                                      |   2 +-
 fs/jffs2/os-linux.h                                |   3 +-
 fs/jfs/inode.c                                     |  11 +-
 fs/jfs/jfs_imap.c                                  |   2 +-
 fs/jfs/jfs_metapage.c                              |  23 +-
 fs/jfs/jfs_mount.c                                 |   2 +-
 fs/jfs/resize.c                                    |   8 +-
 fs/jfs/super.c                                     |   2 +-
 fs/libfs.c                                         |  10 +-
 fs/minix/bitmap.c                                  |  10 +-
 fs/minix/inode.c                                   |  26 +-
 fs/minix/itree_common.c                            |   6 +-
 fs/mpage.c                                         |  70 +++---
 fs/nfs/dir.c                                       |   5 +-
 fs/nfs/direct.c                                    |  12 +-
 fs/nfs/file.c                                      |  25 +-
 fs/nfs/fscache.c                                   |  18 +-
 fs/nfs/fscache.h                                   |   3 +-
 fs/nfs/pagelist.c                                  |  12 +-
 fs/nfs/read.c                                      |  12 +-
 fs/nfs/symlink.c                                   |   6 +-
 fs/nfs/write.c                                     | 122 +++++-----
 fs/nilfs2/alloc.c                                  |  12 +-
 fs/nilfs2/btnode.c                                 |   4 +-
 fs/nilfs2/btree.c                                  |  38 +--
 fs/nilfs2/cpfile.c                                 |  24 +-
 fs/nilfs2/dat.c                                    |   4 +-
 fs/nilfs2/dir.c                                    |   3 +-
 fs/nilfs2/file.c                                   |   2 +-
 fs/nilfs2/gcinode.c                                |   2 +-
 fs/nilfs2/ifile.c                                  |   4 +-
 fs/nilfs2/inode.c                                  |  13 +-
 fs/nilfs2/ioctl.c                                  |   2 +-
 fs/nilfs2/mdt.c                                    |   7 +-
 fs/nilfs2/page.c                                   |   5 +-
 fs/nilfs2/segment.c                                |   7 +-
 fs/nilfs2/sufile.c                                 |  26 +-
 fs/ntfs/aops.c                                     |  25 +-
 fs/ntfs/attrib.c                                   |   8 +-
 fs/ntfs/bitmap.c                                   |   4 +-
 fs/ntfs/file.c                                     |  13 +-
 fs/ntfs/lcnalloc.c                                 |   4 +-
 fs/ntfs/mft.c                                      |   4 +-
 fs/ntfs/super.c                                    |   2 +-
 fs/ntfs/usnjrnl.c                                  |   2 +-
 fs/ocfs2/alloc.c                                   |   2 +-
 fs/ocfs2/aops.c                                    |  30 ++-
 fs/ocfs2/file.c                                    |   4 +-
 fs/ocfs2/inode.c                                   |   2 +-
 fs/ocfs2/mmap.c                                    |   2 +-
 fs/ocfs2/refcounttree.c                            |   3 +-
 fs/ocfs2/symlink.c                                 |   4 +-
 fs/omfs/bitmap.c                                   |   6 +-
 fs/omfs/dir.c                                      |   8 +-
 fs/omfs/file.c                                     |  15 +-
 fs/omfs/inode.c                                    |   4 +-
 fs/orangefs/inode.c                                |   9 +-
 fs/pipe.c                                          |   2 +
 fs/proc/page.c                                     |   2 +-
 fs/qnx4/inode.c                                    |   5 +-
 fs/qnx6/inode.c                                    |   5 +-
 fs/ramfs/inode.c                                   |   8 +-
 fs/reiserfs/file.c                                 |   2 +-
 fs/reiserfs/inode.c                                |  42 ++--
 fs/reiserfs/journal.c                              |  20 +-
 fs/reiserfs/resize.c                               |   4 +-
 fs/romfs/super.c                                   |   3 +-
 fs/splice.c                                        |   3 +-
 fs/squashfs/file.c                                 |   3 +-
 fs/squashfs/symlink.c                              |   4 +-
 fs/sysv/balloc.c                                   |   2 +-
 fs/sysv/ialloc.c                                   |   2 +-
 fs/sysv/inode.c                                    |   8 +-
 fs/sysv/itree.c                                    |  18 +-
 fs/sysv/sysv.h                                     |   4 +-
 fs/ubifs/file.c                                    |  20 +-
 fs/udf/balloc.c                                    |   6 +-
 fs/udf/file.c                                      |   9 +-
 fs/udf/inode.c                                     |  15 +-
 fs/udf/partition.c                                 |   4 +-
 fs/udf/super.c                                     |   8 +-
 fs/udf/symlink.c                                   |   3 +-
 fs/ufs/balloc.c                                    |   4 +-
 fs/ufs/ialloc.c                                    |   4 +-
 fs/ufs/inode.c                                     |  27 ++-
 fs/ufs/util.c                                      |   8 +-
 fs/ufs/util.h                                      |   2 +-
 fs/xfs/xfs_aops.c                                  |  84 ++++---
 fs/xfs/xfs_aops.h                                  |   2 +-
 fs/xfs/xfs_trace.h                                 |   5 +-
 include/linux/balloon_compaction.h                 |  13 -
 include/linux/blkdev.h                             |   5 +-
 include/linux/buffer_head.h                        |  96 +++++---
 include/linux/fs.h                                 |  29 ++-
 include/linux/fscache-cache.h                      |   2 +-
 include/linux/fscache.h                            |  39 +--
 include/linux/jbd2.h                               |  10 +-
 include/linux/ksm.h                                |  12 -
 include/linux/mm-page.h                            | 157 ++++++++++++
 include/linux/mm.h                                 |  11 +-
 include/linux/mpage.h                              |   7 +-
 include/linux/nfs_fs.h                             |   5 +-
 include/linux/nfs_page.h                           |   2 +
 include/linux/page-flags.h                         |  30 ++-
 include/linux/page_ronly.h                         | 169 +++++++++++++
 include/linux/pagemap.h                            |  18 +-
 include/linux/pipe_fs_i.h                          |   2 +
 include/linux/swap.h                               |  20 +-
 include/linux/writeback.h                          |   4 +-
 mm/Kconfig                                         |   4 +
 mm/balloon_compaction.c                            |   7 +-
 mm/filemap.c                                       |  58 ++---
 mm/gup.c                                           |   2 +-
 mm/huge_memory.c                                   |   2 +-
 mm/hugetlb.c                                       |   2 +-
 mm/internal.h                                      |   4 +-
 mm/khugepaged.c                                    |   2 +-
 mm/ksm.c                                           |  26 +-
 mm/memory-failure.c                                |   2 +-
 mm/memory.c                                        |  15 +-
 mm/migrate.c                                       |  18 +-
 mm/mprotect.c                                      |   2 +-
 mm/page-writeback.c                                |  54 +++--
 mm/page_idle.c                                     |   2 +-
 mm/page_io.c                                       |  57 +++--
 mm/process_vm_access.c                             |   2 +-
 mm/readahead.c                                     |   6 +-
 mm/rmap.c                                          |  12 +-
 mm/shmem.c                                         |  46 ++--
 mm/swap_state.c                                    |  14 +-
 mm/swapfile.c                                      |  13 +-
 mm/truncate.c                                      |  32 +--
 mm/vmscan.c                                        |   7 +-
 mm/zsmalloc.c                                      |   8 +-
 mm/zswap.c                                         |   4 +-
 net/ceph/pagevec.c                                 |   2 +-
 net/rds/ib_rdma.c                                  |   2 +-
 net/rds/rdma.c                                     |   4 +-
 302 files changed, 2468 insertions(+), 1691 deletions(-)
 create mode 100644 include/linux/mm-page.h
 create mode 100644 include/linux/page_ronly.h

-- 
2.14.3
