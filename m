Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F00D8C41514
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A76052084C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bTxYL4j2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A76052084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59E156B0008; Thu,  1 Aug 2019 14:43:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54E866B000A; Thu,  1 Aug 2019 14:43:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 465486B000C; Thu,  1 Aug 2019 14:43:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 262046B0008
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:43:13 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id i73so53627069ywa.18
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=LfQYj2OmrExzc7P2TypmvcyFMxGAqWp8dejToxaSLG4=;
        b=tVdGEF4QMofKQI90yY9pvlYxA4+9sWJvEyKwKYaSzxqW0YYjRVaMGm2srtWBfu0ixZ
         jReTh0gryUuGSj0ukI042c+1cfj9PeXhmBLvUpGpWaBNKrN7KtWodMp0zVzQXO6bHhl+
         8gd5ibNQ1v6F9namcH1VStzWXAFPVeV6DhincGa8d77S3dUoNuL76yWKf0Mn9iJR4LiE
         vTLnG1KUPivewkwwzX+3+y0cXAaC1HO1/daPFB74ZlSC79v6KpRHkRgLQGJ4KXEISe2M
         zQjiTY7yKYw/C+nMS8h2Mm3EbAZqwU2YT/PawXsjyUbWZA8/j2/VZe6JVmGs0b8j0Xzr
         95Qg==
X-Gm-Message-State: APjAAAWgsglB6pt6YuRiQ7Vl3OkfxvJvto32nlzcKmRWllj2WsCt/mDu
	f3/pAN6tlR9douvIBatgnLhOdGSJHYjsmqho/TNuydNKiqWKS7U99fXei65vupyPfJTpgRI/cO8
	GAesqc05nvj7TWQ8vI5EKKdkBbnNMT04NxygVLf2zAhemqVHk+ROHsWzUd2qAsMcbxg==
X-Received: by 2002:a25:8602:: with SMTP id y2mr82279881ybk.483.1564684992867;
        Thu, 01 Aug 2019 11:43:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGbxYPm82ATccbXoOT2XwjMOjGY/xR9vGlBKw55KeST3JfSYktFfMWDKPzNSyUudyD6J3z
X-Received: by 2002:a25:8602:: with SMTP id y2mr82279851ybk.483.1564684992240;
        Thu, 01 Aug 2019 11:43:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564684992; cv=none;
        d=google.com; s=arc-20160816;
        b=rvVf5ZmKSxVt9jco99jjm2/HMPRLxuoUhKVx69T+gAvf1USXrT+Rw0RET0ozIGYhcE
         2j+gOceNCwAhLrP6aVs+jH64GZhi4hWEWGnQDzvbA+94AzWKTYXg1ZBzkvE+77XeATEQ
         LqeXa8fjOE4kIHVYmCx1OMAEukvsElGgHunGK6cdLCxtzic1N/p7sgtnfwumTm1iRS61
         s4+kToTtVNzgwtSFwZ8GKRJF9XpewBOS9hxNW7FCDs7X0shwxe55wEUBZYXNFrwdE9+A
         6sCyybwq+dNSu/UduvEodtMCsnArzZq44efNTR64seO1xG3r/ClboGCocq+ud3IyW1xs
         Y2eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=LfQYj2OmrExzc7P2TypmvcyFMxGAqWp8dejToxaSLG4=;
        b=hvDWHY+O6maQ/eJe1AzN/ufBFqt70U/tdDl1iDdGhEkjRmZcNTh4ZJDlD1sGDwU6dH
         hyIUXe+qi4YXCTZZxIWCfQsn3EOWQJULReOMtfuG/5cOu5s1kFUU0JSGZ0SpcCIfxYUr
         /Gjueb6+Do2eX/eBygHo1iDC5S7N1hL9b63tasrwLY+7VeL/i8Mq311ZEdIwMKYc7JKb
         P8GI5wct1O/lozvBNVkZQOnwl6JH5p2qsXp7UOBZ0fge/6IsWoa+LDdWs1hhmSSCIQeN
         O/29T+7ky101tmbLQztjiJZCb65cyphnOLK8R0P4aFl6WlFtPRaRsd/EApYeg0Svok3d
         UVpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bTxYL4j2;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id s63si8299050ybb.108.2019.08.01.11.43.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:43:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bTxYL4j2;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71IbsNR023547
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:43:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=LfQYj2OmrExzc7P2TypmvcyFMxGAqWp8dejToxaSLG4=;
 b=bTxYL4j2Z5s+bEHcpcypRHjABvPo0Jc+onbph55Rtptzyb5U0Vp6QMeZKHCG2US+4RgA
 krB5WdEHYjHv+Yww7rfbrGIXSTTcaEVqE2k2TDUo68HgbeXRunY4JXmPRR4dwi5pcj24
 JQYT3boP+Q4AFIK44WNPme7z10Tj1Ps+vVA= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u435b8nw8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:11 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 1 Aug 2019 11:43:11 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 5FCE362E1E18; Thu,  1 Aug 2019 11:43:10 -0700 (PDT)
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
Subject: [PATCH v10 4/7] mm,thp: stats for file backed THP
Date: Thu, 1 Aug 2019 11:42:41 -0700
Message-ID: <20190801184244.3169074-5-songliubraving@fb.com>
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
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010193
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
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 drivers/base/node.c    | 6 ++++++
 fs/proc/meminfo.c      | 4 ++++
 fs/proc/task_mmu.c     | 4 +++-
 include/linux/mmzone.h | 2 ++
 mm/vmstat.c            | 2 ++
 5 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 75b7e6f6535b..4f2714ee819b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -427,6 +427,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d AnonHugePages:  %8lu kB\n"
 		       "Node %d ShmemHugePages: %8lu kB\n"
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
+		       "Node %d FileHugePages: %8lu kB\n"
+		       "Node %d FilePmdMapped: %8lu kB\n"
 #endif
 			,
 		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
@@ -452,6 +454,10 @@ static ssize_t node_read_meminfo(struct device *dev,
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
index 465ea0153b2a..82673470dde7 100644
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
index 731642e0f5a0..1ea7d730774c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -417,6 +417,7 @@ struct mem_size_stats {
 	unsigned long lazyfree;
 	unsigned long anonymous_thp;
 	unsigned long shmem_thp;
+	unsigned long file_thp;
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
@@ -586,7 +587,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 	else if (is_zone_device_page(page))
 		/* pass */;
 	else
-		VM_BUG_ON_PAGE(1, page);
+		mss->file_thp += HPAGE_PMD_SIZE;
 	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd), locked);
 }
 #else
@@ -803,6 +804,7 @@ static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss,
 	SEQ_PUT_DEC(" kB\nLazyFree:       ", mss->lazyfree);
 	SEQ_PUT_DEC(" kB\nAnonHugePages:  ", mss->anonymous_thp);
 	SEQ_PUT_DEC(" kB\nShmemPmdMapped: ", mss->shmem_thp);
+	SEQ_PUT_DEC(" kB\nFilePmdMapped: ", mss->file_thp);
 	SEQ_PUT_DEC(" kB\nShared_Hugetlb: ", mss->shared_hugetlb);
 	seq_put_decimal_ull_width(m, " kB\nPrivate_Hugetlb: ",
 				  mss->private_hugetlb >> 10, 7);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d77d717c620c..aa0dd8ca36c8 100644
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

