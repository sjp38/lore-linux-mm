Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54252C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:22:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECA012177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:22:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nokpLwLB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECA012177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7CF6B000D; Fri, 14 Jun 2019 14:22:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A80E6B000E; Fri, 14 Jun 2019 14:22:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 870166B0266; Fri, 14 Jun 2019 14:22:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6591F6B000D
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:22:17 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id t203so3362272ywe.7
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=6bxx1gNBJnv8buDPtJpu3vg2bjki9c0pwt5/1gY5jag=;
        b=oBOuT/vmu+2eryc3MvRDy40VdHYYvQ73hQd3t4c861zLclf6k6c0YWZdtLMWFQG3VX
         6nKGzVo9VlfqvCU+XdDU9MoV3fuiHpeCBfse31TZgnl1VsKaSwLr/6PEaFS5jikA8qni
         GaSsLkx7XGqRGf48Mty49cbjO1KMl3SStJe/9Kp+6omV2DSbidIjTDjh40I2HNHImiiA
         V/5NAupTJqyT4Nlw4jxwKgriwGa7WSLKppX76xCBmWQbw/TJT6ZLi63Mwr5b6wJstMA/
         YmNU1Bd7V1vhGNXZGkUSJRTiLBRWjiALdmKvDNdeUWykosvwZeyehAj5ZjLL7C4zeWko
         3x7g==
X-Gm-Message-State: APjAAAVjB89JDCWQjcBjltvaCzQHwfjyvQVXzDqkl1lhjbzzTmHx+UCK
	dMf8Q1fAAFNWGJHAl5pVMwquN6yhs/7M+eZg/u93CmNzCQWcOZIbZPi98P+i+BH7kkrPeYaF8vE
	IMwgeGg3Ld86NaRectHQZzP+8AUm1NE7BllR8pp0QVjG9WZqKOrM4Tsig1QgFPvTvbg==
X-Received: by 2002:a81:8d4b:: with SMTP id w11mr46382864ywj.468.1560536537185;
        Fri, 14 Jun 2019 11:22:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVmpRuY01AM05FQHqP7NXuBRbCPq3wDotYXiPIPq3qmoovjK0EVIw/zu6k7xf5ttxM9kWi
X-Received: by 2002:a81:8d4b:: with SMTP id w11mr46382843ywj.468.1560536536639;
        Fri, 14 Jun 2019 11:22:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560536536; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+KPSxg7rYZzf04gncBaIlhMo3Nxwif2+Z6cWEberSXnLW7/yqxxwAxNrSRGFpckIA
         F42dHF69rd969SDOvq5Huj38GavZRSmH4M0wMpuds0jFfd9494mZ3MqtJ0MsYygJoUq3
         JPdBddRflles54wOUzdGJCj7HMYd6zOvH/yvFo6T47J8N4JLWhNyjvS+rf28dx3998z2
         dkzNGMyua6VLQsLhr3EpARV5ZcSJTY4LDonXHqs+BYyxwKqIbkZfh2IV5jU6e3Zs38eC
         yjFN3T/wwb09HpWDWqX+bgz8SO77pS77OLy18VlNwMNEmsQTVcQyJynRbJfBgfQ5jk9U
         +IEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=6bxx1gNBJnv8buDPtJpu3vg2bjki9c0pwt5/1gY5jag=;
        b=AmXMrRYWtaj1pDnLy5RTaeAzPIRCqzblD5LapTCy9WVNzJZm81Rw6HImk4f2uOs8yX
         nxr6RxSEnlPidVCMj5sg5/gNegQsXqLo/vEPi/4O17VFmon0OWj7C0hIym/j58DQEJu8
         7/Gg9Qtz86yxrJlihZ95yMmsGAf3cbek40MUzPvh9ERGUMRPxyzRxnJ+pDDD8i61Gph9
         NON3zvidGGTsmBu6m8lP0sJm+5fPcQ6vUtUyW4lx4rSLv+dlX2/kBZts6Y8UZ2kol9Ep
         kiV5uIfD90L266Ob9xJdZktZFOp4Azds9g3u6CAYeTYyEP1nGiu3vWU9ZGq5G7jjNT1S
         JvDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nokpLwLB;
       spf=pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10681bb08d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z2si1248036ybn.84.2019.06.14.11.22.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 11:22:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nokpLwLB;
       spf=pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10681bb08d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5EIJKXm027346
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=6bxx1gNBJnv8buDPtJpu3vg2bjki9c0pwt5/1gY5jag=;
 b=nokpLwLBq8i6kLPeX/O/5wcRocE0+cjNzi38HKrcAliDte2oUgR2Pwoz8scgvnvhvop5
 75zOeRAGD2cMG27JkTJPsLr2hDtjZ7WOD6KcFJ4lNaFF1UnC7yYDvlJulvWTxQ1nW1rp
 14hjVK1wJ/wo7NqkzIR6bvlOzZAStCbej90= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2t4915spmx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:16 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 14 Jun 2019 11:22:14 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4EF1E62E1CF4; Fri, 14 Jun 2019 11:22:13 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <chad.mynhier@oracle.com>, <mike.kravetz@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v2 2/3] mm,thp: stats for file backed THP
Date: Fri, 14 Jun 2019 11:22:03 -0700
Message-ID: <20190614182204.2673660-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190614182204.2673660-1-songliubraving@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140145
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for non-shmem THP, this patch adds two stats and exposes
them in /proc/meminfo

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 fs/proc/meminfo.c      | 4 ++++
 include/linux/mmzone.h | 2 ++
 mm/vmstat.c            | 2 ++
 3 files changed, 8 insertions(+)

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

