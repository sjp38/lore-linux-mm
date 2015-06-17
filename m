Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id E448C6B0072
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 12:18:38 -0400 (EDT)
Received: by oiax193 with SMTP id x193so37997283oia.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 09:18:38 -0700 (PDT)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id 203si2970125oic.114.2015.06.17.09.18.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 09:18:38 -0700 (PDT)
Received: by obbgp2 with SMTP id gp2so36368058obb.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 09:18:37 -0700 (PDT)
From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] mm: kmemleak_alloc_percpu() should follow the gfp from
Date: Wed, 17 Jun 2015 11:18:20 -0500
Message-Id: <1434557900-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>, Martin KaFai Lau <kafai@fb.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

Beginning at commit d52d3997f843 ("ipv6: Create percpu rt6_info"), the
following INFO splat is logged:

===============================
[ INFO: suspicious RCU usage. ]
4.1.0-rc7-next-20150612 #1 Not tainted
-------------------------------
kernel/sched/core.c:7318 Illegal context switch in RCU-bh read-side critical section!
other info that might help us debug this:
rcu_scheduler_active = 1, debug_locks = 0
 3 locks held by systemd/1:
 #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff815f0c8f>] rtnetlink_rcv+0x1f/0x40
 #1:  (rcu_read_lock_bh){......}, at: [<ffffffff816a34e2>] ipv6_add_addr+0x62/0x540
 #2:  (addrconf_hash_lock){+...+.}, at: [<ffffffff816a3604>] ipv6_add_addr+0x184/0x540
stack backtrace:
CPU: 0 PID: 1 Comm: systemd Not tainted 4.1.0-rc7-next-20150612 #1
Hardware name: TOSHIBA TECRA A50-A/TECRA A50-A, BIOS Version 4.20   04/17/2014
 0000000000000001 ffff880224e07838 ffffffff817263a4 ffffffff810ccf2a
 ffff880224e08000 ffff880224e07868 ffffffff810b6827 0000000000000000
 ffffffff81a445d3 00000000000004f4 ffff88022682e100 ffff880224e07898
Call Trace:
 [<ffffffff817263a4>] dump_stack+0x4c/0x6e
 [<ffffffff810ccf2a>] ? console_unlock+0x1ca/0x510
 [<ffffffff810b6827>] lockdep_rcu_suspicious+0xe7/0x120
 [<ffffffff8108cf05>] ___might_sleep+0x1d5/0x1f0
 [<ffffffff8108cf6d>] __might_sleep+0x4d/0x90
 [<ffffffff811f3789>] ? create_object+0x39/0x2e0
 [<ffffffff811da427>] kmem_cache_alloc+0x47/0x250
 [<ffffffff813c19ae>] ? find_next_zero_bit+0x1e/0x20
 [<ffffffff811f3789>] create_object+0x39/0x2e0
 [<ffffffff810b7eb6>] ? mark_held_locks+0x66/0x90
 [<ffffffff8172efab>] ? _raw_spin_unlock_irqrestore+0x4b/0x60
 [<ffffffff817193c1>] kmemleak_alloc_percpu+0x61/0xe0
 [<ffffffff811a26f0>] pcpu_alloc+0x370/0x630

Additional backtrace lines are truncated. In addition, the above splat is
followed by several "BUG: sleeping function called from invalid context
at mm/slub.c:1268" outputs. As suggested by Martin KaFai Lau, these are the
clue to the fix. Routine kmemleak_alloc_percpu() always uses GFP_KERNEL
for its allocations, whereas it should follow the gfp from its callers.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Martin KaFai Lau <kafai@fb.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: <stable@vger.kernel.org> # v3.18+
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
V2 - Remove extraneous file added by mistake as noted by Catalin and Kamalesh
     Comment revised and Stable added as suggested by Catalin
     Wording changes in commit message suggested by Martin

---
 include/linux/kmemleak.h | 3 ++-
 mm/kmemleak.c            | 9 +++++----
 mm/percpu.c              | 2 +-
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index e705467..ec4437b 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -28,7 +28,8 @@
 extern void kmemleak_init(void) __ref;
 extern void kmemleak_alloc(const void *ptr, size_t size, int min_count,
 			   gfp_t gfp) __ref;
-extern void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size) __ref;
+extern void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size,
+				  gfp_t gfp) __ref;
 extern void kmemleak_free(const void *ptr) __ref;
 extern void kmemleak_free_part(const void *ptr, size_t size) __ref;
 extern void kmemleak_free_percpu(const void __percpu *ptr) __ref;
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index ca9e5a5..cf79f11 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -930,12 +930,13 @@ EXPORT_SYMBOL_GPL(kmemleak_alloc);
  * kmemleak_alloc_percpu - register a newly allocated __percpu object
  * @ptr:	__percpu pointer to beginning of the object
  * @size:	size of the object
+ * @gfp:	flags used for kmemleak internal memory allocations
  *
  * This function is called from the kernel percpu allocator when a new object
- * (memory block) is allocated (alloc_percpu). It assumes GFP_KERNEL
- * allocation.
+ * (memory block) is allocated (alloc_percpu).
  */
-void __ref kmemleak_alloc_percpu(const void __percpu *ptr, size_t size)
+void __ref kmemleak_alloc_percpu(const void __percpu *ptr, size_t size,
+				 gfp_t gfp)
 {
 	unsigned int cpu;
 
@@ -948,7 +949,7 @@ void __ref kmemleak_alloc_percpu(const void __percpu *ptr, size_t size)
 	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
 		for_each_possible_cpu(cpu)
 			create_object((unsigned long)per_cpu_ptr(ptr, cpu),
-				      size, 0, GFP_KERNEL);
+				      size, 0, gfp);
 	else if (kmemleak_early_log)
 		log_early(KMEMLEAK_ALLOC_PERCPU, ptr, size, 0);
 }
diff --git a/mm/percpu.c b/mm/percpu.c
index dfd0248..2dd7448 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1030,7 +1030,7 @@ area_found:
 		memset((void *)pcpu_chunk_addr(chunk, cpu, 0) + off, 0, size);
 
 	ptr = __addr_to_pcpu_ptr(chunk->base_addr + off);
-	kmemleak_alloc_percpu(ptr, size);
+	kmemleak_alloc_percpu(ptr, size, gfp);
 	return ptr;
 
 fail_unlock:
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
