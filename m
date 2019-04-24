Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B9BBC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:53:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADDBA218FE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:53:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="cah+1d0+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADDBA218FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 344E06B026C; Wed, 24 Apr 2019 10:53:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F42D6B026F; Wed, 24 Apr 2019 10:53:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E42E6B0270; Wed, 24 Apr 2019 10:53:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D78E96B026C
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:53:20 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j12so5684731pgl.14
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:53:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X23kYwFYN72sZ/t5AL1U24e82G/KhEx25JzfWrg1dFY=;
        b=ejQyT2pLbtnhqiwDSdl9LvSHdWqoSdBE6ut8aMYc3QVZpnttunWzAMiYYpJZ6B3HiO
         fDS/BvSU9wZVb+2P2BWHJs4yMr7xxR8qfD4DLM4LpEBUEpFVd5KgRh1R+Iy9V4bXo6yH
         N8+6l39nIgG3cr+mpBRpACKYhN8g6Xv7ONxlUZ9hvlwUnVCDo8gPmTEBBgj0DOhwVfDm
         +tvX8wOLL7SFUtFw8I9cUSVXUuO6ytI55pumKZHVtG+LrkRmTARPqEzXBFPVwbR84x+L
         Ks+BaWUHs/L+3OzhfPzBaRaPCLGCxATmGMwGGQVxzw3b6sKV1O6nRJ5HgM0r/E3eDVZR
         GQVQ==
X-Gm-Message-State: APjAAAVaeEihLfItF6TuF0E2qnDOH8xian3R0JeE2P69gtNqyFb8eG1G
	EZmt8o2X3m2ZRPPHTOHI/TI8R4R5YAf0FJ5tDVft79ehLVnbYYhLGeoLBNtTEajo7Lk4ChkyhXC
	wXzeiNHYvXrJ9MNb3yjHtpBtvTRk1d4HTsh0qKeV9Naz2nFXCXk1D1ktO7E+HaY12Yw==
X-Received: by 2002:a62:ac08:: with SMTP id v8mr35078586pfe.42.1556117600519;
        Wed, 24 Apr 2019 07:53:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC5HNpASarfDX6/jlCZQERPrtqDhKJLvzRDKc97pWzYa0pZLoIjk2ZwtvWsGnuEMY0Blbh
X-Received: by 2002:a62:ac08:: with SMTP id v8mr35078528pfe.42.1556117599729;
        Wed, 24 Apr 2019 07:53:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556117599; cv=none;
        d=google.com; s=arc-20160816;
        b=iUx0Cti5balUi15d7JjmlkG2goIWB05XsibfAfTeMy1OAmzMESPXagNk2PLtZ/OG1C
         18m/5GwE+VRBeif0lMJRr+MZzUASem+Z7Tq6706AJpDLmySaufRIhwAmuz+O5UltMMP1
         4hKsUmfCQKlVRENitC7ee6b/cE2s1N9GTseKou0xKTE/0gTL+QY35X2l1lFP3KPC6TiR
         qR/D4NHXHLosXmBTi/w0j7CiWBH3d97Wr/xYKwW4TS9TRrBqnrqzgJpxDfy+n5R8UiXb
         qd7A1f3G57ECwpwUXuWUKG19yaOSO5NhBd3Nmw1DZQSI7X/EvP9/qMaZ/mhoXP7jFGqj
         pzCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=X23kYwFYN72sZ/t5AL1U24e82G/KhEx25JzfWrg1dFY=;
        b=kyd3/80qYOCirSu3e62Q03U1cYRDaft0rWVz62LC/aSmLdS2n86OGvOxc4H+rchvEf
         bUQo2pQetYvXKvzcGdkwnFUFmbOrnN6HIV4F0Ca9jn9sRh0zM9+wMRHrgf8QDjjODVtF
         mQ32CFSTB5sTtKqkC1EaAJymPMLmVmYz1eSi1Dw7nmwJ1OD1zP390533ZQcDp0XHZ7fX
         OG59fuHbYZDVnSL7WuHXL1g0Wqaajmow/StpAgnFybZsubjF0SBYFzP3cx8a0unh+3zs
         ygOquLhEqvbfmavLgcQqKumkM4lKcJmA858xGoiOoKQ/FWUNhL/vzlkyRgzF7PxQsAPO
         mKCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cah+1d0+;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k9si18864204pfo.173.2019.04.24.07.53.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:53:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cah+1d0+;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4342B21903;
	Wed, 24 Apr 2019 14:53:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556117599;
	bh=k6s6SPrZ+cpDv9wyl8UcPCxG02ovHVKjVxP7dVfr3pk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=cah+1d0+oBMT1MwF7EOoiTyWCDDrxcBJ88Wgea5vDTRKLRDapucTephYVNeRC0u5f
	 zPdS5xOHjsQ3YsjfjEQXVzDqJVPmJiYJOBJUHUyfzqP5pSroeoRjgRURSzQ225CcWJ
	 ZW8wUhTnbaf2JmnGeCODoKTjK5snkiKlxWoHIIzA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 3.18 07/10] hugetlbfs: fix memory leak for resv_map
Date: Wed, 24 Apr 2019 10:52:56 -0400
Message-Id: <20190424145259.31639-7-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190424145259.31639-1-sashal@kernel.org>
References: <20190424145259.31639-1-sashal@kernel.org>
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
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/hugetlbfs/inode.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index ec1ed7e4b8f3..c3a03f5a1b49 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -484,11 +484,17 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
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
@@ -530,8 +536,10 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
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

