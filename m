Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB2886B6CFC
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 00:14:29 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id r11so6004371wmg.1
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 21:14:29 -0800 (PST)
Received: from delany.relativists.org (delany.relativists.org. [176.31.98.17])
        by mx.google.com with ESMTPS id p3si11245430wrf.163.2018.12.03.21.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Dec 2018 21:14:27 -0800 (PST)
From: =?UTF-8?q?Adeodato=20Sim=C3=B3?= <dato@net.com.org.es>
Subject: [PATCH 2/3] mm: move two private functions to static linkage
Date: Tue,  4 Dec 2018 02:14:23 -0300
Message-Id: <75cae66d92a074dbd62590a966d7005b187f4fe5.1543899764.git.dato@net.com.org.es>
In-Reply-To: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
References: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org

follow_page_context() and __thp_get_unmapped_area() have no public
declarations and are only used in the files that define them (mm/gup.c
and mm/huge_memory.c, respectively).

This change also appeases GCC if run with -Wmissing-prototypes.

Signed-off-by: Adeodato Simó <dato@net.com.org.es>
---
 mm/gup.c         | 6 +++---
 mm/huge_memory.c | 5 +++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6dd33e16a806..86a10a9b0344 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -399,9 +399,9 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
  * an error pointer if there is a mapping to something not represented
  * by a page descriptor (see also vm_normal_page()).
  */
-struct page *follow_page_mask(struct vm_area_struct *vma,
-			      unsigned long address, unsigned int flags,
-			      struct follow_page_context *ctx)
+static struct page *follow_page_mask(struct vm_area_struct *vma,
+				     unsigned long address, unsigned int flags,
+				     struct follow_page_context *ctx)
 {
 	pgd_t *pgd;
 	struct page *page;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2dba2c1c299a..45c1ff36baf1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -499,8 +499,9 @@ void prep_transhuge_page(struct page *page)
 	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
 }
 
-unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
-		loff_t off, unsigned long flags, unsigned long size)
+static unsigned long __thp_get_unmapped_area(struct file *filp,
+		unsigned long len, loff_t off, unsigned long flags,
+		unsigned long size)
 {
 	unsigned long addr;
 	loff_t off_end = off + len;
-- 
2.19.2
