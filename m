Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 97D046B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:18:34 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id y10so3836463pdj.4
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:18:34 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id qm15si2153543pab.185.2014.05.09.08.18.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 08:18:33 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id v10so3857391pde.27
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:18:33 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] mm: use a irq-safe __mod_zone_page_state in mlocked_vma_newpage()
Date: Fri,  9 May 2014 23:17:48 +0800
Message-Id: <1399648668-17420-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com, mhocko@suse.cz, aarcange@redhat.com, hanpt@linux.vnet.ibm.com, mgorman@suse.de, oleg@redhat.com, cldu@marvell.com, fabf@skynet.be, sasha.levin@oracle.com, zhangyanfei@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

mlocked_vma_newpage() is only called in fault path by
page_add_new_anon_rmap(), which is called on a *new* page.
And such page is initially only visible via the pagetables, and the
pte is locked while calling page_add_new_anon_rmap(), so we could use
a irq-safe version of __mod_zone_page_state() here.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/internal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/internal.h b/mm/internal.h
index 07b6736..69079b1 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -196,7 +196,7 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
 		return 0;
 
 	if (!TestSetPageMlocked(page)) {
-		mod_zone_page_state(page_zone(page), NR_MLOCK,
+		__mod_zone_page_state(page_zone(page), NR_MLOCK,
 				    hpage_nr_pages(page));
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 	}
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
