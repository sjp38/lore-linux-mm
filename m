Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14B70C48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFFA42064B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="c3uhS5dv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFFA42064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62C296B0008; Thu, 20 Jun 2019 13:28:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DC6D8E0002; Thu, 20 Jun 2019 13:28:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47C4D8E0001; Thu, 20 Jun 2019 13:28:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FAD16B0008
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:28:18 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z10so2200277pgf.15
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=n2snFM7QmmPTPpShlBhEnsGKC2i2/uKCmCMTseCu52k=;
        b=paT8FBn0keMvk0GJ/BbH3sc/wGkGtSkmG+SobticI9SR38o1is4tVT4ZavK2Q6tUlV
         sR22XH8VIF8PUayDtiyhF78WsxaxUfkSipu3LkQV66qXrzFmDPGo/MNc3bQQ9G5LK+oX
         MqC/1id2hNi7s7OTyAlj2GsgfTHm0FHpz0LH2vCT2uAhY1Qc8d7ia+ArJ7+W0y2ZvsaS
         4sbQYYCJZAyNvtIjT5dQjx/RvzpOMXuGxjQVAYhS3WTo1NtdvY8ROWFWqobTftjuDIux
         Wvmt0TxBWwLH0aVOCizzb7cpunlXH2uEC3RrMeHmANkvbJ7iN6Fmu6ZeWdMwo84dg3If
         D73A==
X-Gm-Message-State: APjAAAXyiugtR8DJNyKEqppQbPmwco76xJrgDazYDANOlrtnvaAHlj5L
	XZeOIrXS6ygjt47Kap9If1n18uOhbW0QFCkg0nfBEuu7jjVbL91t+zRZrCLbjhzqNrOwUL+u004
	1eRDX329YNFxwv9IF82fCNIODkY6FT8GedMsqyFJwKNHxe9LwBWGcdQ8iAQIuiXJUkA==
X-Received: by 2002:a17:902:b7c1:: with SMTP id v1mr33194838plz.85.1561051697688;
        Thu, 20 Jun 2019 10:28:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNKQ79Pn0KuQ/tNWSxl9dnHKRFNQxgVQSb1sKGKA1gOk58QTn97BipQWiqtJfuWPmWAVs0
X-Received: by 2002:a17:902:b7c1:: with SMTP id v1mr33194791plz.85.1561051697043;
        Thu, 20 Jun 2019 10:28:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561051697; cv=none;
        d=google.com; s=arc-20160816;
        b=ZAhTb9+JFN9sHNY8K8wkFIrn8rSVSxtM2y/0cAHVioWrNl3moOel8WIxapLM/tynmZ
         N+jq1INxQU5N57i0IiFG1G1+WCQPGtybkN+jwyDs39MOkFVc5f85YmwLWxmfz/xRq63k
         22VrMYI7FaHosDEo6AaeIIbP3r9WiXkAa9G1et8rUtkx0ue/N/oLjMvsG8+wmpWWGYF4
         VcKJqE79V+v+6JaPBMmGYy5hCHKFxjOluBAHht0XlLS5nSZH1v81ct+tJDfArmQZcISf
         kRyeX9BOFMLjnsxQZYKIunBRFaCga6od40Ep7nsy/J4DWPgMpA/7J3uLAVZ3xmPaYZcQ
         IWSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=n2snFM7QmmPTPpShlBhEnsGKC2i2/uKCmCMTseCu52k=;
        b=EEBzvARewC8aisJDg3LanykFR9LnEaDItPQGvQcLdU5PiIIst9dMDVxNuFKXP46728
         r0MdF5MWJ5O+UiZ6w8DzHJNk1F73CGYStQYYQfrXdUi0qArZnD2cW1ObWEk4VNp7IYlE
         Hr4FouAKuz4PoO42D7KVBlyHHzObJ1wntMXuL+Ld722l+dffn6Mr42yH9MEcQgpqeop+
         38h0IaBiwLrrDKIK+7K9pt6qw4L9CuRc750TyJDYAlSwngkbBovoDn8u3dCy/mmQK4Pu
         MELL5wUX/caPrZdP7hH4kD0z0E6VQtX2/QM0X7vMUM/4gec+bgQN9HD+99rj91JWjFrd
         0qCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=c3uhS5dv;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x3si276276plv.26.2019.06.20.10.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 10:28:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=c3uhS5dv;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KHKK21021503
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=n2snFM7QmmPTPpShlBhEnsGKC2i2/uKCmCMTseCu52k=;
 b=c3uhS5dv+i1TaGkWXy4jxAx8EgvqHJeArMxxJXK1A2gC9DEhwbjC9rTkoHSHJStPZ/7x
 GGwY3MNdkh462FJ7vQzguq+h3Hj8ZMXvPbOhJFCDjZTranrnwk0tf3TPHksf8l8WkZoc
 2Eodc4phEC+6YIQ3P8hIadXuYucvgWgiGNM= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t7wrj36sg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:16 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 20 Jun 2019 10:28:15 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id C1F4B62E2004; Thu, 20 Jun 2019 10:28:14 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 4/6] khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
Date: Thu, 20 Jun 2019 10:27:50 -0700
Message-ID: <20190620172752.3300742-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190620172752.3300742-1-songliubraving@fb.com>
References: <20190620172752.3300742-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=567 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200124
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

