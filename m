Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1DA6B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 05:57:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b80so28287933wme.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 02:57:29 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id j15si11177483wmd.88.2016.10.24.02.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 02:57:28 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id d128so8999809wmf.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 02:57:28 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH] mm: unexport __get_user_pages()
Date: Mon, 24 Oct 2016 10:57:25 +0100
Message-Id: <20161024095725.17229-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, Lorenzo Stoakes <lstoakes@gmail.com>

This patch unexports the low-level __get_user_pages() function. Recent
refactoring of the get_user_pages* functions allow flags to be passed through
get_user_pages() which eliminates the need for access to this function from its
one user, kvm.

We can see that the 2 calls to get_user_pages() which replace __get_user_pages()
in kvm_main.c are equivalent by examining their call stacks:

get_user_page_nowait():
  get_user_pages(start, 1, flags, page, NULL)
  __get_user_pages_locked(current, current->mm, start, 1, page, NULL, NULL,
			  false, flags | FOLL_TOUCH)
  __get_user_pages(current, current->mm, start, 1,
		   flags | FOLL_TOUCH | FOLL_GET, page, NULL, NULL)

check_user_page_hwpoison():
  get_user_pages(addr, 1, flags, NULL, NULL)
  __get_user_pages_locked(current, current->mm, addr, 1, NULL, NULL, NULL,
			  false, flags | FOLL_TOUCH)
  __get_user_pages(current, current->mm, addr, 1, flags | FOLL_TOUCH, NULL,
		   NULL, NULL)

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 include/linux/mm.h  |  4 ----
 mm/gup.c            |  3 +--
 mm/nommu.c          |  2 +-
 virt/kvm/kvm_main.c | 10 ++++------
 4 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3a19185..a92c8d7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1271,10 +1271,6 @@ extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *
 extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags);
 
-long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		      unsigned long start, unsigned long nr_pages,
-		      unsigned int foll_flags, struct page **pages,
-		      struct vm_area_struct **vmas, int *nonblocking);
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
diff --git a/mm/gup.c b/mm/gup.c
index 7aa113c..ec4f827 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -526,7 +526,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  * instead of __get_user_pages. __get_user_pages should be used only if
  * you need some special @gup_flags.
  */
-long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas, int *nonblocking)
@@ -631,7 +631,6 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	} while (nr_pages);
 	return i;
 }
-EXPORT_SYMBOL(__get_user_pages);
 
 bool vma_permits_fault(struct vm_area_struct *vma, unsigned int fault_flags)
 {
diff --git a/mm/nommu.c b/mm/nommu.c
index db5fd17..8b8faaf 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -109,7 +109,7 @@ unsigned int kobjsize(const void *objp)
 	return PAGE_SIZE << compound_order(page);
 }
 
-long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		      unsigned long start, unsigned long nr_pages,
 		      unsigned int foll_flags, struct page **pages,
 		      struct vm_area_struct **vmas, int *nonblocking)
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 28510e7..2907b7b 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1346,21 +1346,19 @@ unsigned long kvm_vcpu_gfn_to_hva_prot(struct kvm_vcpu *vcpu, gfn_t gfn, bool *w
 static int get_user_page_nowait(unsigned long start, int write,
 		struct page **page)
 {
-	int flags = FOLL_TOUCH | FOLL_NOWAIT | FOLL_HWPOISON | FOLL_GET;
+	int flags = FOLL_NOWAIT | FOLL_HWPOISON;
 
 	if (write)
 		flags |= FOLL_WRITE;
 
-	return __get_user_pages(current, current->mm, start, 1, flags, page,
-			NULL, NULL);
+	return get_user_pages(start, 1, flags, page, NULL);
 }
 
 static inline int check_user_page_hwpoison(unsigned long addr)
 {
-	int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
+	int rc, flags = FOLL_HWPOISON | FOLL_WRITE;
 
-	rc = __get_user_pages(current, current->mm, addr, 1,
-			      flags, NULL, NULL, NULL);
+	rc = get_user_pages(addr, 1, flags, NULL, NULL);
 	return rc == -EHWPOISON;
 }
 
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
