Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F75EC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28F6B227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="hrQDWBSd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28F6B227BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C9DE6B0007; Wed, 24 Jul 2019 04:38:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 131D88E0002; Wed, 24 Jul 2019 04:38:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0DF16B000A; Wed, 24 Jul 2019 04:38:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0EA76B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:38:23 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id r67so33914675ywg.7
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=YpPGU3ZiU++0VQgyDS3QSdQ0lQHIOIN4ED9AD9AHh/Y=;
        b=RBSQlFn7Qj7xbkRja9A0othvpYoee1ldgLcs+bHnwpy/Rwn32B8VaxxAMxKYzlAFbH
         cdccXDtRrMW6VCNNeahBf2xEtcBFgkmCak2G41h9fo0aKOMSMB60qqZ7ohOOC9PF0+UM
         1be1l0xZoVkASs6urKc4Whp6SSjK/LzhzOyBVHKN3nSQmaKS48ujKA6GJ98qYEnHLVmm
         Gny6oB8v3xbrSYtZ6HDcmhv5vnY7z2+6lkk17dLxgmhnR9s14F5tm5O1uA4/OfXZ9evm
         lxdVaWLDuyCfPP8DoY7HiiE9kK96W5tebNCIxQz5qmoTln+TxM6mwtGF6XcftT5o9bbZ
         WyPw==
X-Gm-Message-State: APjAAAW5SMDJMltgi/5mt6GnmzNHR7zLSDb42HDjQmG5kYdCWMSXrarE
	CmY8JIpW3JjRvW25jZeqDHz3aGXfzA6L3Jiv7SVBD+FBovpaYxblF2l/A1A1/2wguZuS/5Lhnju
	IiezEVHPjv3qcqnAMC5d+aJFxSWrM8HfXXEneJRFh4zIpxXT1SH9o3v26aLVePRWpqg==
X-Received: by 2002:a0d:d616:: with SMTP id y22mr45354605ywd.365.1563957503544;
        Wed, 24 Jul 2019 01:38:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGpn2+TGvHZWnPlUM0LfVeyDx6V1Gs42YmeDN4OZyRwQHjYGfYyk5xsfnl+Fqg9TUaBj8y
X-Received: by 2002:a0d:d616:: with SMTP id y22mr45354592ywd.365.1563957503038;
        Wed, 24 Jul 2019 01:38:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563957503; cv=none;
        d=google.com; s=arc-20160816;
        b=O7IayxKeSHq+Jj3UgWLuJpdH1m6QgeRW6eBQ1i3z3KhsVkgv2b3SxDTNJC8gkfyJW7
         6psdMgyhud4uvQeuFV5em7mOutFmeq+n46+/538Uf/HV2ObRar4L6Vtrlscq4Qs4hROI
         bDKdyyOXgzX/5WfgsJ9DeqNLNfpfaGDWGYcenRWXj9eMr6ROJx+0SibHsac7PVJlyU7G
         oZ2D3+ROEv0q48slMdZRN+pa/5znIa/GV/qvZcLcD5gxMX6me4B5BbhNt4UR8jnlPnBf
         Gxpdm7iowRp7L2J6gW0732Vq0mGlAdhtF25wmw+0f9+yjGa7ERIaVUzNKdCezOSaHhrj
         8OVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=YpPGU3ZiU++0VQgyDS3QSdQ0lQHIOIN4ED9AD9AHh/Y=;
        b=S3gNiM/NzRxJ2U3ebUADd8wvv+FmvlbsYT4DupuIuUd3KQpX5LPy3e90A/oeTNPTiT
         2bf/e0k7Yw00wxWir3lvWFOLXyIzCZ8nJEaIid7dOz2OICCUDB11+EkQjvo6PJocyAHN
         XcfCqg9YgXcvfuQgttU6RQcbtRfF6Ob4A6jbRcs7JFGyRleJfW2myOh/pjaKaJZltSbQ
         0CxheXFBZUl5juSFO43ilsmjFX7cPwH3hekwSGhiCdFoNrYAbDPyK6on7XlETkwCbEcY
         13Ro2svQZAxesCss4V0Nqu7tCjlCg2KbTV+lO3P5JGvKrntViNCfCk9s6SWJO9s/mr3j
         nJxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=hrQDWBSd;
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b140si16341700ywb.36.2019.07.24.01.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:38:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=hrQDWBSd;
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6O8bdl1006351
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:22 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=YpPGU3ZiU++0VQgyDS3QSdQ0lQHIOIN4ED9AD9AHh/Y=;
 b=hrQDWBSd1fkR5fAm2GFn7KYt27f37ZZyry6ErBdKmaOJjwXXEt7xd6SuTiMWII2RzYrt
 LO83GQx1CAu99ecFt91yVnxuGAEURJg91dr+VvZgKnpmrQkzKJbpji+bQWK+s7JJasJD
 dwPnjldMlzo82LPTBLRNIM8qNRDd0zvKCIU= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2txk7904en-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:22 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 24 Jul 2019 01:38:16 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id B1F6F62E30E0; Wed, 24 Jul 2019 01:36:13 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v8 3/4] mm, thp: introduce FOLL_SPLIT_PMD
Date: Wed, 24 Jul 2019 01:35:59 -0700
Message-ID: <20190724083600.832091-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190724083600.832091-1-songliubraving@fb.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-24_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907240097
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

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/mm.h | 1 +
 mm/gup.c           | 8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f189176dabed..74db879711eb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2614,6 +2614,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 #define FOLL_COW	0x4000	/* internal GUP flag */
 #define FOLL_ANON	0x8000	/* don't do file mappings */
 #define FOLL_LONGTERM	0x10000	/* mapping lifetime is indefinite: see below */
+#define FOLL_SPLIT_PMD	0x20000	/* split huge pmd before returning */
 
 /*
  * NOTE on FOLL_LONGTERM:
diff --git a/mm/gup.c b/mm/gup.c
index 98f13ab37bac..3c514e223ce3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -399,7 +399,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 		spin_unlock(ptl);
 		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
 	}
-	if (flags & FOLL_SPLIT) {
+	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
 		int ret;
 		page = pmd_page(*pmd);
 		if (is_huge_zero_page(page)) {
@@ -408,7 +408,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			split_huge_pmd(vma, pmd, address);
 			if (pmd_trans_unstable(pmd))
 				ret = -EBUSY;
-		} else {
+		} else if (flags & FOLL_SPLIT) {
 			if (unlikely(!try_get_page(page))) {
 				spin_unlock(ptl);
 				return ERR_PTR(-ENOMEM);
@@ -420,6 +420,10 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
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

