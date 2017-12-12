Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A17456B026A
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:54 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g80so12518071wrd.17
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:54 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 16si37296wmg.239.2017.12.12.09.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:53 -0800 (PST)
Message-Id: <20171212173334.002013487@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:30 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 09/16] mm: Make populate_vma_page_range() available
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=mm--Make-populate_vma_page_range---available.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

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
