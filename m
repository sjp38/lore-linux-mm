Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2A28C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79C7420B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="RKuPaAkt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79C7420B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A6648E000C; Wed, 19 Jun 2019 02:24:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17F278E0003; Wed, 19 Jun 2019 02:24:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 045708E000C; Wed, 19 Jun 2019 02:24:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id D18848E0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:24:49 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id o135so17948053ywo.16
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=6cpDwB9/DOqvYGBieqT3GM6rp8s/fUHfF1+MzgzUlLc=;
        b=lt/9ePIYZOm0agktJi6WbUXBWedfcNn6UpL94pTidkTEYEUaIQGkwpu1Y8Flqoo1xA
         p4+MAf6HTFrVf2LRGcSPui80zz0fXM8n5WuDbGZ9UYdjk8+1OjNPQi5DPG/hWeE5KGG3
         6DIa2eM91YwpBGOUAxSnFHefwhVyuLf62Qan9YojvYN+dHIycPJUS8SLupbExM/3G52Q
         8GIL7K+U6Is3tkor32reKY21dvE+iC5WLw42L1SNU+ciuVMmSrdMuXsUPT97q5oN+S3n
         rmoFV8H9LFhyL5tTNcBb4MsDI+i5KghS0ccYeWEt/eiMkPwe7ZYpPQ0Srmphc9qPgr5k
         N8Ew==
X-Gm-Message-State: APjAAAXzp7MCHUH6D/4QSmFyxFnMCGURxqkHwwM44QguFPM/BxetaseM
	OaSmx838c8Aj41L7rpWOCpSKj/x7l1lqYafkP7OimgZI5EFVumZXS7UNZ3Zy31WAa59jOhav5sS
	G8GDne4vMBAvv09nvdYZ2OBhUK10qLfvfzSe8LymNFLdCvP/zUPBnDxOJckdwLIVs6Q==
X-Received: by 2002:a0d:edc1:: with SMTP id w184mr53169498ywe.174.1560925489618;
        Tue, 18 Jun 2019 23:24:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1NhBM/JtLp7p4FBT13hK/mIy3vRmHFFAZp7WSYRCeAfRfqlHz85Uhpf6vwusZugpuCNVo
X-Received: by 2002:a0d:edc1:: with SMTP id w184mr53169472ywe.174.1560925488860;
        Tue, 18 Jun 2019 23:24:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560925488; cv=none;
        d=google.com; s=arc-20160816;
        b=0YrybQtVx1s7NcP62i6pEcTnNokXnSu9s1FP4GIs4I1aDZq5e/W/HV56Apm0pdR7J6
         JYw7GJu46MqFZACuhA3u2HiD9ncUQOqkwBE1siAGsW8eyoypPLdNcToRxIlS95axNHqO
         pn0IYttM493yC+tg0LJZLZDcsIGfaAJnANnTqwwWlYLVmtkCRG3McZzEtFNaeUh//9hG
         Y/mkAOn68gKhtFTToDsSMgSwQ8/t8RA8OYGcUk43+RejyIxYsgJoXhzU6a5qc9w2+ghB
         ZT3RQmUlRB1N0MQkIZvyz+KZG4OvO+lAjtDsViL4QWyiMmijUAYJUfh89+FE5DMN3ZoT
         FOAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=6cpDwB9/DOqvYGBieqT3GM6rp8s/fUHfF1+MzgzUlLc=;
        b=V4qev88WNkp0Oy2mGsqQWLkx4l715FK5I5U7dIl3TXRlU2xuGOMNdgMEAHyvP2UGLk
         vAEcUw3Fstp004x0M09FpcDJbnWLixiFmJncbb4fhj0qgQc/icy1FAfX9JFoxjNCeHn2
         i8N9f+MPvuJtvwPB3H6i+9iOwmkeFzXXisVZ+Wwhe6uR2U01Yv/RL81yZQK8kX5FD0wi
         b80iuVziFWbCYgN6ufdv/AZvWKF54wIGmNClKof3RDNkGVOqxaKdLmx51WKv5SJcBDf+
         UT05vX8I82nbqZnAdkQCIiTN7x4Bff0Rcz2DciRY2tjVmkws97zpKMkofENYaCMIj/AA
         s4zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RKuPaAkt;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r127si6149132ywr.312.2019.06.18.23.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:24:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RKuPaAkt;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5J6LM8H025877
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:48 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=6cpDwB9/DOqvYGBieqT3GM6rp8s/fUHfF1+MzgzUlLc=;
 b=RKuPaAkt4RwZsGKXPNeyJrxfkUzDBKl33bpXVgEdf7+g1fqNA1Kqr2L3y4V8CLFAmiw7
 yOrDjpjRRGw+geEXyerRYWa2Z1eoEfCMl59JfURaV9qg/W64vJ+ureGZlR1X8tTfiS92
 es/deAqTiMI+gNcA2uUSYAqQ/4ZIlnFEQWw= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2t77yfhbrk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:48 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 18 Jun 2019 23:24:48 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 7183062E30AA; Tue, 18 Jun 2019 23:24:47 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 6/6] mm,thp: handle writes to file with THP in pagecache
Date: Tue, 18 Jun 2019 23:24:24 -0700
Message-ID: <20190619062424.3486524-7-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190619062424.3486524-1-songliubraving@fb.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=759 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190052
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

This patch briefly handles such writes by truncate the whole file in
sys_open(). A new counter nr_thps is added to struct address_space.
in truncate_pagecache(), if nr_thps is not zero, we force truncate of
the whole file.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 fs/inode.c         |  3 +++
 include/linux/fs.h | 31 +++++++++++++++++++++++++++++++
 mm/filemap.c       |  1 +
 mm/khugepaged.c    |  4 +++-
 mm/truncate.c      |  7 ++++++-
 5 files changed, 44 insertions(+), 2 deletions(-)

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
diff --git a/mm/truncate.c b/mm/truncate.c
index 8563339041f6..bab8d9eef46c 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -790,7 +790,11 @@ EXPORT_SYMBOL_GPL(invalidate_inode_pages2);
 void truncate_pagecache(struct inode *inode, loff_t newsize)
 {
 	struct address_space *mapping = inode->i_mapping;
-	loff_t holebegin = round_up(newsize, PAGE_SIZE);
+	loff_t holebegin;
+
+	/* if non-shmem file has thp, truncate the whole file */
+	if (filemap_nr_thps(mapping))
+		newsize = 0;
 
 	/*
 	 * unmap_mapping_range is called twice, first simply for
@@ -801,6 +805,7 @@ void truncate_pagecache(struct inode *inode, loff_t newsize)
 	 * truncate_inode_pages finishes, hence the second
 	 * unmap_mapping_range call must be made for correctness.
 	 */
+	holebegin = round_up(newsize, PAGE_SIZE);
 	unmap_mapping_range(mapping, holebegin, 0, 1);
 	truncate_inode_pages(mapping, newsize);
 	unmap_mapping_range(mapping, holebegin, 0, 1);
-- 
2.17.1

