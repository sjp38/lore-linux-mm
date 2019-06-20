Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41345C48BE1
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB7B62084E
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="qYjAYh45"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB7B62084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40B478E0009; Thu, 20 Jun 2019 16:54:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BD908E0006; Thu, 20 Jun 2019 16:54:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D3D78E0009; Thu, 20 Jun 2019 16:54:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E89B38E0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 16:54:12 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c17so2793992pfb.21
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=G4U2JA+ITVRUPcGtQR0tfoOVR3mjydybAs8QYLDNQp4=;
        b=Rg1UarGXZY9lH9s2bjhs7Xx0dOv9ghJDvINKO2QtkbYfw4/kDOerqOjpCM/2fu/3+w
         089Zh2WgXl7WNPzE4btUdTVRaeJ0Z86bGkk3+ICX7zaP0YwDlEcQ3V3QiyAxXjdRebRp
         b25o1COrk/EGzZZLUPi27Cm1DqT9Z2f3ymMBRyjIiTk6qYgzixOeG6mw6c7d+0q+BJK3
         cBlZM7+gby1delbVGJeEmnlYBqJ4vm9DJHKLn+Jpc1sA19zhui5OIMHO6ik8NQDUBxsw
         aksxm4sXQII9ECh0LNXX+6BFmPg/UjbG2XzQB8lpoGfox7hAzbI9uDfY2vU1Dl6bSukU
         A3mg==
X-Gm-Message-State: APjAAAVmAtxkwqvdeW5AeHIc90gR9BhLWWCtt0M50qyjPXQUWTIyd3e5
	d4Xjv1b56In05Ofomx7mvADcpEfncqi0wQndEATcnMtvyU7bNDZUiD+ocYBiQUKuc3fRaArUvQJ
	xmfVzbI1v7KwnpxKaPIwwBtn4dVe2f4cC1woS99cPYpVaaiuHnOfdjt68jEydZIY3lw==
X-Received: by 2002:a17:902:f087:: with SMTP id go7mr100523138plb.330.1561064052619;
        Thu, 20 Jun 2019 13:54:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZ9Fc+MtNFP5y0NJQ24Ne01mc1h8b/MKGM0xHmY0iuo6yoPd0ompmzQqLA0prRxPopFtYe
X-Received: by 2002:a17:902:f087:: with SMTP id go7mr100523091plb.330.1561064051916;
        Thu, 20 Jun 2019 13:54:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561064051; cv=none;
        d=google.com; s=arc-20160816;
        b=XV28tWlqWtd7rEmlrhpMNqa7hNsz6eNYaLBWmMQHoecAU+cqQ9PPuCCJd/MChwvWIl
         HPhkYYC8+LjrvQgZty4/exzez3fdsHKFDJLy4nv6hnuUTmASHdczRDwRDmaGcbee/sKu
         6iMgpf8VGkd/eFtJ14LAwLgrmma9sNV95ztu3PslXGTXo7L5qkacofsVvmlf7ygiY6MU
         q+v09njaTAVqRSnY0KxhfajeM9n6wavnBQTZyk+Goq/goC1WvYQ26SBJuNdcuShbXKrG
         Hd18h2dp7cT0UobJg5s/tBogI2akkmlv8L1CD7AeHsHma5MR6k5wH4l1QhPTRava+RVr
         IWPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=G4U2JA+ITVRUPcGtQR0tfoOVR3mjydybAs8QYLDNQp4=;
        b=sEH+At4ATo5VzBv5f3M6v49PUCNdXjv1tcn5W4mNjI6MNB7eZ4vWwH/W0f1jWa+B6o
         HvIeaiY3WqqG733nAjTCEMBuxQtLmMhGJ21FIJVHFd9Hfh+X+1lUR8F4CmCpaKOvffyf
         3HgAHDOIVyhTcyPI+rb/j+P/IdGyIYNzO8y970X7bnLXEMdwy0zdwYx+ffN00/WTwo//
         v45YFnoePnxGEsgUwsnkWyn7j+Oh+lrzr0lNilKsulKfZOUtlJ5AOwR3V44pAFkfki+r
         +X5laF0zLOc0+jUe/KPQXInhRhkQ4f1GaZPCxoAiS3yE2HfSPAKcSsNvsz9k40f7jxDr
         GpOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qYjAYh45;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l8si488016pgk.528.2019.06.20.13.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 13:54:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qYjAYh45;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KKoPXK018563
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:11 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=G4U2JA+ITVRUPcGtQR0tfoOVR3mjydybAs8QYLDNQp4=;
 b=qYjAYh45EGSY4OgxqpFwWGg173IslKGH4D3OsTeKJXtWmuZlesb9RpVT52HsRwDBYrEL
 Fx12DrVOZvp8XDbzVrxGphAcObmSiRfknktbFbxwYqpBr4L6lEdV8lEXmbJJUhctBMiA
 LBduJdWjlB5W8F4f8yH2HvX+yPNEFv2uj9Q= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8deeh0gc-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:11 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 20 Jun 2019 13:54:09 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 1608262E2A35; Thu, 20 Jun 2019 13:54:09 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v5 6/6] mm,thp: avoid writes to file with THP in pagecache
Date: Thu, 20 Jun 2019 13:53:48 -0700
Message-ID: <20190620205348.3980213-7-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190620205348.3980213-1-songliubraving@fb.com>
References: <20190620205348.3980213-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=611 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200149
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

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 fs/inode.c         |  3 +++
 fs/namei.c         | 22 +++++++++++++++++++++-
 include/linux/fs.h | 31 +++++++++++++++++++++++++++++++
 mm/filemap.c       |  1 +
 mm/khugepaged.c    |  4 +++-
 5 files changed, 59 insertions(+), 2 deletions(-)

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
index f7fdfe93e25d..3edf4ee42eee 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -444,6 +444,10 @@ struct address_space {
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
@@ -2790,6 +2794,33 @@ static inline errseq_t filemap_sample_wb_err(struct address_space *mapping)
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
index fbcff5a1d65a..17ebe9da56ce 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1500,8 +1500,10 @@ static void collapse_file(struct vm_area_struct *vma,
 
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

