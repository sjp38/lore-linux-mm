Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0796B0261
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:37 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id j7so3967993pgv.20
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o4si2849829pgf.8.2017.12.14.03.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:35 -0800 (PST)
Message-Id: <20171214113851.696839441@infradead.org>
Date: Thu, 14 Dec 2017 12:27:38 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 12/17] mm: Make populate_vma_page_range() available
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=mm--Make-populate_vma_page_range---available.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

From: Peter Zijlstra <peterz@infradead.org>

Make populate_vma_page_range() outside mm, so special mappings can be
populated in dup_mmap().

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/mm.h |    2 ++
 mm/internal.h      |    2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2159,6 +2159,8 @@ do_mmap_pgoff(struct file *file, unsigne
 }
 
 #ifdef CONFIG_MMU
+extern long populate_vma_page_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end, int *nonblocking);
 extern int __mm_populate(unsigned long addr, unsigned long len,
 			 int ignore_errors);
 static inline void mm_populate(unsigned long addr, unsigned long len)
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -284,8 +284,6 @@ void __vma_link_list(struct mm_struct *m
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
 
 #ifdef CONFIG_MMU
-extern long populate_vma_page_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end, int *nonblocking);
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 static inline void munlock_vma_pages_all(struct vm_area_struct *vma)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
