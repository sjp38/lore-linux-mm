Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA483C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65A4120B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="io6Ul3MA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65A4120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74AD68E000D; Wed, 19 Jun 2019 02:24:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 723C98E0003; Wed, 19 Jun 2019 02:24:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59C0A8E000D; Wed, 19 Jun 2019 02:24:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 203178E0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:24:51 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so9243230plp.12
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=UcBQx3V3cM3XT9Fzx7VrthaHanV1PsrKo4nQSd3ehcM=;
        b=sPDp21Byyqjgg7AOTBGIXfqB5fVr9aNybz5jdFsa0veON505A+HLsnUB+sfW9Zivwg
         I62M44GqHuvcFlgDK8L0VU4U8iyjMWzA3nzsqafiF2ZdMmImpHAlYZhMSeO8W672few1
         ZaxWPsQckCrHbMxJgY+1BszKygtoBFblpi7va0Ev12tN3PX7p997lZNRycDaF36c9Ke6
         rMNDH/Tq721QkSqABCJbW7gBEVWjYbtACdaGQ7+68A44hmHGvJKOK2KnEMtIFsEMUPyJ
         GLbxpwNfYeB4JIcpiCYfuQeoJN0koni1mXIHX31MUJPnJCmxPdpOSj4LL3P2laJI+L3F
         5adg==
X-Gm-Message-State: APjAAAUN/eHJAXkIHyJYwS/ArIiQXC2baiktfAgioRMAwhKJi434jtsM
	g8ECuw+qHTeh+d03VBn0SEIDtbab75on4z7jCraTD4BqDYz0zsSRMzatIqYWSIkamDxYFG+hxS5
	J+X/jcH2nKiHy1TlwdEredzyNjZyDdXmUDf6cBDVGs/IpMzls33RIMbrse+3re2sQwA==
X-Received: by 2002:a17:90a:cb15:: with SMTP id z21mr5580297pjt.87.1560925490713;
        Tue, 18 Jun 2019 23:24:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8/y1eVlcpUK5J0xNgCIhIw6wQIzrRbl4EWK8Le5ofLC41jnTYr2kRcI8rk3siKnK+RImC
X-Received: by 2002:a17:90a:cb15:: with SMTP id z21mr5580253pjt.87.1560925490067;
        Tue, 18 Jun 2019 23:24:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560925490; cv=none;
        d=google.com; s=arc-20160816;
        b=NwYBERMvlcJOxRF1ULAgA1zJIjexX/AfpvpXLsxD1IP+g6w+6mPHsDs8JKogvT0ZN4
         ufu73ESC/TLbajsGAiwUpBlfU9uzras2oi4G/XICiT/+o80WtduNV2uoZmyunrOKoVQg
         DThyQE6KrMpyHBdguUCxjQzvxRRSvHijZxcpS7UV58bqCBYnMLSlOcHuqrs3wwnWXlW2
         zJHw5M6oWSZZtodPXLhnmxrGLycfKFDaiLJ/ThdZwUj2asjDUOW3/LJ/QkLwp3qH3VB8
         mI2uiRD6DKLX4Gzzz1aYqTYABts+4u29+jH+L6NLscDhBx1VvzqoWBWRshv7M5oXtmCv
         7Vdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=UcBQx3V3cM3XT9Fzx7VrthaHanV1PsrKo4nQSd3ehcM=;
        b=rOgccFFuxRCiLQPsk2oXoKmaFSudipDupqwj4xYibWSP89RyYF2PKY5lpoyTSJmQqG
         +yM8L2kIjPlxGMOy6P07l2pBpEZ70oaRuPz5wC+teuLGcQZpgsm0qUvgOjNpUmbdBBQN
         we2ge/58Cd+V0pgTsl9fap4YDTVXhaUo9aXnJE1tjcow69TNZ9xoMKCK63FNwxhrYTwd
         bGVYcA+7ZCv9a2+yOzAdjY1AcYoZP5W8svcjKEXxFdspC0HHF5tRPcViMD/VSL7+uTJg
         /GTqxyzZjKDupEnmNw2+Q/Y4wQxDYOD1rXah73HJInpBEj3szWPiUsMYuolnd+poxt9j
         FPuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=io6Ul3MA;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u2si2304691pgc.87.2019.06.18.23.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:24:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=io6Ul3MA;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5J6OniT014215
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:49 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=UcBQx3V3cM3XT9Fzx7VrthaHanV1PsrKo4nQSd3ehcM=;
 b=io6Ul3MA8HC/k5AERHzQ1h6EMRVFblG2QKDHlpT2COIFF1L3+j3aJ2O2fQ/JjSbkUMLF
 LaIkgd7fh11ZH4Dfduqcy8B+KqzdNkhkTXruSIL1Xy7Wt+t36fCzHjhK6NnID0ZdDJDX
 2VNobPbyrQLzbI1p/Wr7QhNMRVYj9sOAbPM= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t77yusdtj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:49 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 18 Jun 2019 23:24:42 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 603D562E30AA; Tue, 18 Jun 2019 23:24:42 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 4/6] khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
Date: Tue, 18 Jun 2019 23:24:22 -0700
Message-ID: <20190619062424.3486524-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190619062424.3486524-1-songliubraving@fb.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=492 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190052
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Next patch will add khugepaged support of non-shmem files. This patch
renames these two functions to reflect the new functionality:

    collapse_shmem()        =>  collapse_file()
    khugepaged_scan_shmem() =>  khugepaged_scan_file()

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/khugepaged.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 0f7419938008..dde8e45552b3 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1287,7 +1287,7 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 }
 
 /**
- * collapse_shmem - collapse small tmpfs/shmem pages into huge one.
+ * collapse_file - collapse small tmpfs/shmem pages into huge one.
  *
  * Basic scheme is simple, details are more complex:
  *  - allocate and lock a new huge page;
@@ -1304,10 +1304,11 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
  *    + restore gaps in the page cache;
  *    + unlock and free huge page;
  */
-static void collapse_shmem(struct mm_struct *mm,
+static void collapse_file(struct vm_area_struct *vma,
 		struct address_space *mapping, pgoff_t start,
 		struct page **hpage, int node)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	gfp_t gfp;
 	struct page *new_page;
 	struct mem_cgroup *memcg;
@@ -1563,7 +1564,7 @@ static void collapse_shmem(struct mm_struct *mm,
 	/* TODO: tracepoints */
 }
 
-static void khugepaged_scan_shmem(struct mm_struct *mm,
+static void khugepaged_scan_file(struct vm_area_struct *vma,
 		struct address_space *mapping,
 		pgoff_t start, struct page **hpage)
 {
@@ -1631,14 +1632,14 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
 			result = SCAN_EXCEED_NONE_PTE;
 		} else {
 			node = khugepaged_find_target_node();
-			collapse_shmem(mm, mapping, start, hpage, node);
+			collapse_file(vma, mapping, start, hpage, node);
 		}
 	}
 
 	/* TODO: tracepoints */
 }
 #else
-static void khugepaged_scan_shmem(struct mm_struct *mm,
+static void khugepaged_scan_file(struct vm_area_struct *vma,
 		struct address_space *mapping,
 		pgoff_t start, struct page **hpage)
 {
@@ -1722,7 +1723,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 				file = get_file(vma->vm_file);
 				up_read(&mm->mmap_sem);
 				ret = 1;
-				khugepaged_scan_shmem(mm, file->f_mapping,
+				khugepaged_scan_file(vma, file->f_mapping,
 						pgoff, hpage);
 				fput(file);
 			} else {
-- 
2.17.1

