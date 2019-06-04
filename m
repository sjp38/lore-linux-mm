Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C45FC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:51:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD6A523CF3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:51:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="hlet+lin"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD6A523CF3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 175D66B0274; Tue,  4 Jun 2019 12:51:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B0B46B0276; Tue,  4 Jun 2019 12:51:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D594F6B0277; Tue,  4 Jun 2019 12:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A21E76B0274
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:51:55 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id o184so5961981pfg.1
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=uQVFU2CvZFbm2ziFu1mR1VOcrYWG8oH6RytDeroq8Og=;
        b=RDiOHl+uUOIsZCmqWByfkwhTRivif7l1hK5cfqONoku3lJ0Hd+klLRVpGHBOAkQsRj
         Kboac4S1xM8lz27yRvbyeK1zeIDycQB8RgxoE/MJwyxde4rz8h/zG++n34kpEQ71w+Ki
         kN/e4p5WP4PjpqrFoweH51A+Yg5cnVZsciEUsVaozSOanrY3BUy6UoJCA5CMmz68ZOCl
         EGdvWmtSkfF/4dOLmNQqbdhc8wR1+m02mbE3SFq91l99qtiPzhLF+PVxaMB7S+uOCe/r
         QtL2PXBFpAQiPVw2dmBa300v1HqL0zwngMRCGNWpMkSDdcGNA+07fmG2cMBv+JX4u3AS
         s6pg==
X-Gm-Message-State: APjAAAU8CtbUKB0htqqymQP4hx89+68fjj02XVWU84DH5IfTMz/oEHtw
	l+EgCHQFP48mJN+rUAovsGjlTo0IbGEjtSbxtqhhZDDX4KC3mFpd+9/wNW23Ronm/PFaxq7f0sJ
	PThf7cDlyLeUdbKGoUZxgJd28kKoSRmv0HfwV2FsIsMHvR83QVUPN+jawShl7fvJKJg==
X-Received: by 2002:a63:d658:: with SMTP id d24mr36857689pgj.191.1559667115074;
        Tue, 04 Jun 2019 09:51:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/hFJpOJrHQM2ULgwI+HcStP74jErEgDQK5Uk+S7arhBxBt03hE5gmPLkTCLtITJ7IAHC2
X-Received: by 2002:a63:d658:: with SMTP id d24mr36857647pgj.191.1559667114329;
        Tue, 04 Jun 2019 09:51:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559667114; cv=none;
        d=google.com; s=arc-20160816;
        b=SRw98bwk4uJ4Rv1hlFaXMHLVQ8yz7EMDDqI+kIHHaI15C5MXMUoy7oXs/M7BTtG5pk
         3Kbcad1+Cm7iEjQVorO45vdMP/cWl7L2WVRKL24QO0vfqrjqqeO4hqyfjLxE5i/1NnbT
         U09F6c728Yny2l5xJQl0dLCouL30WPnb24aq+SSzauFtX6RxpQpp+sXB5i1OuwT7uCV+
         waCDBAuv5P9oUNOm00WXb8CDs4cKyk5P6n2JFSD2woTlGAZo7bCoWJxoJ0R7NILJbUNs
         e43ziR6rdvMgizUlpddECnx8EZ78zbj+XNSQvJ2YJQea5pqxjZVAx2/hOJ1tFGZ33uJs
         4W4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=uQVFU2CvZFbm2ziFu1mR1VOcrYWG8oH6RytDeroq8Og=;
        b=pkeMx16BUS4dNMjU6a5zrdt2as/kVeFYk31vOpGjAQLbcucAJ9mKZKo2UX2WSi0ZMm
         EoHQi/c87vb+EzI6wx1YBe3rZtciOXWHrriH37je/jlF+4JAk5rXL3MtXF85umY8l+uW
         3sIE50/6QqhBU0dBlewUXrJF9Dk51oZLLzaCDPYBmcT9dAGO7SJKD4kWd0Y4yqaeeKe8
         wyW//O8MUo0NAvqts0P/BYHVg35acMOAaC4J8dzWup9g8sJ1qxiBgi7mBkcyEBVe+uIZ
         dl4DutHtN+okFwJ9hQg0ppYNKoS1HXr5+JeymnQm9L5I9L2h223+IIVFT02eA/E+OSrX
         D7RA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=hlet+lin;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e7si15178034pjj.21.2019.06.04.09.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 09:51:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=hlet+lin;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x54Gbc5g009600
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 09:51:53 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=uQVFU2CvZFbm2ziFu1mR1VOcrYWG8oH6RytDeroq8Og=;
 b=hlet+lin/ilJqoGqNCD/y1sisAALXvDGG82vfA10F54gO8l2cJj5kbmk44HkgL1oXn5j
 vioRETuIMB+nIfHuKt8jyob8cjdaYHI2fUHPPShTbzCFJY7I5vLlLqr7e18Ki5W+E0k6
 8D9S3JVDkBfi8P7xi/RUPIkugGWQx8HpkI8= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2swe1ftj56-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:53 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 4 Jun 2019 09:51:52 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 8ECF162E1EE3; Tue,  4 Jun 2019 09:51:50 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <mhiramat@kernel.org>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH uprobe, thp v2 4/5] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Tue, 4 Jun 2019 09:51:37 -0700
Message-ID: <20190604165138.1520916-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190604165138.1520916-1-songliubraving@fb.com>
References: <20190604165138.1520916-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=811 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040106
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
 kernel/events/uprobes.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 3fca7c55d370..88a8e1624bfa 100644
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
@@ -188,7 +186,9 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	get_page(new_page);
 	if (orig) {
+		lock_page(new_page);  /* for page_add_file_rmap() */
 		page_add_file_rmap(new_page, false);
+		unlock_page(new_page);
 		inc_mm_counter(mm, mm_counter_file(new_page));
 		dec_mm_counter(mm, MM_ANONPAGES);
 	} else {
@@ -482,7 +482,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			FOLL_FORCE | FOLL_SPLIT_PMD, &old_page, &vma, NULL);
 	if (ret <= 0)
 		return ret;
 
-- 
2.17.1

