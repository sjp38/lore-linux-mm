Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5522C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EBDC20B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="DUVDHpee"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EBDC20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6279A6B0266; Wed, 12 Jun 2019 18:06:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5629F6B0269; Wed, 12 Jun 2019 18:06:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 403176B026A; Wed, 12 Jun 2019 18:06:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9E16B0266
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:06:22 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b75so18904805ywh.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
        b=j3IiouoecYuKasjj30d7TRh34nTnGSuY0nz/gVXZFkDA/sAv5iztFou17znxB5khSV
         Wz3Ad4oZ2oSHagJZPzXi73XmD+vUogI1oI3/4avZVrCcMxPM3a8cMaAcZB/ipXSIBChH
         qNsWeCoPt2toKzfTpGEaC/k39QwDVXPbzxX4ExrZQlETtQ4Clg9aXoYhZKIA/MReuUVf
         uuZDUGaRAz1wnFQRf008rmiTSwoXvHBGmVGDIG2q4fuRWmRQkRYW0XXKM1CBX2U9Zg0h
         oNHia25cmXeAKPdYfjYrgCDcaF4wS9FDfHwNQNG1EEu7r2Qvgg7J5Dv79JZxaWvEDx+x
         2ajg==
X-Gm-Message-State: APjAAAW+WHPZnjrgduMo5IW6JQyDbCpxHmll+K0jPP9Y8W5f5hvk1Ej5
	XoIwYT3mSwUMzc71SxXA2UDU0fPKGCavFYxbUdAvkA16KptaWY+0udkCW60GhBQxCabgdrOGkfR
	DOlXpAwEjG3t9w+SymJVswQ7kG3rn0zpCR2Xo/kXV7V7PICet/oT2koAFJEcVlNOsTA==
X-Received: by 2002:a81:5ec2:: with SMTP id s185mr6351834ywb.35.1560377181785;
        Wed, 12 Jun 2019 15:06:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXjcSOJq1B6X/rYc4R9iQ4maNOU4sVodaxb/Fk73GijxWpVXfAWDBGxeABzbMyJNZ9VHGT
X-Received: by 2002:a81:5ec2:: with SMTP id s185mr6351801ywb.35.1560377181275;
        Wed, 12 Jun 2019 15:06:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560377181; cv=none;
        d=google.com; s=arc-20160816;
        b=MfsOBuQbq0ZzIus4iNpuSDPN833ZEPh8Ya2CZie06AP1CT5uQNAXB8cO0Uvp29D6zi
         370XSyVv2jy6FrZTMpOVUNKE40QCOdyIS0AKTMckAP0cuC+egdoUFkyoGYNKYPLO20nM
         VKYKcXLQg19Ho2VQaQmSbwtSSG0aBoq2DpEtEcy8GDiGJs89QEVkf90i9+/BTPDnge/G
         IxDIss/qqhK6AO53+SZa0n9czdFfWy955hADgkTkXtWwvZOj8TXTbeLQrCxP8eOqhvqp
         tYlvuaHmu9HeZ8/j+UpWyUBXSIWoNv3+P2Vn2V9MkSw9LU+AUIAzDdxZvUo63L81r+0z
         In0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
        b=VEQEUF/h5+vxYb6tGRI5858If89DgtZS278xJzHRlqEuMT34lPM00edK9Yvmaom9CI
         iQzGxgrr3YTgAVta3j3RK1VNZes6nqZ2ZrBymQrmu1UOQLjV8ysA8MXBT2RXjhliE7EZ
         QMgjsgC/YlPKi7pokDuD4s6YYm4w2KJlAB36Exzi2CpnWMSqQXEQAY5SiYHS0YGt5mGU
         SoR9OjC/MhNwXq8EjKFds/Onfxhj6UGTNUVhTrIETzwk+f/Sg9Gcxr7gbOCTZDxNMWKP
         vsFHzlYZL5ZvjEqvPSE/WEjDxv2fE/i06Ho4Bkojj2tc7iNU6esV6WAr93ZiU76nMfi2
         Mppg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DUVDHpee;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z138si256755ywa.342.2019.06.12.15.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 15:06:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DUVDHpee;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5CLxCWZ008898
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:21 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
 b=DUVDHpeehWi10Lab//cDJwDOb/LI4bsHpLt5aH50Rgna7p8/rCnjYziNeuis0xU0Wxws
 jfRURV1mTQbo2ldDDAYkYwWv7EwKRnaLoj2tPFSsi1yqOxUQeMk+3cyfGWoYULT+FU/k
 Czvqi3Ku+4e2072gRPXrVbJCSLzjTDFnxS0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t3338hk6n-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:20 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 12 Jun 2019 15:06:14 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 04C3C62E2CFA; Wed, 12 Jun 2019 15:03:41 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 4/5] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Wed, 12 Jun 2019 15:03:18 -0700
Message-ID: <20190612220320.2223898-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190612220320.2223898-1-songliubraving@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-12_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=727 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906120153
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patches uses newly added FOLL_SPLIT_PMD in uprobe. This enables easy
regroup of huge pmd after the uprobe is disabled (in next patch).

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index f7c61a1ef720..a20d7b43a056 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -153,7 +153,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page_vma_mapped_walk pvmw = {
-		.page = old_page,
+		.page = compound_head(old_page),
 		.vma = vma,
 		.address = addr,
 	};
@@ -165,8 +165,6 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 
-	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
-
 	if (!orig) {
 		err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
 					    &memcg, false);
@@ -483,7 +481,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			FOLL_FORCE | FOLL_SPLIT_PMD, &old_page, &vma, NULL);
 	if (ret <= 0)
 		return ret;
 
-- 
2.17.1

