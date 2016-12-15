Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6021C6B025E
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 09:07:52 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id he10so23326904wjc.6
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 06:07:52 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id c137si2656015wmd.151.2016.12.15.06.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 06:07:50 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id m203so6711688wma.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 06:07:50 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/9] lockdep: allow to disable reclaim lockup detection
Date: Thu, 15 Dec 2016 15:07:07 +0100
Message-Id: <20161215140715.12732-2-mhocko@kernel.org>
In-Reply-To: <20161215140715.12732-1-mhocko@kernel.org>
References: <20161215140715.12732-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

The current implementation of the reclaim lockup detection can lead to
false positives and those even happen and usually lead to tweak the
code to silence the lockdep by using GFP_NOFS even though the context
can use __GFP_FS just fine. See
http://lkml.kernel.org/r/20160512080321.GA18496@dastard as an example.

=================================
[ INFO: inconsistent lock state ]
4.5.0-rc2+ #4 Tainted: G           O
---------------------------------
inconsistent {RECLAIM_FS-ON-R} -> {IN-RECLAIM_FS-W} usage.
kswapd0/543 [HC0[0]:SC0[0]:HE1:SE1] takes:

(&xfs_nondir_ilock_class){++++-+}, at: [<ffffffffa00781f7>] xfs_ilock+0x177/0x200 [xfs]

{RECLAIM_FS-ON-R} state was registered at:
  [<ffffffff8110f369>] mark_held_locks+0x79/0xa0
  [<ffffffff81113a43>] lockdep_trace_alloc+0xb3/0x100
  [<ffffffff81224623>] kmem_cache_alloc+0x33/0x230
  [<ffffffffa008acc1>] kmem_zone_alloc+0x81/0x120 [xfs]
  [<ffffffffa005456e>] xfs_refcountbt_init_cursor+0x3e/0xa0 [xfs]
  [<ffffffffa0053455>] __xfs_refcount_find_shared+0x75/0x580 [xfs]
  [<ffffffffa00539e4>] xfs_refcount_find_shared+0x84/0xb0 [xfs]
  [<ffffffffa005dcb8>] xfs_getbmap+0x608/0x8c0 [xfs]
  [<ffffffffa007634b>] xfs_vn_fiemap+0xab/0xc0 [xfs]
  [<ffffffff81244208>] do_vfs_ioctl+0x498/0x670
  [<ffffffff81244459>] SyS_ioctl+0x79/0x90
  [<ffffffff81847cd7>] entry_SYSCALL_64_fastpath+0x12/0x6f

       CPU0
       ----
  lock(&xfs_nondir_ilock_class);
  <Interrupt>
    lock(&xfs_nondir_ilock_class);

 *** DEADLOCK ***

3 locks held by kswapd0/543:

stack backtrace:
CPU: 0 PID: 543 Comm: kswapd0 Tainted: G           O    4.5.0-rc2+ #4

Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006

 ffffffff82a34f10 ffff88003aa078d0 ffffffff813a14f9 ffff88003d8551c0
 ffff88003aa07920 ffffffff8110ec65 0000000000000000 0000000000000001
 ffff880000000001 000000000000000b 0000000000000008 ffff88003d855aa0
