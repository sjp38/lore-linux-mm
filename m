Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29135C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D41A720657
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="XACg37lK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D41A720657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 137BB8E0003; Sun, 23 Jun 2019 01:48:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09B476B0008; Sun, 23 Jun 2019 01:48:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E07FA8E0003; Sun, 23 Jun 2019 01:48:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3AA86B0007
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:48:09 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id i11so4062746pgt.7
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=OCLrqfSXcpxK+1VOccrQtP7qai4h6E5adUP8VenR0FM=;
        b=a+73xbgpCnHnRBLulafMLd9/TaSGfhu8PUAH1vGwBd5qSEYin6rppLB05lRKblz/sX
         D+IR+rpdkZdi9EBZzye1V/tdVXhXRYBbBAyD9CC/OkaVu3G29RTcU7GAmALSUGt20/U+
         1hN7G/Bn6n7xgV9BMhCqbKNCLX2KoGipyrVfXp1nNHOlWJDddJc1eEdE8b6thNE3ov0b
         fbD8nkd6EqS+mefnH9IwREkPZa9meqhH9eGYMMR5evMqTHp/F3RmJrckGfimBwzQ+f8b
         z0hKWi8XALsr53wO6an+1OsN9YZJSW6npJF/AglGbqF0yogkct9+8A3ubEp4wLRRCWoX
         vrUg==
X-Gm-Message-State: APjAAAXVMihXKIkAylYMkcSogjpc0jp4WFUvngB8FvVfUTkqWNbFOeFk
	QQo25JvPrC6KKTFcUWGd0WUKw80oZZWo7Hm1g7eKykTZl2afU8cE3EshVrhvKiwsYpVIE31KFMf
	wb8p4H//RI4ulFnBE6pxOxjmnRJhp3ZyYlEu7cuwNTOh4Nwu3SsTyHy61N2iRYkWKpw==
X-Received: by 2002:a17:902:403:: with SMTP id 3mr138404894ple.66.1561268889341;
        Sat, 22 Jun 2019 22:48:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUd8WeQE7gFCLJZm8C0QsWl0ZU3xzx2aehJKIJDTaxWU9aIQ4ayFoDg+/eOGTuyNe5qdQY
X-Received: by 2002:a17:902:403:: with SMTP id 3mr138404858ple.66.1561268888535;
        Sat, 22 Jun 2019 22:48:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268888; cv=none;
        d=google.com; s=arc-20160816;
        b=0VjR+KNlWy4YvVtBSZ4CJFiVm9TojSRYSMF6qXtS/NnEyyirRSKK+XHBswzE0PzkZT
         gGV33z4B2fSAJqAJpr0BWeWgkqXYLYjVB/OWPBkaL8pssQIpiFNJHgKaN2bPdNZZwglH
         oGophTdT7xTHBxj2qbGpHYhjWHgyGzvp0ReOAuCUFicWCmtEtOhwBCrmrtsRsjqkuRuM
         TPjUzynWBNZsTsL7SNveYyCRtYb++0NIpzgGiID1RY11iZTDyHXawKg0lWqSLFLKDxq7
         L/TK+nKIM3veHg4WGJZBSTYMuJ1+8UxE6YnMg8X4UxuUwiQ2X/Dv7HjLR2WKNAgXfZpo
         0R5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=OCLrqfSXcpxK+1VOccrQtP7qai4h6E5adUP8VenR0FM=;
        b=VARe9JXJ4lnM0aFUuMESQZz/cDCgaH7tcI8NM5gsY2cZCpNVGCD1M+UB6fnO8/vNFa
         m53rM8T56LKT+OLP2ChwX5HxkaJvf9yZ87YDGGlVTcKLpyUT/CButfy4DVr/SY8MOyMu
         xZWfaAW3v5N1RDUtYnQ2oCAzhDEokFWCPHn/0NSLqkCosEOWPwstPoFexPZIkRbeKjUO
         D6K6hQeq08HqSOu/kN4WlLH1Q+bi9itSF+wla7SXY0cH/gXYnszKkq3psyPgc3krgO6i
         16Q2eJ1Zj6RUltp+dNFs5PFSdUevaIkdKTSqiQWH5Cb0TeJH2lNQ5bUgdVuWLGZeIOtY
         /ZpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=XACg37lK;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d67si6897946pgc.62.2019.06.22.22.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:48:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=XACg37lK;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5iEvB015402
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:08 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=OCLrqfSXcpxK+1VOccrQtP7qai4h6E5adUP8VenR0FM=;
 b=XACg37lKEV90/F5mriDHnYNQrSoMA73T2pJ1EfyNCjj0mnKpdojTvsQUJLFebiS8eshZ
 RughF7uKEfJhTDjYho2hW+eZsIX3xaKPxsqfd9J8PD2o5HOezvj3GNp5qN+u5p8BACKl
 2vlKjgnvmueW56iXHP5M5NCxaQRQX1oRPFA= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9fmjjfmm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:07 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:48:06 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 2EA2C62E2CFB; Sat, 22 Jun 2019 22:48:06 -0700 (PDT)
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
Subject: [PATCH v7 6/6] mm,thp: avoid writes to file with THP in pagecache
Date: Sat, 22 Jun 2019 22:47:49 -0700
Message-ID: <20190623054749.4016638-7-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190623054749.4016638-1-songliubraving@fb.com>
References: <20190623054749.4016638-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=765 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230050
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
 fs/namei.c         | 22 +++++++++++++++++++++-
 include/linux/fs.h | 32 ++++++++++++++++++++++++++++++++
 mm/filemap.c       |  1 +
 mm/khugepaged.c    |  4 +++-
 5 files changed, 60 insertions(+), 2 deletions(-)

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
index 20831c2fbb34..de64f24b58e9 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3249,6 +3249,22 @@ static int lookup_open(struct nameidata *nd, struct path *path,
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
+#ifdef CONFIG_READ_ONLY_THP_FOR_FS
+	struct inode *inode = file_inode(file);
+
+	if (inode_is_open_for_write(inode) && filemap_nr_thps(inode->i_mapping))
+		truncate_pagecache(inode, 0);
+#endif
+}
+
 /*
  * Handle the last step of open()
  */
@@ -3418,7 +3434,11 @@ static int do_last(struct nameidata *nd,
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
index 090127e4e185..a4f90a1b06f5 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1499,8 +1499,10 @@ static void collapse_file(struct mm_struct *mm,
 
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

