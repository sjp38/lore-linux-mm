Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E429C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 06:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1496720665
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 06:30:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="aZXkBDUW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1496720665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 783496B0003; Sun, 23 Jun 2019 02:30:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BE8E8E0002; Sun, 23 Jun 2019 02:30:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4005F8E0001; Sun, 23 Jun 2019 02:30:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05BB76B0003
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 02:30:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so6911290pgk.16
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 23:30:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Kr37aYRy2KacRNeWnEOl8WIgUYHSnWgZ3fV+borBCvY=;
        b=Yd/Q3MJ/GxONgxm4VxztR6Dlwfv8UVSqLx553ojdlk37llIg8cDBnm9qY9zezQxpNq
         JJXTfv/CtHl4JZkRgRbkYiQfaEvLJsSjYbWAj4movpio3EfFOlKwljyxJS0QExIKSyPz
         zxi+s9hp0kLlKdlePYpxunLsG4Vd6rZpATLdPl+eU9RmBfs5RbtQTQ+vLShDiG1YHGd9
         6E8oSFgaIogupY5ImGdScNL3q71hLcXlGEPZg1mtpxIn+7t53I4j+3geqflQp3key0rq
         4obOj3c3hKulC+lywFaYWvfpNqtorioMFY5PQuO4zsEP43p73j2QVkSRqNpLas0uEYl5
         HseQ==
X-Gm-Message-State: APjAAAUsbla4uE1V8aSBIy9JF+Nhndh8udkFSrFooNvuxjeRaccYaCFA
	Ls1C3G5iBVd8cWkixRNAnLA4TP4mnC0s2wEHzJ/OSFDQ8yIYVU/5yAF51h+aPO26slV2g1dB313
	4YPIL/LCqFM/Mc9ThHrI/cM4EZ5MkQjgJsn1WflccdDvppSgIUzhwjfozfY5IOWT4MQ==
X-Received: by 2002:a63:2985:: with SMTP id p127mr25130257pgp.400.1561271401568;
        Sat, 22 Jun 2019 23:30:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2+ge3rN+CgQnimZbpebE82G5AahAzI7rfLoSjnKVMIPvfEpWGkdSunA7m3/RuTJuHxJhw
X-Received: by 2002:a63:2985:: with SMTP id p127mr25130216pgp.400.1561271400695;
        Sat, 22 Jun 2019 23:30:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561271400; cv=none;
        d=google.com; s=arc-20160816;
        b=YBZGlIt9eAd0JaOJcD9pLC3C1643+pvFrrwzhzorrTKWTx6gpOuyT1ksn3mleoIJ5s
         23LDqso0q2BqtegYR/9L9goAzx6pAHQLuS1ArPWEH6ewrIBTUnHsGB9q1mUZZKX8Db0b
         g4KkHA1oUuUvv0kLuW7zsjUriy0fdQ7eaYyrBqC2q0t86exNCQdXJ9xLhNkwm6jxd4w6
         KqDxinD8vkYRL31FlBffWRbvZPXVSUMYYBTGovoib104FEGvfcG35EVEmuB6STQ0boGN
         6lw9XFXcnogv5sBZrktEtujGcIAbI/de4AqRxbL5mqAB+y3q/Jrv7kQjzEbbahP53bU0
         JBlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=Kr37aYRy2KacRNeWnEOl8WIgUYHSnWgZ3fV+borBCvY=;
        b=ybF2oYFAhEU1zjkqVuTeEmIGiEVrXrtgGbPK28/YsjSeU9J/CElIv3pfeFbOAYbVB1
         F1Cuvr4Bm2uGC9jBfDuqolGfMY9tBxwQ3lNHSRycSMnBplXOPnGw5kQideKaWcUZfQLu
         gPszh/xa6JvG60cjY8ptiLAAeThaZ8o6B+GAVOnPVecEXphgRcZazbD1S3Ox0Kri3ITc
         KgLrxXm3ZSqFxwuSM0LijwX6dGwprlgWlcvK9jVcKVjCblOc0LPo2bE1b26NS4fmAmuy
         vFdxXCB9JMUAj94Gg0qx+TnhakxBbMJV2FsnQiEDojacZQ5KeiJ7tIfELXmZ+dCxm+GG
         s7Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=aZXkBDUW;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m1si7082323pjr.47.2019.06.22.23.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 23:30:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=aZXkBDUW;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N6Ro97018427
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 23:30:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Kr37aYRy2KacRNeWnEOl8WIgUYHSnWgZ3fV+borBCvY=;
 b=aZXkBDUWBAxL6VM2VUmr2HhxlWoVql7hYob6GSLvl5bca4qxkLshU/ThbTI2qq8C0Zdl
 hYLatvDXMiRKVOA23zOhJz0n7mYr8EbPs7aVkeEFv/M0mn0/afxvtD7ZMtRlTsDLnOzg
 D+P+vBel+RxasIlfbOKqC1Qm4wgLJsdOxBE= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9kmja3gf-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 23:30:00 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:36:48 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 34DE762E2CFB; Sat, 22 Jun 2019 22:48:02 -0700 (PDT)
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
Subject: [PATCH v7 4/6] khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
Date: Sat, 22 Jun 2019 22:47:47 -0700
Message-ID: <20190623054749.4016638-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190623054749.4016638-1-songliubraving@fb.com>
References: <20190623054749.4016638-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=628 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230055
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
 mm/khugepaged.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 0f7419938008..158cad542627 100644
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
-		struct address_space *mapping, pgoff_t start,
+static void collapse_file(struct mm_struct *mm,
+		struct file *file, pgoff_t start,
 		struct page **hpage, int node)
 {
+	struct address_space *mapping = file->f_mapping;
 	gfp_t gfp;
 	struct page *new_page;
 	struct mem_cgroup *memcg;
@@ -1563,11 +1564,11 @@ static void collapse_shmem(struct mm_struct *mm,
 	/* TODO: tracepoints */
 }
 
-static void khugepaged_scan_shmem(struct mm_struct *mm,
-		struct address_space *mapping,
-		pgoff_t start, struct page **hpage)
+static void khugepaged_scan_file(struct mm_struct *mm,
+		struct file *file, pgoff_t start, struct page **hpage)
 {
 	struct page *page = NULL;
+	struct address_space *mapping = file->f_mapping;
 	XA_STATE(xas, &mapping->i_pages, start);
 	int present, swap;
 	int node = NUMA_NO_NODE;
@@ -1631,16 +1632,15 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
 			result = SCAN_EXCEED_NONE_PTE;
 		} else {
 			node = khugepaged_find_target_node();
-			collapse_shmem(mm, mapping, start, hpage, node);
+			collapse_file(mm, file, start, hpage, node);
 		}
 	}
 
 	/* TODO: tracepoints */
 }
 #else
-static void khugepaged_scan_shmem(struct mm_struct *mm,
-		struct address_space *mapping,
-		pgoff_t start, struct page **hpage)
+static void khugepaged_scan_file(struct mm_struct *mm,
+		struct file *file, pgoff_t start, struct page **hpage)
 {
 	BUILD_BUG();
 }
@@ -1722,8 +1722,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 				file = get_file(vma->vm_file);
 				up_read(&mm->mmap_sem);
 				ret = 1;
-				khugepaged_scan_shmem(mm, file->f_mapping,
-						pgoff, hpage);
+				khugepaged_scan_file(mm, file, pgoff, hpage);
 				fput(file);
 			} else {
 				ret = khugepaged_scan_pmd(mm, vma,
-- 
2.17.1

