Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B2A5C48BE3
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4117C20821
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="QXr0LedM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4117C20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E88358E0005; Fri, 21 Jun 2019 20:01:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E39898E0001; Fri, 21 Jun 2019 20:01:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D01AA8E0005; Fri, 21 Jun 2019 20:01:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABD2B8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:01:26 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id e7so7363266ybk.22
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=VaTYZS3FdWj202Z1cIYQJggrJMEpd/wr+92gO5GUCcA=;
        b=mWZev+096aNOGQTEMwUCU9F2CmtCLB1M3vXQO1EcvSApnf/hzr7BB834XoVgUyA/fb
         iWvv/PC2u3OG6P88EFbykbp3DZBr6jhQo6t6hzwn6k9+3c/bhgMtPwwkL+nIJbIO2+XE
         /1+d3Fe3gdqMIjQkh726j+rhM0MkkYngVWp51xSYY907qlN35m+O4BFpRyelC6/D6o1a
         z81DA34smyiO9pFvqzwvp4BWUhxLl6YzhkBvxa4F50e2Hqt1DpkwaMTrRLkrktbfc/wo
         A7UDt7qvghnAKGeDpVgdKoQ6PW9E6TSSd7bWD6sJ5e9NTZBmVU5SVtIIQHRKwd1WYL7j
         bBCA==
X-Gm-Message-State: APjAAAXQR2A7Ld6ToZefPeWd1QrAwf4vZYe77xRkw/du9AKROK+8OSnQ
	HhLRxIDB6UHN/TzzNgC/lBROkoHaEUf18gfqaf25MXh0OZeuOQoNKrHTe0/AOvObo7McHRIuamM
	Vm4YZNSATgW42tBbtjOMpaBG+0Ov1uHqKHyvASz3KnNzl63WbHu2K+Z6L5h2H+wcwuw==
X-Received: by 2002:a05:6902:52f:: with SMTP id y15mr20024122ybs.328.1561161686432;
        Fri, 21 Jun 2019 17:01:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzX2BDwizvYAuuR7s6wvMmZXh7BSLv0Xgylomaq53opidgLQKMH/eL75mR7+6N929U8LlGH
X-Received: by 2002:a05:6902:52f:: with SMTP id y15mr20024084ybs.328.1561161685780;
        Fri, 21 Jun 2019 17:01:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161685; cv=none;
        d=google.com; s=arc-20160816;
        b=WWieuQpe4XYiwHyD5CE+Q86AMXyrUgg1XtVCln4HfaxqnfHs5rwLZuFDQ3upS30GTG
         u3FZgnNhKz3+mg2/4ubrPbRhkLDUA2Cmr9u1joscW0djchhHsOq6lpjeuVmEiiwsZ+Kf
         5362dlYpLlyQyIay+y6rNfyFMq4QSDWIQ3/JBBXo8ZqSGLfDUwW/gtFaTshd345HmvSS
         l17vvhTtogmlLQAWrDEA15PhLC3LphnDlp0byEeKLNhPuwrgvnmaxfWKtjyrm6aQ8dG8
         5CnVaWwKo/sS6nFW+iBtHNgu1FTO0sPNejzlDnlKVjOFAyZcMJ7LVqYf2olwJOHb3Pnn
         T+CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=VaTYZS3FdWj202Z1cIYQJggrJMEpd/wr+92gO5GUCcA=;
        b=NqW5SEBDTCfxV3SOm/luJ8F0wzKY8H6lt0+HUf5Zd6b1hiNH0+aORL1ev64aIughL1
         4ieTC+/vvYrCJY+1AFPUUxQN17TBavuRXqK8F9Z+gemJAMbpOFqieAk31qrAwDUnnOMd
         IBMaB+w1z/ggUDer6GzbjpV1Alqp8uV+kFrts2MK+pjXMHVeMfP8lVXjnIluQynTXbyT
         Oj6xWfCv7DemR+Kbo/gyuif9Q2nXB5d0QWuabbYrCd4LnbZhyaVe8JLtTefB5sK+nzZw
         mlERb666iEVQJQdmWxGyMkss2mVy9PXYitQCG6r2AaBWnaLmdttDo/rFlxf5Sjhclpho
         YBcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=QXr0LedM;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i192si1425646ybg.26.2019.06.21.17.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:01:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=QXr0LedM;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNsAEk006695
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:25 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=VaTYZS3FdWj202Z1cIYQJggrJMEpd/wr+92gO5GUCcA=;
 b=QXr0LedM/Vc4aA9QWlq8TFaaf6K7yB1JiO8LZC1T4cAWNojl+OGoSbtmgounz/i1/Fhx
 A/rshCVAOA43bxGsJrPKEfp+lec9VQdtWAoeP5fJuBJKKxVIB9WDIX6WXXRABbIQZuh6
 j6nQZFOEExiNyRXTCyYdBVX9kWDN7ZgnPXg= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t94ucrwj6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:25 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 21 Jun 2019 17:01:24 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 6FAAD62E2D56; Fri, 21 Jun 2019 17:01:23 -0700 (PDT)
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
Subject: [PATCH v5 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Date: Fri, 21 Jun 2019 17:01:07 -0700
Message-ID: <20190622000109.914695-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190622000109.914695-1-songliubraving@fb.com>
References: <20190622000109.914695-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=979 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patches introduces a new foll_flag: FOLL_SPLIT_PMD. As the name says
FOLL_SPLIT_PMD splits huge pmd for given mm_struct, the underlining huge
page stays as-is.

FOLL_SPLIT_PMD is useful for cases where we need to use regular pages,
but would switch back to huge page and huge pmd on. One of such example
is uprobe. The following patches use FOLL_SPLIT_PMD in uprobe.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/mm.h | 1 +
 mm/gup.c           | 8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0ab8c7d84cd0..e605acc4fc81 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2642,6 +2642,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 #define FOLL_COW	0x4000	/* internal GUP flag */
 #define FOLL_ANON	0x8000	/* don't do file mappings */
 #define FOLL_LONGTERM	0x10000	/* mapping lifetime is indefinite: see below */
+#define FOLL_SPLIT_PMD	0x20000	/* split huge pmd before returning */
 
 /*
  * NOTE on FOLL_LONGTERM:
diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e4..41f2a1fcc6f0 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -398,7 +398,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 		spin_unlock(ptl);
 		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
 	}
-	if (flags & FOLL_SPLIT) {
+	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
 		int ret;
 		page = pmd_page(*pmd);
 		if (is_huge_zero_page(page)) {
@@ -407,7 +407,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			split_huge_pmd(vma, pmd, address);
 			if (pmd_trans_unstable(pmd))
 				ret = -EBUSY;
-		} else {
+		} else if (flags & FOLL_SPLIT) {
 			if (unlikely(!try_get_page(page))) {
 				spin_unlock(ptl);
 				return ERR_PTR(-ENOMEM);
@@ -419,6 +419,10 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			put_page(page);
 			if (pmd_none(*pmd))
 				return no_page_table(vma, flags);
+		} else {  /* flags & FOLL_SPLIT_PMD */
+			spin_unlock(ptl);
+			split_huge_pmd(vma, pmd, address);
+			ret = pte_alloc(mm, pmd);
 		}
 
 		return ret ? ERR_PTR(ret) :
-- 
2.17.1

