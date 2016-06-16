Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79AA16B0253
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 20:28:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so75534864pfa.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 17:28:46 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id 87si2272171pfn.73.2016.06.15.17.28.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 17:28:44 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 04/13] mm: Track NR_KERNEL_STACK in pages instead of number of stacks
Date: Wed, 15 Jun 2016 17:28:26 -0700
Message-Id: <24279d4009c821de64109055665429fad2a7bff7.1466036668.git.luto@kernel.org>
In-Reply-To: <cover.1466036668.git.luto@kernel.org>
References: <cover.1466036668.git.luto@kernel.org>
In-Reply-To: <cover.1466036668.git.luto@kernel.org>
References: <cover.1466036668.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, x86@kernel.org, Borislav Petkov <bp@alien8.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Andy Lutomirski <luto@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

Currently, NR_KERNEL_STACK tracks the number of kernel stacks in a
zone.  This only makes sense if each kernel stack exists entirely in
one zone, and allowing vmapped stacks could break this assumption.

It turns out that the code for tracking kernel stack allocations in
units of pages is slightly simpler, so just switch to counting
pages.

Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 fs/proc/meminfo.c | 2 +-
 kernel/fork.c     | 3 ++-
 mm/page_alloc.c   | 3 +--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 83720460c5bc..8338c0569a8d 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -145,7 +145,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 				global_page_state(NR_SLAB_UNRECLAIMABLE)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE)),
 		K(global_page_state(NR_SLAB_UNRECLAIMABLE)),
-		global_page_state(NR_KERNEL_STACK) * THREAD_SIZE / 1024,
+		K(global_page_state(NR_KERNEL_STACK)),
 		K(global_page_state(NR_PAGETABLE)),
 #ifdef CONFIG_QUICKLIST
 		K(quicklist_total_size()),
diff --git a/kernel/fork.c b/kernel/fork.c
index 5c2c355aa97f..95bebde59d79 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -225,7 +225,8 @@ static void account_kernel_stack(struct thread_info *ti, int account)
 {
 	struct zone *zone = page_zone(virt_to_page(ti));
 
-	mod_zone_page_state(zone, NR_KERNEL_STACK, account);
+	mod_zone_page_state(zone, NR_KERNEL_STACK,
+			    THREAD_SIZE / PAGE_SIZE * account);
 }
 
 void free_task(struct task_struct *tsk)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6903b695ebae..2b0203b3a976 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4457,8 +4457,7 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_SHMEM)),
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
-			zone_page_state(zone, NR_KERNEL_STACK) *
-				THREAD_SIZE / 1024,
+			K(zone_page_state(zone, NR_KERNEL_STACK)),
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
