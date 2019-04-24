Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B327AC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:52:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5479B21907
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:52:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="p7SbhMCY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5479B21907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 085DB6B026B; Wed, 24 Apr 2019 10:52:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 035346B026C; Wed, 24 Apr 2019 10:52:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E41646B026F; Wed, 24 Apr 2019 10:52:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A73046B026B
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:52:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 132so12224221pgc.18
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:52:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=u90zZgerCi+bjebsXNO1aTHlM6va04ndO6E2r0jE54Q=;
        b=fwTyxlf3n2qq4MeCOjp8Eueh78rxUiCKlVJP9a8ggqypYKmF7u/L2Z0ZGaXYsfg5Az
         vfa3NavmV8H3BWIDjie0fNqk7SLAahGB2M2CkjLkOKyJ6zStLK0gU1WL6jmAfl/x3f4f
         dsE9VsGvLppScmlW7CMr98d3wFhOUlraJwV9ifY9Wm9CcIfJkVnjrPFngZRBAWf48mJc
         5hyJho8XfxE65TSIpGPEMu+7nXmtBTvnf8vt0tLOAiZX16gXKLBOhj9RcEoER3LAcGuR
         9T49/jhusCbxOSdPXmKL50FBW00bOcT7JuNyOyxYxcLILoyVllh869WSWbrd704k6QwN
         0rGw==
X-Gm-Message-State: APjAAAXIhVopUQL4SFK6214iOOC2DvWM6vZORoiR3slsrFTM3KAIrIyk
	yCDUXeZIrgdNDjDstpo0V1vdSH5coZvwmyCzVnZ3BTZa0fwISk1y0dzxegtjQC3R9sIux2dAd1D
	qm0M69wtj5WuLd6/uioWDTBWcEf2AZ9bu3mCOyM1BS4sbjlBuU1a2fak0AP3RD0CQtg==
X-Received: by 2002:a63:fc0b:: with SMTP id j11mr30545138pgi.74.1556117550339;
        Wed, 24 Apr 2019 07:52:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxX2i2zV811vKkvkVVpMWM03OjJyHjGHQy6m325w198cJgznHFX4HLQgU51mjLmyyAGUqi3
X-Received: by 2002:a63:fc0b:: with SMTP id j11mr30545103pgi.74.1556117549671;
        Wed, 24 Apr 2019 07:52:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556117549; cv=none;
        d=google.com; s=arc-20160816;
        b=b/F+52uTKtmDJWK82xOuNXldjEM1BIBmql++LkfLeK836CKtttvljyo5ThHNJA7OwF
         WaZIPXDjmi3/w07q50synRJHvaC5DGL+hhssLlueJpexFmUhhA8e5QzC2MrXlgo1IATg
         cReCsDUKGnZBzH2hND4ZIfLKdZb8mFqR3Oxo6plyVUAN/Aieardrs8ebMqacBozubFoj
         Y5sQ6MKSOdkyrXt8oOQT1AnKvkhKyFRqSJeWdpr7jjShsrKlzMhKfUK0odY3RrR4M3eM
         gjXjMXcBPhu6PuEt/e4r05u3ch1wRraQKnk/KqZgrYrvr22qIDjFIhrCyj4qNn4GfMmW
         uYAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=u90zZgerCi+bjebsXNO1aTHlM6va04ndO6E2r0jE54Q=;
        b=g4+FNk4UPbJLJdMfMjFMZv5wlMdQWwF9SO0oU3ZXbGjaFKbX+i+SUoRCC4A/eMhK0W
         yPO9T5x26qw8okcRp/tumcl2ZYt3Y6o0/PiNfRQY1ESZVIqmna9dF8sf/Eu3zXPLB2ko
         +Oj80+sLJ1Bg7fQGCVTE0NoMaSlsRK3ZWkfB+a9VqKyKrAZCQ74WpuUzcpjjZ271uHTy
         kCfh9jfq4qwOVC9Np2DBaONOUKzWLvIxTAIEGDCag7YU01d/G5yE0CZC0hY3Ca0j6iFi
         KSC1HbJMkSm6k1kteZWUJmWYLRnxjPP3A0C/KPtlleVcOH1gZA8r/Or5JwIlrtTpS7dV
         OXMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=p7SbhMCY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l62si19773773pfc.65.2019.04.24.07.52.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:52:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=p7SbhMCY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 699C2218FE;
	Wed, 24 Apr 2019 14:52:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556117549;
	bh=HUdHo3J9BCDfV6o4EOB0r6oGZt3+aBvAAtgAudEswSc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=p7SbhMCYh7+PDCUolyL3jDoLvEuvzDgRB2iZqa7fUMQoSr5v9mfB3mervjvEDhv5D
	 31e1kVQTSQ15fCGcNUNLVBibhikaGzIU+eyOplqd5EfyQDx1TCV6Q8iB/jFz4wArnY
	 NaYHlrzM82oKjO6UMqTETcgx6XVsOfEHb0oxOftE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.4 12/15] hugetlbfs: fix memory leak for resv_map
Date: Wed, 24 Apr 2019 10:51:49 -0400
Message-Id: <20190424145152.31351-12-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190424145152.31351-1-sashal@kernel.org>
References: <20190424145152.31351-1-sashal@kernel.org>
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
index cefae2350da5..27c4e2ac39a9 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -745,11 +745,17 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
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
@@ -790,8 +796,10 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
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

