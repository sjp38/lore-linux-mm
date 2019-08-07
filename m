Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95EA8C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4857C20880
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="J+m5f/t4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4857C20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D5206B000A; Wed,  7 Aug 2019 19:37:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70E906B000C; Wed,  7 Aug 2019 19:37:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D8956B000D; Wed,  7 Aug 2019 19:37:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19C4C6B000A
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 19:37:43 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so57754476pfy.20
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=QCXgQ1j+DyNDDAhgp7fIcjUO5uiv3v51QF0EDrfCLxw=;
        b=VvAQiqqG0Eou9HhkJHGe8VIjXOXrO2B3M/Dl+C2azT+Ai7hIPraWwcBm5AdemB5fI4
         k0EM9aecwRA2ozEiMXb/xyQpvNBNi/9WfWlRCwl/cp0Q0VfKe4AoP9VBulAvWS+3gqGL
         svR7b9ttFBHdh5Xd83uaXxw/FtxeJ9NO9iQgn09Od5DjsWeFO52UO4JGUL7CiIn0IzYu
         w0KJg6vuTSNl6bkdAF3teRXDIxKoek0znKvYSunynwZZsuZDXsQMHSBN35sfbePJqp9f
         2QtszUoJB155uxwJODnqx73Wxged7uHGqfvcufN4MNAGw+i+B5UWlpDvnosQEqty6YFN
         RCCA==
X-Gm-Message-State: APjAAAWmuV9k1SWRPx5gUflbMVes4tFquBmVkOe1Jy74VhojfP4ChhVO
	5rRm0FhBwphZC8JnanXFGGlYg+Jbr/LcU7vCWCiKqQQNTic7Lna5IvQ17n9jcmEWRJ49Ou+2PHo
	Ak4pcyColw+LfwPsTod68Zew4EdE4HS5qIArj7ZspYijvh0vfH6zbWIrHHOhQGHcJfw==
X-Received: by 2002:a65:6497:: with SMTP id e23mr9558226pgv.89.1565221062594;
        Wed, 07 Aug 2019 16:37:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWjXpC9IyHn/Yw2iklPXGVtqc6yBDUb77cpKjbSsxVt33eOtqdyQYefXgYp5xjiXuLYjvj
X-Received: by 2002:a65:6497:: with SMTP id e23mr9558184pgv.89.1565221061762;
        Wed, 07 Aug 2019 16:37:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565221061; cv=none;
        d=google.com; s=arc-20160816;
        b=IRflJ+q+sG34tIAwwa9R/ErUMgptzBd7GFLcSMcnzZfjip4rYrDlZKpYLQ0DFtMKzt
         wCcEpQU40QFC1qBRY9s8l2bHiHS05byeHL4IrnKPSFKCHv7YNgDHUXJewmhqBAjVViK8
         X5/4+iunVVSB61iDuYcRPAP3CNBpfHV+1+ozECy96Ena5c7dy2NnYsTJg6W9GzVwYbf0
         xd2I+z78P3z6xRc3Csu9QZxLQ1P/+j2whpYs0nHjN+c3H9Jon2dwtiSyEaOWzR1Qtqsp
         4gkVsKgFxQXkGuzEmBc1opds/Q7QsyJkwkoq0Hda5OkjAlsHDsM3G/x/mYneXaJzWKE8
         jNSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=QCXgQ1j+DyNDDAhgp7fIcjUO5uiv3v51QF0EDrfCLxw=;
        b=NeIJNfKzEaCGncI0fBWAwI1C4us9PRq3wKp2U0iGdLZieRVU0puyCXhRbN16FlPk8y
         I3xPbWJH+a1nPmQr889i8SurY7m2VWj+/OuX+BBgzI1XF5KTTI225OMT5crJx8H78M/y
         lHPU/KTy65KrKDvNQPKulvoaA189KPv8iVlm+Dd/qsLfMKN6sd+kNpe4kLzxU2+VZTTh
         bL+FOw9QL7MsYx0NqfVojAjUD51snQaXwduv0iYGDeZ0LMlvMg41rOJqX5XESYXQd81T
         HQ46EfTicZkb60wBGwqQRxtEig1MbuEM7AiSebwmfUyzU87qsW0pjxcEzPOB5bCtV4T6
         dpJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="J+m5f/t4";
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s13si12415808pgn.123.2019.08.07.16.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 16:37:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="J+m5f/t4";
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x77NYIRm003950
	for <linux-mm@kvack.org>; Wed, 7 Aug 2019 16:37:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=QCXgQ1j+DyNDDAhgp7fIcjUO5uiv3v51QF0EDrfCLxw=;
 b=J+m5f/t4QpaD1Wrw+w57zoiiogbQqFA+DYikA89WMmTFzK3vpitmrsmCQkdquggXEV1+
 +JyroykUIoO1yXXYS9WXD3BLSKUXgk59E+l+WL4OrDcX+ghbjJj2jR8UidZUdeIsXFw2
 lz8Z4vl5Kb0fUbgxwxOp5dQNqBY5R8fBTso= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u87ueg4sc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:41 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 7 Aug 2019 16:37:39 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 314A762E2D9E; Wed,  7 Aug 2019 16:37:39 -0700 (PDT)
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
Subject: [PATCH v12 3/6] mm, thp: introduce FOLL_SPLIT_PMD
Date: Wed, 7 Aug 2019 16:37:26 -0700
Message-ID: <20190807233729.3899352-4-songliubraving@fb.com>
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
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908070208
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

