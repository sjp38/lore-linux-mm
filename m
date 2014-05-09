Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id AD7B06B0037
	for <linux-mm@kvack.org>; Fri,  9 May 2014 12:16:59 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so4638778pab.0
        for <linux-mm@kvack.org>; Fri, 09 May 2014 09:16:59 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ov9si2490355pbc.299.2014.05.09.09.16.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 09:16:58 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so4552869pab.12
        for <linux-mm@kvack.org>; Fri, 09 May 2014 09:16:58 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: Re: [PATCH] mm: use a irq-safe __mod_zone_page_state in mlocked_vma_newpage()
Date: Sat, 10 May 2014 00:16:48 +0800
Message-Id: <1399652208-18987-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, riel@redhat.com, minchan@kernel.org, zhangyanfei@cn.fujitsu.com, hanpt@linux.vnet.ibm.com, sasha.levin@oracle.com, oleg@redhat.com, fabf@skynet.be, mgorman@suse.de, aarcange@redhat.com, cldu@marvell.com, nasa4836@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

>You are changing from the irq safe variant to __mod_zone_page_state which
>is *not* irq safe. Its legit to do so since presumably irqs are disabled
>anyways so you do not have to worry about irq safeness of
>__mod_zone_page_state.

>Please update the description. Its a bit confusing right now.

Hi, Christoph, I'm sorry for the misleading phrasing. 
Would be this one OK? Thanks.

--------<8---------
mm: use a light-weight __mod_zone_page_state in mlocked_vma_newpage()

mlocked_vma_newpage() is only called in fault path by
page_add_new_anon_rmap(), which is called on a *new* page.
And such page is initially only visible via the pagetables, and the
pte is locked while calling page_add_new_anon_rmap(), so we need not
use an irq-safe mod_zone_page_state() here, using a light-weight version
__mod_zone_page_state() would be OK.

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
