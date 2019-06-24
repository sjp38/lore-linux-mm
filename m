Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB22DC4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:30:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CE5F20674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:30:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="oHI2WN65"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CE5F20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E84186B0008; Mon, 24 Jun 2019 18:30:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0A828E0003; Mon, 24 Jun 2019 18:30:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5E6E8E0002; Mon, 24 Jun 2019 18:30:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8EF6B0008
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 18:30:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so10449503pfi.6
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Kr37aYRy2KacRNeWnEOl8WIgUYHSnWgZ3fV+borBCvY=;
        b=OqcT52xjeEHgMnee7nJgl11HMaz+aVFKU8hsmYV6GBrQS4bk7PQlgw2Fppp3eAPAAU
         uBDn544Cj0Ua7DCL9t97Nbt50wX0NCY+cVCFszd8hpqT1UrY0xPcJ5zhdPGhA/ey77F3
         Unyi9q+66Y8TMKPfnRqDtk+jnOJiBpYfuddQwSh2JcuHSSlHnbz6qTtkub347vNGdYgM
         I/sBN4b6xuU1UuB+pnOSy6C67yf7i07h3KF9hbR/XHZUuJIL720hIG2OyKvv/uoAqnyF
         /Vq3pYuUkfkiMekv619iBSME79tSMSHGpN6OanAV8mgHB7RFcf8EfJsAY32G1LRlxJhz
         jiMQ==
X-Gm-Message-State: APjAAAVKjtXWIlIkvknshUvJWyPeyXaWQ2LJzkEeG2rSaEDts2D9D8x6
	mMo1b4TQg5+uCY1ygeOSVtyeDr1zR6CyfDdjKOYOcRWlpqepbQBhi2+D4JHjuf+m4XUdZkl4Wka
	MpjNb/mzlwJPtTzyFfYql4s9Bboiw/TUidhKCTpAHprnOq+9IBJjfTICo9nwB20STWg==
X-Received: by 2002:a65:404a:: with SMTP id h10mr36007076pgp.262.1561415412178;
        Mon, 24 Jun 2019 15:30:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8YLJQAF44qS6wFIh/3G+Kuh/GKsDCbrpZoQYKHO7KzxXCCqDwjFMxLMoyPV623x0eFj22
X-Received: by 2002:a65:404a:: with SMTP id h10mr36007015pgp.262.1561415411428;
        Mon, 24 Jun 2019 15:30:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561415411; cv=none;
        d=google.com; s=arc-20160816;
        b=QxjIQjOvsSx9QffWhzcEUj6JTC9A7XSkg2UPKFS0P40mM07KdN7proZ+c65mpBmjBT
         qlPVBu/NjF3IRTGv2ZoLlH0LLdbY6+6CC/SLhoyqSmEbZzTyspyWAbOaGZLhxy0pI2NW
         5b0+BzkW3rOLp30fI+ALl4/Hv0hTe7dWS7I63jgunbpbSbqKp82BaWFGssih+Uc/Wyos
         2EKJl9TllGUn67lMQTGroHkwPglsJ99Ep27GagdDvhNfR3bi6D8B+RiyLswQcHDt1JUO
         3pon6Qug013NCZjhOH1dxhmpZYYk1yLzdqcJDa1XyZzjQsU/j3e7x6F60UG2mMcY6s7o
         hxhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=Kr37aYRy2KacRNeWnEOl8WIgUYHSnWgZ3fV+borBCvY=;
        b=haaOOCeyRcfVQFrqwh3U2rTmJsotF4ddBWFEdsWxX/NZhpeWzHwnmGXfG6w8S5RdtG
         IpwNIGrwKImB3U+qn4jG3QJxfOP6A8/isX6BbGKn+RmQZEhR4JBv7qfmE13vY+eg4/Uj
         jF3JkGB2o3l+9ZiT23sNKwSUuGGsUN6B6ZuTfwzskdr864riyJl/upqCN05ZiFzpDt/c
         j9JTdWEoXdblDjRf1nAuWaSJWyOzdhkJ4aem6voZlWb4twc3jEFGngGN4FD4B9BHaiVu
         Ydsi2XP0pN2JqSMqRZGk6QU6M+t8hCZ9q1JwWE3WhCzvHnIhaE+Ze2nKldroVKtS3XEy
         hRDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oHI2WN65;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a22si11138593pgw.60.2019.06.24.15.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 15:30:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oHI2WN65;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5OMFof7015249
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:11 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Kr37aYRy2KacRNeWnEOl8WIgUYHSnWgZ3fV+borBCvY=;
 b=oHI2WN65t3TCnQDE//aJ/s9nxwaKSLmp8pfBq6Bq5WgQBS+03mEnzm2xT8XTwrotvIAT
 RErBC9VDCiAyM6aWLLXosrEdEea3qR5kI6PjmEadNZTbc7efeog0HLnU5pFdQng14eEa
 Mdl0JrumO1UlAS3iHYGFewHgzlbWTxxw/b0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2tb3cm9169-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:10 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 24 Jun 2019 15:30:09 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id DDC9162E206E; Mon, 24 Jun 2019 15:30:05 -0700 (PDT)
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
Subject: [PATCH v8 4/6] khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
Date: Mon, 24 Jun 2019 15:29:49 -0700
Message-ID: <20190624222951.37076-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190624222951.37076-1-songliubraving@fb.com>
References: <20190624222951.37076-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=627 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240176
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

