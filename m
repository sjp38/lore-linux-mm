Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2882F6B00BF
	for <linux-mm@kvack.org>; Sun, 24 May 2015 12:01:45 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so53590206pdb.0
        for <linux-mm@kvack.org>; Sun, 24 May 2015 09:01:44 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id es5si12377008pbb.19.2015.05.24.09.01.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 May 2015 09:01:44 -0700 (PDT)
Received: by pacwv17 with SMTP id wv17so54546594pac.2
        for <linux-mm@kvack.org>; Sun, 24 May 2015 09:01:44 -0700 (PDT)
From: Jungseok Lee <jungseoklee85@gmail.com>
Subject: [RFC PATCH 1/2] kernel/fork.c: add a function to calculate page address from thread_info
Date: Mon, 25 May 2015 01:01:32 +0900
Message-Id: <1432483292-23109-1-git-send-email-jungseoklee85@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: barami97@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-arm-kernel@lists.infradead.org

A current implementation assumes thread_info address is always correctly
calculated via virt_to_page. It restricts a different approach, such as
thread_info allocation from vmalloc space.

This patch, thus, introduces an independent function to calculate page
address from thread_info one.

Suggested-by: Sungjinn Chung <barami97@gmail.com>
Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-arm-kernel@lists.infradead.org
---
 kernel/fork.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 03c1eaa..6300bbd 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -212,9 +212,14 @@ struct kmem_cache *vm_area_cachep;
 /* SLAB cache for mm_struct structures (tsk->mm) */
 static struct kmem_cache *mm_cachep;
 
+struct page * __weak arch_thread_info_to_page(struct thread_info *ti)
+{
+	return virt_to_page(ti);
+}
+
 static void account_kernel_stack(struct thread_info *ti, int account)
 {
-	struct zone *zone = page_zone(virt_to_page(ti));
+	struct zone *zone = page_zone(arch_thread_info_to_page(ti));
 
 	mod_zone_page_state(zone, NR_KERNEL_STACK, account);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
