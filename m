Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32F24C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:46:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA1F720838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:46:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="YQzgCtlG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA1F720838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 748F66B000C; Thu,  1 Aug 2019 14:46:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F9146B0010; Thu,  1 Aug 2019 14:46:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C1246B0266; Thu,  1 Aug 2019 14:46:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34B586B000C
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:46:17 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 77so53822468ywp.14
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:46:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=DSUSc38wHM5RkmzSyeUjxuPKYIC6pKxjmKbqWbRefe4=;
        b=CG2pnciswqv6ubHIl6qDunsdjMZu8ufXlZ845z1UIc+vjD5fkIE53NL+EKe77lduRF
         2LNhUQNc6M/jfQ5GXBc8rXud+iYwB31vSDBjzhO2KOIy9j9gXr5R4KFBKgtbmZVHcxdU
         Gv2GZoV5jFCILOo6sC9L5j9HrcEKwjeyLHyk6oRSdUviToTpOLkvmi7AZjr5J/0S6+2f
         gJlUOTYU3bxTBQL41YLx47W2sq79Vqq9mlss8w8A0QvnMGVz8DQr2bOTHAFvK8b52T89
         PzPUh/VWFEYLleVKGGiNn38/lQpnjDlRR6f80PYANJ2xUyoeiwO3CZqWvMFKRWIZ/bsx
         bO7Q==
X-Gm-Message-State: APjAAAVtNnVSaEVK/FxMYNY3dfIo0zqzvENlGtXnhaJoSChjnziCrNN5
	H3STCYnSAL7odAfkw2iwgWqmqivy+5YCunkQ3/ZtFOf82LRP7250qxuuWLh7EPlE8NB5TTA6J+7
	yThsaaD2XkcQvgCF4xwbKMBGRdS0QTotlRbmehZIGdTALFedn1I864DA4ZOqFnR6a5w==
X-Received: by 2002:a25:6c2:: with SMTP id 185mr37421612ybg.68.1564685176962;
        Thu, 01 Aug 2019 11:46:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOQhnwdEFKJl6a2AV2I/saIXxk4W8A0xVQeeQkmtwZO6jECg0455vnHPFSfdHq6LXA0onu
X-Received: by 2002:a25:6c2:: with SMTP id 185mr37421547ybg.68.1564685176025;
        Thu, 01 Aug 2019 11:46:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564685176; cv=none;
        d=google.com; s=arc-20160816;
        b=vTByJaiIZBPcPfdCjIwobbYmJsXtJ3YqitIc+ycqfKydU+thPx6zRBkE/1SAHUIcJ5
         6tSqJ62CSwyyaj9lQMmrhluaKM/7w/kR7s2YX4ZF7knoq67rLlqLJnUxUP13NLhTjZOk
         y0Mt5fn9TfLsh01XxCQ/0p+5fwd5KIOi3DjaLwukQa+hzwa8wvOMwHilhOKm3thQ77fX
         5d4UB3IpfravhPl55HjhLEUW1tsw5gvhA8RoAQVuTpSXkMBfgp1zvfAPUE1zxN9R312w
         AVt4F5hrLWflRNOvot1MCBhPy/gkgudoqDvIVshwPh/N2073j2Xawjqfe07EAzWeTUgS
         Ilvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=DSUSc38wHM5RkmzSyeUjxuPKYIC6pKxjmKbqWbRefe4=;
        b=jG2ikB1o5G+SXj2M/eYCu/eGMVYPbz/N19moBDEAee7JEnvnT1y+j6gdCWV/4wHhfq
         K+qJXIhGTzab4lRjPneNBXNhIu2GXvumvGJ6rIl5CqolMBmAW3hM7LkDm7dFq6tTe7b/
         pJ2bewLKLP3R4cSXVQyqSc94Vy7ftIOf/zN52pJbgla+S5uZLqqDJnObgQvEytmA5CJK
         R/0lH3rVc2VdNUFZWfeB8v26GLNzzSlCGzSWccwU4zTbu1xzlBRGUHH6Q+hNEjrOPWcP
         V3CDLVvCpTWmCKN5CDerfkCB7lvhv7lSqmNfqtszufBn1yBv8fv/+Lmv/ESv7kKEkYew
         +qNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=YQzgCtlG;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 191si24810556ybe.19.2019.08.01.11.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:46:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=YQzgCtlG;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71IhoFJ006842
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:46:15 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=DSUSc38wHM5RkmzSyeUjxuPKYIC6pKxjmKbqWbRefe4=;
 b=YQzgCtlGKcw3cZAFdT3dY+Q0nIn0gOdjHOIyt0NnuKjMY2KwdwRYvCCdJneWssmu1TXf
 dc0TQ6UKsM4GRJgEsQP3AXyQpRY/XM7eDEo6RbFSQKs4lCR2fV46VMS4r6yR7fwhnw+u
 FJNidSnfXfFpoh6Y+ZmN7aWHX2n87/4WWlY= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u41gys3xy-7
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:46:15 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 1 Aug 2019 11:45:53 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 835FE62E225C; Thu,  1 Aug 2019 11:43:20 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, <hdanton@sina.com>,
        Song Liu
	<songliubraving@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v10 7/7] mm,thp: avoid writes to file with THP in pagecache
Date: Thu, 1 Aug 2019 11:42:44 -0700
Message-ID: <20190801184244.3169074-8-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190801184244.3169074-1-songliubraving@fb.com>
References: <20190801184244.3169074-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=876 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010194
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
address_space. In do_dentry_open(), if the file is open for write and
nr_thps is non-zero, we drop page cache for the whole file.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Reported-by: kbuild test robot <lkp@intel.com>
Acked-by: Rik van Riel <riel@surriel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 fs/inode.c         |  3 +++
 fs/open.c          |  8 ++++++++
 include/linux/fs.h | 32 ++++++++++++++++++++++++++++++++
 mm/filemap.c       |  1 +
 mm/khugepaged.c    |  4 +++-
 5 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/fs/inode.c b/fs/inode.c
index 0f1e3b563c47..ef33fdf0105f 100644
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
diff --git a/fs/open.c b/fs/open.c
index a59abe3c669a..c60cd22cc052 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -818,6 +818,14 @@ static int do_dentry_open(struct file *f,
 		if (!f->f_mapping->a_ops || !f->f_mapping->a_ops->direct_IO)
 			return -EINVAL;
 	}
+
+	/*
+	 * XXX: Huge page cache doesn't support writing yet. Drop all page
+	 * cache for this file before processing writes.
+	 */
+	if ((f->f_mode & FMODE_WRITE) && filemap_nr_thps(inode->i_mapping))
+		truncate_pagecache(inode, 0);
+
 	return 0;
 
 cleanup_all:
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 56b8e358af5c..29b2729bd48a 100644
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
@@ -2775,6 +2780,33 @@ static inline errseq_t filemap_sample_wb_err(struct address_space *mapping)
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
index 0b8b117dbed6..45940d1f59db 100644
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
index 8fb26856a7e9..80735bf2a70e 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1653,8 +1653,10 @@ static void collapse_file(struct mm_struct *mm,
 
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

