Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06E3BC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:53:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2EEB21743
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:52:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="JZ39mimo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2EEB21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 172F66B0005; Fri, 26 Jul 2019 01:52:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FEE16B0006; Fri, 26 Jul 2019 01:52:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E880A8E0002; Fri, 26 Jul 2019 01:52:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8BAD6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:52:57 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id b188so38445889ywb.10
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:52:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=UDDhhnpIwhL65SFKuOG28sTsSPl2JTdHqEX1HZsGTmw=;
        b=Cftr84R0RMRznzz3KQQZLDATmQGpKQVY8YnFHCBXk0mwLBxCbxGhfheVx1AjAxvGXF
         boPbgv/0/gi2/4roipo8PBW07EiMhKR5Ov8TqkAnctTuatZEwPlE2OcYNadmkpfPZEkI
         jeUlN+gBZ8Y7/GeLGha3oj+JzjLnvOqsMbNgtKAuvHzcEKwF5eXHNAdvig55Vs0LPBkA
         /ka/LSBIzloAKzwmvngin42F/71ySCvyxtPkz5mLilBuhtGFsDqjg0MzZSvfDE5urVCU
         q3BVHW02DvPFRm/pwOVzNNQigcTy98kbv9txmc/n//G4LaIUZZTzMqTa0yoCC/jztSyf
         Ziww==
X-Gm-Message-State: APjAAAUeTLHTn6XlsvMaH/RRgo5AY1mFo4nkSi91HtWfbkQW7nN/S1oC
	txWbIBBzDr3YcjSEADd0WwgKcCT00LJ7eh/GYiAmhYv6U4CLDl4paV1YrMEzJeBnc/B8Kfx3AuN
	iFK77JJcy37cki2x6qOzALN3PAMWormFkODulG4f9Yth3kv4CirpRLYzK3//4sllz4A==
X-Received: by 2002:a81:6d07:: with SMTP id i7mr58607320ywc.112.1564120377619;
        Thu, 25 Jul 2019 22:52:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOYKwxfdG39SPcz+KUg8C7HIfma0g2QmuaLUgvtWkuHjJ3rfBwlcnEz2451VJoxbC5Z51r
X-Received: by 2002:a81:6d07:: with SMTP id i7mr58607315ywc.112.1564120377190;
        Thu, 25 Jul 2019 22:52:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564120377; cv=none;
        d=google.com; s=arc-20160816;
        b=CBkE37amxX9UGZ1yZz8UmHbw4DaNp8mha1zf9khxaV5RKSuX5b2gCybGvHutvE2YrC
         XZ+4jVV69RwL0J+UN09eNjr5AlfeL0CijunARpuuOz5S6kc0l4amYTgoIMuVXVEjtHJn
         1CTYDK7YjAzKcD2l080UyPc6AaQWG3ojvcK8ddTuczxNIxqPcld6uD7AiV95mIzoSdT5
         aCwDlDIkt7OpjKmDwuvOerK3nPUkBlRgvGGrV2Udwdn+JCpEV48LWSzYckzt7I9CLXpT
         5kn2cKCiKGAYyTP4zGc1lf73CFKNhOWxo9ohwKjDfJNQZEFHICQp7nex9uVwM5o1OY2X
         jRNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=UDDhhnpIwhL65SFKuOG28sTsSPl2JTdHqEX1HZsGTmw=;
        b=ANnwYQqsWrElssOtmc4ZzHGZvYzQj9xBUOQWH/sWJmnLbQffANdzaj7Kt1eu0iTxeH
         qRHlL5lnbE9jrcszl7FqAgqJ9ZxVkYCG8c4JKCSlOTj5Cn2I313tGJnY2UKI/tIk7qVQ
         iSwEKB6K3azae7gLMZL8Rz2Af/oYS7emSrZMgwwkZ2+r4Ox5ih/g8OOSm2HLUpEPpseC
         mUJSnqQnAn1Lk77t2aqdxLQyjRlJWeZBNs62eBLYxclrbginTB8KzTp5IsGyQ/b+nUuA
         NKtz/a2BGTKwnxQdUHAnT5DX6eYZ2BLbHDmGHX+qyT5TAOgz1C7BWAy5365MQvVLriVw
         HsgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=JZ39mimo;
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q1si19029885ywd.77.2019.07.25.22.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 22:52:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=JZ39mimo;
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x6Q5qC5p013835
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:52:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=UDDhhnpIwhL65SFKuOG28sTsSPl2JTdHqEX1HZsGTmw=;
 b=JZ39mimog7+GeZFLDwQxFCXtIubs8LHH3C5++YUmetQnVjLjCI96xwEiP14uFhHYa2Ej
 cxQluds+zdHsKlqjoplamVPLFj+PWx/RZgVJUdbuE+P030nlSzhH3jzmzGjE4pxRUY91
 vDGy6hlWNVJqwXXND5AP8GRpPqNsmkQ3wOk= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2tye8mawqw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:52:56 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 25 Jul 2019 22:52:54 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 78FF462E305E; Thu, 25 Jul 2019 22:47:20 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <srikar@linux.vnet.ibm.com>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v9 4/4] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Thu, 25 Jul 2019 22:46:54 -0700
Message-ID: <20190726054654.1623433-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190726054654.1623433-1-songliubraving@fb.com>
References: <20190726054654.1623433-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-26_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=710 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907260078
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patches uses newly added FOLL_SPLIT_PMD in uprobe. This enables easy
regroup of huge pmd after the uprobe is disabled (in next patch).

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index bd248af7310c..58ab7fc7272a 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -155,7 +155,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page_vma_mapped_walk pvmw = {
-		.page = old_page,
+		.page = compound_head(old_page),
 		.vma = vma,
 		.address = addr,
 	};
@@ -166,8 +166,6 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 
-	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
-
 	if (new_page) {
 		err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
 					    &memcg, false);
@@ -479,7 +477,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			FOLL_FORCE | FOLL_SPLIT_PMD, &old_page, &vma, NULL);
 	if (ret <= 0)
 		return ret;
 
-- 
2.17.1

