Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A66CC48BE0
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:06:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE34820656
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:06:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="TkB3WEMk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE34820656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81DCB8E0008; Fri, 21 Jun 2019 20:06:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77EFC8E0001; Fri, 21 Jun 2019 20:06:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66E7D8E0008; Fri, 21 Jun 2019 20:06:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB248E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:06:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a125so5318168pfa.13
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:06:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=n2snFM7QmmPTPpShlBhEnsGKC2i2/uKCmCMTseCu52k=;
        b=QksPa2C9reR3caIS1v1fiXIJDHiL4/jBvVnRW0wPxN5xY8amzWoAbGUKt2QzRaB961
         zK+8RjSxoKudi0J0PP942T0rT5eIv5muhm0VllbPz4KXMP+AJ4MHwBIZ/p/R17P31L7s
         G7ZJhHMSc4BVbCoeR+1zF1qJfd9nEfWdiYElXGKSlEgi0TJ8m98dkSLdgref4Zs0FHrN
         KnhXIWggPn91C6/mv2DI1Lq9aRnJHhnHyHwFHLT6FOfWAEaZWZi7gepfjaDAbXsBivcz
         wsS5PeLlj3C91iIScF/+2nstH+8A+8ef5WVwqckAQS9yohHiTnir1Bv0OUw7v27GZNQt
         zwZA==
X-Gm-Message-State: APjAAAXS1gt+ke+oKfd+t8Ky6icMFYZajShExGmGsyWf+91dswJ/1RXg
	3crwzAh/lj46/fEXExPJPuvooGSHkwriqCW9ihxZe+ZZfOJqk9KDKXSnme5cR9v9PqJeEEJsVgZ
	imoNlDvCPL8evbZaEBzJXR6axmyhFLBQm5rQUWluzSuRLb6wSrKzdobkl+Ik6pU+XnQ==
X-Received: by 2002:a17:90a:9b8a:: with SMTP id g10mr9745439pjp.66.1561161964846;
        Fri, 21 Jun 2019 17:06:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrVy1yCyj8WZrvovOhgQLga3HuVLAcj/CqSlSWYXGlhbPJ4vtEO2VdIskEGalWM4ulvxWW
X-Received: by 2002:a17:90a:9b8a:: with SMTP id g10mr9745384pjp.66.1561161964218;
        Fri, 21 Jun 2019 17:06:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161964; cv=none;
        d=google.com; s=arc-20160816;
        b=zUPYZiM8x4jo6cSFZgGOU51aXPiaWYKUJAMBqVie+DqkuNMlJMgAR6jaeuPW5mvdp7
         9R0EZsK8H7frHhYb2qry7FMnQ5v38nP3ymuNPJ6KARq0JUEUqTErpGdKA48JAucz0sTW
         7sNTAlJGEdT2rhPaujH1tronv+zqOKmRTf1flX0hYcccicLYk5vfVobESwGWSK4A1nTu
         qqIt0eDfeRwCoKFHDqMZe/Www959slJssZZQ1wVcYq7DOp/kepUIIzEufe2JTBTl8Ohb
         NphKGEXR8rHYldmyGmSOXNjqcwjsBT9TD5yLXPCARx0KGze+fDNfHGC2SWpnPWZv9MON
         farQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=n2snFM7QmmPTPpShlBhEnsGKC2i2/uKCmCMTseCu52k=;
        b=AgHlEw9TGW1gRHxoQb7sET9sXltk7GDSwh8PqQYBsQvkernpYaLIyLgUhU8Xv2SYJi
         9yRZUHVb+CEK7ask7IsBF2jN7pRTwjYbTyl/wFNXCql7yyVavuFB/qhMg1/qQeHGaiRh
         e/pFwA/2mHzFTVfbYBuqSpMUY8M5g72r8JxKO4voo5tK8U0woWwyxnyl2/LauCkqn0yi
         v67zk+EckvoRoR8g3rNu9BzHXDbGp610QdJ5k8tZ5SsMn9ic2OFeTR3FHvU9Nn1DoELi
         XXoWVgZ4DbTofkvH56bKjvpDmgq5GUk6w+X9rza6kkTFf4PuT0fMoRvXyPhKWzc6qnGJ
         qexQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=TkB3WEMk;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f4si3881584pgo.216.2019.06.21.17.06.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:06:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=TkB3WEMk;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNt1fZ005696
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:06:03 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=n2snFM7QmmPTPpShlBhEnsGKC2i2/uKCmCMTseCu52k=;
 b=TkB3WEMksGPkiSgJMtbOi5nd60Vn9LkBFGWBLqllbfRHKqjMvyN9xgpjLMSBxiNsT59u
 xXSjznVWMZNCtWyTtBnc2LUl/YYmfYW56N4xJiuIsFr+y6Qe5ZFFAOb3Jro0mEberPQs
 hJx7W5AQaf95gqEbevnn2c0lR2ZmiRAx+Bc= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t90mjj1eg-5
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:06:03 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 21 Jun 2019 17:05:27 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 1BB8B62E2D56; Fri, 21 Jun 2019 17:05:27 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 4/6] khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
Date: Fri, 21 Jun 2019 17:05:10 -0700
Message-ID: <20190622000512.923867-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190622000512.923867-1-songliubraving@fb.com>
References: <20190622000512.923867-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=563 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
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

Acked-by: Rik van Riel <riel@surriel.com>
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

