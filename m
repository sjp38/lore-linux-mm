Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id E2F256B00C1
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 08:59:33 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id q8so3702766lbi.0
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:33 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id q7si10191996lbw.8.2014.03.24.05.59.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 05:59:32 -0700 (PDT)
Received: by mail-la0-f50.google.com with SMTP id y1so3709912lam.9
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:31 -0700 (PDT)
Message-Id: <20140324125926.013008345@openvz.org>
Date: Mon, 24 Mar 2014 16:28:40 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 2/4] mm: Dont forget to set softdirty on file mapped fault
References: <20140324122838.490106581@openvz.org>
Content-Disposition: inline; filename=mm-file-pte-softdirty-on-fault
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: hughd@google.com, xemul@parallels.com, akpm@linux-foundation.org, gorcunov@openvz.org

Otherwise we may not notice that pte was softdirty.

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
@@ -3422,7 +3422,7 @@ static int __do_fault(struct mm_struct *
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		else if (pte_file(orig_pte) && pte_file_soft_dirty(orig_pte))
-			pte_mksoft_dirty(entry);
+			entry = pte_mksoft_dirty(entry);
 		if (anon) {
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
 			page_add_new_anon_rmap(page, vma, address);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
