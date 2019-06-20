Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 536DBC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10E242089C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="MO6t/uuq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10E242089C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98A998E0007; Thu, 20 Jun 2019 16:54:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93CEC8E0006; Thu, 20 Jun 2019 16:54:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 829E08E0007; Thu, 20 Jun 2019 16:54:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48ECA8E0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 16:54:07 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so2818966pfj.4
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=n2snFM7QmmPTPpShlBhEnsGKC2i2/uKCmCMTseCu52k=;
        b=gB2/VOK9yR11bUizy+F0b97CRArU4+b6IBtD+UTT18chCAH0feIzUKqUg5c6dL0INc
         PmaTmQsrnjfJxyjQ/md39+xpOJ8dmvs/8BpYrFMQrgiSgE/aw+qSJCF+Cd3WdHE3BoNr
         PmHAE7sQZv0d6RqhsQKjEq7soCoMVff2tst/puxn6A0a9VI3hhRw/YfDyLdBV7kNBzhP
         g4G9Ru697Ct3+F0kWhBI1X1uVFgwSwh49rUdFaxn6NNO2qCKc205nTAzLl6d3ycRUJ1G
         oYPLcD8LYhqD9cu+xwt0AvCi+aMEgEg1ON4OP4LJ3GYue0gXMzFP9KN1AAcQcssVlTI4
         wPWw==
X-Gm-Message-State: APjAAAWeniXLslDooCL7l3nDKSLIOC6gOsrk8bB9n6Zo4p+JSl2oIpKZ
	UwWoDAcdLcvnzeiX4aLZSHJBH1tOygjmnwrtTUSo7J9x2bhqHET4Xicsf5TUjIObDVlVnvIcEvz
	DFdRkVcCpcBbpSC8tzdMZFuuAzvJlz4hd5eNKTSWNtDQFxJtmRxGOmNRNKgDT/kNUjA==
X-Received: by 2002:a62:3103:: with SMTP id x3mr50668264pfx.107.1561064046881;
        Thu, 20 Jun 2019 13:54:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfYOLEcQTKjRtk/y30aHTrc3i11+pTSBP4R7eX01tA/FbxtHPG3uEj8QopLN6Oi45tyxkp
X-Received: by 2002:a62:3103:: with SMTP id x3mr50668227pfx.107.1561064046225;
        Thu, 20 Jun 2019 13:54:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561064046; cv=none;
        d=google.com; s=arc-20160816;
        b=HExyNBjISyVx+4Z8G01YQDuBu8/bfZ8H9linELMpdhApqSl03yjDsIhxS8sOswOnzc
         jPVkdZxK7D82REemgGqUPUqGsXTLijGuPFbCXSxR+Ch1KiwfzKMt9BnUcFOLt4gxWa8Q
         o+TFd+UWRNfg8pN8rxCKkyNVpkH1FNfuibhigYoU3hG2EESLgst1cpZG6bOjSQdofH8J
         l7rWyPhvsnwR9hCxZiSb5u5C2frW4UHHfJrNRxDmy4mqvkgjo3eKNMBh3D5m63xJ5JXL
         TsxjNN7k4g96kCzwfp+/lrgGZZgS4mHOQ/+IC1BxwY4WAjmCJc3oMu9fBLKy/moe23Zf
         2Xrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=n2snFM7QmmPTPpShlBhEnsGKC2i2/uKCmCMTseCu52k=;
        b=YR61aiLj/6n9GhB6a+AizA3wH4Sd9mACwKXPZ4a6CGzQwPp0NVY+wsAnAaeo5/jsnI
         luEguUmdw/wBH/efGW5ltEwhZRLlIXlTXcbAuzBW7RfbzCkUeS2HQfwdKEYqwDprzUPg
         G/99HgeuBmXbUSUF+NY7BBJ9bq3eU6MxWHwoOgoNBVxRoQgw6NlsWAdy+ivW8nLTs7Pb
         t+fDsrzLZpwpk/Pz3mhcEgpjspxHU79Pwc2C81gyk80ej69wcNl96JL19q25aPa4WehC
         s7T4ZhyY6+vDUmEg89jYcXk1d0IdNaGdeNRsXMx0/1yAhHOAPzg6SJKUPlCPb9kkBZfj
         jSPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="MO6t/uuq";
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e10si493694pfi.187.2019.06.20.13.54.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 13:54:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="MO6t/uuq";
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KKr3CJ022769
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:05 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=n2snFM7QmmPTPpShlBhEnsGKC2i2/uKCmCMTseCu52k=;
 b=MO6t/uuqWiOOomNBwU97YOg+TXttbjxehR5XUim4OqdKWGOalMKxrKcMTqcpsoFCSNTE
 v2Tyx+5GHTxXTSPAKkK7icdV+5yVIe0Ew+tP8foHoFHqdgSuCNXYJKLQy9typVFfpkod
 AIK/nAgzi7COfwqaGzTulaxsSRSMbugt65w= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8gch8935-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:05 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 20 Jun 2019 13:54:04 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 06C3D62E2A35; Thu, 20 Jun 2019 13:54:04 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v5 4/6] khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
Date: Thu, 20 Jun 2019 13:53:46 -0700
Message-ID: <20190620205348.3980213-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190620205348.3980213-1-songliubraving@fb.com>
References: <20190620205348.3980213-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=567 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200150
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

