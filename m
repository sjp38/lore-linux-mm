Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27F886B0397
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 09:52:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s15so46772253pfi.1
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 06:52:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f22si2085517plk.264.2017.04.14.06.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 06:52:48 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3EDi2EU051442
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 09:52:48 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29tw55nvuk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 09:52:47 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 14 Apr 2017 23:52:45 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3EDqYkb21823648
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 23:52:42 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3EDqA9l023055
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 23:52:10 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V2] mm/madvise: Move up the behavior parameter validation
Date: Fri, 14 Apr 2017 19:21:41 +0530
In-Reply-To: <20170413092008.5437-1-khandual@linux.vnet.ibm.com>
References: <20170413092008.5437-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170414135141.15340-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org

The madvise_behavior_valid() function should be called before
acting upon the behavior parameter. Hence move up the function.
This also includes MADV_SOFT_OFFLINE and MADV_HWPOISON options
as valid behavior parameter for the system call madvise().

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Changes in V2:

Added CONFIG_MEMORY_FAILURE check before using MADV_SOFT_OFFLINE
and MADV_HWPOISONE constants.

 mm/madvise.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index efd4721..ccff186 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -694,6 +694,10 @@ static int madvise_inject_error(int behavior,
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+#ifdef CONFIG_MEMORY_FAILURE
+	case MADV_SOFT_OFFLINE:
+	case MADV_HWPOISON:
+#endif
 		return true;
 
 	default:
@@ -767,12 +771,13 @@ static int madvise_inject_error(int behavior,
 	size_t len;
 	struct blk_plug plug;
 
+	if (!madvise_behavior_valid(behavior))
+		return error;
+
 #ifdef CONFIG_MEMORY_FAILURE
 	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
 		return madvise_inject_error(behavior, start, start + len_in);
 #endif
-	if (!madvise_behavior_valid(behavior))
-		return error;
 
 	if (start & ~PAGE_MASK)
 		return error;
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
