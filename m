Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA193C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:22:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8662520896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:22:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Oak3fSM0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8662520896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66A5B6B0006; Thu, 13 Jun 2019 01:22:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F3186B0007; Thu, 13 Jun 2019 01:22:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B94A6B000A; Thu, 13 Jun 2019 01:22:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5256B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:22:03 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j68so19864316ywj.4
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:22:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=6bxx1gNBJnv8buDPtJpu3vg2bjki9c0pwt5/1gY5jag=;
        b=gitIy+svX+DH7XtO19ozFJlMK2XubsfZybZqcJUkZnVh2z1fxWDy1PNrvSThwmTyBx
         PpbTrPELSXVdE29KQj+sbH/2uTGlQNQkPzzgb5BKBjp8GqeB6RW2mtV4/1mp5GUHAdDq
         2h4K3VfNs+kE5TOn8l8QYIDTNJXmz7R0ofMi8fHXvhtPwzTWJhDgkBYEigVz41rbYCLH
         hGGVAHpSrzQxjl77nBz1tiwa+w8szUi1oyhNIJBLIh7hxE3cBc/KIOwKGowUlLbphSpd
         ZzPHTIiEY+VhtFVxGyfGkCFBY3YOpU5PsSPpAeRCuquq5QZNZcQhRz+Y9pBlDORNZVZ/
         IOHQ==
X-Gm-Message-State: APjAAAXD4xqQc2uLiu8euTNdt3V5ruedPutnEmJ0F64uWvLUC7V4vnAH
	lGGrV3QCFAMChYE98Ixn/yOu0J8GWbfn1stlKIq6oTAdQSfeD6VG3s2QOl2ZEDCeEZ2PSIv2F8z
	vwHVe4NYb1ybQ397tS7YLlFiLlibLOjR/y0VhkU9jCvmTW6uGmQmSa7AqOFZQfUe/Lw==
X-Received: by 2002:a0d:d853:: with SMTP id a80mr35565005ywe.426.1560403322824;
        Wed, 12 Jun 2019 22:22:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5RjbQDkpREzmSXiFqTcE6DYqTM1NfAF++G7vt4fsrKKwREsvyT0Dc8YK0DJ3Khh30mUKy
X-Received: by 2002:a0d:d853:: with SMTP id a80mr35564994ywe.426.1560403322328;
        Wed, 12 Jun 2019 22:22:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560403322; cv=none;
        d=google.com; s=arc-20160816;
        b=vcOJynnOgB4TgeupA6/hdBu+XjP96qGMX0xZcK/HxzVVS36r3LHGBsu8c+UdC+KJv5
         c2JTBzmdRvAo8jP6BCHLv/McZHimjVnX3vPib/aSoLluyMnjOa4k74GCraEFrESut4Z5
         PBlzFFPQasVdkS5Vro4MyTKegeW29+rlFrKWpvgUA0k0SNmvMh+II6LR2RpdPNrC5yIf
         vQnZhRmpJIkFukv0K9UfeNuY0neFrowvC58+X8Pp+DgBFENzPMQ+3DA1KajPRPzSlS64
         Z3gMep+4J3Y3ZiQ/ilmsM+MD3nZLj5YgKZ/2uy0Yfl0gftQjvQvomzavqQJc5tW0pjP2
         OSRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=6bxx1gNBJnv8buDPtJpu3vg2bjki9c0pwt5/1gY5jag=;
        b=AAumg4db626i+kpTnn2J47tJSbIvphMPF+0ocYcmqBWo2spDk/B6cDsxjQZ715OK8k
         jntnAfgF893G/Qlq4qGcWGtNjuZxeBZ/g8a7LGF5tP5gHG2zJnWsDwnT5HHMGrT5smAI
         VhT4R+iRtm2doiCiLiJY+asqU1JiK1LU9oCicrHAP4JM8/BKAfV1VUS6nzfKnYhxuoUh
         /ZfCXxI6DCprrTWs5VkxRrg7JqNZXajQ5AosdBLr2Twl3KWHa5+yCvKOToxQNlg+Y5vh
         KbtZgb5qfFsoDSZM302qWy6Qtn4RdSn9xfPyPBQnKBd8u8ca3Yjh1y0j0lowV1/JH+7O
         fhjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Oak3fSM0;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u4si610468ybk.233.2019.06.12.22.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 22:22:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Oak3fSM0;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5D5GesM002380
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:22:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=6bxx1gNBJnv8buDPtJpu3vg2bjki9c0pwt5/1gY5jag=;
 b=Oak3fSM0yK0P2N9ojsALhTEKA8oeeqqdpqX50OCe0XZlogs/31LxD/cnFSdPR1/NBKim
 9SzMrWJ3ZzHsyk0RIk+PdTHMVVCOBi68C1WLZHXNkpncdFadPWcC55kTWvTK4rWEud9N
 SWZbVVgrwg9fpqShmcqYZyjsXdcUpp/VWjE= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2t3a7dgy1s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:22:01 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 12 Jun 2019 22:22:00 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id ECB1562E2FC5; Wed, 12 Jun 2019 22:21:59 -0700 (PDT)
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
Subject: [PATCH 2/3] mm,thp: stats for file backed THP
Date: Wed, 12 Jun 2019 22:21:50 -0700
Message-ID: <20190613052151.3782835-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190613052151.3782835-1-songliubraving@fb.com>
References: <20190613052151.3782835-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130043
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

