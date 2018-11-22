Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6096B2CF8
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 14:56:22 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id l131so3057426pga.2
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:56:22 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f61si13275929plb.51.2018.11.22.11.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 11:56:21 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.14 21/21] mm, page_alloc: check for max order in hot path
Date: Thu, 22 Nov 2018 14:54:52 -0500
Message-Id: <20181122195452.13520-21-sashal@kernel.org>
In-Reply-To: <20181122195452.13520-1-sashal@kernel.org>
References: <20181122195452.13520-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Balbir Singh <bsingharora@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Aaron Lu <aaron.lu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Byoungyoung Lee <lifeasageek@gmail.com>, "Dae R. Jeong" <threeearcat@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Michal Hocko <mhocko@suse.com>

[ Upstream commit c63ae43ba53bc432b414fd73dd5f4b01fcb1ab43 ]

Konstantin has noticed that kvmalloc might trigger the following
warning:

  WARNING: CPU: 0 PID: 6676 at mm/vmstat.c:986 __fragmentation_index+0x54/0x60
  [...]
  Call Trace:
   fragmentation_index+0x76/0x90
   compaction_suitable+0x4f/0xf0
   shrink_node+0x295/0x310
   node_reclaim+0x205/0x250
   get_page_from_freelist+0x649/0xad0
   __alloc_pages_nodemask+0x12a/0x2a0
   kmalloc_large_node+0x47/0x90
   __kmalloc_node+0x22b/0x2e0
   kvmalloc_node+0x3e/0x70
   xt_alloc_table_info+0x3a/0x80 [x_tables]
   do_ip6t_set_ctl+0xcd/0x1c0 [ip6_tables]
   nf_setsockopt+0x44/0x60
   SyS_setsockopt+0x6f/0xc0
   do_syscall_64+0x67/0x120
   entry_SYSCALL_64_after_hwframe+0x3d/0xa2

the problem is that we only check for an out of bound order in the slow
path and the node reclaim might happen from the fast path already.  This
is fixable by making sure that kvmalloc doesn't ever use kmalloc for
requests that are larger than KMALLOC_MAX_SIZE but this also shows that
the code is rather fragile.  A recent UBSAN report just underlines that
by the following report

  UBSAN: Undefined behaviour in mm/page_alloc.c:3117:19
  shift exponent 51 is too large for 32-bit type 'int'
  CPU: 0 PID: 6520 Comm: syz-executor1 Not tainted 4.19.0-rc2 #1
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
  Call Trace:
   __dump_stack lib/dump_stack.c:77 [inline]
   dump_stack+0xd2/0x148 lib/dump_stack.c:113
   ubsan_epilogue+0x12/0x94 lib/ubsan.c:159
   __ubsan_handle_shift_out_of_bounds+0x2b6/0x30b lib/ubsan.c:425
   __zone_watermark_ok+0x2c7/0x400 mm/page_alloc.c:3117
   zone_watermark_fast mm/page_alloc.c:3216 [inline]
   get_page_from_freelist+0xc49/0x44c0 mm/page_alloc.c:3300
   __alloc_pages_nodemask+0x21e/0x640 mm/page_alloc.c:4370
   alloc_pages_current+0xcc/0x210 mm/mempolicy.c:2093
   alloc_pages include/linux/gfp.h:509 [inline]
   __get_free_pages+0x12/0x60 mm/page_alloc.c:4414
   dma_mem_alloc+0x36/0x50 arch/x86/include/asm/floppy.h:156
   raw_cmd_copyin drivers/block/floppy.c:3159 [inline]
   raw_cmd_ioctl drivers/block/floppy.c:3206 [inline]
   fd_locked_ioctl+0xa00/0x2c10 drivers/block/floppy.c:3544
   fd_ioctl+0x40/0x60 drivers/block/floppy.c:3571
   __blkdev_driver_ioctl block/ioctl.c:303 [inline]
   blkdev_ioctl+0xb3c/0x1a30 block/ioctl.c:601
   block_ioctl+0x105/0x150 fs/block_dev.c:1883
   vfs_ioctl fs/ioctl.c:46 [inline]
   do_vfs_ioctl+0x1c0/0x1150 fs/ioctl.c:687
   ksys_ioctl+0x9e/0xb0 fs/ioctl.c:702
   __do_sys_ioctl fs/ioctl.c:709 [inline]
   __se_sys_ioctl fs/ioctl.c:707 [inline]
   __x64_sys_ioctl+0x7e/0xc0 fs/ioctl.c:707
   do_syscall_64+0xc4/0x510 arch/x86/entry/common.c:290
   entry_SYSCALL_64_after_hwframe+0x49/0xbe

Note that this is not a kvmalloc path.  It is just that the fast path
really depends on having sanitzed order as well.  Therefore move the
order check to the fast path.

Link: http://lkml.kernel.org/r/20181113094305.GM15120@dhcp22.suse.cz
Signed-off-by: Michal Hocko <mhocko@suse.com>
Reported-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Reported-by: Kyungtae Kim <kt0755@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Byoungyoung Lee <lifeasageek@gmail.com>
Cc: "Dae R. Jeong" <threeearcat@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a604b5da6755..2074f424dabf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3867,17 +3867,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned int cpuset_mems_cookie;
 	int reserve_flags;
 
-	/*
-	 * In the slowpath, we sanity check order to avoid ever trying to
-	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
-	 * be using allocators in order of preference for an area that is
-	 * too large.
-	 */
-	if (order >= MAX_ORDER) {
-		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
-		return NULL;
-	}
-
 	/*
 	 * We also sanity check to catch abuse of atomic reserves being used by
 	 * callers that are not in atomic context.
@@ -4179,6 +4168,15 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = { };
 
+	/*
+	 * There are several places where we assume that the order value is sane
+	 * so bail out early if the request is out of bound.
+	 */
+	if (unlikely(order >= MAX_ORDER)) {
+		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
+		return NULL;
+	}
+
 	gfp_mask &= gfp_allowed_mask;
 	alloc_mask = gfp_mask;
 	if (!prepare_alloc_pages(gfp_mask, order, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
-- 
2.17.1
