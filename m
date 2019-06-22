Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5913BC43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:06:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D3A020881
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:06:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ov9Wys35"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D3A020881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9F1B8E000A; Fri, 21 Jun 2019 20:06:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B013A8E0001; Fri, 21 Jun 2019 20:06:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97AB48E000A; Fri, 21 Jun 2019 20:06:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC278E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:06:11 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id f11so8125010ywc.4
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:06:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=G4U2JA+ITVRUPcGtQR0tfoOVR3mjydybAs8QYLDNQp4=;
        b=MYDH0eR0p6pcOZIHSEP/9Gt3mseSfsYqjTBn35D6nyMVi80h5xP4metzM2qMkW1SI9
         QDdJwbPxrrrBO8WTf4yi1vFZ5lT7RRRu4N08/+JdKh9655GzXEmHRYEmxixZtGpNScqx
         iwlG6IA77y3hWkpF7/c8z8qEmjfjPDeZpa/JFkD4Qf152Ak8jSVUJJ3JpMrpSGtQwkob
         1s9E+oxiENGpzSZ7k3B2p/5j6vUNtCD/YJm949dtobfXhiLn163iSR9AT7FRaAKxVrO6
         Hc0inwHSiKgKgNXJfinjaV2y8mHhwjqcPz7qYD0orm6gjDyBy2pUWVGEEjil9+uOGK/f
         D8VQ==
X-Gm-Message-State: APjAAAXdhgWROME2k2nej3Vmoh63DKpzvsqH48sWbd3e71vOmV2YhftL
	5iHo2bEXW95ohTwqAtjUkNh3OiI5sZ8Bt4ooaF+TRsVVec4xtRnjIfycrM/RbBeqzE0W4/DGo2O
	2y32iu7XCMycL+Iny86mdxXYz18wuJSi2a4tUGMNcTdVF0F4vkBlvkhoszyB6NH50BA==
X-Received: by 2002:a81:708d:: with SMTP id l135mr74952048ywc.225.1561161971202;
        Fri, 21 Jun 2019 17:06:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwB58sm0m+VXsxkWgbT2HbL7daLhVEMCcEGEtG2Dm7p4h54MeqDFlvBA4myoUrpMc8d4i5J
X-Received: by 2002:a81:708d:: with SMTP id l135mr74952012ywc.225.1561161970510;
        Fri, 21 Jun 2019 17:06:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161970; cv=none;
        d=google.com; s=arc-20160816;
        b=oN/OmmZdbjlcLy4lUuuEN26BeUP7iZ3sqDYVveD2I04LlI+qKrpBIZvs8QH8w/iWg/
         pS8PEVm77byl/16Kl+Dw/6I0VGpg71oTc/vFjTUVY5eCMWRTdC7yg0yUba31X3i4pcKP
         iHfJ9tTcRhG1JuBMyYSavjGNq/7SEG9oH+gGuYcsdFckFhYmKgYD1eOskNYqwHsFNVJ+
         Ggio7q4kyXPdDm/cS5eVOxK/0Dyjkqb4rGUkR9zQXT7oe6WfEWWMHpWozai1zVkHwM7W
         qaAktc1TPxKeHqKaetb1m3USKktJF0aJQVX6vyLCevkjmkOY01ncD50PLqOVaIl1DP8y
         OhLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=G4U2JA+ITVRUPcGtQR0tfoOVR3mjydybAs8QYLDNQp4=;
        b=eWmaYjswqF8Sh99oTqBJLAZ/IGd1kPXKfRu2U7yT4HZGL3wsVYWg597WM02Ayg5QWw
         8znlsSvR5TTm55BJiwY6XkbZtxe9q33kmG9TLt+K/atuXN90igBzOfdRVgkt+PHJ9Xyt
         6gUbODgakhPoMeiq88ygxiV7EhO4SH7zYwbxzufr2lbuxLmEZ+EuKQB0acWqO8ztbQ1U
         JCmCHCJ115dEUd8kV7SayIulOSTAI9Czi5btvupOfLgVDiChScUrYU2y/UXDLIh1dU+w
         0Zo2RXcVbAuFhANeylrtanQ9P4ARqPi6TcywcdO82rZNrYiFFLcuYMobQ3t+49i0rmzH
         785w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ov9Wys35;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 5si1605540ybb.383.2019.06.21.17.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:06:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ov9Wys35;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5LNsBEA018724
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:06:10 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=G4U2JA+ITVRUPcGtQR0tfoOVR3mjydybAs8QYLDNQp4=;
 b=ov9Wys356HeJMTOhjJyvf09iU61MVwV9DlIOXWcRwc4uMSJ71zbAfKOLG/Y1zklxUweo
 toEHE/vDQB4xFKuqzRAs96BzcTLaH1DHXQLBuiFZ/ppm7PZuf0IvT1BG/maN2sll9JN/
 pIq6XLGME0LZezrk6NQv3iOiSQSDN0oQNlQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2t936x1a2f-14
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:06:10 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 21 Jun 2019 17:05:32 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id A698162E2D56; Fri, 21 Jun 2019 17:05:31 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 6/6] mm,thp: avoid writes to file with THP in pagecache
Date: Fri, 21 Jun 2019 17:05:12 -0700
Message-ID: <20190622000512.923867-7-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190622000512.923867-1-songliubraving@fb.com>
References: <20190622000512.923867-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=608 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
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

