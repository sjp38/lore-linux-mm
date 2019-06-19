Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28F85C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEF6620B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="CVCpvvmr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEF6620B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7502D8E000A; Wed, 19 Jun 2019 02:24:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FBD98E0003; Wed, 19 Jun 2019 02:24:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C2428E000A; Wed, 19 Jun 2019 02:24:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC708E0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:24:42 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 77so18061909ywp.14
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=iFz1RdjWCbrw1b7w4eZ5iGWyb2zDfKg3QSt6me6ZtqE=;
        b=eF7TFIs9TCx8ANjmXiC0/WGsf3NbdhMtYrcRxsYcbKhzJUtPTRNqrnN6s889F/2etO
         bIgQIwUa91IiiCPJC6FJI/J46JSHkQ1oCG4IQEYCL5VNMuz8PDxjrN3GrN9/wMhoRlBA
         3zKxRc1LrPO6qQhNMKN234D4xZtCtjZ+pou5Ey9FhGnW4zizFcG+tiA8S36yeO6XZvnn
         4aveJzP73vUfI53MlIL4lRsQThwRSlAEjejmAJ0zQRwAdQBgRTM4X/C7Qy2cBN+gyOsb
         k84Lf+y9kQgmX5h56EVfh1M/ozgYns03ShKdqC0cK43GB5x6135Mez18IZx51UDJtR/u
         VQDQ==
X-Gm-Message-State: APjAAAV33iM9rlna+bMT+rh9kDH6EIgsciFOSxBB8T9Hyc4ksvM82378
	IX9J1eB/JmA4/ccZxsDbNZBqJRnQ0ct3Wyg8TcwN5DvReWruWZePPFu9RoAzwajSrtJy4PVKnf5
	6ojW0DfZNuBA0Nx2F0iFjFO93TA0wemxtOO8U+MBvw1scaFqWvnVV0Ne5olhIkDYblQ==
X-Received: by 2002:a0d:d6ce:: with SMTP id y197mr619799ywd.329.1560925481935;
        Tue, 18 Jun 2019 23:24:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz307hkH2rkoB32N6kqnwIlMx/t3hfcAvIEnB4V06aBNyjGQI5MDj7BVOVrHpMuuYn5gb7B
X-Received: by 2002:a0d:d6ce:: with SMTP id y197mr619786ywd.329.1560925481451;
        Tue, 18 Jun 2019 23:24:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560925481; cv=none;
        d=google.com; s=arc-20160816;
        b=v9ezVBN2dlrWP7VJL1KSzEAM3RiVjOF+uQrBFPyi3jfefvM2t2ThjrPhgaQb6uNqkp
         HB6bcGZ6p6mlQYCFo/DXdDhaarKGfRc/KBBCcD57ooloY3k77p3h8iYL0CqysCYsZzHu
         2OUzLY/+wyq+eQ8nMVECmUviG7mnF799eDfIAvMtt0M9yMKqr7dN19mL2zBY0cFjSyBT
         ojUijQP7wdBnSo6Ple2jFhf6myUcdSAZBX4T/9gmpSjruHYcbXL2ci9LbXz64Avrdkoq
         lreYeuSwbJBlEKtk4Uc/Md00eqUuuO8OqVnShQ/s6193cAFTgxaUNGPi7zQlSYTcVgT5
         Owjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=iFz1RdjWCbrw1b7w4eZ5iGWyb2zDfKg3QSt6me6ZtqE=;
        b=WijFVqzMZ9Fw2rl03VdQNdXLG2/2NFHiVxLm+YW/UfO/Ulwp0gWCP5nWFg2tZ7jIbk
         S2Ughpq5oKH+TrNsy9ubpD+w3WGpNZ7pdaelFEP1SNPlm73W3xHlXWj/bNxTaDYWuKdo
         BOOTzGqOxzkN6TOU7YmLJWMmJICxGUzT7Dv6PPY6nYX07CU+JeTJS3cMevVdTOMvzn6l
         3QjU6/tLFbsLkwpZaRyKzh31ExiNvMquT6c/9DIkDmH6tIUryRmOEaXFDypkvhJsDL8B
         Y8Bca4putteeyW5VgAC1vQIeuvPKJvBKh+PTKGq5K2bpKkO4Sa0sbNucuPYtrBWRQTGs
         KaWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=CVCpvvmr;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f132si6290615ybf.483.2019.06.18.23.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:24:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=CVCpvvmr;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5J6OcD7011458
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=iFz1RdjWCbrw1b7w4eZ5iGWyb2zDfKg3QSt6me6ZtqE=;
 b=CVCpvvmrty2+BmU8R61TTEjty064z3cQqZ//jbIofM1juXWXIdjB1yJInN2QpQjUQzan
 9H9A7a7RgQsLxPy+v7Btkc7zepdtdiKEXUlXnUqdkqCYrlC4IfaY6LyF/jJDXkY9PTBl
 5oDPADIQ/yoQpAdClpHeevLd2aD+ylblhjk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2t77yyhbnu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:41 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 18 Jun 2019 23:24:39 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 9B1B962E30AA; Tue, 18 Jun 2019 23:24:39 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 3/6] mm,thp: stats for file backed THP
Date: Tue, 18 Jun 2019 23:24:21 -0700
Message-ID: <20190619062424.3486524-4-songliubraving@fb.com>
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
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190052
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for non-shmem THP, this patch adds two stats and exposes
them in /proc/meminfo

Acked-by: Rik van Riel <riel@surriel.com>
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

