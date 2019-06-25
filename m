Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2DA0C4646B
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:13:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D90A20820
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:13:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="gP9uYvk9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D90A20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0067C6B000D; Mon, 24 Jun 2019 20:13:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAB588E0005; Mon, 24 Jun 2019 20:13:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2E068E0003; Mon, 24 Jun 2019 20:13:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB6D06B000C
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 20:13:10 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id y205so18827851ywy.19
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:13:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=3XZFERUpQR9pfQReUygYqP0Ugwxnn7ZlmK3Hj2ioXA8=;
        b=qJaK3vviaTsax6edArKr7mOHB6CgwIySLnDL6QpPbhrzpeENvC6QCdq6i8UXva3IPB
         T3AKxCYbpu7/mSGLAUS8IdcjTtyq10be1tnQgWBF+Gto24nLYfBqGPEIVTGRbSqHIBCW
         WDlA9grX7q1pvndlh3pRfz33Vk4c6f2OWptrzpRZDptJ8GqEmqjoOYhUNEXd4j2r+kR8
         66LpjH11VN9+2LZvXC6KFV+acfgPEV2hpbxCRIPpAGMYsKSW047qyt7E/T/7TOtClJZ/
         /q/IZfkyoUTg8oDBO2r0kVzwHQB2jtnBBB+CN3EeBdOTCYPiRtW4OiqCcYGX/Fd/aCP5
         XRAg==
X-Gm-Message-State: APjAAAUmZmYY5ETNxVZwK1lgNbnVM0qfCYYP4P+i/oCnscs7C756DV7v
	vK3tTtDmPFIwJOjRDeufjFpXQoiVG0qkeS8I6RomRBORjxEPML7RWDzPMbHbvFhsj0vGC8EejKB
	2JTRkOAgiY1bBSGtbJr1HIjTb6H5XWekIi7s5tx4oSpcxjZ2yTrmJkIFmMGlbXZezPA==
X-Received: by 2002:a81:bc41:: with SMTP id b1mr70500882ywl.404.1561421590465;
        Mon, 24 Jun 2019 17:13:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVgj6D/WWWVTVRu6oGsyzwH8uvFpskpwus6QvfQw80colQmGhDuetHNsn+gDVOWTTpZwgI
X-Received: by 2002:a81:bc41:: with SMTP id b1mr70500857ywl.404.1561421589766;
        Mon, 24 Jun 2019 17:13:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561421589; cv=none;
        d=google.com; s=arc-20160816;
        b=s0cDgHTgYpBnjZRusIXAkHFmBxm9XBKA5SDQEL4YUuEIxyXQ+2gy6cB12uFD/ryCPw
         mMBFfDNrP5D5nkFSBKMPdULK3gnbbPIAaUFFwSuKMlyiDKhWYFie4MENJBO3Zf3kp61b
         ALcq09wZRllgCeOP8BYBSd1bWld1kAV9hKyHQvIsMMJuVwbDH3ev31m8JPCHwsu7E1pF
         zxu7U90t2w7bEIewh1DhK6pZLmNeYmhnZcDB8olRJimSoJJZ/81b1jUoYuZ4XQaC30R8
         pXH54QCWUZryNzYhX4gP8kQ3loZ1deCoCngLLJAPHOYa0KMNIDfAPtwIRac+uL6b4Tbx
         Jc9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=3XZFERUpQR9pfQReUygYqP0Ugwxnn7ZlmK3Hj2ioXA8=;
        b=kFJDVR+7iYUaokG374mN4E/Y52P8FWppybtYZYHHesJIFDOITZcwU7fzjDnpV3E0MY
         BGDvB5H2086y0aTitRPlQOzJ0PEhS96gh0F696Er6QI831X6oNiM69yeh2v2jl/YCyyq
         B3gf/EG7pb2wVjMxiUZLAVDvctjHcMEklNOnB5AMNQD9sl0qXgNa3jKr1Dpnu8V/Oz9f
         0chzsLNewpejd/diPMNrSWrHKKgVlBdZDVCAxQ/2PT125Rs04TXeAzRFrB1ubyh0X2Xf
         EoKQwV7NO7ywbRRCSjMkv6Sn8JSXVPG94IR2j3CwvqjydNcKMSt1PwyW+Eaup2ozY2bh
         XIlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=gP9uYvk9;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t198si1026131ywc.273.2019.06.24.17.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 17:13:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=gP9uYvk9;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5P09dlU018475
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:13:09 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=3XZFERUpQR9pfQReUygYqP0Ugwxnn7ZlmK3Hj2ioXA8=;
 b=gP9uYvk9m8yAdtzGQs0XBLX8EnTnPpfzTgbRHqWiehHM03h4T22lEs/DkZ5H4o6gkQ7K
 KXlIyL0QYQ9hjbl6u4GESqmPMbO+19kdVAeiH2mWYhOqCTCGyyK8b9luL+QmCW/ac1m2
 4Jbmts9ZD8cF41JQBoBYvFBTYtSUv33Go8o= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2tawbtarag-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:13:09 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 24 Jun 2019 17:13:08 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id C93A962E206E; Mon, 24 Jun 2019 17:13:07 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, <hdanton@sina.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v9 6/6] mm,thp: avoid writes to file with THP in pagecache
Date: Mon, 24 Jun 2019 17:12:46 -0700
Message-ID: <20190625001246.685563-7-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190625001246.685563-1-songliubraving@fb.com>
References: <20190625001246.685563-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=801 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250000
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In previous patch, an application could put part of its text section in
THP via madvise(). These THPs will be protected from writes when the
application is still running (TXTBSY). However, after the application
exits, the file is available for writes.

