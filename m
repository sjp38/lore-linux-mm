Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34045C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:49:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6565208C3
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:49:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="n1Mcb0xG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6565208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FBFC6B000E; Sun, 23 Jun 2019 01:49:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 188608E0006; Sun, 23 Jun 2019 01:49:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E05F66B000E; Sun, 23 Jun 2019 01:49:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B625B8E0006
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:49:01 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id o135so10961270ywo.16
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:49:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=nrhKkEIFZQZyLO47iU67e7PRaxciftm8IRTz/uqOqR0=;
        b=oD3C26mM+dYc5kZ0lGw7R49432/aY3FfXOzPtaoMpY421CCBbwUetQU5rs9FzqkLcb
         GQZPE096C5v+dz/md9Eu+42cQ95lYjJnotjmdAwjNgAvG793ttil2KzILSXzLOxYCJgf
         7QDimKWD3/t9QfOQvRUQhuCd9O4KDLGS5rrjrC7jzKgXpA/Uy5unJDGtHqz7sJLM6/rh
         JDs7niKtYY1ae19nrab+dqurhbhMNUvpmRCsURAmmRjsyquVLQVGF4yFS7wMU/7K3vde
         tICQEdQ2gCyfuegirwzoFI1lNaQMKUAgJew2NhN2oBB+9YkiPQThQ1cmbNb8tviJbDu1
         OcYg==
X-Gm-Message-State: APjAAAX3IVNv6GpDaYEVhvB4Ey04mAtAVCqlPWSCxjvgRHMZb7b5lE6c
	Plt6HqD7Bbj9l4IgYHMVBHllgWYZlwgS5Vd9TPHshvGfp4oc/oe73f4MYGTMeUDOCgI1PGG7cLZ
	DAwZGXAJthloFUmuPQ0Q6wq1Yi5OHhwxYavBECrSniC4rCDVk3+TCVu3GXffXQn0y2w==
X-Received: by 2002:a25:cc0a:: with SMTP id l10mr15659734ybf.433.1561268941489;
        Sat, 22 Jun 2019 22:49:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBgdrAib88ZSNTQQyj8cf+AyEZQzM8Uk6+fmkOQZM97pwBMDSPXSXPhTtGyBiq7veondc5
X-Received: by 2002:a25:cc0a:: with SMTP id l10mr15659728ybf.433.1561268940978;
        Sat, 22 Jun 2019 22:49:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268940; cv=none;
        d=google.com; s=arc-20160816;
        b=ak3FtZNeBZWImN10tFra29dEnukYddWQo+gPwAwauepO9Vupd/oNJhlhycXm4VrB6F
         VWRGVfVj3paWL7kGFmk0J/P4n9IF+VhH3VroLrOvRGx+Plmebx8KYKyvPTOd0KBPHRGd
         4JJDP0P94zJD2Gews/1w6uzDBJ5WmaRXib9TLwFXpAb1WntQ3PmWgVyE+TTwEO+6mAEp
         DEtkeLHY6WZSgjlvkgJYjnSs6ENKiZzQwmZ0O/heNiedEkVpYQxSii3Fax/jo6/NtUO3
         vctNMrx4Otmgk6p8y2h+kymuQEi7IzkRvD0WOdwMJHmQi1LabOtNo0G04pvMxG1sdutY
         mWqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=nrhKkEIFZQZyLO47iU67e7PRaxciftm8IRTz/uqOqR0=;
        b=HSFhRovPssOaElOvRdWTocNwPX0crRGJ3jOAhnLvXoyC2M3iH5SIe8YCO0jyhjG4E5
         RqH234usbN0amepse08j8lHLz1kVtDQYYyZLB/WydLGg7IH24TbLwnveycZP6R8XgBMN
         v/2PClVqQxtq2Z6rgcfDMpta3SS8txDSNrukebaAne0wqEDml3iqyr3sYkMjB7vnEWj/
         eB+/EMn1bfb+GLfReCjAO/+PXVSzpydm4lHQQ2tmaFL/KOlDd05JI4M0ifEgTzZXY6vc
         q5kMb+Zueqat8ugKRmKjQ//hHgTQyxmuYDoiZtQg8eH9BaP1DElBR0JLEARmwqLKeikq
         ZXkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=n1Mcb0xG;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l189si2667685ywf.14.2019.06.22.22.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:49:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=n1Mcb0xG;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5jBqZ023070
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:49:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=nrhKkEIFZQZyLO47iU67e7PRaxciftm8IRTz/uqOqR0=;
 b=n1Mcb0xGlFicl1b6shGpkYWp0dyD67YcBa33e1T8uSrJxtYb4UfwBYdtfsPWoV7EkMhp
 5uVeE8tweF3P7RCVVxSK3WJq5YpcBEOxpchg/g8wF8itEhVIC/ddefSvFxVw/VIvlCBt
 W3QMPnENFjD20JsVCgt2dOeCFPCeAyljreE= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9j58a3fa-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:49:00 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:48:59 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4567E62E2CFB; Sat, 22 Jun 2019 22:48:58 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 6/6] uprobe: collapse THP pmd after removing all uprobes
Date: Sat, 22 Jun 2019 22:48:29 -0700
Message-ID: <20190623054829.4018117-7-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190623054829.4018117-1-songliubraving@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=724 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230050
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After all uprobes are removed from the huge page (with PTE pgtable), it
is possible to collapse the pmd and benefit from THP again. This patch
does the collapse by setting AS_COLLAPSE_PMD. khugepage would retrace
the page table.

A check for vma->anon_vma is removed from retract_page_tables(). The
check was initially marked as "probably overkill". The code works well
without the check.

An issue on earlier version was discovered by kbuild test robot.

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 6 +++++-
 mm/khugepaged.c         | 3 ---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index a20d7b43a056..418382259f61 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -474,6 +474,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	struct page *old_page, *new_page;
 	struct vm_area_struct *vma;
 	int ret, is_register, ref_ctr_updated = 0;
+	struct page *orig_page = NULL;
 
 	is_register = is_swbp_insn(&opcode);
 	uprobe = container_of(auprobe, struct uprobe, arch);
@@ -512,7 +513,6 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
 
 	if (!is_register) {
-		struct page *orig_page;
 		pgoff_t index;
 
 		index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
@@ -540,6 +540,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	if (ret && is_register && ref_ctr_updated)
 		update_ref_ctr(uprobe, mm, -1);
 
+	if (!ret && orig_page && PageTransCompound(orig_page))
+		set_bit(AS_COLLAPSE_PMD,
+			&compound_head(orig_page)->mapping->flags);
+
 	return ret;
 }
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 9b980327fd9b..2e277a2d731f 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1302,9 +1302,6 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff,
 
 	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
-		/* probably overkill */
-		if (vma->anon_vma)
-			continue;
 		addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		if (addr & ~HPAGE_PMD_MASK)
 			continue;
-- 
2.17.1

