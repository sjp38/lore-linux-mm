Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 25AB56B006E
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 14:15:22 -0400 (EDT)
Received: by mail-yh0-f48.google.com with SMTP id v1so1939651yhn.35
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 11:15:21 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i25si25124475yhg.96.2014.10.21.11.15.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 11:15:21 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm, hugetlb: correct bit shift in hstate_sizelog
Date: Tue, 21 Oct 2014 14:15:07 -0400
Message-Id: <1413915307-20536-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, a.ryabinin@samsung.com, Sasha Levin <sasha.levin@oracle.com>

hstate_sizelog() would shift left an int rather than long, triggering
undefined behaviour and passing an incorrect value when the requested
page size was more than 4GB, thus breaking >4GB pages.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/hugetlb.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 65e12a2..57e0dfd 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -312,7 +312,8 @@ static inline struct hstate *hstate_sizelog(int page_size_log)
 {
 	if (!page_size_log)
 		return &default_hstate;
-	return size_to_hstate(1 << page_size_log);
+
+	return size_to_hstate(1UL << page_size_log);
 }
 
 static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
