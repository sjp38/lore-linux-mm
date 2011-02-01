Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B0ACD8D0041
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 06:21:51 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 2/2] KVM: Enable async page fault processing.
Date: Tue,  1 Feb 2011 13:21:47 +0200
Message-Id: <1296559307-14637-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1296559307-14637-1-git-send-email-gleb@redhat.com>
References: <1296559307-14637-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: avi@redhat.com, mtosatti@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If asynchronous hva_to_pfn() is requested call GUP with FOLL_NOWAIT to
avoid sleeping on IO. Check for hwpoison is done at the same time,
otherwise check_user_page_hwpoison() will call GUP again and will put
vcpu to sleep.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 virt/kvm/kvm_main.c |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 74d032a..80f42ab 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1029,6 +1029,17 @@ static pfn_t get_fault_pfn(void)
 	return fault_pfn;
 }
 
+int get_user_page_nowait(struct task_struct *tsk, struct mm_struct *mm,
+	unsigned long start, int write, struct page **page)
+{
+	int flags = FOLL_TOUCH | FOLL_NOWAIT | FOLL_HWPOISON | FOLL_GET;
+
+	if (write)
+		flags |= FOLL_WRITE;
+
+	return __get_user_pages(tsk, mm, start, 1, flags, page, NULL, NULL);
+}
+
 static inline int check_user_page_hwpoison(unsigned long addr)
 {
 	int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
@@ -1062,7 +1073,14 @@ static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr, bool atomic,
 		if (writable)
 			*writable = write_fault;
 
-		npages = get_user_pages_fast(addr, 1, write_fault, page);
+		if (async) {
+			down_read(&current->mm->mmap_sem);
+			npages = get_user_page_nowait(current, current->mm,
+						     addr, write_fault, page);
+			up_read(&current->mm->mmap_sem);
+		} else
+			npages = get_user_pages_fast(addr, 1, write_fault,
+						     page);
 
 		/* map read fault as writable if possible */
 		if (unlikely(!write_fault) && npages == 1) {
@@ -1085,7 +1103,8 @@ static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr, bool atomic,
 			return get_fault_pfn();
 
 		down_read(&current->mm->mmap_sem);
-		if (check_user_page_hwpoison(addr)) {
+		if (npages == -EHWPOISON ||
+			(!async && check_user_page_hwpoison(addr))) {
 			up_read(&current->mm->mmap_sem);
 			get_page(hwpoison_page);
 			return page_to_pfn(hwpoison_page);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
