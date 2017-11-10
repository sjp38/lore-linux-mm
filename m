Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 584FC440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 20:09:11 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id m191so90173itg.1
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 17:09:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 68sor3421212ioy.86.2017.11.09.17.09.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 17:09:10 -0800 (PST)
Date: Thu, 9 Nov 2017 18:09:07 -0700
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20171110010907.qfkqhrbtdkt5y3hy@smitten>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
 <20170920223452.vam3egenc533rcta@smitten>
 <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
 <20170921000901.v7zo4g5edhqqfabm@docker>
 <d1a35583-8225-2ab3-d9fa-273482615d09@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d1a35583-8225-2ab3-d9fa-273482615d09@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

Hi Dave,

On Wed, Sep 20, 2017 at 05:27:02PM -0700, Dave Hansen wrote:
> On 09/20/2017 05:09 PM, Tycho Andersen wrote:
> >> I think the only thing that will really help here is if you batch the
> >> allocations.  For instance, you could make sure that the per-cpu-pageset
> >> lists always contain either all kernel or all user data.  Then remap the
> >> entire list at once and do a single flush after the entire list is consumed.
> > Just so I understand, the idea would be that we only flush when the
> > type of allocation alternates, so:
> > 
> > kmalloc(..., GFP_KERNEL);
> > kmalloc(..., GFP_KERNEL);
> > /* remap+flush here */
> > kmalloc(..., GFP_HIGHUSER);
> > /* remap+flush here */
> > kmalloc(..., GFP_KERNEL);
> 
> Not really.  We keep a free list per migrate type, and a per_cpu_pages
> (pcp) list per migratetype:
> 
> > struct per_cpu_pages {
> >         int count;              /* number of pages in the list */
> >         int high;               /* high watermark, emptying needed */
> >         int batch;              /* chunk size for buddy add/remove */
> > 
> >         /* Lists of pages, one per migrate type stored on the pcp-lists */
> >         struct list_head lists[MIGRATE_PCPTYPES];
> > };
> 
> The migratetype is derived from the GFP flags in
> gfpflags_to_migratetype().  In general, GFP_HIGHUSER and GFP_KERNEL come
> from different migratetypes, so they come from different free lists.
> 
> In your case above, the GFP_HIGHUSER allocation come through the
> MIGRATE_MOVABLE pcp list while the GFP_KERNEL ones come from the
> MIGRATE_UNMOVABLE one.  Since we add a bunch of pages to those lists at
> once, you could do all the mapping/unmapping/flushing on a bunch of
> pages at once

So I've been playing around with an implementation of this, which is basically:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3d9c1b486e1f..47b46ff1148a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2348,6 +2348,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		if (is_migrate_cma(get_pcppage_migratetype(page)))
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
 					      -(1 << order));
+		xpfo_pcp_refill(page, migratetype, order);
 	}
 
 	/*
diff --git a/mm/xpfo.c b/mm/xpfo.c
index 080235a2f129..b381d83c6e78 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -260,3 +265,85 @@ void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
 			kunmap_atomic(mapping[i]);
 }
 EXPORT_SYMBOL(xpfo_temp_unmap);
+
+void xpfo_pcp_refill(struct page *page, enum migratetype migratetype, int order)
+{
+	int i;
+	bool flush_tlb = false;
+
+	if (!static_branch_unlikely(&xpfo_initialized))
+		return;
+
+	for (i = 0; i < 1 << order; i++) {
+		struct xpfo *xpfo;
+
+		xpfo = lookup_xpfo(page + i);
+		if (!xpfo)
+			continue;
+
+		if (unlikely(!xpfo->initialized)) {
+			spin_lock_init(&xpfo->maplock);
+			atomic_set(&xpfo->mapcount, 0);
+			xpfo->initialized = true;
+		}
+
+		xpfo->trace.max_entries = 20;
+		xpfo->trace.skip = 1;
+		xpfo->trace.entries = xpfo->entries;
+		xpfo->trace.nr_entries = 0;
+		xpfo->trace2.max_entries = 20;
+		xpfo->trace2.skip = 1;
+		xpfo->trace2.entries = xpfo->entries2;
+		xpfo->trace2.nr_entries = 0;
+
+		xpfo->migratetype = migratetype;
+
+		save_stack_trace(&xpfo->trace);
+
+		if (migratetype == MIGRATE_MOVABLE) {
+			/* GPF_HIGHUSER */
+			set_kpte(page_address(page + i), page + i, __pgprot(0));
+			if (!test_and_set_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags))
+				flush_tlb = true;
+			set_bit(XPFO_PAGE_USER, &xpfo->flags);
+		} else {
+			/*
+			 * GFP_KERNEL and everything else; for now we just
+			 * leave it mapped
+			 */
+			set_kpte(page_address(page + i), page + i, PAGE_KERNEL);
+			if (test_and_clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags))
+				flush_tlb = true;
+			clear_bit(XPFO_PAGE_USER, &xpfo->flags);
+		}
+	}
+
+	if (flush_tlb)
+		xpfo_flush_kernel_tlb(page, order);
+}
+

But I'm getting some faults:

