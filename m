Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47456C4646B
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:13:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3B8B20820
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:13:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="PbgtNCDz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3B8B20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5F456B000A; Mon, 24 Jun 2019 20:13:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C11128E0003; Mon, 24 Jun 2019 20:13:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B015F8E0002; Mon, 24 Jun 2019 20:13:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED0F6B000A
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 20:13:06 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id z4so18345476ybo.4
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:13:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Kr37aYRy2KacRNeWnEOl8WIgUYHSnWgZ3fV+borBCvY=;
        b=KZsZqdKqTjqrjptSjoGVX+foCovty4yAzbTfZCueXazl9AJXW2dySfhWDPiYJYzhpb
         iG8DeMGXmeI2eXS5ffUQyyKHxqXxvIG0H0I82CuxGQdT1wuBj9i3Bg6gTVY6QbD45SlY
         MBnU0ngSZzDncl+qh3Xdl4Sio9edpeGoonO3tGuLtk7n+Go4H0F7kGhTZ51/aDaeXC5V
         xWKRX3ev9Wri4GwXc/2dSOrs+7cURmlntbk0an93I9yMYbykQEZPXEeaeYcsN0x9tpCH
         2F7IQIO0FmYGbwsOmliDMk+yD5bEFatLwBrLLvG8RZC9usYxZkbSgBB9AX/MRBwFzh57
         ZoDQ==
X-Gm-Message-State: APjAAAVhD43NkuzEBM3UmFajyFGOqg+0JHe8R+zIPxWs6y7TATqcqxGE
	oo/LLePDy3k4sewDBuu2RF4uON1TxWsBP13ZHAU0g1Eyc+V8OPRjKn689c52suuaDVYvg6NbqIF
	QKxrf2CjTl5tPKM+gu8n0qo2nA88e5zpSET5efcXarqggM6lWUli+hJLVs6mSUOt6XQ==
X-Received: by 2002:a25:1454:: with SMTP id 81mr37546020ybu.96.1561421586335;
        Mon, 24 Jun 2019 17:13:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYiY+pVbgQI1koNmpUJ4EytuTL9sb62mGFS8hVhF0fCr6ixuaCUyvwWrsScuaJceUQbVfs
X-Received: by 2002:a25:1454:: with SMTP id 81mr37546011ybu.96.1561421585811;
        Mon, 24 Jun 2019 17:13:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561421585; cv=none;
        d=google.com; s=arc-20160816;
        b=CqpB866Bpqd43HCc9zGm8VGcp7gJl1NMwZ1r9qj9GN/WkNVByiJKQuVIlPKxeCVLif
         JeUt+8DQ4gG5POoTqSgTVz68D3BR6MEmYm4qqpamnE5iZ/33gINNd8DCHfgfQXEWFwbX
         4lfqxELt5AFFvmsmvq+s5Efkfdv9BPWsIQRH5yM5hVzfyQImykropvclIJ0ZJFRXpDUY
         5eZkS6YaLmZrn07IhPGKtgZEjD5F2B0DuJCGluyQ+wkyWNRai5MRCNGtoW1Lh623go35
         fL/Fundf9Ye3rcIoM0B6LWYP6ygXwJWqqe3MG/ggohuPr60M4VVIIXuTYSVi3bv5X9Uq
         ylow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=Kr37aYRy2KacRNeWnEOl8WIgUYHSnWgZ3fV+borBCvY=;
        b=T2aTh3Vccta/WCSle1k9WdYSLSIfwEf4TSpH2j3jgygZPoM0DrkeO9a1bPs3j/hKwY
         qZAaw+qWlmgxBtKiqqiddG3pPN3EVnzTzs4P2g4T5WtEcpZBsnO0y0wwaz+UBo4vDwM4
         bSeO1eO7QuZeYxOVfLiP0G0trp6D/85F+u7rmct+NzxuWEC675QUKV4Sk7c1hHulYxlY
         M+aMiI5W6WX6olMi15GTHH/VpQIlAWcJjZMKPn/e/XnX5QkAH+v9qHrD8e4dhoF2+WgX
         S01D/hQUdqT2dI3c9ElQJwq/o8So8XS+2VRszgYsl3+E4vQWa9K6kveKsm61y9EyTEjz
         6CWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PbgtNCDz;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v70si2800560ybe.488.2019.06.24.17.13.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 17:13:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PbgtNCDz;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5P0C2wW002816
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:13:05 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=Kr37aYRy2KacRNeWnEOl8WIgUYHSnWgZ3fV+borBCvY=;
 b=PbgtNCDzYwbcMDtTXSXCHRmWRfbMZn8ph3GVIZcgyrJ4iXSMnpMCUEuIprfzqQxTugLt
 CTJUOFz3gJfM5B+/JWlIoxw4Re2hAbQm75Gf3rhH0irVDpUbGb/Ka4rWYoQQ9EUtANFL
 +hnoUF91iNrCNMSBInBfRt1BvO0049fa7j0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2tb22xspgt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:13:05 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 24 Jun 2019 17:13:04 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id ED70962E093E; Mon, 24 Jun 2019 17:13:02 -0700 (PDT)
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
Subject: [PATCH v9 4/6] khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
Date: Mon, 24 Jun 2019 17:12:44 -0700
Message-ID: <20190625001246.685563-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190625001246.685563-1-songliubraving@fb.com>
References: <20190625001246.685563-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=627 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250000
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

