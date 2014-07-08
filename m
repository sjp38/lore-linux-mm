Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id BB1D36B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 15:21:54 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id l4so4361675lbv.28
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 12:21:53 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id qf3si76477187lbb.64.2014.07.08.12.21.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 12:21:53 -0700 (PDT)
Received: by mail-la0-f47.google.com with SMTP id s18so4270929lam.20
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 12:21:53 -0700 (PDT)
Date: Tue, 8 Jul 2014 23:21:51 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH] mm: Don't forget to set softdirty on file mapped fault
Message-ID: <20140708192151.GD17860@moon.sw.swsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>

Otherwise we may not notice that pte was softdirty because pte_mksoft_dirty
helper _returns_ new pte but not modifies argument.

CC: Pavel Emelyanov <xemul@parallels.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.git/mm/memory.c
===================================================================
--- linux-2.6.git.orig/mm/memory.c
+++ linux-2.6.git/mm/memory.c
@@ -2744,7 +2744,7 @@ void do_set_pte(struct vm_area_struct *v
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 	else if (pte_file(*pte) && pte_file_soft_dirty(*pte))
-		pte_mksoft_dirty(entry);
+		entry = pte_mksoft_dirty(entry);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
