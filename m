Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B13B6B0397
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 01:29:48 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a80so17698900wrc.19
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 22:29:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 64si2166497wrn.189.2017.04.17.22.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 22:29:46 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3I5SXQu002406
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 01:29:45 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29w2e9mc7a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 01:29:44 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 18 Apr 2017 15:29:42 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3I5TVOf40370362
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 15:29:39 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3I5T6qF029899
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 15:29:06 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V3] mm/madvise: Move up the behavior parameter validation
Date: Tue, 18 Apr 2017 10:58:44 +0530
In-Reply-To: <20170413092008.5437-1-khandual@linux.vnet.ibm.com>
References: <20170413092008.5437-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170418052844.24891-1-khandual@linux.vnet.ibm.com>
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
Changes in V3:

Moved the madvise_inject_error() function down which will make
sure that the boundary conditions are checked for address and
length arguments as per Naoya.

Changes in V2:

Added CONFIG_MEMORY_FAILURE check before using MADV_SOFT_OFFLINE
and MADV_HWPOISONE constants.

 mm/madvise.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index efd4721..721dd6f 100644
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
@@ -767,10 +771,6 @@ static int madvise_inject_error(int behavior,
 	size_t len;
 	struct blk_plug plug;
 
-#ifdef CONFIG_MEMORY_FAILURE
-	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
-		return madvise_inject_error(behavior, start, start + len_in);
-#endif
 	if (!madvise_behavior_valid(behavior))
 		return error;
 
@@ -790,6 +790,11 @@ static int madvise_inject_error(int behavior,
 	if (end == start)
 		return error;
 
+#ifdef CONFIG_MEMORY_FAILURE
+	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
+		return madvise_inject_error(behavior, start, start + len_in);
+#endif
+
 	write = madvise_need_mmap_write(behavior);
 	if (write) {
 		if (down_write_killable(&current->mm->mmap_sem))
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
