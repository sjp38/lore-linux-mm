Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 845F6C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F3B6206B8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="UbU4pV0W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F3B6206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA6E78E0008; Tue, 30 Jul 2019 01:23:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D56658E0002; Tue, 30 Jul 2019 01:23:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF86F8E0008; Tue, 30 Jul 2019 01:23:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A04D8E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:23:36 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id l141so46692925ywc.11
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=+zWjU0C6LD6HpRrP4wreVSMF6ug2Y3cK0xwApLG5ZA4=;
        b=SklugcSyNdLF+fCeVBF7/NBFGoPfh6FPluknV359NBwi1hKIQp1atlWpMxtdEIwl5l
         TIZGqOJuQw1XzxKZxYXffKh0AxtOmPXFeomdPxTAlC9IaXt6e6KyDqrakjHaEQeFoTso
         58jQY+zoacQAuSBFLcodoHMOT3BtM5rpOm2fb54+il+kzU6keLk5QCP/XM8zNlCMV3SH
         1wPiFkbuK0BCB35bUsyhXym6lvjVdeqIPnwBMg+5C3f/SBaMNzaauVOfjJFJx8+Y7M6Y
         an6ePkinfaiHlBJM8QC/MCJv3U9dw6cIyEDr3wO8jSpUdfLgFQ5Y8lDKjGGRM25iUdtU
         bWcw==
X-Gm-Message-State: APjAAAXRYFygKVaVemxxOhiF0xyBzcuOy2ogTAeO9p+MXowRA+/MywOX
	/oGmFFRpfWrpeBtFWnLZAHGZLzpcQ18KLVQYpYX+QggMB8k3tA6yQCEfF+edpRAGPHH0GczLzzQ
	fj/87+AXhKMZX3nvXc7D0UXRAmaOTUNjXf2utQQGZ/Ct4cuhjr+bgGzExOPpzN8GE/Q==
X-Received: by 2002:a81:3d7:: with SMTP id 206mr64570703ywd.411.1564464216396;
        Mon, 29 Jul 2019 22:23:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3znVuaujYJRX5CWYyvYQfbcz1msYh0LR8lWYMEFpxgrEbxC4CL9FlBSJGnd++XXVN5/pv
X-Received: by 2002:a81:3d7:: with SMTP id 206mr64570690ywd.411.1564464215862;
        Mon, 29 Jul 2019 22:23:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564464215; cv=none;
        d=google.com; s=arc-20160816;
        b=wjylkJWyrIBYkG65WU0+veP8NHxCFYDsitm0EP17mZbXQiRmkG8aZMTtqdka8/Zwse
         phFZGfm9em2FWrmLu6X4Lz0HKTzDMdY9bNFRNqg8gdvAk6CxarBcGa5BKGNXNEUeBPp+
         5jhjkWKjPjCxBA9UKcWotNtuOQ3bVEjDEf9AfBs5r26FnEkwMJ0Q0B5RCuNll0zNscSj
         xA9vOeLFQE8rptPxbAeXQ/TksWW4jk3l1To6wbGmwoTh3z/HDtDPBln98C360HaPxVbr
         tWfMEJOu46LFoZTE8Aidj8gMOTJt1TMHfeh+likd4o5zPgWjkhxy1V2hEqIJKCokRFkv
         VkRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=+zWjU0C6LD6HpRrP4wreVSMF6ug2Y3cK0xwApLG5ZA4=;
        b=OvxUtyTCZeipJFO43oZn06wauvWzv/9jR/AnlSEXI9yGhVRSsdbKjG+loJm1Vj4ilo
         lmF5m5d0wmIlUuezf+Qu9daKVEFKY6K0CdQYObIojsNCdyVcK9ofLJK2YWQk8/dgDQ41
         AM7uwqixzn+IBUc9Lycb2H8IJWZojZC8Tufpi3xUvLgK3NEyCjzXxw3psXaGfSbrgpMT
         KyYINtcTZui4cZSlB1ZwwNDLzPigKq5jcbBA2e8PnjHcM2NwCaumg4a1AO+IX0d5lnMj
         bfL0HVMoE5/ryCOAMVUwnSCPEmo+4TCZA/pcTj3sXPlJBQ55sDEwynQWL2lwy+9yQDtz
         1Lrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UbU4pV0W;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x18si16014245ybs.101.2019.07.29.22.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 22:23:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UbU4pV0W;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x6U5NWPO009788
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:35 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=+zWjU0C6LD6HpRrP4wreVSMF6ug2Y3cK0xwApLG5ZA4=;
 b=UbU4pV0W3DxRWEaix/W2co//eu5KlKLS2m1VkOsi0GL2xPlA2eBds9vqvxXaOnJl6ZK/
 5gjj6EaJwgtu1vn19XtMDjo4BlPzJde+muZDfGqKIXn9cqNJV8DNnPJGeCmtFsAyidHR
 YG4lkGx0ik2CAyHfxZYrzX4QAUtqekPyhR4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2u234ku0np-7
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:35 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 29 Jul 2019 22:23:27 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4162862E2FF4; Mon, 29 Jul 2019 22:23:26 -0700 (PDT)
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
Subject: [PATCH v10 4/4] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Mon, 29 Jul 2019 22:23:05 -0700
Message-ID: <20190730052305.3672336-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190730052305.3672336-1-songliubraving@fb.com>
References: <20190730052305.3672336-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=771 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300056
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

