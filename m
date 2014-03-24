Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id E001C6B00AA
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 08:59:32 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id c11so3649452lbj.12
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:32 -0700 (PDT)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id 1si10170212lam.153.2014.03.24.05.59.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 05:59:31 -0700 (PDT)
Received: by mail-la0-f52.google.com with SMTP id ec20so3661902lab.11
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:30 -0700 (PDT)
Message-Id: <20140324125926.111035579@openvz.org>
Date: Mon, 24 Mar 2014 16:28:41 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 3/4] mm: Dont forget to save file map softdiry bit on unmap
References: <20140324122838.490106581@openvz.org>
Content-Disposition: inline; filename=mm-file-pte-softdirty-try_to_unmap_cluster
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: hughd@google.com, xemul@parallels.com, akpm@linux-foundation.org, gorcunov@openvz.org

pte_file_mksoft_dirty operates with argument passed by
a value and returns modified result thus need to assign
@ptfile here, otherwise it's nop operation which may lead
to lose of softdirty bit.

CC: Pavel Emelyanov <xemul@parallels.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 mm/rmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.git/mm/rmap.c
===================================================================
--- linux-2.6.git.orig/mm/rmap.c
+++ linux-2.6.git/mm/rmap.c
@@ -1339,7 +1339,7 @@ static int try_to_unmap_cluster(unsigned
 		if (page->index != linear_page_index(vma, address)) {
 			pte_t ptfile = pgoff_to_pte(page->index);
 			if (pte_soft_dirty(pteval))
-				pte_file_mksoft_dirty(ptfile);
+				ptfile = pte_file_mksoft_dirty(ptfile);
 			set_pte_at(mm, address, pte, ptfile);
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
