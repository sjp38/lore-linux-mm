Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4C60C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C893215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="MYkh3U+J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C893215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 899436B0010; Wed, 12 Jun 2019 18:06:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FD476B0266; Wed, 12 Jun 2019 18:06:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6788D6B0269; Wed, 12 Jun 2019 18:06:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9A06B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:06:21 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id u3so10338651ybu.7
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=kq4OSN4555gAGkuBdC1pCdofeLuUMnKNDEdg6BpuyMo=;
        b=Lmy0LG7fVJepai1HRiDF2c0IFFri8D8eFtedp0pknocNEIysnBbaZZalLkuOR2zizB
         PmTX9To677R3b8pev7hahCss5JWWkhtfe8G9SDqxFJRtR1jf8C1vfWXfuUPNTOilJ1tx
         3o2Ddo206g6U3tBKhRmlUR0X3flhi4tLKAsEDjlThRYXjgg4pQLxhNg+EpX44Wj04Waf
         6yKJkCgqhqYCf+9AaokQwmroyvKA32oNL+1/BE8q1XeDLKRrMi8jwbwGM+zaUL7gdMpE
         ltG1zYcWfNNkTGztwuQmXHwv8Wg/WanAPkPCcDRQOc3XEiC4fqCOJCWS3eUCTOjLflNa
         LfEg==
X-Gm-Message-State: APjAAAWB7D81JL97q8+EbkfhaPUsnUJAXA1fqKAC6OJMWOQnmiVXr7uH
	ymtvzG0rWpN0FsTVMIgqJVLXWSDWECslyXIpOX2EBznSGdO4QsfW/XmoNgyNWrr/OudEJdNxLX5
	xO5z1zdSbb9fqBtNqClpe7hAK8dPCWPaJrb10DYIwfZ4RjrNVB+iv0fG5Tdt4MpjYng==
X-Received: by 2002:a25:d789:: with SMTP id o131mr24823324ybg.20.1560377180958;
        Wed, 12 Jun 2019 15:06:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypDep0T3M3VvEpVrp0+k6/FIEg4MLa5PAZiMiUU2aASTmH/uNCYNH+zCVrPcNe2wdUT/Jg
X-Received: by 2002:a25:d789:: with SMTP id o131mr24823291ybg.20.1560377180357;
        Wed, 12 Jun 2019 15:06:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560377180; cv=none;
        d=google.com; s=arc-20160816;
        b=cPh6eVrwp/IOnvhpVp0JmfdVCnrGFpaRdm++pZbaAQOrSvHhf8kJP4PFs+8S3NYBJt
         r12PIu2uS+0/Nrf8SaWXYVr98mvmt93HPYbDk9jxFqKyhfWdPbPOUqRaVSwKt4d3WpVN
         N5Tm2/cEE4PiPdhCxkLVpYDIZW1iXTMm44TIFjgogx5RkF6CeMHBKRgThvYi2cu7fpz9
         g/L59hPWhyGH7OBffQDqEnnrvTpGuN9rsuz3AEf1aBo7taL2UaNTDjQx8bpfIHktktkb
         HDf/G5jiiYnpBtJuyMVRfDl/fs1WXuTseHlutK20TTUMqR7o0A461oXVSZOosRMcNEDv
         4snw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=kq4OSN4555gAGkuBdC1pCdofeLuUMnKNDEdg6BpuyMo=;
        b=yWJzry7v14+eDjT2p7vnH93rgBB24VQ4k1ZKOmCvmQRXn0pi0S3inijvn71Z4c6uO2
         VDsPKaWYEEgmr4nTM7kjq8iypzPi0W+u25iIG3s6fdK0U6qcHPuJjB5ofQZYaaO1TYPA
         dKs/qKVtUVqWPDoUOD3P4WaSS3HBcSSrgNDkUUiyQD122GSY1RDU8a3TlS/mxXgpV48w
         h27YqTeyypxqEdXMG4ENCaa6+DijdOsOBgNqscCPJpcuwkAU6neFRvyv1symFvKZNAtb
         9nLWNv2JH4umheU90otG84cKAF+kFmeY7Tuu6krB2Ip+8p0SrEht1XKA5ji4KE1YzmAl
         l9TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=MYkh3U+J;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l195si281642ywc.3.2019.06.12.15.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 15:06:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=MYkh3U+J;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5CM3M4A016862
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=kq4OSN4555gAGkuBdC1pCdofeLuUMnKNDEdg6BpuyMo=;
 b=MYkh3U+Ju7SqSxVPQrNXSAF+zvZ9PcRsQQDXJE24KvAVT9tY7UMNyR+CJi3WNtay3Uqh
 A2Gd0CQrwjeMl8FMIvWIQa+WwTyvwpbAQzh2ItVZvgwSI/YPjM7YuEJJTYMZMxLfcSli
 WR6tRr0HbvftJ4if31pP0NfFpizKrmvQquU= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2t353y1470-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:20 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 12 Jun 2019 15:06:15 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id B9B4B62E2D1F; Wed, 12 Jun 2019 15:03:45 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 6/6] mm, thp: introduce FOLL_SPLIT_PMD
Date: Wed, 12 Jun 2019 15:03:20 -0700
Message-ID: <20190612220320.2223898-7-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190612220320.2223898-1-songliubraving@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-12_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906120153
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
 include/linux/mm.h |  1 +
 mm/gup.c           | 38 +++++++++++++++++++++++++++++++++++---
 2 files changed, 36 insertions(+), 3 deletions(-)

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
index ddde097cf9e4..3d05bddb56c9 100644
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
@@ -419,8 +419,40 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			put_page(page);
 			if (pmd_none(*pmd))
 				return no_page_table(vma, flags);
-		}
+		} else {  /* flags & FOLL_SPLIT_PMD */
+			unsigned long addr;
+			pgprot_t prot;
+			pte_t *pte;
+			int i;
+
+			spin_unlock(ptl);
+			split_huge_pmd(vma, pmd, address);
+			lock_page(page);
+			pte = get_locked_pte(mm, address, &ptl);
+			if (!pte) {
+				unlock_page(page);
+				return no_page_table(vma, flags);
+			}
 
+			/* get refcount for every small page */
+			page_ref_add(page, HPAGE_PMD_NR);
+
+			prot = READ_ONCE(vma->vm_page_prot);
+			for (i = 0, addr = address & PMD_MASK;
+			     i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
+				struct page *p = page + i;
+
+				pte = pte_offset_map(pmd, addr);
+				VM_BUG_ON(!pte_none(*pte));
+				set_pte_at(mm, addr, pte, mk_pte(p, prot));
+				page_add_file_rmap(p, false);
+			}
+
+			spin_unlock(ptl);
+			unlock_page(page);
+			add_mm_counter(mm, mm_counter_file(page), HPAGE_PMD_NR);
+			ret = 0;
+		}
 		return ret ? ERR_PTR(ret) :
 			follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
 	}
-- 
2.17.1

