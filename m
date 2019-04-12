Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78B1AC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 03:58:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBD1A2083E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 03:58:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBD1A2083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2411E6B000C; Thu, 11 Apr 2019 23:58:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CA6E6B026A; Thu, 11 Apr 2019 23:58:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 092F96B026B; Thu, 11 Apr 2019 23:58:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id C85596B000C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 23:58:31 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id c9so3936105oib.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 20:58:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=PM7FLMp8EK8vbJKy+33/z94n1cPGfqwTEyK+RHiQfa0=;
        b=JVdLic+ERos3rkPXCUrXUpQ3J9F0YE8Xs9TUxa0g2oTBufFFau2iZ2LUd+TCQmO4TK
         9Df5Flbsj118wSM8vB+ATr6sjIKnlUb7KjuLJkvOvs3+N9Hkrs2d82gBUMJ0WtyxNqDS
         D0+XnxbtSGw1KXteP7k2RSDxyJZUXNm53fypCFldYQkwDkeVLdpYJxzp9DPyX8ilKvKw
         P9LE9qGH592sbarnO+XyhsK55Gg+Ib+b8zLILHtNr/QQVtnLRFqKmQlaOiAS2rUT41/C
         kXf/1da1p+fdS8f9V36EvnKmvIAPKGL++blmFzyag08kFOFUoyadtlSj/QnpEptXn3CD
         jCjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAV6woqqFTvcZSQzdn/+w8HlS7K+7k/YzkUv5rW1SHLf9dkEv7E1
	xnY2e7F60u6hukfoyKuGbHyTFw5dMTIsln84yh052t2H+uXN3xJ9VyM6xeG0vlXGlYXVK7G1GWx
	m2ERUMvLPFH0Wo0Zc3U2ltyTGNm+mpLaTZOcWzBq1wuAqk8DByTjRCqREwbuPHEKDkA==
X-Received: by 2002:aca:b68a:: with SMTP id g132mr8744686oif.47.1555041511311;
        Thu, 11 Apr 2019 20:58:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRS3Gr8XsfG2hg/OuiRJEvFjxvjpCTGHUxBIbVLQQu2SW18SG3REX94PGOtQw2xmEMQdXH
X-Received: by 2002:aca:b68a:: with SMTP id g132mr8744637oif.47.1555041509882;
        Thu, 11 Apr 2019 20:58:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555041509; cv=none;
        d=google.com; s=arc-20160816;
        b=fqHL3coXgmOtlZiZ/03Hk1MYe30CFwudX6EsmMjo6yH7MMCKP306iKUmgNjS0zqVj4
         EKHlYKjbJxwEgdQQPQHiu9Eo97y6Y1xG6qWISjprKflHi+qmTIgyUIn/EbCWjtI+IkmX
         JInI/JL9ryY6m/SIAiQpfrtZs8fGdFeXjuYRBB0HyuLqXNLVRfK+7jNn9DYlgyHXdmWW
         kYLzcYsr5JGyvZuTZupWjl+oIaLCNmOUGki8ARuN+ZWePLFs8z/CoQ0a4GecI53Yxeyz
         WzKW2ken+7AofOxLJpsUMCebRn+6xAgLaaIZfcyB5i/ybUx+l4PLT9tiTueTNt4Y4Pwp
         l68g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=PM7FLMp8EK8vbJKy+33/z94n1cPGfqwTEyK+RHiQfa0=;
        b=tAQAlC4ghRX64lmJ2RdncOJCTexaazq7PBWhlNlxC05eqKbGJt7qc4TCAsyW7O2PXO
         DNn1gEPDEkuX7Yn7N6vi3aWDIlOzO/dGRUcTDahRTmdLHyARaGX3XS5H/c6iw6pt5JVb
         LgNUf3UkDtUUgbnIf2iEl1Gvohu7WPuVlTp1wUb6QgH+sQdVupydP4ql4eHLKkG5566M
         k8tFDd/zsL0/4aSAIIuS3mzqsx1Xwe03qKQtvZlfTZfzRMM6ETgWeNghC9uZ/GO70P1K
         tXYbZ6nrc0YiZrK5SmryH4jBp/H17OPDCtftT4zDX2Zpi8/obTfD1jUuOb9tH08jTWKd
         B+ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id t4si18149304oth.91.2019.04.11.20.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 20:58:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 109CC8F0EAB7FC385619;
	Fri, 12 Apr 2019 11:58:24 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.408.0; Fri, 12 Apr 2019
 11:58:18 +0800
