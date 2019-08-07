Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26225C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D10BA20880
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="fBsqb63h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D10BA20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F1E16B000C; Wed,  7 Aug 2019 19:37:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 253D06B000D; Wed,  7 Aug 2019 19:37:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F6CC6B000E; Wed,  7 Aug 2019 19:37:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD6A36B000C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 19:37:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so57808631pfd.3
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=+zWjU0C6LD6HpRrP4wreVSMF6ug2Y3cK0xwApLG5ZA4=;
        b=OklF3yXLacnk4QIX+75J2C4uAXtxYcEwrYM/KukEC7POu6Nf7K0R/+GVSH2s7BRDGG
         U3ZLgzfVU5SLAEypqNZfVDUzYFGCPtyvlSevpvub8tO8m4YU5KDKfIK4DjiTCk1UBpMI
         09BvNsfA7w9qnb7X1tBYay5eWF82rws8BMhfyG2/zPog7ALaO9NArOoEyRRni+OJRanR
         XXbjgFdKHwRMbeXho8pFLYZ4JTYdmqmm7oYLAYBj80CuCMKIyuREIJZAPv8fvwQyiH77
         0N43U5MYesmMSqPpqt5o2UZwEevOU2AcOBdFOh/SGOzkzA+H5z/x/pRBd9L2vODckXLz
         jtgg==
X-Gm-Message-State: APjAAAUeKO6k20Dyj7lN05lj8W03AvWzM78W0xg8f/4EkLnpk2KMW9Ma
	cyzqqLEdFFcbZoVZrGtWSAQUegI7nE6IipHoexcPAny6jBxUIjMDKL9dK0KlmliZyPQdMl6bHFT
	TVjkSyHF7FtqcBrDWbZxUcMd7EH7AsOw4KCd/iddml69D12USc1Q24p5FzQVm4SCLfg==
X-Received: by 2002:a17:902:8ec7:: with SMTP id x7mr10475884plo.224.1565221064516;
        Wed, 07 Aug 2019 16:37:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxj4ZcOPNzlMWG3DPWPA9MZpquDyNLAYxG8UcvaNMoVDWRRBRHgwPcH420K6cPSizxrDpLO
X-Received: by 2002:a17:902:8ec7:: with SMTP id x7mr10475857plo.224.1565221063880;
        Wed, 07 Aug 2019 16:37:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565221063; cv=none;
        d=google.com; s=arc-20160816;
        b=rN0Z9DjDUIAktIxDK76n9VrbB72dHUA3pV0ODkGky4z7oDW7MfRqbt8vjBaJgSh/2C
         H/0Dodzaxn7bGcBKnD4duPQYf1fA71PJqvENMSa8JKtGEjpguM3FcFdB/XUcUNZCXxM6
         v0Wzv1SpSbGRKHwW03C3ClU2xYVtnyYPo9X7f3nHLLsHqvn+RDtEM0xz7kDhe6ANq4TV
         QCkS7uJcRWmH3rfi6QS3EKL2PDtQZ71+/MkqoJzPHQ3lqwpcXG720h6QaDoARLm2PC6w
         /8szDtWYOccA9h/dKm9VJ6tAbx0E3pR4vJjZaZKwDhwVuTr3I14GwPXichsUurKYoiu6
         bTOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=+zWjU0C6LD6HpRrP4wreVSMF6ug2Y3cK0xwApLG5ZA4=;
        b=iWpZaJA2VY2FUdCjRZ9ZW1yp/yoypshkBnVd7BnvNzU5K/hweeSmyiee3QiLG0KgDP
         qe1YQXl4rcSVwKslBytinUN6uhpLGEtQAH89rpZUou6iEXlPCvE48BMdRgzgMmZ2n3zh
         QPPfb+Y7cMjKn2k1NK4q0FgOSQHBtXrbdqueq1d8vqHMcgBTbrlqOdmFPHwn0UmgxsgN
         HyTIITJZitDr04cggTxQVRY9knW8IHi1FcunfB88kZCFXFNE0DqBynRpqtdjmSTJXVco
         scSpau69O0NjlDtt3K2Fhv/29ZVAZYp1SPRpuxqItH1IWE0k2ySb6RyUD1fNO9lwqHPU
         mTPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fBsqb63h;
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f59si51365781plf.220.2019.08.07.16.37.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 16:37:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fBsqb63h;
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x77NbOgh012893
	for <linux-mm@kvack.org>; Wed, 7 Aug 2019 16:37:43 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=+zWjU0C6LD6HpRrP4wreVSMF6ug2Y3cK0xwApLG5ZA4=;
 b=fBsqb63hUdkjfm3MVSkoshMICce62OK0B0pWD24A0iTxFYJJFooPgx4TMwhbAYMZuikx
 KPOvmn3+GSl0HOhokd8YHWYB0F5QFPR0VDY6WjjBR2cuANN0w484i9z+8tpXEE9Wyq9X
 OeDCnBjge64sKhBPNskFtf+TpJ59YZMzWz4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u87ueg4jw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:43 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 7 Aug 2019 16:37:42 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 42B5562E2D9E; Wed,  7 Aug 2019 16:37:41 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <oleg@redhat.com>, <kernel-team@fb.com>,
        <william.kucharski@oracle.com>, <srikar@linux.vnet.ibm.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v12 4/6] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Wed, 7 Aug 2019 16:37:27 -0700
Message-ID: <20190807233729.3899352-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190807233729.3899352-1-songliubraving@fb.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-07_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=809 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908070209
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch uses newly added FOLL_SPLIT_PMD in uprobe. This preserves the
huge page when the uprobe is enabled. When the uprobe is disabled, newer
instances of the same application could still benefit from huge page.

For the next step, we will enable khugepaged to regroup the pmd, so that
existing instances of the application could also benefit from huge page
after the uprobe is disabled.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 648f47553bff..27b596f14463 100644
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
@@ -481,7 +479,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			FOLL_FORCE | FOLL_SPLIT_PMD, &old_page, &vma, NULL);
 	if (ret <= 0)
 		return ret;
 
-- 
2.17.1

