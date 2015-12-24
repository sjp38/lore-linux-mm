Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7490F82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 06:51:59 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 78so65672947pfw.2
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 03:51:59 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id y17si33421025pfa.150.2015.12.24.03.51.58
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 03:51:58 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] mm: stop __munlock_pagevec_fill() if THP enounted
Date: Thu, 24 Dec 2015 14:51:22 +0300
Message-Id: <1450957883-96356-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

THP is properly handled in munlock_vma_pages_range().

It fixes crashes like this:
 http://lkml.kernel.org/r/565C5C38.3040705@oracle.com

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mlock.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/mlock.c b/mm/mlock.c
index af421d8bd6da..9197b6721a1e 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -393,6 +393,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 		if (!page || page_zone_id(page) != zoneid)
 			break;
 
+		/*
+		 * Do not use pagevec for PTE-mapped THP,
+		 * munlock_vma_pages_range() will handle them.
+		 */
+		if (PageTransCompound(page))
+			break;
+
 		get_page(page);
 		/*
 		 * Increase the address that will be returned *before* the
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
