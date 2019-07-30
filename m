Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6774C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:31:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0B5A2067D
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:31:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ZWcLBLTS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0B5A2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3648C8E0003; Tue, 30 Jul 2019 15:31:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3156E8E0001; Tue, 30 Jul 2019 15:31:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DD4A8E0003; Tue, 30 Jul 2019 15:31:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC65E8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:31:12 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id e12so48139175ywe.6
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:31:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=QCXgQ1j+DyNDDAhgp7fIcjUO5uiv3v51QF0EDrfCLxw=;
        b=PWa+jhKgKUxEFr44XR17A/ueFBOtzzPZ5MZAM3fS0fD4hLGPPVTxzdAq9HwFzhPno4
         1pz9HAqwtyH0/oujf4IGkzzZBOwds1HPD19ABx4D1Z9HZH9y+QzFxlfDAAaZnSFTFm74
         8ZcMapy7NQtJGCbY3FHVUKcQkx4nkxWTi9qcOKcpebd9+f5FEBGur+l8pGjnnnZnSUsA
         Cona6ro2OvZubZrf9H+GRCsJhJ/A+cBbqABTbpQ3cjct9AMqf6VQaHe7h9+PPIDFCgzj
         SBDyvUwa9G/R/C8GhSf7DNaltk58wf1pRh0EOt52fZuV8YbvnHDTauw96d+ofDinvkqH
         Eauw==
X-Gm-Message-State: APjAAAWsLDyttU+NGUcUwaNwDIhSkvAAc/NeiAsh05KLQKxHe/WZduKf
	lV+3QEa3TNLZe/9B9DJreIYWLySg9pJcEQTCE++OzZyiu1SHLvu70dhzIu2t/Q06JvMIJSUnfmG
	YJPHTBOhHQ4prEAUe/cszoZQLq4EHcOM9k4mKgTUpbA2JTJEcdRNbOzOOkN7xgSwtdg==
X-Received: by 2002:a25:bc87:: with SMTP id e7mr67941886ybk.361.1564515072594;
        Tue, 30 Jul 2019 12:31:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2qZb3oHrxD4nS4ZZ43WbxHjjpIvJM6FPlwGcnf+dCpGK+HYdo/7rM4PJ/2R/FqQiizqUw
X-Received: by 2002:a25:bc87:: with SMTP id e7mr67941843ybk.361.1564515071972;
        Tue, 30 Jul 2019 12:31:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564515071; cv=none;
        d=google.com; s=arc-20160816;
        b=Ea8sTJLteRCc1aEQCTz0P1vqoJQz6xUSZ7/tW+kchY2VQ3TGBQ6qZpIVcIdEoSpKH+
         gm5aCwQsGez6tF9MqNJLrAbYP2gFvTgYnx7UiS2el9GhXhOyILmz36CUdyxBf5FXmLlj
         EIP4oUYnnd0EvlNH6nCpjSxoNR0phcdcNS6hskwptTmMytB/M1wpMtn0QbveKfwe5Kns
         k8Qmhmb6PVZXTs7rNF2ayzW6wdZxFukkBV+vXHatNQbY1F/z2HZhot54/4badUXS1dKI
         mhofyYGGL2MSmoRS3Es1BV/cChjNo6b4L+2uk11nATxSW2sGE/SxK+heoWrPWFeQrMO/
         jjdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=QCXgQ1j+DyNDDAhgp7fIcjUO5uiv3v51QF0EDrfCLxw=;
        b=mWyM0xJ6R6N2+HgGczhgsljOTzrvIBnf811yWxpgJWiLfaTTjDmhuVzzSMDQZ4sFCi
         KZnP4cs86m8eMUg0PWzAGe7IIZJjIC2ocxXvOtOub1T6WmXFYk9F7uco30n2RRx71L2M
         lTa35f43Ys1UO82RphB1F8YZjbcgeJyGhsmWrzbzGwURTQm5PzecfTUo9YzlhF2qNzBg
         gFfTX0sb5EErNQ4MTg3Y1DUYPmDuQDGDk6QDRgo/9jLolFu49EcYE57Y2Whn4L7Uneqv
         s8Jmwhp+kZFAigREw0T2CiWqBwfqHe1Y2BUtkYCCFQKv97G0Bzc62jWFoVoGneDNIcAu
         IAbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ZWcLBLTS;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a14si7718631ybp.39.2019.07.30.12.31.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 12:31:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ZWcLBLTS;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6UJQqfA020413
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:31:11 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=QCXgQ1j+DyNDDAhgp7fIcjUO5uiv3v51QF0EDrfCLxw=;
 b=ZWcLBLTScwU0k2aa3wveOMGf8/UQWCDrJl+bv647ihHa/2Ufyy1wcNRunSXXWBqaL5Se
 1cXGwr9U64RQRrKRn3LYrgaVYgcpAhDEYrlvjma4/wj6e+IiUiH0BgY2scvQD8TwzGr+
 DkmmpxUEbflq/gOYOcHjU+qlyiz9LRnMqCI= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2u2uy0r15u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:31:11 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 30 Jul 2019 12:31:10 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 0F54762E1D35; Tue, 30 Jul 2019 12:31:09 -0700 (PDT)
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
Subject: [PATCH v11 3/4] mm, thp: introduce FOLL_SPLIT_PMD
Date: Tue, 30 Jul 2019 12:31:00 -0700
Message-ID: <20190730193100.2295258-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190730193100.2295258-1-songliubraving@fb.com>
References: <20190730193100.2295258-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300196
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

Cc: Oleg Nesterov <oleg@redhat.com>
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
index 98f13ab37bac..c20afe800b3f 100644
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
+			ret = pte_alloc(mm, pmd) ? -ENOMEM : 0;
 		}
 
 		return ret ? ERR_PTR(ret) :
-- 
2.17.1

