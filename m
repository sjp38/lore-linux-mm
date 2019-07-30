Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA0F1C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1C21206B8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mu1ySjw/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1C21206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E3AF8E0007; Tue, 30 Jul 2019 01:23:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36C198E0002; Tue, 30 Jul 2019 01:23:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 233768E0007; Tue, 30 Jul 2019 01:23:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id F0FCC8E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:23:27 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id h203so46742306ywb.9
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=YpPGU3ZiU++0VQgyDS3QSdQ0lQHIOIN4ED9AD9AHh/Y=;
        b=ToMS4ghTZn42SOJliwVuSHguQJcKyQgoTBC9Jft7BnqaEYLqlC4ovmCD0m2sOzNa25
         uNsmA0GbcUVRw6t706e4zWExOFNsAwEjO0qLyocFIHff2JkVUxFxdV1a9FIRqVJ5QLia
         xiJ7f3gUJrDQKBZj5tiihgWgHB6RlBZqhcqNb4pMlWjeOtgfVbH7UcVa6fE1K/UJUuD1
         sLypEkh0k9ZmYH+WNYBgAYRs0KRsXNvDoe+5EUYxXIDA7aYB3zEQqiKZUJgeFoapNhAh
         P8IgGeg4xUsTgx6USvEI2nQEApgC67un1OKzBx8UmM0gwPRUmvgc3DFb++p+V8Ggpsdy
         jamQ==
X-Gm-Message-State: APjAAAU2HW9lWHw8rzitx9WCRD+bLYivATT7BQS9fHKOfNANbsUw3pnO
	5ZAYY+C0TnjcwPCKH3cuzQSTA1HUZHR14iaZFMWpUOarTnw2O0WqYpvL2uXPZAX90E3zM6QeuOK
	eS6N9es4TQMZWUIwIUuvb6CPhyCAeEzdmvpJffrwNdkExw1Vl2tTw4Hk19pNk3wP5BQ==
X-Received: by 2002:a81:9b8e:: with SMTP id s136mr73013332ywg.114.1564464207659;
        Mon, 29 Jul 2019 22:23:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlVlRdVjoyRtq2z6yu3wEXhB42PL7NKuT0Y0i7xXDZcblv5izKPaD/X3HtDwqG1B+uOn35
X-Received: by 2002:a81:9b8e:: with SMTP id s136mr73013314ywg.114.1564464207032;
        Mon, 29 Jul 2019 22:23:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564464207; cv=none;
        d=google.com; s=arc-20160816;
        b=KzVxsqZGiGMBqUfSSp3lvBp0Tf+hM9HHKXRtQTP4DHSo2UgGvjX+ExXV6IzScipChk
         A4jR6AAtK58Lr41RFgp1vymB0QjS0D+jBZMfgXGh5nVwkdoWr5g3qwk62GYyZ3nMmz0v
         ehPf/QajonqWb7cdmrESCaDFYs767ewUiOteXwEJb+fkYvlILqR6Ef3HLjbOz7ThPgfn
         C02KOsYx4G24DdTZ77JredB+u9BUitvxG9SGHCzi0Sst7EKmt4Ruv4MeXzI2pyy7DFvu
         y94O7XdOJkRaujf9oQMBaGZIj/IgMeoAE075YxmgJ8UR5YED3PRxRTc682+ZrEM/RwA9
         fAPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=YpPGU3ZiU++0VQgyDS3QSdQ0lQHIOIN4ED9AD9AHh/Y=;
        b=jvX/DCHTcTIDtggOcytXRH/uffA5i9Hiyr2oIE5ZzVVbLFi+pAOGphdfeXh/UT9IsK
         5f3MAWULW3mPlQ/A0tWt/MvrjypKmYWm8LaHrR8Onf6graWb1+73JiWdaCFMlKS9vsfm
         qK7G2qVBd+9IzNy+1DOkUXxnlIDCeyI7WfU4IjgnHxEqQyuwNIiNt1c0ri0D9B6UPUE5
         7EdxAmcxYl8QFkP4Ve6KjmhJ3Dw468MPbdPoesBdGhk2ykkJOXRwmxSlrWxN3sFHzpSG
         9HvQzSPjAtpA/KDm1lyNPGFV7QkIkOtI40AKn9gkPNz7Po2cOCZoq5O3jvobIKpX8Elz
         2teA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="mu1ySjw/";
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q195si24768274ybg.339.2019.07.29.22.23.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 22:23:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="mu1ySjw/";
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6U5JAgP001064
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:26 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=YpPGU3ZiU++0VQgyDS3QSdQ0lQHIOIN4ED9AD9AHh/Y=;
 b=mu1ySjw/kbTmhP5vRfEKL8I9vZPwH5AJPB64Yuj7PIVtwKVfOuBGKkFvD9WcYT15Y6Yv
 u5Q9iC4QQsqvoemsDexIz5UoLroNpi5oRsT5dz4mvh7bQx5so6G+LGP+0mgOqKeAT1st
 v0r7aD6F+c5D6G1UsPbKjNDFGLqm42SPP7s= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u2eqgr4vq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:26 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 29 Jul 2019 22:23:25 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id B584662E2FF0; Mon, 29 Jul 2019 22:23:22 -0700 (PDT)
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
Subject: [PATCH v10 3/4] mm, thp: introduce FOLL_SPLIT_PMD
Date: Mon, 29 Jul 2019 22:23:04 -0700
Message-ID: <20190730052305.3672336-4-songliubraving@fb.com>
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
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300055
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

