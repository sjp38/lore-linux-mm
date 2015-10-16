Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2D29882F68
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 18:15:43 -0400 (EDT)
Received: by oiao187 with SMTP id o187so14763208oia.3
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:15:43 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z8si11368933oes.74.2015.10.16.15.15.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 15:15:42 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/3] mm/hugetlb: Define hugetlb_falloc structure for hole punch race
Date: Fri, 16 Oct 2015 15:08:28 -0700
Message-Id: <1445033310-13155-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
References: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

A hugetlb_falloc structure is pointed to by i_private during fallocate
hole punch operations.  Page faults check this structure and if they are
in the hole, wait for the operation to finish.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 685c262..4be35b9 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -42,6 +42,16 @@ struct resv_map {
 extern struct resv_map *resv_map_alloc(void);
 void resv_map_release(struct kref *ref);
 
+/*
+ * hugetlb_falloc is used to prevent page faults during falloc hole punch
+ * operations.  During hole punch, inode->i_private points to this struct.
+ */
+struct hugetlb_falloc {
+	wait_queue_head_t *waitq;	/* Page faults waiting on hole punch */
+	pgoff_t start;			/* Start of fallocate hole */
+	pgoff_t end;			/* End of fallocate hole */
+};
+
 extern spinlock_t hugetlb_lock;
 extern int hugetlb_max_hstate __read_mostly;
 #define for_each_hstate(h) \
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
