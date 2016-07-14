Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5476B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 15:14:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so172314330pfx.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 12:14:19 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id u125si5676874pfb.245.2016.07.14.12.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 12:14:17 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 1/4] mm: Track NR_KERNEL_STACK in KiB instead of number of stacks
Date: Thu, 14 Jul 2016 12:14:10 -0700
Message-Id: <083c71e642c5fa5f1b6898902e1b2db7b48940d4.1468523549.git.luto@kernel.org>
In-Reply-To: <cover.1468523549.git.luto@kernel.org>
References: <cover.1468523549.git.luto@kernel.org>
In-Reply-To: <cover.1468523549.git.luto@kernel.org>
References: <cover.1468523549.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Andy Lutomirski <luto@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

Currently, NR_KERNEL_STACK tracks the number of kernel stacks in a
zone.  This only makes sense if each kernel stack exists entirely in
one zone, and allowing vmapped stacks could break this assumption.

Since frv has THREAD_SIZE < PAGE_SIZE, we need to track kernel stack
allocations in a unit that divides both THREAD_SIZE and PAGE_SIZE on
all architectures.  Keep it simple and use KiB.

Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org
Reviewed-by: Josh Poimboeuf <jpoimboe@redhat.com>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 drivers/base/node.c    | 3 +--
 fs/proc/meminfo.c      | 2 +-
 include/linux/mmzone.h | 2 +-
 kernel/fork.c          | 3 ++-
 mm/page_alloc.c        | 3 +--
 5 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 560751bad294..27dc68a0ed2d 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -121,8 +121,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
 		       nid, K(i.sharedram),
-		       nid, node_page_state(nid, NR_KERNEL_STACK) *
-				THREAD_SIZE / 1024,
+		       nid, node_page_state(nid, NR_KERNEL_STACK_KB),
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
 		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
 		       nid, K(node_page_state(nid, NR_BOUNCE)),
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 83720460c5bc..239b5a06cee0 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -145,7 +145,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 				global_page_state(NR_SLAB_UNRECLAIMABLE)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE)),
 		K(global_page_state(NR_SLAB_UNRECLAIMABLE)),
-		global_page_state(NR_KERNEL_STACK) * THREAD_SIZE / 1024,
+		global_page_state(NR_KERNEL_STACK_KB),
 		K(global_page_state(NR_PAGETABLE)),
 #ifdef CONFIG_QUICKLIST
 		K(quicklist_total_size()),
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 02069c23486d..63f05a7efb54 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -127,7 +127,7 @@ enum zone_stat_item {
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
-	NR_KERNEL_STACK,
+	NR_KERNEL_STACK_KB,	/* measured in KiB */
 	/* Second 128 byte cacheline */
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
diff --git a/kernel/fork.c b/kernel/fork.c
index 4a7ec0c6c88c..466ba8febe3b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -225,7 +225,8 @@ static void account_kernel_stack(unsigned long *stack, int account)
 {
 	struct zone *zone = page_zone(virt_to_page(stack));
 
-	mod_zone_page_state(zone, NR_KERNEL_STACK, account);
+	mod_zone_page_state(zone, NR_KERNEL_STACK_KB,
+			    THREAD_SIZE / 1024 * account);
 }
 
 void free_task(struct task_struct *tsk)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6903b695ebae..a277dea926c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4457,8 +4457,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_SHMEM)),
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
-			zone_page_state(zone, NR_KERNEL_STACK) *
-				THREAD_SIZE / 1024,
+			zone_page_state(zone, NR_KERNEL_STACK_KB),
 			K(zone_page_state(zone, NR_PAGETABLE)),
 			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
 			K(zone_page_state(zone, NR_BOUNCE)),
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
