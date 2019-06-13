Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90E36C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53BFB20645
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="b7Nfvr06"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53BFB20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B36078E0006; Thu, 13 Jun 2019 13:58:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEA9E8E0004; Thu, 13 Jun 2019 13:58:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EB908E0006; Thu, 13 Jun 2019 13:58:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54DCC8E0004
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:58:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k36so9859552pgl.7
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=9+PXCMixt9lRw9/JwM+cwAKSDJ/N3K3PePNnztPNT8U=;
        b=hnzbu+tu6CdizrHgfLRTw/PNpZBpWYRZGbfonOjL2wcw6jgvnHyp3ORIdj3nKoHffO
         ThBpuw3t63wcHjc9fgbJKIP9kVVO7CnDq03lwUdkrVbL9wFDl1t9mly2m+gAMmUaweSY
         lg2i4ihZPpaqNkHhzFu0nXL7aEAokbVEmIZ8CJpgdp3WNK85UroTNw5UV3u2DqSZV9Wu
         H1vlfKuiR3cEnZ+nE7cTydkYi/N1hSXCZhRT0UdyN1p6ehUH5BH+bCxDZV7EZ9LyoqUW
         BXYZ7qPZoYYcBZ3Zvif2XEwjCiyJl4BM9oIu0i7VxXinMvMU06gjFlKQjKlAKkVvywmW
         H0Kg==
X-Gm-Message-State: APjAAAUzBlvNNgj8+PYv/HjLGqo5EmDFpDwSkyIkRyYO+wcFwJXj9If+
	3wgxWtD5iv6dRySvct0iPYJyu5y7S3ONfB0iiPxw+C1xhH6Lvur5c8El8hcfeEcglTFQXBOScpn
	BclqtkoZQwYvvKOPy2b3GeiP7QEHWgeFM3AAuHbV4z5/80D7la/W52i2rh1GL1NeORQ==
X-Received: by 2002:a65:64d6:: with SMTP id t22mr28944915pgv.406.1560448683921;
        Thu, 13 Jun 2019 10:58:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN8R0CA3c2BDaqMkpxYOv1WelQQGHaEG9BCpg2gA6Ul7o8XZJlcLY3R0eaDEop04wh9Ghp
X-Received: by 2002:a65:64d6:: with SMTP id t22mr28944863pgv.406.1560448683194;
        Thu, 13 Jun 2019 10:58:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560448683; cv=none;
        d=google.com; s=arc-20160816;
        b=GlzJ9Fs9R46W0ibNeP4jRUrBj4hsyzcLH9TPQl1/qWULMB4OVsb9OErh5SWk4HWQmT
         XUdpsXRPApbnX7CqOJSKFlhoxjKxAeNic7VQQJCVVazbmp4YoMAL8QBPm0zmb+QKU3H8
         L5WeTiaOqj5sdIiTkg9JmYhO+FtFUt/v6BDWJ+8AVuiPxlVEwd4I5+7YK0QQMmhzmfIZ
         CotnNjyfc1XtJmC33lIq7GPKTyaVriAQd5PHsYCxGXmjUhSuU0qE/g7am0eG4irHV/ge
         /sozLMzqHsvikYy7NRPVjw6XxPSMvAQr8mBZvDq75w8NaqI8nziQhouLhd0LsXKXRmoi
         vPSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=9+PXCMixt9lRw9/JwM+cwAKSDJ/N3K3PePNnztPNT8U=;
        b=uGXVIEZOxQ/Ywkzb8GWoQc9JQM1+djtPSNhdUbJH+rYGp/y/TOVEgt/MNFOdEhOB16
         KD9fl78q7mBRSYTXAWRv66wBHiCxB+4jvNJD/fEOUYFK+Z9H5q1kkUvMtN3pLwgUEByv
         fV1DGGM8I/qYb9hxEehYPv2d44cDRak04GwID6abADaaHJGttKhbOof/lfvkoSUS7Bq0
         Ly6D3mWdmm6+/7QproUid7wDdHpg0NTri5D1EFuGtWTTBUKgZUZm7OxWayjTPYxs/L0o
         QiRIybEa5/kg+noG57Gu7E+ENqsaSdJxqwyOwHM0XDEuQuRcZv/ngqgsU5k/l1CPgVIO
         54iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=b7Nfvr06;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h9si275046pjk.47.2019.06.13.10.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 10:58:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=b7Nfvr06;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5DHpumX012700
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:02 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=9+PXCMixt9lRw9/JwM+cwAKSDJ/N3K3PePNnztPNT8U=;
 b=b7Nfvr067DMelu6Yc/rrrMnDWuH5y+Aue0tApSYAe8vFf/SYmb+jNvsNtKoIes2OWueC
 biR2uwNKLh0SsWD5C24++c0gPkVuHGGHnjy45aRTTvzb1s6iWJtMLHX+1NJ91ajBLB/C
 OAXZxpq7Dx2ietQ0atTW6+4HiT/FvNDyTDk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t3mtdsgec-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:02 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 13 Jun 2019 10:58:00 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 51B5662E1C18; Thu, 13 Jun 2019 10:58:00 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <oleg@redhat.com>, <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Date: Thu, 13 Jun 2019 10:57:45 -0700
Message-ID: <20190613175747.1964753-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190613175747.1964753-1-songliubraving@fb.com>
References: <20190613175747.1964753-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=973 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130131
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
 mm/gup.c           | 9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

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
index ddde097cf9e4..0cd3ce599f41 100644
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
@@ -419,6 +419,11 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			put_page(page);
 			if (pmd_none(*pmd))
 				return no_page_table(vma, flags);
+		} else {  /* flags & FOLL_SPLIT_PMD */
+			spin_unlock(ptl);
+			ret = 0;
+			split_huge_pmd(vma, pmd, address);
+			pte_alloc(mm, pmd);
 		}
 
 		return ret ? ERR_PTR(ret) :
-- 
2.17.1

