Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59A566B039F
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:20:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j16so28450213pfk.4
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:20:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m2si23421245pgn.69.2017.04.13.02.20.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 02:20:20 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D9J3kT000588
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:20:20 -0400
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com [125.16.236.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29sw2am9ej-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:20:19 -0400
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 13 Apr 2017 14:50:16 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay08.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D9IqhN15728698
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 14:48:52 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D9KEEc010025
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 14:50:14 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/madvise: Move up the behavior parameter validation
Date: Thu, 13 Apr 2017 14:50:08 +0530
Message-Id: <20170413092008.5437-1-khandual@linux.vnet.ibm.com>
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
This applies on top of the other madvise clean up patch I sent
earlier this week https://patchwork.kernel.org/patch/9672095/

 mm/madvise.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index efd4721..3cb427a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -694,6 +694,8 @@ static int madvise_inject_error(int behavior,
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+	case MADV_SOFT_OFFLINE:
+	case MADV_HWPOISON:
 		return true;
 
 	default:
@@ -767,12 +769,13 @@ static int madvise_inject_error(int behavior,
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