From: Yufen Yu <yuyufen@huawei.com>
To: <mike.kravetz@oracle.com>, <linux-mm@kvack.org>
CC: <mhocko@kernel.org>, <n-horiguchi@ah.jp.nec.com>,
	<kirill.shutemov@linux.intel.com>, <yuyufen@huawei.com>
Subject: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
Date: Fri, 12 Apr 2019 12:02:40 +0800
Message-ID: <20190412040240.29861-1-yuyufen@huawei.com>
X-Mailer: git-send-email 2.16.2.dirty
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
fix memory leak for resv_map. It only allocate resv_map for inode mode
is 'S_ISREG' and 'S_ISLNK', avoiding i_mapping->private_data be set as
bdev_inode private_data.

However, for inode mode that is 'S_ISBLK', hugetlbfs_evict_inode() may
free or modify i_mapping->private_data that is owned by bdev inode,
which is not expected!

Fortunately, bdev filesystem have not actually use i_mapping->private_data.
Thus, this bug has not caused serious impact. But, we can not ensure
bdev will not use that field in the furture. And hugetlbfs should not
depend on bdev filesystem implementation.

We fix the problem by moving resv_map to hugetlbfs_inode_info. It may
be more reasonable.

Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Yufen Yu <yuyufen@huawei.com>
---
 fs/hugetlbfs/inode.c    | 11 ++++++++---
 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            |  2 +-
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 9285dd4f4b1c..f1342a3fa716 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -497,12 +497,15 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 static void hugetlbfs_evict_inode(struct inode *inode)
 {
 	struct resv_map *resv_map;
+	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
 
 	remove_inode_hugepages(inode, 0, LLONG_MAX);
-	resv_map = (struct resv_map *)inode->i_mapping->private_data;
+	resv_map = info->resv_map;
 	/* root inode doesn't have the resv_map, so we should check it */
-	if (resv_map)
+	if (resv_map) {
 		resv_map_release(&resv_map->refs);
+		info->resv_map = NULL;
+	}
 	clear_inode(inode);
 }
 
@@ -777,7 +780,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 				&hugetlbfs_i_mmap_rwsem_key);
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
-		inode->i_mapping->private_data = resv_map;
+		info->resv_map = resv_map;
 		info->seals = F_SEAL_SEAL;
 		switch (mode & S_IFMT) {
 		default:
@@ -1047,6 +1050,7 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
 	 * private inode.  This simplifies hugetlbfs_destroy_inode.
 	 */
 	mpol_shared_policy_init(&p->policy, NULL);
+	p->resv_map = NULL;
 
 	return &p->vfs_inode;
 }
@@ -1061,6 +1065,7 @@ static void hugetlbfs_destroy_inode(struct inode *inode)
 {
 	hugetlbfs_inc_free_inodes(HUGETLBFS_SB(inode->i_sb));
 	mpol_free_shared_policy(&HUGETLBFS_I(inode)->policy);
+	HUGETLBFS_I(inode)->resv_map = NULL;
 	call_rcu(&inode->i_rcu, hugetlbfs_i_callback);
 }
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 11943b60f208..584030631045 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -297,6 +297,7 @@ struct hugetlbfs_inode_info {
 	struct shared_policy policy;
 	struct inode vfs_inode;
 	unsigned int seals;
+	struct resv_map *resv_map;
 };
 
 static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index fe74f94e5327..a2648edffb02 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -740,7 +740,7 @@ void resv_map_release(struct kref *ref)
 
 static inline struct resv_map *inode_resv_map(struct inode *inode)
 {
-	return inode->i_mapping->private_data;
+	return HUGETLBFS_I(inode)->resv_map;
 }
 
 static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
-- 
2.16.2.dirty

