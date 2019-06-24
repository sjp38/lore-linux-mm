Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58624C4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:30:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0964720674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:30:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nGoZgA4b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0964720674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B33A6B000C; Mon, 24 Jun 2019 18:30:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C68C8E0003; Mon, 24 Jun 2019 18:30:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E59C18E0002; Mon, 24 Jun 2019 18:30:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC146B000C
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 18:30:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so8022131pla.7
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=TFx9H37w6mZg+4Tg54qFCnWnzVBpXQ/B3y/2N1lbRw0=;
        b=QkYua390P/lSwcEnUQ5HmygnLO8GqvFh7kQiygDcsZzzjrksQLTQ33QUt9e34vOb64
         8s7vW6Bqadwn0ewtYYD1vgQqH6FcZY4zR9i7pxG4ApZQqdOUw9tqo05Y2xCJ+pZRnceO
         JRz87hr08tRKyc+60Vi5Vj3pheWi5GMNT6IwJ7VumKBph5+PfYRadoEhtHyHFTDvpYzy
         rsfuAX5JauOu6DaImqj8RjrF57Q3CEZhDcVlEC2ADXuZQqdTGFtL5s1XN7s+2AUSrg01
         lrKvXysMGwxznxDPu95a97MF/q9wuLeVA2I/MdsJ6rZcYn4CzaaL20oiHo79SteR6qc9
         WiNQ==
X-Gm-Message-State: APjAAAXEA1K82jU1n3vME1rWzQakd1H2GHSV4v9q++oLjZomMkCVB43H
	0cLQm9MClrBYYH+mHa2MxzSrPr+jM2tj93AOHpwhDL0O9hI960a4wy/yhAbu/B0GXPKVL+nZC5J
	xX6xqz1C8XMKPyGJGzNkxy5gKTwztqgUPvUFh+mZBKHdOF41YB6lTyD1PEqEKhzhbZA==
X-Received: by 2002:a63:1d2:: with SMTP id 201mr29717306pgb.232.1561415414119;
        Mon, 24 Jun 2019 15:30:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzVvNJLRjUntwvwaj3Vo+MenCGzSP4fa9rhPFWFDOhAjMCYC3RLEIjRKVNFuBEsHCDKLic
X-Received: by 2002:a63:1d2:: with SMTP id 201mr29717229pgb.232.1561415413260;
        Mon, 24 Jun 2019 15:30:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561415413; cv=none;
        d=google.com; s=arc-20160816;
        b=owuZjBE5YcgjbWvMQbD7drVTkf0pwT+NaaoMt1SzvxDf+adXb8ykft2j/8vG9tuA+O
         9dWUkhvTrM7faLIWU9+ivUhbpK/Jm4S5aecm3H+RgDOeF8XHQOFKdRh3VAHGHXSuSQeS
         CzAsS5zC6U8BgFEHM90LvAaJnEnQ+6E0lqvqySIphmSNyu7ZOsYBcOZgwCAlkJcrU4Zf
         CCFMLsIAkvtNfD2d5G5Mcc3Y+9U25R9IsrtLr7Rst5gv5/QaFTEPwsjgZ9kjL17QCaNP
         O7vSpk3FqTEGbnsPvCvK8vw+xsB5S3cbdyT5fxy1VViUXo9NVsERXxgP7oaBegVnBX6Z
         4jvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=TFx9H37w6mZg+4Tg54qFCnWnzVBpXQ/B3y/2N1lbRw0=;
        b=kmd4tZ+zjIRvpopwiFFQ83fXr7zf+mpXHDkULsITJsq/SI8GGsGKH/G/Vi9iRy5LHC
         rdxnXKapMt8WqSPkOZunTaPS78MJ/BWP6L+stYrj1A245xRW3PiYppRGESmjufdy5acw
         9KOaZkW74ksKQ0ReSAPIWG2Y2PUC09Au3gaxB8plzf4YzvwNsmSNfFU+4WFBrP5NnV/R
         pj6/PckUwdgg7FCk+SOuSDl1QhpOIEFy8nbr2+XyE6jIknF7RKQcKV146Xj8dgQu4aXP
         L7texVyP6xCqjT/X/pe6kA9AnQO6sDNRv5brdsdf6NZ+6DAHeyX6h35iMP7JOOn3GFUJ
         0kiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nGoZgA4b;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m11si691790pjk.22.2019.06.24.15.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 15:30:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nGoZgA4b;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5OMFUoQ002405
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=TFx9H37w6mZg+4Tg54qFCnWnzVBpXQ/B3y/2N1lbRw0=;
 b=nGoZgA4bFIxTxSJpW45LP2xb0Gl2w2/yr7YJrL5L7/39wHrN1xyutk3JKAalrkR+AjIW
 lHPkovThuQR53Zax67lXLt8JyUl90HvrSf3ZJPHPxfVemD4e5F1MW+D91DdJmCFCAMUv
 LPPap67YCLStiu+1yAGQWgtgjAAUM+zaW9I= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2tb2vc94s3-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:12 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 24 Jun 2019 15:30:09 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4DC0162E206E; Mon, 24 Jun 2019 15:30:03 -0700 (PDT)
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
Subject: [PATCH v8 3/6] mm,thp: stats for file backed THP
Date: Mon, 24 Jun 2019 15:29:48 -0700
Message-ID: <20190624222951.37076-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190624222951.37076-1-songliubraving@fb.com>
References: <20190624222951.37076-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240176
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for non-shmem THP, this patch adds a few stats and exposes
them in /proc/meminfo, /sys/bus/node/devices/<node>/meminfo, and
/proc/<pid>/task/<tid>/smaps.

