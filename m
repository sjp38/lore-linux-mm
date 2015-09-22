Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id BEDD76B0259
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:15 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so145564046wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:15 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id p10si22355376wik.84.2015.09.21.23.24.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:14 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so176871945wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:14 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 06/11] x86/virt/guest/xen: Remove use of pgd_list from the Xen guest code
Date: Tue, 22 Sep 2015 08:23:36 +0200
Message-Id: <1442903021-3893-7-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

xen_mm_pin_all()/unpin_all() are used to implement full guest instance
suspend/restore. It's a stop-all method that needs to iterate through
all allocated pgds in the system to fix them up for Xen's use.

This code uses pgd_list, probably because it was an easy interface.

But we want to remove the pgd_list, so convert the code over to walk
all tasks in the system. This is an equivalent method.

(As I don't use Xen this is was only build tested.)

Reviewed-by: David Vrabel <david.vrabel@citrix.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Waiman Long <Waiman.Long@hp.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/xen/mmu.c | 45 +++++++++++++++++++++++++++++++++++++++------
 1 file changed, 39 insertions(+), 6 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 9c479fe40459..96bb4a7a626d 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -45,6 +45,7 @@
 #include <linux/vmalloc.h>
 #include <linux/module.h>
 #include <linux/gfp.h>
+#include <linux/oom.h>
 #include <linux/memblock.h>
 #include <linux/seq_file.h>
 #include <linux/crash_dump.h>
@@ -854,18 +855,34 @@ static void xen_pgd_pin(struct mm_struct *mm)
  */
 void xen_mm_pin_all(void)
 {
-	struct page *page;
+	struct task_struct *g;
 
+	rcu_read_lock(); /* Task list walk */
 	spin_lock(&pgd_lock);
 
-	list_for_each_entry(page, &pgd_list, lru) {
+	for_each_process(g) {
+		struct task_struct *p;
+		struct mm_struct *mm;
+		struct page *page;
+		pgd_t *pgd;
+
+		p = find_lock_task_mm(g);
+		if (!p)
+			continue;
+
+		mm = p->mm;
+		pgd = mm->pgd;
+		page = virt_to_page(pgd);
+
 		if (!PagePinned(page)) {
-			__xen_pgd_pin(&init_mm, (pgd_t *)page_address(page));
+			__xen_pgd_pin(&init_mm, pgd);
 			SetPageSavePinned(page);
 		}
+		task_unlock(p);
 	}
 
 	spin_unlock(&pgd_lock);
+	rcu_read_unlock();
 }
 
 /*
@@ -968,19 +985,35 @@ static void xen_pgd_unpin(struct mm_struct *mm)
  */
 void xen_mm_unpin_all(void)
 {
-	struct page *page;
+	struct task_struct *g;
 
+	rcu_read_lock(); /* Task list walk */
 	spin_lock(&pgd_lock);
 
-	list_for_each_entry(page, &pgd_list, lru) {
+	for_each_process(g) {
+		struct task_struct *p;
+		struct mm_struct *mm;
+		struct page *page;
+		pgd_t *pgd;
+
+		p = find_lock_task_mm(g);
+		if (!p)
+			continue;
+
+		mm = p->mm;
+		pgd = mm->pgd;
+		page = virt_to_page(pgd);
+
 		if (PageSavePinned(page)) {
 			BUG_ON(!PagePinned(page));
-			__xen_pgd_unpin(&init_mm, (pgd_t *)page_address(page));
+			__xen_pgd_unpin(&init_mm, pgd);
 			ClearPageSavePinned(page);
 		}
+		task_unlock(p);
 	}
 
 	spin_unlock(&pgd_lock);
+	rcu_read_unlock();
 }
 
 static void xen_activate_mm(struct mm_struct *prev, struct mm_struct *next)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
