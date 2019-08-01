Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9BBCC41514
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0D8A20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="PFEjq2jj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0D8A20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B2F86B000D; Thu,  1 Aug 2019 14:43:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 466386B000E; Thu,  1 Aug 2019 14:43:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3F76B0010; Thu,  1 Aug 2019 14:43:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 004066B000D
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:43:19 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b63so53623642ywc.12
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=AzYai9sTcIKTsjMHtj4n9MazMkcrW4fTxycCVLF20+Q=;
        b=WhLr94DjcANv0A2EV8PueooqwoXoWxSzeLDCoeLwdzKEqPyErRY6C94vserwqP8FZL
         l9OeV0acUx2wm5Jc4F5i1mj2OR7/GYK/+gfagQmgMw7wMlvRj+wI/ShKhQdKcQilnBhs
         Gt2d5Z8ORLupijP1OxFINSbt8GG4foSIkwhmFwp0CChuWxhq7Ras79okaSRWCICcHKDz
         f8KSXQt/0pmypXVEP7HaWo7epie4sDJttFlpB5lPSK1/21F3Av6ygNWefgRrVV22T7vb
         FxSb45IczP+jmAoYIHUiMUbseBHn+uv4YitixspiyJJRhuXOhsAg5/+ok68QY0CyK8i1
         eA+g==
X-Gm-Message-State: APjAAAWusbt9RYakxbnMQ6Ss0DXXI03kICzSTMBZtsXTTkhIKhdGHMhT
	c9xp6/yEAPjc+iWSoMKa/oBCmxT0Jf7Qz6b58GJiML1HH1ToIc3U66QYPfgc2gUsSoJ6kKc1oPb
	VUA2JsSsuJNSbgLuuKEeWcS+x7YDpKuT5Bg2leNI58qrG4228mJJYJFbCS4lCtNU5xQ==
X-Received: by 2002:a25:8248:: with SMTP id d8mr76023367ybn.393.1564684998741;
        Thu, 01 Aug 2019 11:43:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9rjHS8pfaRR1S/Z1mzttgW0dm1B8M1cXDvxG/V/ixiDElpJoBeByTu0B1jduvMk3mejD5
X-Received: by 2002:a25:8248:: with SMTP id d8mr76023350ybn.393.1564684998230;
        Thu, 01 Aug 2019 11:43:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564684998; cv=none;
        d=google.com; s=arc-20160816;
        b=U0Vv05wJQwJsRfsWkBzkJxuZWYTnKHCQWMMfNrEV/82OStutFWTpqs0YVGvGV2j2OC
         kg1Tgv2X7Ud+IO1iTqUaz5HoN1Lq7/24mpfHwaWQoBK7j3huZv2KdOkc7zkBnwkvNiTQ
         FtmEBUh3nO5N9uUSi+zjc+9wnHxTIUQvp9mFPGX9s+bLv5VwAK9mS8119Bsyzs0zLpMq
         bMvalNO9jA5c3CEsQSMqWHM/uSzHdsq9v5CqErYDispBrj7iWLY2zpzPMZWh6x5APmFp
         1nTDz0yhMv+l3MX1rAwL+1mvdco9GGpJeqMkmszcjuBUiuYEjyTEB9SlpdABIJiKDa0A
         7BkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=AzYai9sTcIKTsjMHtj4n9MazMkcrW4fTxycCVLF20+Q=;
        b=figtip1lU5eWZS7MwMVB/DV5BUus3mpv+gpFQwOLU4QTd4XTQnF+qoHT4GLQ0npxsN
         ik2Qv9+6iDgKhxFOzE8gXev4leex6ptmNIFbWefU27YkkzTAPDZ7MqQToK2+pvNGDZdK
         rIrWr6u6/7CcXw8Nqn+/8l9kdoqC+SZD32PdOWL/MrP6aHmmZfZkVn+0uNIb1IPS2r9L
         9hLa1PCrdETpy8VGU3Oi5s9Bgis7FO5HM6qlI0ZdJUmV2cpoOP9hcEj/tsMLtd+sBchD
         XVeBncS8ZHtHPiyXNqQiNA56vahOe7N3dNjBBQQEVn4cQ7Hj9u9jym54Pi8K0y8KDRDP
         zE8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PFEjq2jj;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y13si23549206ybk.460.2019.08.01.11.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:43:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PFEjq2jj;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71IgBIW001277
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:43:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=AzYai9sTcIKTsjMHtj4n9MazMkcrW4fTxycCVLF20+Q=;
 b=PFEjq2jjC9LTyDyDwNC7HQFn1A/r25tzdX3bUfGIUvc2iC20XaQqeApxuSuSKTxL8YcM
 /zXquoKzDH5QrHVenNuHrklRnI5oTJkTte6rI6x8OEAZ/I8kO9wd8R6Iw57+LTZjwMnV
 lTblVg9TuIpzjqqzAfZzPj+BkLVDW3XFkvI= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2u427wrwcg-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:17 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 1 Aug 2019 11:43:15 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 527C562E1E18; Thu,  1 Aug 2019 11:43:13 -0700 (PDT)
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
Subject: [PATCH v10 5/7] khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
Date: Thu, 1 Aug 2019 11:42:42 -0700
Message-ID: <20190801184244.3169074-6-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190801184244.3169074-1-songliubraving@fb.com>
References: <20190801184244.3169074-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=644 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010194
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
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/khugepaged.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index b9949014346b..9d3cc2061960 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1426,7 +1426,7 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 }
 
 /**
- * collapse_shmem - collapse small tmpfs/shmem pages into huge one.
+ * collapse_file - collapse small tmpfs/shmem pages into huge one.
  *
  * Basic scheme is simple, details are more complex:
  *  - allocate and lock a new huge page;
@@ -1443,10 +1443,11 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
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
@@ -1702,11 +1703,11 @@ static void collapse_shmem(struct mm_struct *mm,
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
@@ -1770,16 +1771,15 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
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
@@ -1862,8 +1862,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
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

