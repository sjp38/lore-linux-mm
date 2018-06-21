Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEFC96B0006
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 19:16:17 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n20-v6so222030pgv.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 16:16:17 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id q2-v6si5857757plh.136.2018.06.21.16.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 16:16:16 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v2 PATCH 2/2] mm: thp: inc counter for collapsed shmem THP
Date: Fri, 22 Jun 2018 07:15:49 +0800
Message-Id: <1529622949-75504-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1529622949-75504-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1529622949-75504-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

/sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed is used
to record the counter of collapsed THP, but it just gets inc'ed in
anonymous THP collapse path, do this for shmem THP collapse too.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
v1 --> v2:
* Seperate from the previous patch per Kirill's comment

 mm/khugepaged.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 9b0ec30..4018826 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1521,6 +1521,8 @@ static void collapse_shmem(struct mm_struct *mm,
 		unlock_page(new_page);
 
 		*hpage = NULL;
+
+		khugepaged_pages_collapsed++;
 	} else {
 		/* Something went wrong: rollback changes to the radix-tree */
 		shmem_uncharge(mapping->host, nr_none);
-- 
1.8.3.1
