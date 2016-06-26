Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C15F828E2
	for <linux-mm@kvack.org>; Sun, 26 Jun 2016 17:56:08 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so364427788pfb.3
        for <linux-mm@kvack.org>; Sun, 26 Jun 2016 14:56:08 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id i9si21895903pai.89.2016.06.26.14.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Jun 2016 14:56:07 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v4 07/29] mm: Fix memcg stack accounting for sub-page stacks
Date: Sun, 26 Jun 2016 14:55:29 -0700
Message-Id: <eced7c0671ef8a2d23c2a60f6de9aedb312cb014.1466974736.git.luto@kernel.org>
In-Reply-To: <cover.1466974736.git.luto@kernel.org>
References: <cover.1466974736.git.luto@kernel.org>
In-Reply-To: <cover.1466974736.git.luto@kernel.org>
References: <cover.1466974736.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andy Lutomirski <luto@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

We should account for stacks regardless of stack size, and we need
to account in sub-page units if THREAD_SIZE < PAGE_SIZE.  Change the
units to kilobytes and Move it into account_kernel_stack().

Fixes: 12580e4b54ba8 ("mm: memcontrol: report kernel stack usage in cgroup2 memory.stat")
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org
Reviewed-by: Josh Poimboeuf <jpoimboe@redhat.com>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 include/linux/memcontrol.h |  2 +-
 kernel/fork.c              | 19 ++++++++-----------
 mm/memcontrol.c            |  2 +-
 3 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a805474df4ab..3b653b86bb8f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -52,7 +52,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
 	/* default hierarchy stats */
-	MEMCG_KERNEL_STACK = MEM_CGROUP_STAT_NSTATS,
+	MEMCG_KERNEL_STACK_KB = MEM_CGROUP_STAT_NSTATS,
 	MEMCG_SLAB_RECLAIMABLE,
 	MEMCG_SLAB_UNRECLAIMABLE,
 	MEMCG_SOCK,
diff --git a/kernel/fork.c b/kernel/fork.c
index 466ba8febe3b..146c9840c079 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -165,20 +165,12 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk,
 	struct page *page = alloc_kmem_pages_node(node, THREADINFO_GFP,
 						  THREAD_SIZE_ORDER);
 
-	if (page)
-		memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
-					    1 << THREAD_SIZE_ORDER);
-
 	return page ? page_address(page) : NULL;
 }
 
 static inline void free_thread_stack(unsigned long *stack)
 {
-	struct page *page = virt_to_page(stack);
-
-	memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
-				    -(1 << THREAD_SIZE_ORDER));
-	__free_kmem_pages(page, THREAD_SIZE_ORDER);
+	free_kmem_pages((unsigned long)stack, THREAD_SIZE_ORDER);
 }
 # else
 static struct kmem_cache *thread_stack_cache;
@@ -223,10 +215,15 @@ static struct kmem_cache *mm_cachep;
 
 static void account_kernel_stack(unsigned long *stack, int account)
 {
-	struct zone *zone = page_zone(virt_to_page(stack));
+	/* All stack pages are in the same zone and belong to the same memcg. */
+	struct page *first_page = virt_to_page(stack);
 
-	mod_zone_page_state(zone, NR_KERNEL_STACK_KB,
+	mod_zone_page_state(page_zone(first_page), NR_KERNEL_STACK_KB,
 			    THREAD_SIZE / 1024 * account);
+
+	memcg_kmem_update_page_stat(
+		first_page, MEMCG_KERNEL_STACK_KB,
+		account * (THREAD_SIZE / 1024));
 }
 
 void free_task(struct task_struct *tsk)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ac8664db3823..ee44afc1f2d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5133,7 +5133,7 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "file %llu\n",
 		   (u64)stat[MEM_CGROUP_STAT_CACHE] * PAGE_SIZE);
 	seq_printf(m, "kernel_stack %llu\n",
-		   (u64)stat[MEMCG_KERNEL_STACK] * PAGE_SIZE);
+		   (u64)stat[MEMCG_KERNEL_STACK_KB] * 1024);
 	seq_printf(m, "slab %llu\n",
 		   (u64)(stat[MEMCG_SLAB_RECLAIMABLE] +
 			 stat[MEMCG_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
