Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6FC280003
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:46 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so35642883wib.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:45 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id cy1si7853336wib.89.2015.06.13.02.49.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:44 -0700 (PDT)
Received: by wibdq8 with SMTP id dq8so34971802wib.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:44 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 07/12] x86/virt/guest/xen: Remove use of pgd_list from the Xen guest code
Date: Sat, 13 Jun 2015 11:49:10 +0200
Message-Id: <1434188955-31397-8-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

xen_mm_pin_all()/unpin_all() are used to implement full guest instance
suspend/restore. It's a stop-all method that needs to iterate through
all allocated pgds in the system to fix them up for Xen's use.

This code uses pgd_list, probably because it was an easy interface.

But we want to remove the pgd_list, so convert the code over to walk
all tasks in the system. This is an equivalent method.

(As I don't use Xen this is was only build tested.)

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
 arch/x86/xen/mmu.c | 51 ++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 38 insertions(+), 13 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index dd151b2045b0..70a3df5b0b54 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -853,15 +853,27 @@ static void xen_pgd_pin(struct mm_struct *mm)
  */
 void xen_mm_pin_all(void)
 {
-	struct page *page;
+	struct task_struct *g, *p;
 
-	spin_lock(&pgd_lock);
+	spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
 
-	list_for_each_entry(page, &pgd_list, lru) {
-		if (!PagePinned(page)) {
-			__xen_pgd_pin(&init_mm, (pgd_t *)page_address(page));
-			SetPageSavePinned(page);
+	for_each_process_thread(g, p) {
+		struct mm_struct *mm;
+		struct page *page;
+		pgd_t *pgd;
+
+		task_lock(p);
+		mm = p->mm;
+		if (mm) {
+			pgd = mm->pgd;
+			page = virt_to_page(pgd);
+
+			if (!PagePinned(page)) {
+				__xen_pgd_pin(&init_mm, pgd);
+				SetPageSavePinned(page);
+			}
 		}
+		task_unlock(p);
 	}
 
 	spin_unlock(&pgd_lock);
@@ -967,19 +979,32 @@ static void xen_pgd_unpin(struct mm_struct *mm)
  */
 void xen_mm_unpin_all(void)
 {
-	struct page *page;
+	struct task_struct *g, *p;
 
-	spin_lock(&pgd_lock);
+	spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
 
-	list_for_each_entry(page, &pgd_list, lru) {
-		if (PageSavePinned(page)) {
-			BUG_ON(!PagePinned(page));
-			__xen_pgd_unpin(&init_mm, (pgd_t *)page_address(page));
-			ClearPageSavePinned(page);
+	for_each_process_thread(g, p) {
+		struct mm_struct *mm;
+		struct page *page;
+		pgd_t *pgd;
+
+		task_lock(p);
+		mm = p->mm;
+		if (mm) {
+			pgd = mm->pgd;
+			page = virt_to_page(pgd);
+
+			if (PageSavePinned(page)) {
+				BUG_ON(!PagePinned(page));
+				__xen_pgd_unpin(&init_mm, pgd);
+				ClearPageSavePinned(page);
+			}
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
