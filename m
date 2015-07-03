Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id E615C280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 08:46:21 -0400 (EDT)
Received: by wguu7 with SMTP id u7so87654106wgu.3
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 05:46:21 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id qg11si15003215wic.73.2015.07.03.05.46.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jul 2015 05:46:20 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 3 Jul 2015 13:46:19 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4B06B1B0806B
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 13:47:25 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t63CkG0w38273138
	for <linux-mm@kvack.org>; Fri, 3 Jul 2015 12:46:16 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t63CkFSA020118
	for <linux-mm@kvack.org>; Fri, 3 Jul 2015 06:46:16 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 3/4] mm: hugetlb: allow hugepages_supported to be architecture specific
Date: Fri,  3 Jul 2015 14:46:08 +0200
Message-Id: <1435927569-41132-4-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1435927569-41132-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1435927569-41132-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>

s390 has a constant hugepage size, by setting HPAGE_SHIFT we also
change e.g. the pageblock_order, which should be independent in
respect to hugepage support.

With this patch every architecture is free to define how to check
for hugepage support.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2050261..d891f94 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -460,15 +460,14 @@ static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
 	return &mm->page_table_lock;
 }
 
-static inline bool hugepages_supported(void)
-{
-	/*
-	 * Some platform decide whether they support huge pages at boot
-	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
-	 * there is no such support
-	 */
-	return HPAGE_SHIFT != 0;
-}
+#ifndef hugepages_supported
+/*
+ * Some platform decide whether they support huge pages at boot
+ * time. Some of them, such as powerpc, set HPAGE_SHIFT to 0
+ * when there is no such support
+ */
+#define hugepages_supported() (HPAGE_SHIFT != 0)
+#endif
 
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
-- 
2.3.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
