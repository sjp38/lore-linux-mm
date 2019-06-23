Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9050CC4646C
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B09920657
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="NH/YvZ3A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B09920657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE7728E0002; Sun, 23 Jun 2019 01:48:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B71396B0008; Sun, 23 Jun 2019 01:48:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 974F98E0002; Sun, 23 Jun 2019 01:48:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0096B0007
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:48:05 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g21so1116300pfb.13
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=DNX0Ai841ZgyA6yG9XH0uRWq8DS0N63a6b+fvROsjjM=;
        b=HGgWVB2NLdCQMQifdxZPOP1y2gqlCkWjID2BmegO+RmswNnz8QSSdg7baRbjj2Y3kD
         vXG7kzzBE1z+WkhLD/LwrNiHNmzxzk0com4YkCYJoJtXHJ1Pk5ONBiiDKaxdfXKpwD6M
         Y5jWJZESdEHaMJ82rrz238GGk8TdNQKuPjMy822qAweRkVQXzhGETtRo2tsiMtmBOlBP
         PlKZCpbAo1SyhccMqid1ECJg982ThuzZLgXklONIDXX7Fv1lLlw9E+fEZSVBn6kJgZMP
         bJE7/2swBpbVZqYI1I6nHUFBY2o8kSBBLqPY006NetXFa0C3o9yGHvYAmASBLpDNKQq/
         27Xw==
X-Gm-Message-State: APjAAAUNPA/lxeEgkR8QLdB7DRgpV7BPNI5PvPw1/2ZySDLUpEn+egeB
	Hkmm2HJgeKfNHrsZWVouoPd14ZUkYnzGKQ2+ObgCkLu3qTiUkDRy3ifbKGS+ZmuksDPaV0tGMCM
	HwCOcmn5jV9A8rnGmuadZ4HLiyvQk/8MpGDaRNB6IEq/7xB2jfrK3jbZZeaUgjy27Lw==
X-Received: by 2002:a63:e14c:: with SMTP id h12mr25472479pgk.87.1561268884375;
        Sat, 22 Jun 2019 22:48:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcVrOBTTqsFsHCIKhW5VNQ4sOUQ0PIWQXYrk1ztQ5WW32d41ZEpLBSegF4Kblm4BW9IkVr
X-Received: by 2002:a63:e14c:: with SMTP id h12mr25472444pgk.87.1561268883627;
        Sat, 22 Jun 2019 22:48:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268883; cv=none;
        d=google.com; s=arc-20160816;
        b=rEnXeCTVBicfCYNh8GVfXD57WdrncxubfmPTjSxxDrxm0UhJJ06OJPZz5c3skgcuKI
         yjL1OMMqXPWzYA5XExgdDCH6qHiWpBiEJdPuHqe+PWVstiVRZW+5hV4BwswTD2h0g2Wd
         qsnxH4fC3tAklDH2T9Ez9DtugtkgYKubi2ku/ON4RQVVuHzl+zS5pOWTEKe8LmTHzBv7
         YbyJ8Dem/EFP3l9du+9M1ED/4qUrmMNuuHOeex5ZliKaTJnUjQc0HxjRdd+KwS9AsoJt
         gLpUU8G9bKBoZgA2PXKkbt4PxWJ30pHn3Y04zJxevOg6NugiOrGSD6G/hvYmuWnaV4TS
         DbLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=DNX0Ai841ZgyA6yG9XH0uRWq8DS0N63a6b+fvROsjjM=;
        b=vlCzjUN29Sz5FsqVMUl7qg7nuvRDyCnOV+3dVyuTUhw8CVOYyNVXCgMZC+SvR6gTYa
         ZHxRY9Eqrb3mB0M5qE/2jZcg+KEZbKVXSN/WihVVu1YBNVP6Ws3LDatJdlVUbh2y6vj1
         3eU9OvLON/v1phE2HiVtdChhL55woRYbyusZxHUc7sBW+VgoCoRyv9sqtM5ftPG6Jxjq
         svpZoRrSvDEeRvCTwbQFCcvoYi9smN3Yn+yQ1AzErHqeQppZAOdRLr6NQNaPln9U1kid
         w/IRYGLVzQdcaebqYQ7aK3qDK90zjuAZdeIEOBcLJgu4Uwfw0oKXJj3b7fKPObMJ6dRa
         77Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="NH/YvZ3A";
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u13si6488959pgp.478.2019.06.22.22.48.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:48:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="NH/YvZ3A";
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5j1aQ008141
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:03 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=DNX0Ai841ZgyA6yG9XH0uRWq8DS0N63a6b+fvROsjjM=;
 b=NH/YvZ3A9KYYikbaXGSCR+tX0cwr+D9Chp5GcViw8hlPikEsX3+fHG262Aj1RKIOQO1y
 RMvw1/XiFKdn6YBEJDE71g9zSyL6shxagudVY6N8mnm5czXVJjctI3bSIyGwdMJEYJzG
 QO1P496Jx/B66gviXL93Zw3cZaj7vWNYeY0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9fn2ag9x-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:03 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:48:00 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 3B48462E2CFB; Sat, 22 Jun 2019 22:48:00 -0700 (PDT)
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
Subject: [PATCH v7 3/6] mm,thp: stats for file backed THP
Date: Sat, 22 Jun 2019 22:47:46 -0700
Message-ID: <20190623054749.4016638-4-songliubraving@fb.com>
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
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230050
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
https://lkml.org/lkml/2017/1/26/284.

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

