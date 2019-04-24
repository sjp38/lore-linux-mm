Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3E14C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:41:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A2E621901
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:41:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="SjQbnkGd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A2E621901
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE5F36B026C; Wed, 24 Apr 2019 10:41:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBEEC6B026D; Wed, 24 Apr 2019 10:41:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD4186B026E; Wed, 24 Apr 2019 10:41:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A77CA6B026C
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:41:06 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z7so12264062pgc.1
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:41:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=h/zIEdT673coxAmqcLOdvNn7LQEBsd3ZjyeWaqFQPWg=;
        b=C1wNSy5gzhQyTNYTkj52we0E40Ueyt9DfFkR+fjnxmN+cxcAe21/6ndC6HHrKWrAAF
         b8ccrg7DvX1wEAVISEw1bIE98TvV9CMo6ksl6jgPfAAVhpxpvHcKkK4XIv1T8nxRtAdz
         4JyEFccxbxNC21O5GkBVP3DQybY8Qxi9yRg5N/0rIzVRiYpFY4/gT36+iIO0IsdMDxM/
         yJvRYLaEqHrtIei9e15JU8ZbeN9bw4/5I3ce8VhG8O0FNuSJnrfJwJTRSGjjMPLOi0nk
         W4qAJRHTiHpmi1uZG6ZQcUkdJ3vAGJFzUiCP9guswS0suK4EcmHXu55DRPMNuCoTpg3w
         SPqQ==
X-Gm-Message-State: APjAAAXpUSXCTEpb9hKXom9Bxgi0qMMS1VeEzxLg9lEGcBsBysGk8Jeh
	v5I4dJ6ECbkSJBHb9irhL+PbyvOYNnyPnG8ReAh+s8p7lxqcB/vDVUvedm/Qw7Hf3GQ0i1tvvH1
	3Oe8EAduZ160iySqKKr3g1Q31nL/EwXquki8VQUzsEiln+2DAb0JsdbspaANodyXqIw==
X-Received: by 2002:a63:5041:: with SMTP id q1mr7984945pgl.386.1556116866336;
        Wed, 24 Apr 2019 07:41:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpwvYiquQ5P6QPTonZQkmOZCLtZIfn1sbejIJ6hOLoKff+W1T6tdGZ49JZEkEXV9BVZuAR
X-Received: by 2002:a63:5041:: with SMTP id q1mr7984880pgl.386.1556116865451;
        Wed, 24 Apr 2019 07:41:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556116865; cv=none;
        d=google.com; s=arc-20160816;
        b=KnWV03GLKJz4rLWye8amME+3phHVGpOEiePHGZUEnWwa/BTenY9oXEvXAgC7V2yuaB
         Nn7OPKGHXazAtiklkgipFXwpMnDvDTVrKNQ+0S0uzhcs+CsF1NR/3sT3lg66WUIXjsP9
         no9JiKg+qqLwmBZlJbpt0SnAw3vm7RhmoJFZzTscEShD8RZhX5eu7Q89a2grAoEr9Ilh
         faiFsA9vy2N3bO6rPhG/EB2EfUHMtq2H4l6SQmaWplUDYBpTOc6GBRKLeqHaq1JBBwcG
         dYhr4BGLsz7lVPVBE0OHjLVmF+TDwtcLOSh+dxk492Yfj7E8nmtsz81vush4TkpuEJxA
         U4CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=h/zIEdT673coxAmqcLOdvNn7LQEBsd3ZjyeWaqFQPWg=;
        b=zFZHOySmAGSlgmPVcTIp6Yi4SpjVCTSlYvoHR8wAYH0W48WGqJjnQm4hl4UA4RWWV9
         K2Q8ANRiusqAf8faVD0kmLklKCBMWoFELgO+dV7lztAT8IC2E6qgpbhPN6u8sqqvN6jp
         PiNuQ5gUWphbP4Kt9MeZIyN50sRyIcyoNnyGsRS0lqcN4y7UFApTD79kTb0Wx+qm0znc
         yPYcLEEE7uvd78uImyb4AiXi8tvB5dA2N+Vtly/uwrlCw1ShXtgdK7Y1JbK2xCUE7oSo
         XYwPYB+aOTnrHeDrfrnnMBEUSEkTypbs7/H8N6TcTpucQT9QmC1bix8j2gj5sMD2tHRq
         IrVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=SjQbnkGd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z8si17975251pgf.593.2019.04.24.07.41.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:41:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=SjQbnkGd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9D65B21901;
	Wed, 24 Apr 2019 14:41:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556116865;
	bh=6FnYK8tpkJRKEBgCryFJbaQQAnR4mPdtoYBkDzoVrO4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=SjQbnkGdDG1SrTj//23LqzXDx8WVGcPDdOkkGrt6H40awj2SAEicv/mrj+U7xN5Ik
	 km8PplOZEgYsTiUHak/SOHGh5eYprHPqUXOWNOAEBeFysmIzCmy+Ul82wi/Rtk9vKO
	 0XUSjr2slodxaFYf5S3kK/07XbON51d7i2KVT8gk=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 45/52] hugetlbfs: fix memory leak for resv_map
Date: Wed, 24 Apr 2019 10:39:03 -0400
Message-Id: <20190424143911.28890-45-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190424143911.28890-1-sashal@kernel.org>
References: <20190424143911.28890-1-sashal@kernel.org>
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