Call Trace:
 [<ffffffff813a14f9>] dump_stack+0x4b/0x72
 [<ffffffff8110ec65>] print_usage_bug+0x215/0x240
 [<ffffffff8110ee85>] mark_lock+0x1f5/0x660
 [<ffffffff8110e100>] ? print_shortest_lock_dependencies+0x1a0/0x1a0
 [<ffffffff811102e0>] __lock_acquire+0xa80/0x1e50
 [<ffffffff8122474e>] ? kmem_cache_alloc+0x15e/0x230
 [<ffffffffa008acc1>] ? kmem_zone_alloc+0x81/0x120 [xfs]
 [<ffffffff811122e8>] lock_acquire+0xd8/0x1e0
 [<ffffffffa00781f7>] ? xfs_ilock+0x177/0x200 [xfs]
 [<ffffffffa0083a70>] ? xfs_reflink_cancel_cow_range+0x150/0x300 [xfs]
 [<ffffffff8110aace>] down_write_nested+0x5e/0xc0
 [<ffffffffa00781f7>] ? xfs_ilock+0x177/0x200 [xfs]
 [<ffffffffa00781f7>] xfs_ilock+0x177/0x200 [xfs]
 [<ffffffffa0083a70>] xfs_reflink_cancel_cow_range+0x150/0x300 [xfs]
 [<ffffffffa0085bdc>] xfs_fs_evict_inode+0xdc/0x1e0 [xfs]
 [<ffffffff8124d7d5>] evict+0xc5/0x190
 [<ffffffff8124d8d9>] dispose_list+0x39/0x60
 [<ffffffff8124eb2b>] prune_icache_sb+0x4b/0x60
 [<ffffffff8123317f>] super_cache_scan+0x14f/0x1a0
 [<ffffffff811e0d19>] shrink_slab.part.63.constprop.79+0x1e9/0x4e0
 [<ffffffff811e50ee>] shrink_zone+0x15e/0x170
 [<ffffffff811e5ef1>] kswapd+0x4f1/0xa80
 [<ffffffff811e5a00>] ? zone_reclaim+0x230/0x230
 [<ffffffff810e6882>] kthread+0xf2/0x110
 [<ffffffff810e6790>] ? kthread_create_on_node+0x220/0x220
 [<ffffffff8184803f>] ret_from_fork+0x3f/0x70
 [<ffffffff810e6790>] ? kthread_create_on_node+0x220/0x220

To quote Dave:
"
Ignoring whether reflink should be doing anything or not, that's a
"xfs_refcountbt_init_cursor() gets called both outside and inside
transactions" lockdep false positive case. The problem here is
lockdep has seen this allocation from within a transaction, hence a
GFP_NOFS allocation, and now it's seeing it in a GFP_KERNEL context.
Also note that we have an active reference to this inode.

So, because the reclaim annotations overload the interrupt level
detections and it's seen the inode ilock been taken in reclaim
("interrupt") context, this triggers a reclaim context warning where
it thinks it is unsafe to do this allocation in GFP_KERNEL context
holding the inode ilock...
"

This sounds like a fundamental problem of the reclaim lock detection.
It is really impossible to annotate such a special usecase IMHO unless
the reclaim lockup detection is reworked completely. Until then it
is much better to provide a way to add "I know what I am doing flag"
and mark problematic places. This would prevent from abusing GFP_NOFS
flag which has a runtime effect even on configurations which have
lockdep disabled.

Introduce __GFP_NOLOCKDEP flag which tells the lockdep gfp tracking to
skip the current allocation request.

While we are at it also make sure that the radix tree doesn't
accidentaly override tags stored in the upper part of the gfp_mask.

Suggested-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/gfp.h      | 10 +++++++++-
 kernel/locking/lockdep.c |  4 ++++
 lib/radix-tree.c         |  2 ++
 3 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4175dca4ac39..1a934383cc20 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -41,6 +41,11 @@ struct vm_area_struct;
 #define ___GFP_OTHER_NODE	0x800000u
 #define ___GFP_WRITE		0x1000000u
 #define ___GFP_KSWAPD_RECLAIM	0x2000000u
+#ifdef CONFIG_LOCKDEP
+#define ___GFP_NOLOCKDEP	0x4000000u
+#else
+#define ___GFP_NOLOCKDEP	0
+#endif
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -186,8 +191,11 @@ struct vm_area_struct;
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE)
 
+/* Disable lockdep for GFP context tracking */
+#define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
+
 /* Room for N __GFP_FOO bits */
-#define __GFP_BITS_SHIFT 26
+#define __GFP_BITS_SHIFT (26 + IS_ENABLED(CONFIG_LOCKDEP))
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /*
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 7c38f8f3d97b..5684682a9ef8 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2879,6 +2879,10 @@ static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
 	if (DEBUG_LOCKS_WARN_ON(irqs_disabled_flags(flags)))
 		return;
 
+	/* Disable lockdep if explicitly requested */
+	if (gfp_mask & __GFP_NOLOCKDEP)
+		return;
+
 	mark_held_locks(curr, RECLAIM_FS);
 }
 
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 5e8fc32697b1..e528bd426f8e 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -2498,6 +2498,8 @@ static int radix_tree_cpu_dead(unsigned int cpu)
 void __init radix_tree_init(void)
 {
 	int ret;
+
+	BUILD_BUG_ON(RADIX_TREE_MAX_TAGS + __GFP_BITS_SHIFT > 32);
 	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
 			sizeof(struct radix_tree_node), 0,
 			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