This patch is mostly a rewrite of Kirill A. Shutemov's earlier version:
https://lkml.kernel.org/r/20170126115819.58875-5-kirill.shutemov@linux.intel.com/

Acked-by: Rik van Riel <riel@surriel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 drivers/base/node.c    | 6 ++++++
 fs/proc/meminfo.c      | 4 ++++
 fs/proc/task_mmu.c     | 4 +++-
 include/linux/mmzone.h | 2 ++
 mm/vmstat.c            | 2 ++
 5 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8598fcbd2a17..71ae2dc93489 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -426,6 +426,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d AnonHugePages:  %8lu kB\n"
 		       "Node %d ShmemHugePages: %8lu kB\n"
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
+		       "Node %d FileHugePages: %8lu kB\n"
+		       "Node %d FilePmdMapped: %8lu kB\n"
 #endif
 			,
 		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
@@ -451,6 +453,10 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
 		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
+				       HPAGE_PMD_NR),
+		       nid, K(node_page_state(pgdat, NR_FILE_THPS) *
+				       HPAGE_PMD_NR),
+		       nid, K(node_page_state(pgdat, NR_FILE_PMDMAPPED) *
 				       HPAGE_PMD_NR)
 #endif
 		       );
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 568d90e17c17..bac395fc11f9 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -136,6 +136,10 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		    global_node_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR);
 	show_val_kb(m, "ShmemPmdMapped: ",
 		    global_node_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR);
+	show_val_kb(m, "FileHugePages: ",
+		    global_node_page_state(NR_FILE_THPS) * HPAGE_PMD_NR);
+	show_val_kb(m, "FilePmdMapped: ",
+		    global_node_page_state(NR_FILE_PMDMAPPED) * HPAGE_PMD_NR);
 #endif
 
 #ifdef CONFIG_CMA
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 01d4eb0e6bd1..0360e3b2ba89 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -413,6 +413,7 @@ struct mem_size_stats {
 	unsigned long lazyfree;
 	unsigned long anonymous_thp;
 	unsigned long shmem_thp;
+	unsigned long file_thp;
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
@@ -563,7 +564,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 	else if (is_zone_device_page(page))
 		/* pass */;
 	else
-		VM_BUG_ON_PAGE(1, page);
+		mss->file_thp += HPAGE_PMD_SIZE;
 	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd), locked);
 }
 #else
@@ -767,6 +768,7 @@ static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss)
 	SEQ_PUT_DEC(" kB\nLazyFree:       ", mss->lazyfree);
 	SEQ_PUT_DEC(" kB\nAnonHugePages:  ", mss->anonymous_thp);
 	SEQ_PUT_DEC(" kB\nShmemPmdMapped: ", mss->shmem_thp);
+	SEQ_PUT_DEC(" kB\nFilePmdMapped: ", mss->file_thp);
 	SEQ_PUT_DEC(" kB\nShared_Hugetlb: ", mss->shared_hugetlb);
 	seq_put_decimal_ull_width(m, " kB\nPrivate_Hugetlb: ",
 				  mss->private_hugetlb >> 10, 7);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 70394cabaf4e..827f9b777938 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -234,6 +234,8 @@ enum node_stat_item {
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_SHMEM_THPS,
 	NR_SHMEM_PMDMAPPED,
+	NR_FILE_THPS,
+	NR_FILE_PMDMAPPED,
 	NR_ANON_THPS,
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VMSCAN_WRITE,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fd7e16ca6996..6afc892a148a 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1158,6 +1158,8 @@ const char * const vmstat_text[] = {
 	"nr_shmem",
 	"nr_shmem_hugepages",
 	"nr_shmem_pmdmapped",
+	"nr_file_hugepages",
+	"nr_file_pmdmapped",
 	"nr_anon_transparent_hugepages",
 	"nr_unstable",
 	"nr_vmscan_write",
-- 
2.17.1

