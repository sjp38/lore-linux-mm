Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 979CA6B025D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 17:54:43 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so3814180qkd.3
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 14:54:43 -0700 (PDT)
Received: from mail.catern.com (catern.com. [104.131.201.120])
        by mx.google.com with ESMTPS id k14si7471108qhk.127.2015.07.23.14.54.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 14:54:42 -0700 (PDT)
From: Spencer Baugh <sbaugh@catern.com>
Subject: [PATCH] hugetlb: cond_resched for set_max_huge_pages and follow_hugetlb_page
Date: Thu, 23 Jul 2015 14:54:31 -0700
Message-Id: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>
Cc: Joern Engel <joern@purestorage.com>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>, Spencer Baugh <sbaugh@catern.com>

From: Joern Engel <joern@logfs.org>

~150ms scheduler latency for both observed in the wild.

Signed-off-by: Joern Engel <joern@logfs.org>
Signed-off-by: Spencer Baugh <sbaugh@catern.com>
---
 mm/hugetlb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a8c3087..2eb6919 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1836,6 +1836,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
 		else
 			ret = alloc_fresh_huge_page(h, nodes_allowed);
+		cond_resched();
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
@@ -3521,6 +3522,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				spin_unlock(ptl);
 			ret = hugetlb_fault(mm, vma, vaddr,
 				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
+			cond_resched();
 			if (!(ret & VM_FAULT_ERROR))
 				continue;
 
-- 
2.5.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
