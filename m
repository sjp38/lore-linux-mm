Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61DBE6B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 16:01:02 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id he1so144203610pac.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 13:01:02 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id r6si27973051paw.125.2016.06.17.13.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 13:01:01 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 05/13] mm: Move memcg stack accounting to account_kernel_stack
Date: Fri, 17 Jun 2016 13:00:41 -0700
Message-Id: <8a17889a9d47b7b4deb41f2fcccada8bf54d4b6f.1466192946.git.luto@kernel.org>
In-Reply-To: <cover.1466192946.git.luto@kernel.org>
References: <cover.1466192946.git.luto@kernel.org>
In-Reply-To: <cover.1466192946.git.luto@kernel.org>
References: <cover.1466192946.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andy Lutomirski <luto@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

We should account for stacks regardless of stack size.  Move it into
account_kernel_stack.

Fixes: 12580e4b54ba8 ("mm: memcontrol: report kernel stack usage in cgroup2 memory.stat")
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 kernel/fork.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index be7f006af727..cd2abe6e4e41 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -165,20 +165,12 @@ static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
 	struct page *page = alloc_kmem_pages_node(node, THREADINFO_GFP,
 						  THREAD_SIZE_ORDER);
 
-	if (page)
-		memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
-					    1 << THREAD_SIZE_ORDER);
-
 	return page ? page_address(page) : NULL;
 }
 
 static inline void free_thread_info(struct thread_info *ti)
 {
-	struct page *page = virt_to_page(ti);
-
-	memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
-				    -(1 << THREAD_SIZE_ORDER));
-	__free_kmem_pages(page, THREAD_SIZE_ORDER);
+	free_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
 }
 # else
 static struct kmem_cache *thread_info_cache;
@@ -227,6 +219,11 @@ static void account_kernel_stack(struct thread_info *ti, int account)
 
 	mod_zone_page_state(zone, NR_KERNEL_STACK_KB,
 			    THREAD_SIZE / 1024 * account);
+
+	/* All stack pages belong to the same memcg. */
+	memcg_kmem_update_page_stat(
+		virt_to_page(ti), MEMCG_KERNEL_STACK,
+		account * (THREAD_SIZE / PAGE_SIZE));
 }
 
 void free_task(struct task_struct *tsk)
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
