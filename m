Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95A77C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 16:37:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FF02214AE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 16:37:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FF02214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEAD86B0003; Mon, 22 Apr 2019 12:37:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E98456B0006; Mon, 22 Apr 2019 12:37:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D608C6B0007; Mon, 22 Apr 2019 12:37:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B12626B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:37:47 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i124so10842117qkf.14
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 09:37:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=UMiPxA5a9I3WRnlYT8Q+bw+lp7n/9t5sbj86bHNZKtM=;
        b=gMojuurobDFZSPTs0COETpubJZNd831yjyXqQrV/lUWE5F1DZK77OcQVet/0FnxWF8
         1zyWEzyfyv/4RYLa68xkinYrokBWgmbjUiNs9yMOPHeARwksFLQMV4i469VFm3C0F8MJ
         O7y87rgzFRs6T2LeIU4MkVmfd81yRduFbymuYwytehsjP555aq8/TX/euYyQUhtRrJiZ
         ayasE2rDqkjHb8wRe4Pa1Ohs/CkEJNTgksiOjLsMooVevuZ8+0zvH3q88EK/AfErjzYP
         Bpcvih5i+gG0x9zIIltTTtwuKdNmcBI3noUDZTu+QuuhS26atwxBnL/3YXsriWtEQ6Ad
         8btg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUhKqj6RpQ+Xs/HUZtl0nOcZWK0hl+xLu+h0LGuvPewKOni1uef
	nIbQo2w02pDzTpeUy649QpHJKWr/dBbPF0s674BwCM11S5DWSjd6mTManKsIPWNUsDEXEEdUM74
	AAUDv+G/0vERsdCoi7TgjQDXrOjkhijR00/nect8EMyBTeiqWE1pSqjQroSskgbA80Q==
X-Received: by 2002:a37:7402:: with SMTP id p2mr15158682qkc.351.1555951067462;
        Mon, 22 Apr 2019 09:37:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyAjK+f8Y/GyVcSsD1VvcXBLsOPi2kvNzlVaZgBlbESlPVUUjo9jT42AgdNCu/1+Y5XtE2
X-Received: by 2002:a37:7402:: with SMTP id p2mr15158616qkc.351.1555951066395;
        Mon, 22 Apr 2019 09:37:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555951066; cv=none;
        d=google.com; s=arc-20160816;
        b=qFqvD9id+betX7PzcbUD6FhMOAVHYGmINHgzZQ2UoVr7r/V6n9TL9QT6NKoUztuZWX
         v2kmT/JMeVRuy2nCoChpuEL01VkPwDAnDpQ1ElYLJunc+Ro5Hm/fSElrDvjmsAKQ43ps
         MUOIjtSvsDFKT3zd6//jr9UcpsZx7sU9rdoc646gotZsziyBU8+J1N4+8H4ginYZ9SAp
         0LrQRJH5Dtb6U9qDlMErpDbhZKLBF5nyjpWILG+EF/QzVDPyKjF67i9d1nBRluQcoWGr
         JH1IEFzq4a7RzmjoOdibLYY+cmhRVl58Y+mALBl4gSU+v1uPUKtgtK0iFciDlRc5Zglj
         sH5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=UMiPxA5a9I3WRnlYT8Q+bw+lp7n/9t5sbj86bHNZKtM=;
        b=xOgotW3Q9yOIzB5s++bUO5WngdKAoUk+/GI89z++vnjllHwkYib1MnCz/P9e5CF7/f
         uzadA88gKXJqDPVLKLwFfthfXbWsTGF8Qqv0dA/OZz8eadETo7Ka7wG3MmkGhn17njs/
         FhBNvaSJJvNWRfhF5QTBcfuXRGG+B1fnY+mzio4u5IRjz1VL0T9oBBz1lg86i74KCwoe
         Ge7mw4yazv0H+dr/+SzPRhU5H5fnNgLRFuGr4rqPc9iiJ+/wSI33/SaWdvuvFk36QxoM
         JJ/abH7E3/hVsB/ysT8KKumM4VORiMeF0obWd0kDhBGfE2d1pEXqxyW97uU4yKkqtchQ
         5XaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e61si166648qtb.286.2019.04.22.09.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 09:37:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 88806C0B615A;
	Mon, 22 Apr 2019 16:37:45 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A742B600CC;
	Mon, 22 Apr 2019 16:37:43 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH] mm/hmm: move THP and hugetlbfs code path behind #if KCONFIG
Date: Mon, 22 Apr 2019 12:37:41 -0400
Message-Id: <20190422163741.13029-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 22 Apr 2019 16:37:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

To avoid any undefined symbol build warning or error, move THP and
hugetlbfs code behind kconfig #if/#else/#endif against appropriate
Kconfig option.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/hmm.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index ecd16718285e..a8a950fe46b6 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -520,6 +520,7 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 			      uint64_t *pfns,
 			      pmd_t pmd)
 {
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	unsigned long pfn, npages, i;
@@ -550,6 +551,10 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 	}
 	hmm_vma_walk->last = end;
 	return 0;
+#else
+	/* If THP is not enabled then we should never reach that code ! */
+	return -EINVAL;
+#endif
 }
 
 static inline uint64_t pte_to_hmm_pfn_flags(struct hmm_range *range, pte_t pte)
@@ -792,6 +797,7 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 			return hmm_vma_walk_hole_(addr, end, fault,
 						write_fault, walk);
 
+#ifdef CONFIG_HUGETLB_PAGE
 		pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 		for (i = 0; i < npages; ++i, ++pfn) {
 			hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
@@ -807,6 +813,9 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 		}
 		hmm_vma_walk->last = end;
 		return 0;
+#else
+		return -EINVAL;
+#endif
 	}
 
 	split_huge_pud(walk->vma, pudp, addr);
-- 
2.20.1

