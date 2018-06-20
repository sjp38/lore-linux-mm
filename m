Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 937EB6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 07:09:35 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h26-v6so2623148itj.6
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 04:09:35 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id n22-v6si1540902ioh.147.2018.06.20.04.09.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 04:09:34 -0700 (PDT)
Date: Wed, 20 Jun 2018 14:09:21 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] hugetlbfs: Fix an error code in init_hugetlbfs_fs()
Message-ID: <20180620110921.2s4krw4zjbnfniq5@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, David Howells <dhowells@redhat.com>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org

We accidentally deleted the error code assignment.

Fixes: 9b82d88c136c ("hugetlbfs: Convert to fs_context")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 9a5c9fcf54f5..91fadca3c8e6 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -1482,8 +1482,10 @@ static int __init init_hugetlbfs_fs(void)
 	i = 0;
 	for_each_hstate(h) {
 		mnt = mount_one_hugetlbfs(h);
-		if (IS_ERR(mnt) && i == 0)
+		if (IS_ERR(mnt) && i == 0) {
+			error = PTR_ERR(mnt);
 			goto out;
+		}
 		hugetlbfs_vfsmount[i] = mnt;
 		i++;
 	}
