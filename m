Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4C62C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BEA5208C3
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="R51XPFQ2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BEA5208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46F906B000C; Sun, 23 Jun 2019 01:48:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AA3F8E0007; Sun, 23 Jun 2019 01:48:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 246808E0006; Sun, 23 Jun 2019 01:48:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id F349D6B000C
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:48:53 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id f11so11084119ywc.4
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=VaTYZS3FdWj202Z1cIYQJggrJMEpd/wr+92gO5GUCcA=;
        b=SrSsmYuVfqtHXhDqA7bnXrlI1hwCpBL/DkD4xyXCsC8FXyYN4ctKctMo0YgPz+8ELq
         IPN08S6vlVmRsBCl55mHxTVGm3OA4x3an5Fx6DCj392Vhfw5yxU2nchWu1Vq1SGMLqwl
         OQWU9x9F71fBkDhoTcpcFkh+ipbIOG23HldxMPNyQbxBjYZTSU3OWPXxAnFxi7a8E0wc
         KMJQxdLvuKuRJBZFMF41LCTeubr5JnME6WuBFFyQMkHqGcIIt+258WjyVsn8DkHEzmib
         C7eHyIdo1EHsmofYUNwUJiEpEcxg0Da5KNFFIPnMzZC0zAGrb5PCH7SLCbCCmP/HtHvw
         llfQ==
X-Gm-Message-State: APjAAAUtaoJaEyUjiBiHwY0VUulvE4VI/Jjm48PeUdfW+AP0ERBRnkAe
	QPoWdwVfwfxS4iA1cNhHwcDGgcUqnAQjN04nz9ONG3PB3HrtuR6bPmvIpIyLSa8haQHyQxyqHzT
	Jl4rdZpcOZo6ENs6bGqnjWerUxEqNNnQ3ruqwZftu14q0RYboXhYOp7ZCReWLi2QGTQ==
X-Received: by 2002:a81:7815:: with SMTP id t21mr79384569ywc.222.1561268933735;
        Sat, 22 Jun 2019 22:48:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMx0+hN0cCHLmvGqw44cHAwAl6dy8tCEeiI7/+xB+lNrXK9rmx20Dd4L+nRIZFdy3vJuPY
X-Received: by 2002:a81:7815:: with SMTP id t21mr79384555ywc.222.1561268933094;
        Sat, 22 Jun 2019 22:48:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268933; cv=none;
        d=google.com; s=arc-20160816;
        b=EnrLnMUiUJv/c55wOf85mglsycbXFiZpr0i6SWmyHVWfRgTs5MXuSoKLDgoPzo9gQY
         iiS+j20zuKWLFei21JLQyJTort05SCAcnZOgBpEWaVcy3sZlrSeGkQVJ/1I1S3/PA+ii
         wYo29bOTHUVXjgCXEPJClq8G+vkg1aiaDuqm3mdK4DAYlAB2o89hsujXiZxH9Ht+zabF
         yovVrJ6P/aQ9W9gVaZQrZSjU42uwDPrfTQso92xBpR+aUMetDCtufpa287HX+kLkb+m6
         aTaboBib2g9ddRX4huCJvJ4VQYvK3UEtEtJHcIsfJNLJBIHrSGQDP94oBlmPMqM4hPmn
         HkKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=VaTYZS3FdWj202Z1cIYQJggrJMEpd/wr+92gO5GUCcA=;
        b=aDjCjuQyD9cauZ2WWgoGGUKmo/Kv75AEEFbryIDLJgV/ZRKaU+6o+l2w46jSgadwiZ
         Hnd6NmPePKMYqWRM8Qgq9dYCJw5OUlU5ceZdJdeFkOB0B3jVM3/giEeMcHl8Xu5FwRj3
         H/Y7yiw8q1yrraGKiTFJ3MJONwtpVt4wh5CUJyWCMXaQRZLowCiBWCyiEpwmtoiqThKQ
         Dnwnxe/6f2o7twZOv34FLRxmUBXzvXCtl4krxmKAqopit5rn0VwMNsTQgpU03bZSLbKz
         y0el/hi1uGechkQNVpcJx/bHGUln8aGztCwr+JUMFP48EBYlyrwYZmQH63IVmJ9qdua+
         qUbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=R51XPFQ2;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id g9si1490346ywc.199.2019.06.22.22.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:48:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=R51XPFQ2;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5mlt4006687
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=VaTYZS3FdWj202Z1cIYQJggrJMEpd/wr+92gO5GUCcA=;
 b=R51XPFQ2x7NrBKNEtYxeij9Ig8VOtiudDe77XRijTVwui2ISAx5usXUxkWd/sMwCRqp6
 32BInFccXA9rl6yxYakxPBV5Ws2p9/HxpYbbnui7lNTYWC3PcEv/YH7NffZVOpnGntZs
 33ejP5P3GkpkXvZogeJesLNoJDiLG1fxb34= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9j2ca3jy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:52 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:48:52 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 2465562E2CFB; Sat, 22 Jun 2019 22:48:50 -0700 (PDT)
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
Subject: [PATCH v6 3/6] mm, thp: introduce FOLL_SPLIT_PMD
Date: Sat, 22 Jun 2019 22:48:26 -0700
Message-ID: <20190623054829.4018117-4-songliubraving@fb.com>
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
 mlxlogscore=980 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230051
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

