Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8801628042A
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:44:16 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i74so1798952pgd.5
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 03:44:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n4si2618495pgc.281.2017.08.24.03.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 03:44:15 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7OAhfx3146348
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:44:14 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2chsxkn5yv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:44:14 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 24 Aug 2017 20:44:11 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v7OAgsia39387368
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 20:42:54 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v7OAgkDu011397
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 20:42:46 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] xfs: Drop setting redundant PF_KSWAPD in kswapd context
Date: Thu, 24 Aug 2017 16:12:47 +0530
Message-Id: <20170824104247.8288-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: dchinner@redhat.com, bfoster@redhat.com, sandeen@sandeen.net

xfs_btree_split() calls xfs_btree_split_worker() with args.kswapd set
if current->flags alrady has PF_KSWAPD. Hence we should not again add
PF_KSWAPD into the current flags inside kswapd context. So drop this
redundant flag addition.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 fs/xfs/libxfs/xfs_btree.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/xfs/libxfs/xfs_btree.c b/fs/xfs/libxfs/xfs_btree.c
index e0bcc4a..b3c85e3 100644
--- a/fs/xfs/libxfs/xfs_btree.c
+++ b/fs/xfs/libxfs/xfs_btree.c
@@ -2895,7 +2895,7 @@ struct xfs_btree_split_args {
 	 * in any way.
 	 */
 	if (args->kswapd)
-		new_pflags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
+		new_pflags |= PF_MEMALLOC | PF_SWAPWRITE;
 
 	current_set_flags_nested(&pflags, new_pflags);
 
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
