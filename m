Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6651EC282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:36:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AD5E21903
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:36:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="dB504dg3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AD5E21903
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C1476B0006; Wed, 24 Apr 2019 10:36:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C9746B0007; Wed, 24 Apr 2019 10:36:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B9AB6B0008; Wed, 24 Apr 2019 10:36:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5E116B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:36:04 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d10so12527069plo.12
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:36:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BHyL9YYDMtS6RxskTv3KPf+/shPOb0Unhx9LMpKAfeY=;
        b=lbrhrgKXE5s+yJjmRdjLElLz2HuR/CDKbiGCSpfo0xCCtCHyl7d6wyjwNuyK/Sv0Oq
         PDdyUqSOHCFPquqMeRA9UohB90kPvljwxCUEcVk+efsiW6sOKhqYc6aV4BcnK73c5W4V
         4gx3DLNuYL2jYSFFZJR0lNbcWIxjXcBLKgO9RcN+z3f4LCmRgqQ+C1fuw/FQ+y65o3Rz
         f3sM//P3feHzs5/BcBCi3MQl/Zjo0mQlToJPrBNrR1OlKcNFESP/bWLXCtgSMxuYQw6p
         IF3gUMeIJuxf4Pbl7pzV8SZOkmYNJTzizSEqfONVi0zd4AuzMq0oUZ5RubUgDYZ5dB0g
         CyKw==
X-Gm-Message-State: APjAAAVpDuK2Vy5wky1kS1Lv1iI79C1d+QQPOKBgXNsvctfXYCCZJ1nF
	aDYjrvEhDafBfsSp5z9d3RbOe8D8sITRwnuQf9tHGDrHoGE33XJugzFYTplMDUgJPHuoBxAc2qG
	WYqXg8JK1r2jfO8ZZTYzqAu/pPDmOKkPmqltBz6/VC7V5xElQvYJIzVERV1UFCt/PEQ==
X-Received: by 2002:a17:902:bb84:: with SMTP id m4mr31810042pls.302.1556116564399;
        Wed, 24 Apr 2019 07:36:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOPVcMpPqg7VYr+URwGHdhlOBqb/TZpd+84LI8og4/bDSChAHcwYyJ8BFHnkVisNEtKZqD
X-Received: by 2002:a17:902:bb84:: with SMTP id m4mr31809964pls.302.1556116563579;
        Wed, 24 Apr 2019 07:36:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556116563; cv=none;
        d=google.com; s=arc-20160816;
        b=GwsWJswLFjoYlxMRnDZRQjIkThbdVqs2KDXuPwlXqM0HuzMUa7GYv/GBOWxfpc52BQ
         fajJ9ztuks4g6nhzlRB+YFzDFkS+jVdZ2dL9tngs/ykacv1fZvTpcngiA50dm9arjhGJ
         crUGdXqQf6Zrn26zYHQhASVCbbkOM6VxgLXm3XqE9XBAun2hyCQgT2h/ZRe7nUNB5Bdk
         g4uVd4DjVhjcZk7+9zsOnbncI68I+31b1K2rrcqOx+uV8BwIbqvJykgoDLZsuj2rK/T2
         GAfa58vRLaQw8AGX/Cor2odEVxN8dd6ysv/WOWz1My7vdrWoFTT9lYtlLGKVnKsSwo3K
         woeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BHyL9YYDMtS6RxskTv3KPf+/shPOb0Unhx9LMpKAfeY=;
        b=YPAo7d+S5lMNYQHjsuTuLmtPZSgjhRLiADO9AKs6H5W0HB2zst2i0EiEuk4DX6YCAT
         YUtYMJHs2X1p48ORaUZ/pzuP9zqh7tKVN4yTITMBTag/7AwXjhnxL6EfF7r11+sh0oIB
         GTT7sEJvOWJyuTHTa7Gk11at1HgjlxL5SjqaCQJ292+KhLfFKnTOKeLg7OmAKFpR0tA1
         NmiCZS7oo61365wCojWrr9GvYDJ2gDT9DFfW3GjjW8mslcrTQhQ7yWXTF+FiDw0scbIS
         y0SvKkVAaYx98F67IqE/YoFnmO2tt4tSLQsYFVUgLNoDd/EjSRdPr6nL97c6MCgzSEeO
         aBpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dB504dg3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p32si8080179pgm.310.2019.04.24.07.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:36:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dB504dg3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C64F021900;
	Wed, 24 Apr 2019 14:36:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556116563;
	bh=KCtQ4vM7xnsR0gwT4PZu2oJCOSK0CL094Z94E2MGvkI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=dB504dg3VsEefptg8AmA1KzJF1rtBYTuORjRlP7AifEyHIMCEInrKGN5ZBRzw/xst
	 SDbZ7Lj8pRMhkA21567YoSIDCqZ6Af6YQyh5nTnNxpIiPaHpcmRIPCbDIHAb1UfP/y
	 /7q2JhfmtDtIelf+9/3aL4dK5loWphZbsQ4h3zOo=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 54/66] hugetlbfs: fix memory leak for resv_map
Date: Wed, 24 Apr 2019 10:33:28 -0400
Message-Id: <20190424143341.27665-54-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190424143341.27665-1-sashal@kernel.org>
References: <20190424143341.27665-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mike Kravetz <mike.kravetz@oracle.com>

[ Upstream commit 58b6e5e8f1addd44583d61b0a03c0f5519527e35 ]

When mknod is used to create a block special file in hugetlbfs, it will
allocate an inode and kmalloc a 'struct resv_map' via resv_map_alloc().
inode->i_mapping->private_data will point the newly allocated resv_map.
However, when the device special file is opened bd_acquire() will set
inode->i_mapping to bd_inode->i_mapping.  Thus the pointer to the
allocated resv_map is lost and the structure is leaked.

Programs to reproduce:
        mount -t hugetlbfs nodev hugetlbfs
        mknod hugetlbfs/dev b 0 0
        exec 30<> hugetlbfs/dev
        umount hugetlbfs/

resv_map structures are only needed for inodes which can have associated
page allocations.  To fix the leak, only allocate resv_map for those
inodes which could possibly be associated with page allocations.

Link: http://lkml.kernel.org/r/20190401213101.16476-1-mike.kravetz@oracle.com
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Reported-by: Yufen Yu <yuyufen@huawei.com>
Suggested-by: Yufen Yu <yuyufen@huawei.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin (Microsoft) <sashal@kernel.org>
---
 fs/hugetlbfs/inode.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a7fa037b876b..a3a3d256fb0e 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -741,11 +741,17 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 					umode_t mode, dev_t dev)
 {
 	struct inode *inode;
-	struct resv_map *resv_map;
+	struct resv_map *resv_map = NULL;
 
-	resv_map = resv_map_alloc();
-	if (!resv_map)
-		return NULL;
+	/*
+	 * Reserve maps are only needed for inodes that can have associated
+	 * page allocations.
+	 */
+	if (S_ISREG(mode) || S_ISLNK(mode)) {
+		resv_map = resv_map_alloc();
+		if (!resv_map)
+			return NULL;
+	}
 
 	inode = new_inode(sb);
 	if (inode) {
@@ -780,8 +786,10 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 			break;
 		}
 		lockdep_annotate_inode_mutex_key(inode);
-	} else
-		kref_put(&resv_map->refs, resv_map_release);
+	} else {
+		if (resv_map)
+			kref_put(&resv_map->refs, resv_map_release);
+	}
 
 	return inode;
 }
-- 
2.19.1

