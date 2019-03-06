Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDF18C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 06:06:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4394620652
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 06:06:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4394620652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE8DF8E0004; Wed,  6 Mar 2019 01:06:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A95118E0001; Wed,  6 Mar 2019 01:06:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D1B38E0004; Wed,  6 Mar 2019 01:06:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8678E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 01:06:00 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id 202so6171739vkv.11
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 22:06:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:mime-version;
        bh=zKmOhBghltAUYaHuAeFS+OtF/FieaDr0jFkVOQWl1sM=;
        b=e/YgQgzzLlQHyRdnsARUzpZCzKcxt1x+Pgn+A7Cuu+8rTv3k7dP+5TFrsg9TCho4V6
         MIrsNl4r3NRrMvVYFfxQJHsbc1AQt2rD93dJsgKsJm8lU4V3TvMltKIJe9kgyezIN+YU
         S9fj167Ynmrk4znkYkEpLxpS4vu79UhQY1ngr0vq4dKy82sbahIZC5fDOYIjMr9mc4h/
         xm5U8/mvWcdj6o6CsWqWTBj69BlsK5AysoaxEGi0G0+4lq8aCL+H29YEMW8Rn3rc8pGO
         Q+YrzkjwBVrG0mQX10925B3mgc0RThvhLVQob8klQmLyS1u0y8rYr8BART+aaZYQJrYR
         wcDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAViWGeiJKy6QGtsoAmX8x9CStb4LM6n9NMFqwveX1JaB3xbWNwf
	gx7nAKtFce4aIis5egC1l256LYp5ej4DgrmfAPBRQLB5IUqyE1Rkzz5WaKx9DKhh79hvRNZBA8l
	ADrJsMzBwnSH4ih3W4aJ9EgiwmPnrePpovr3jgt3CRszuUW/7ITODVN0Sbwmik59RMQ==
X-Received: by 2002:a1f:bd15:: with SMTP id n21mr2384441vkf.35.1551852360130;
        Tue, 05 Mar 2019 22:06:00 -0800 (PST)
X-Google-Smtp-Source: APXvYqyoZ9KYYmOmb51QQPCGCgXusIrgJUVPBnYEwCATfVHRjUCJo4uN2syZS4S64af78/lNjaRL
X-Received: by 2002:a1f:bd15:: with SMTP id n21mr2384419vkf.35.1551852358859;
        Tue, 05 Mar 2019 22:05:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551852358; cv=none;
        d=google.com; s=arc-20160816;
        b=jvh+9Dv5euzKX52RtCsHWZ9XDcUTr9LwbjcrM4TicHDTYyD7TjKSqD1TyRtQoLlPGz
         G5qtPjFDltxMBeFJR8y9Kf+pp88SxWQiRw8XUO9Z8I+CqJhRBMZC6Cv5sA5cqt5J8cl1
         J/sTGbkpv59KphhW1R3NserMJgQA0pwb7KvnRnB8LDzTlOHzXXNVa7uVCGoEjAKW1pA7
         MtuheP6U9f+MCoGF/rIhaugbsx5Y55UJG0opiA9wVSwzbDYxpo9DTL+/wU8mOwJWLUlj
         h9ByzbSYGsGuxBND4UXg+/7/wPU+icP5yAV2lyLk3RH7yf+mngAkBCofP6u2O7joTjrF
         7LbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:to:from;
        bh=zKmOhBghltAUYaHuAeFS+OtF/FieaDr0jFkVOQWl1sM=;
        b=x0+4y6XT0c5bhRNGEkj7ouH7ndm84WeBQ0m4BnS8Tb+eT2X7+jLJiAnzjj9FV3Bt/T
         yIDuJjCZaff3237+/36RhanV9AYbC6/0HN66cyhZs4oQDF4o6+mL3sY3jYDjHQXNCNg4
         kRG08rgcj3VcS1HGrQFxFlW6pQo8hAhD5aMVceKKqrQ9PO1864Ra8OETYY0DJmPPsTek
         0CstWKXpIKNpwGU+6I34vuHycWx4eOUaieMZIye84O8yxLJpWE3/3Q3rTv2xRE2bK3l9
         rCyV4yErmXMEPvxBG6z1HdUwII2dkPfklinp4mjHDg9Ee6xvXYgLBGQtu8GYMcKjvom0
         Ifug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id e8si157671ual.194.2019.03.05.22.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 22:05:58 -0800 (PST)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 8EF36456F71EE2397638;
	Wed,  6 Mar 2019 14:05:54 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS404-HUB.china.huawei.com
 (10.3.19.204) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Mar 2019
 14:05:51 +0800
From: Yufen Yu <yuyufen@huawei.com>
To: <mike.kravetz@oracle.com>, <linux-mm@kvack.org>
Subject: [PATCH v2] hugetlbfs: fix memory leak for resv_map
Date: Wed, 6 Mar 2019 14:10:07 +0800
Message-ID: <20190306061007.61645-1-yuyufen@huawei.com>
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

When .mknod create a block device file in hugetlbfs, it will
allocate an inode, and kmalloc a 'struct resv_map' in resv_map_alloc().
For now, inode->i_mapping->private_data is used to point the resv_map.
However, when open the device, bd_acquire() will set i_mapping as
bd_inode->imapping, result in resv_map memory leak.

We fix it by waiting until a call to hugetlb_reserve_pages() to allocate
the inode specific resv_map. We could then remove the resv_map allocation
at inode creation time.

Programs to reproduce:
	mount -t hugetlbfs nodev hugetlbfs
	mknod hugetlbfs/dev b 0 0
	exec 30<> hugetlbfs/dev
	umount hugetlbfs/

Signed-off-by: Yufen Yu <yuyufen@huawei.com>
---
 fs/hugetlbfs/inode.c | 10 ++--------
 mm/hugetlb.c         |  6 ++++++
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a7fa037b876b..eb87cfb80eb9 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -741,11 +741,6 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 					umode_t mode, dev_t dev)
 {
 	struct inode *inode;
-	struct resv_map *resv_map;
-
-	resv_map = resv_map_alloc();
-	if (!resv_map)
-		return NULL;
 
 	inode = new_inode(sb);
 	if (inode) {
@@ -757,7 +752,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 				&hugetlbfs_i_mmap_rwsem_key);
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
-		inode->i_mapping->private_data = resv_map;
+		inode->i_mapping->private_data = NULL;
 		info->seals = F_SEAL_SEAL;
 		switch (mode & S_IFMT) {
 		default:
@@ -780,8 +775,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 			break;
 		}
 		lockdep_annotate_inode_mutex_key(inode);
-	} else
-		kref_put(&resv_map->refs, resv_map_release);
+	}
 
 	return inode;
 }
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8dfdffc34a99..088fd1239d49 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4462,6 +4462,12 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE) {
 		resv_map = inode_resv_map(inode);
+		if (!resv_map) {
+			resv_map = resv_map_alloc();
+			if (!resv_map)
+				return -ENOMEM;
+			inode->i_mapping->private_data = resv_map;
+		}
 
 		chg = region_chg(resv_map, from, to);
 
-- 
2.16.2.dirty

