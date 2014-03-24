Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id A2B556B00AF
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 08:59:32 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id mc6so3566988lab.41
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:31 -0700 (PDT)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id g7si10187835lab.40.2014.03.24.05.59.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 05:59:30 -0700 (PDT)
Received: by mail-lb0-f169.google.com with SMTP id q8so3711356lbi.28
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:29 -0700 (PDT)
Message-Id: <20140324125925.911631019@openvz.org>
Date: Mon, 24 Mar 2014 16:28:39 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 1/4] mm: Make freshly remapped file pages being softdirty unconditionally
References: <20140324122838.490106581@openvz.org>
Content-Disposition: inline; filename=mm-file-pte-softdirty-update-2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: hughd@google.com, xemul@parallels.com, akpm@linux-foundation.org, gorcunov@openvz.org

Hugh reported:

 | I noticed your soft_dirty work in install_file_pte(): which looked
 | good at first, until I realized that it's propagating the soft_dirty
 | of a pte it's about to zap completely, to the unrelated entry it's
 | about to insert in its place.  Which seems very odd to me.

Indeed this code ends up being nop in result -- pte_file_mksoft_dirty()
operates with pte_t argument and returns new pte_t which were never
used after. After looking more I think what we need is to soft-dirtify
all newely remapped file pages because it should look like a new mapping
for memory tracker.

Reported-by: Hugh Dickins <hughd@google.com>
CC: Pavel Emelyanov <xemul@parallels.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 mm/fremap.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

Index: linux-2.6.git/mm/fremap.c
===================================================================
--- linux-2.6.git.orig/mm/fremap.c
+++ linux-2.6.git/mm/fremap.c
@@ -66,13 +66,10 @@ static int install_file_pte(struct mm_st
 
 	ptfile = pgoff_to_pte(pgoff);
 
-	if (!pte_none(*pte)) {
-		if (pte_present(*pte) && pte_soft_dirty(*pte))
-			pte_file_mksoft_dirty(ptfile);
+	if (!pte_none(*pte))
 		zap_pte(mm, vma, addr, pte);
-	}
 
-	set_pte_at(mm, addr, pte, ptfile);
+	set_pte_at(mm, addr, pte, pte_file_mksoft_dirty(ptfile));
 	/*
 	 * We don't need to run update_mmu_cache() here because the "file pte"
 	 * being installed by install_file_pte() is not a real pte - it's a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