[    1.897311] BUG: unable to handle kernel paging request at ffff880139b75012
[    1.898244] IP: ext4_fill_super+0x2f3b/0x33c0
[    1.898827] PGD 1ea6067 
[    1.898828] P4D 1ea6067 
[    1.899170] PUD 1ea9067 
[    1.899508] PMD 119478063 
[    1.899850] PTE 139b75000
[    1.900211] 
[    1.900760] Oops: 0000 [#1] SMP
[    1.901160] Modules linked in:
[    1.901565] CPU: 3 PID: 990 Comm: exe Not tainted 4.13.0+ #85
[    1.902348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[    1.903420] task: ffff88011ae7cb00 task.stack: ffffc9001a338000
[    1.904108] RIP: 0010:ext4_fill_super+0x2f3b/0x33c0
[    1.904649] RSP: 0018:ffffc9001a33bce0 EFLAGS: 00010246
[    1.905240] RAX: 00000000000000f0 RBX: ffff880139b75000 RCX: ffffffff81c456b8
[    1.906047] RDX: 0000000000000001 RSI: 0000000000000082 RDI: 0000000000000246
[    1.906874] RBP: ffffc9001a33bda8 R08: 0000000000000000 R09: 0000000000000183
[    1.908053] R10: ffff88011a9e0800 R11: ffffffff818493e0 R12: ffff88011a9e0800
[    1.908920] R13: ffff88011a9e6800 R14: 000000000077fefa R15: 0000000000000000
[    1.909775] FS:  00007f8169747700(0000) GS:ffff880139d80000(0000) knlGS:0000000000000000
[    1.910667] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.911293] CR2: ffff880139b75012 CR3: 000000011a965000 CR4: 00000000000006e0
[    1.912050] Call Trace:
[    1.912356]  ? register_shrinker+0x80/0x90
[    1.912826]  mount_bdev+0x177/0x1b0
[    1.913234]  ? ext4_calculate_overhead+0x4a0/0x4a0
[    1.913744]  ext4_mount+0x10/0x20
[    1.914115]  mount_fs+0x2d/0x140
[    1.914490]  ? __alloc_percpu+0x10/0x20
[    1.914903]  vfs_kern_mount.part.20+0x58/0x110
[    1.915394]  do_mount+0x1cc/0xca0
[    1.915758]  ? _copy_from_user+0x6b/0xa0
[    1.916198]  ? memdup_user+0x3d/0x70
[    1.916576]  SyS_mount+0x93/0xe0
[    1.916915]  entry_SYSCALL_64_fastpath+0x1a/0xa5
[    1.917401] RIP: 0033:0x7f8169264b5a
[    1.917777] RSP: 002b:00007fff6ce82bc8 EFLAGS: 00000202 ORIG_RAX: 00000000000000a5
[    1.918576] RAX: ffffffffffffffda RBX: 0000000000fb2030 RCX: 00007f8169264b5a
[    1.919313] RDX: 00007fff6ce84e61 RSI: 00007fff6ce84e70 RDI: 00007fff6ce84e66
[    1.920042] RBP: 0000000000008000 R08: 0000000000000000 R09: 0000000000000000
[    1.920771] R10: 0000000000008001 R11: 0000000000000202 R12: 0000000000000000
[    1.921512] R13: 0000000000000000 R14: 00007fff6ce82c70 R15: 0000000000445c20
[    1.922254] Code: 83 ee 01 48 c7 c7 70 e6 97 81 e8 1d 0c e2 ff 48 89 de 48 c7 c7 a4 48 96 81 e8 0e 0c e2 ff 8b 85 5c ff ff ff 41 39 44 24 40 75 0e <f6> 43 12 04 41 0f 44 c7 89 85 5c ff ff ff 48 c7 c7 ad 48 96 81 
[    1.924489] RIP: ext4_fill_super+0x2f3b/0x33c0 RSP: ffffc9001a33bce0
[    1.925334] CR2: ffff880139b75012
[    1.942161] ---[ end trace fe884f328a0a7338 ]---

This is the code:

if ((grp == sbi->s_groups_count) &&
    !(gdp->bg_flags & cpu_to_le16(EXT4_BG_INODE_ZEROED)))

in fs/ext4/super.c:ext4_check_descriptors() that's ultimately failing. It looks
like this allocation comes from sb_bread_unmovable(), which although it says
unmovable, seems to allocate the memory with:

MOVABLE
IO
NOFAIL
HARDWALL
DIRECT_RECLAIM
KSWAPD_RECLAIM

which I guess is from the additional flags in grow_dev_page() somewhere down
the stack. Anyway... it seems this is a kernel allocation that's using
MIGRATE_MOVABLE, so perhaps we need some more fine tuned heuristic than just
all MOVABLE allocations are un-mapped via xpfo, and all the others are mapped.

Do you have any ideas?

> Or, you could hook your code into the places where the migratetype of
> memory is changed (set_pageblock_migratetype(), plus where we fall
> back).  Those changes are much more rare than page allocation.

I guess this has the same issue, that sometimes the kernel allocates MOVABLE
stuff that it wants to use.

Thanks,

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
