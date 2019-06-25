Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9191AC48BD7
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B77B20869
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="MWRRYvz7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B77B20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC7658E0006; Tue, 25 Jun 2019 19:53:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7AB48E0003; Tue, 25 Jun 2019 19:53:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1B1F8E0006; Tue, 25 Jun 2019 19:53:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE5508E0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:53:40 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id a4so952450ybl.9
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=5x4CyyHGkS8Ksf2g8Si1t+/7cLJQzDvLwXFviKMvEaw=;
        b=F424RyBpP9n+873qBvDl10Gu75tDBmhoqCiRkeOqymYAIy5mwHYDMzh7Ns3rt9NMBI
         b3Bpwlgk9MbD7pZ4pvN8HVJfiArRKrhchFWjMnpOSNnl6fwzhMmLL0z21Nmu1FUcPL9k
         HlYq/Ae2mgECur/wJGuiT7l1HeoziRt72Wql/s/3Nb96TSzMbLvkyFyoi+TvDiU/GAmf
         3XZCnzX+nc6epJJhXby80XS0aopzQjl2AlNSwKp4f8v7i4eTngEiNCrswFZWzOjulgjM
         mm0ir0z6wB8AAMtHFSK4oTMyX7AiWGeEDSAto797jyibRW2feWr147HNToqBSstE8x4S
         v64Q==
X-Gm-Message-State: APjAAAXKkTs9pYYXPIP+J4qUwr/gEC17eAqfKigv1EO4YxiN5TDJKVHX
	4o/eqVO04LeEmSFbRNamDajC9X5J9JXVIwX/GBWODA7P2+5RZc/MxCALLXS4CpasJxoDtteoezF
	nBCJ0OYOz8UOCWL4Yt3PXqQmZCCCy1WR++Ss5MHB+qr3QmHVg+jVemAPLJ3U7j/onSA==
X-Received: by 2002:a25:ef02:: with SMTP id g2mr778920ybd.271.1561506820498;
        Tue, 25 Jun 2019 16:53:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvwwr38iID+1XC3iYZsuhinb7BerPMLRSn7IH+jp2hIM4YFioWZU7lazWMehonkcttif6+
X-Received: by 2002:a25:ef02:: with SMTP id g2mr778898ybd.271.1561506819966;
        Tue, 25 Jun 2019 16:53:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561506819; cv=none;
        d=google.com; s=arc-20160816;
        b=b6pU4aE/P/EHbf/z8lXJXGFhu0jgsR0oK4mtU2+dwYJ2fhn2ifJkb9k3tICU4QMSi/
         EVlxCqo1EZSpeR3oTJjB6eG2qJoyDQfhU4lLBpI973b+Kej2Ob8ZR5zIUhgkWIwZ3EJn
         0UMrveykSfRQPe8KVk8hqLf2LdLCAmRxHtCxwqn7H5kQaCsrmlglqLqhlSm2w0U6lecc
         sdku2pmciAsesSRTRC9T4Z7UWcxuCtwm9l+xjYWrY/tPRylB/+tVMyw7bCMF/Xe43Xl9
         lT8vLVTp3tsdKn4C9cxMRrzP0k0JCdpPAyi8zFkpaw1wdOfArsW6tnLaA4J7orEHaxHN
         WS9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=5x4CyyHGkS8Ksf2g8Si1t+/7cLJQzDvLwXFviKMvEaw=;
        b=HRZ6CoUhgkCC2gV5edfs0oog1OzfJT6WKjvg9G2l3IWxG/0028QR4zqWcoPGeUW5Qa
         c9zIKXkNfUBRivCvv5z+I48eq9XEbZYFfBphNXrAaYoFJUZa+oArxQL5fyr16nxzSVL8
         w5e0c1wa0aNoqz3VdE2AiwLTSydZJwbiAe8E7t6UzkyHHRWdQ8pX6rUUbI3jfTLrSb/4
         gsqkJHgwDtGlRCYX1DKwgMRly77L/TyG6KJ/16Dj8DirnOGDEKS+SjXi+4UMl9I8vPL0
         pbXYibDauVtLxIGC3TiI+hHapKMgShY7npFV9eLJLmx1hAcq9FWYJeUHIyA7rsgePLtB
         gJZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=MWRRYvz7;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f3si5769952ybh.294.2019.06.25.16.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 16:53:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=MWRRYvz7;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5PNmm4Q020396
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:39 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=5x4CyyHGkS8Ksf2g8Si1t+/7cLJQzDvLwXFviKMvEaw=;
 b=MWRRYvz78FvcXt3p58yon+68zcAGBYbbqkDqwzq3CTgaVw4O4/WrH/0LIH/ZunYkOzLg
 yCx2yY7bl3vWPctIAaQcM+7xH75fPXzuJG+nTmgrdGNug5ysJrKsKPWBkHIrcp8CYHf1
 uJLgDDCDTBkhppBR9bOVOletyXXLqltJJCQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2tbsw3gux4-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:39 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 25 Jun 2019 16:53:38 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4882662E1F8B; Tue, 25 Jun 2019 16:53:37 -0700 (PDT)
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
Subject: [PATCH v7 3/4] mm, thp: introduce FOLL_SPLIT_PMD
Date: Tue, 25 Jun 2019 16:53:24 -0700
Message-ID: <20190625235325.2096441-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190625235325.2096441-1-songliubraving@fb.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-25_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250196
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