This patch avoids writes to file THP by dropping page cache for the file
when the file is open for write. A new counter nr_thps is added to struct
address_space. In do_last(), if the file is open for write and nr_thps
is non-zero, we drop page cache for the whole file.

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 fs/inode.c         |  3 +++
 fs/namei.c         | 23 ++++++++++++++++++++++-
 include/linux/fs.h | 32 ++++++++++++++++++++++++++++++++
 mm/filemap.c       |  1 +
 mm/khugepaged.c    |  4 +++-
 5 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index df6542ec3b88..518113a4e219 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -181,6 +181,9 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	mapping->flags = 0;
 	mapping->wb_err = 0;
 	atomic_set(&mapping->i_mmap_writable, 0);
+#ifdef CONFIG_READ_ONLY_THP_FOR_FS
+	atomic_set(&mapping->nr_thps, 0);
+#endif
 	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
 	mapping->private_data = NULL;
 	mapping->writeback_index = 0;
diff --git a/fs/namei.c b/fs/namei.c
index 20831c2fbb34..3d95e94029cc 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3249,6 +3249,23 @@ static int lookup_open(struct nameidata *nd, struct path *path,
 	return error;
 }
 
+/*
+ * The file is open for write, so it is not mmapped with VM_DENYWRITE. If
+ * it still has THP in page cache, drop the whole file from pagecache
+ * before processing writes. This helps us avoid handling write back of
+ * THP for now.
+ */
+static inline void release_file_thp(struct file *file)
+{
+	if (IS_ENABLED(CONFIG_READ_ONLY_THP_FOR_FS)) {
+		struct inode *inode = file_inode(file);
+
+		if (inode_is_open_for_write(inode) &&
+		    filemap_nr_thps(inode->i_mapping))
+			truncate_pagecache(inode, 0);
+	}
+}
+
 /*
  * Handle the last step of open()
  */
@@ -3418,7 +3435,11 @@ static int do_last(struct nameidata *nd,
 		goto out;
 opened:
 	error = ima_file_check(file, op->acc_mode);
-	if (!error && will_truncate)
+	if (error)
+		goto out;
+
+	release_file_thp(file);
+	if (will_truncate)
 		error = handle_truncate(file);
 out:
 	if (unlikely(error > 0)) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f7fdfe93e25d..082fc581c7fc 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -427,6 +427,7 @@ int pagecache_write_end(struct file *, struct address_space *mapping,
  * @i_pages: Cached pages.
  * @gfp_mask: Memory allocation flags to use for allocating pages.
  * @i_mmap_writable: Number of VM_SHARED mappings.
+ * @nr_thps: Number of THPs in the pagecache (non-shmem only).
  * @i_mmap: Tree of private and shared mappings.
  * @i_mmap_rwsem: Protects @i_mmap and @i_mmap_writable.
  * @nrpages: Number of page entries, protected by the i_pages lock.
@@ -444,6 +445,10 @@ struct address_space {
 	struct xarray		i_pages;
 	gfp_t			gfp_mask;
 	atomic_t		i_mmap_writable;
+#ifdef CONFIG_READ_ONLY_THP_FOR_FS
+	/* number of thp, only for non-shmem files */
+	atomic_t		nr_thps;
+#endif
 	struct rb_root_cached	i_mmap;
 	struct rw_semaphore	i_mmap_rwsem;
 	unsigned long		nrpages;
@@ -2790,6 +2795,33 @@ static inline errseq_t filemap_sample_wb_err(struct address_space *mapping)
 	return errseq_sample(&mapping->wb_err);
 }
 
+static inline int filemap_nr_thps(struct address_space *mapping)
+{
+#ifdef CONFIG_READ_ONLY_THP_FOR_FS
+	return atomic_read(&mapping->nr_thps);
+#else
+	return 0;
+#endif
+}
+
+static inline void filemap_nr_thps_inc(struct address_space *mapping)
+{
+#ifdef CONFIG_READ_ONLY_THP_FOR_FS
+	atomic_inc(&mapping->nr_thps);
+#else
+	WARN_ON_ONCE(1);
+#endif
+}
+
+static inline void filemap_nr_thps_dec(struct address_space *mapping)
+{
+#ifdef CONFIG_READ_ONLY_THP_FOR_FS
+	atomic_dec(&mapping->nr_thps);
+#else
+	WARN_ON_ONCE(1);
+#endif
+}
+
 extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
 			   int datasync);
 extern int vfs_fsync(struct file *file, int datasync);
diff --git a/mm/filemap.c b/mm/filemap.c
index e79ceccdc6df..a8e86c136381 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -205,6 +205,7 @@ static void unaccount_page_cache_page(struct address_space *mapping,
 			__dec_node_page_state(page, NR_SHMEM_THPS);
 	} else if (PageTransHuge(page)) {
 		__dec_node_page_state(page, NR_FILE_THPS);
+		filemap_nr_thps_dec(mapping);
 	}
 
 	/*
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index acbbbeaa083c..0bbc6be51197 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1503,8 +1503,10 @@ static void collapse_file(struct mm_struct *mm,
 
 	if (is_shmem)
 		__inc_node_page_state(new_page, NR_SHMEM_THPS);
-	else
+	else {
 		__inc_node_page_state(new_page, NR_FILE_THPS);
+		filemap_nr_thps_inc(mapping);
+	}
 
 	if (nr_none) {
 		struct zone *zone = page_zone(new_page);
-- 
2.17.1

