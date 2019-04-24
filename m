Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5992EC282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:51:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EDC42190C
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:51:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0i7YU/SR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EDC42190C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4C876B026B; Wed, 24 Apr 2019 10:51:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D33C6B026C; Wed, 24 Apr 2019 10:51:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 874676B026F; Wed, 24 Apr 2019 10:51:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2D56B026B
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:51:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b37so7704122pgl.19
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:51:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F1W3PQ/xWZLZN7vG28FtQK6gkAE1MyhT2wspVEUeKY8=;
        b=IL7RjequnTYuvy8W5CeMAmYdZArtBWnZyUmB4DpitSCOt+kRbf8gUf1y+N/hzwutcv
         2HCNBHxBgwpxNQZMrXDH4K7Za8GExIN0Ui4a2KJCtADWzve1bUhfx0CxJkLgOrK2nQPC
         0wQC1QbF6LIZ9cjHsnawTpsb4SbrSLZxRwRjiZyFpSttW8wyGGuIDyfkFjEXObFevEdq
         w5MNzbe8QL9ZKFHtiEt3duR8guzX2HpznTVHcSBrONImVqKauspBiXPy3Tg7sLCK1g63
         y1pW30cIw65gs0HVg3nSpsq8bMJ+aWDjT+s+PX0QIWoDfdGlXFmIIC/Fpepfb1VUSozs
         Ihpw==
X-Gm-Message-State: APjAAAWhKQxnCagAvnCscFY/rPyVwFV78MvMTN0oC7SoeiWpYWl2/OAH
	p4PlCLMrKQm/b3KneKWlZpRn9uptVdXdUSWFPw6u94r+Lvmrb+IhfpiRZxSBKne6SeZoeSCzQc/
	wn1U6JRZaZI7Oa4QQs1sJv8o9+TJ3m5qjXHB5vpdg3EeOYQKcYHgjh55vyMElO7OnyQ==
X-Received: by 2002:a65:5009:: with SMTP id f9mr30832306pgo.390.1556117477870;
        Wed, 24 Apr 2019 07:51:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLf+nkd3Qs8fiCimr9n1BIwYorBME7bVZWtBgBt4nBkiN3tpuCytuGub4puE3+Fi0QPxnV
X-Received: by 2002:a65:5009:: with SMTP id f9mr30832261pgo.390.1556117477057;
        Wed, 24 Apr 2019 07:51:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556117477; cv=none;
        d=google.com; s=arc-20160816;
        b=ShTmxZjiSBJw0qMUIlLmuJZZL/tOCuFPex3Z152sXWJ+t9z96zz76k4hzPd3t61Jqq
         WbuK1ZW2D5iRuKMqbdTJJYLkHqq5kczPHa8nOEOKl7pvIZkWPIwpSjCG0h6QOi6dVEyC
         wGvLfD3s+t0drnTqF4iPy8XF9mOzbx7mxvmAenwHaViUH78KC55kzr4ooqSDh51HSJ35
         s5NRqggBQ6aVVuJI0LOp0Q+hVWYqAef2H6QEOFFT0/k7ptM+y5hEpIszVxmyIz7C//4J
         860RKdh2viX50x3Oqau37LXQQbRx/g+BlSoOnQxbtw5P7leCeKhy12u/In+LAkrts4xZ
         ui7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=F1W3PQ/xWZLZN7vG28FtQK6gkAE1MyhT2wspVEUeKY8=;
        b=JODTNkSQDz7WFilVJ+pLPEK1aIp8hGvx7ZuTtnbw28JiIiwxDqSCXEd3/zZ1E5xBK8
         5i9QFXKGfVnCuVNvJCDwuBzYuFKf5pUDA2mV8njKdyzgOW3nq0VxZYzVFNXrdVFPcS/Q
         q+oWElnHkHGknQNZEIoEyPIQctUxa89rC/bU1V68cfHkPPeIZwptCIxoQfuxbwsdZKMm
         km/VslQfrSmMLUV2v+8rDY9i404wkp281FblU92bSuAmHhtKd3Ez+n+omZwbbMoEyzmB
         knIhyFxIgHrXW6tTzGAoUuOLn12WFm52dXqji1byQ9w3TmMjd4hrnw3IeDrzWaeAkV8I
         np3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="0i7YU/SR";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f18si18390378pgg.361.2019.04.24.07.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:51:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="0i7YU/SR";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E219B218FD;
	Wed, 24 Apr 2019 14:51:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556117476;
	bh=33Gn4RX9w7PnpKe/p7WdD26A51nQUhczgLDGa3vcGas=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=0i7YU/SRfgA4e0ZNavooxrPGI4VLQomXOnQzD6OweQ1MW1HaQ/bMGm0xMQpJ9qgIC
	 6JeAEMz4YZpC7F6NKQExcsjzV3hz3xkddzZArCBSaRoq+LdlKIMG526UU7sOOvtGhh
	 YMWQdjNU9rD34vmlmNSKt7heeqDHBLLRld34+Q04=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 23/28] hugetlbfs: fix memory leak for resv_map
Date: Wed, 24 Apr 2019 10:50:07 -0400
Message-Id: <20190424145012.30886-23-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190424145012.30886-1-sashal@kernel.org>
References: <20190424145012.30886-1-sashal@kernel.org>
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
index 001487b230b5..4acc677ac8fb 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -746,11 +746,17 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
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
@@ -782,8 +788,10 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
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

