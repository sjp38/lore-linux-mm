Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEE78C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:44:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81DE120896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 04:44:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81DE120896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C8016B0005; Thu, 13 Jun 2019 00:44:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 177E76B0006; Thu, 13 Jun 2019 00:44:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 066FD6B0007; Thu, 13 Jun 2019 00:44:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C52DE6B0005
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:44:34 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b127so13592768pfb.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:44:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=j5MbCLhVNCmEPDQlr1rpYtmPkjYr3dRGdvMWKjAKhpQ=;
        b=SpFkuns6YE9W8o23+LB/0lPZTXqw5xvnhJv0N3dUFDNVI3FmikZm0tw5tgX04IvY4p
         jrtw30SDd474DpPeVnJT6e5iZh2HxZAhRcY7slmbCTWfi6kJm/k2zvMip35/OR552Nru
         E3pDxnMaGOU+Mif+UFyH8E3dYicoJ0gU6Rxp57ylWs5eVWHuHQVjl28laXYN2T8JV/ER
         Jbxth+tmj9Op5KGl4F+yO6AhxHif+ExXTFqlCMoIUmDGs7vWFVE5kvu25IS83Gff5rVF
         vY+ExzKJnWYvGKlsiFUFhdHrBBMXr+RJWXNSWdJ77CE9Hjf3SQeMv82AIp32BnElDw+M
         o1Zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUp2SYW/9PMxgHSfZ0pm7l9ur2QOhLa64+IvDF9htQfTbJOufIH
	+GwbYv7WxeKnc3zrUTR/YpmxNwAqiCpX2c++rKQyv4IooJ58F5/il1u9m/L6LnkSaL970xjji3F
	hVWReNm/vsU4h9yd74L3ahWQ0nsHnGDVyY7wV0H6nBVgeWwAHzXIkqL0oXqr3O0raYg==
X-Received: by 2002:a17:90a:24ac:: with SMTP id i41mr2946515pje.124.1560401074431;
        Wed, 12 Jun 2019 21:44:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztGVBpoecT25cVHR/6RucPouBOhgTx2A7iTHZbEBbdjAlo83yitW+gIfZ9Sz7+nT9qIQ9C
X-Received: by 2002:a17:90a:24ac:: with SMTP id i41mr2946374pje.124.1560401073098;
        Wed, 12 Jun 2019 21:44:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560401073; cv=none;
        d=google.com; s=arc-20160816;
        b=BJyPGOS17nsyiVyxCdiKndO0v4p9k45lF1TltKuzaPNZKmEhJmufIuiKhArT22cLH7
         a2DELC7Xx9fM4iHs2VxelnsaCRIl3IpK1OKkwxibbt/HL56Rw8CWNSRJmoPFgf76KMoR
         j4wjBXUNtXmgzkgDFceCnWd5V/ki8SaqMsTkVU5d7V3K0ksMEQNUlc4xMklmUzyELMGf
         TXaiLhrirTG/VElMJpDgrSF5+NZxth3FGLiBqF26TngtCSF52hNsrzAg46uvi176UqL6
         Tup6tPF/Av+yw7OkVTOmAFPfdELvmzle9ruFQFHCbHO9ptE6qAzyfVte6chTEDDPkDKr
         ywDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=j5MbCLhVNCmEPDQlr1rpYtmPkjYr3dRGdvMWKjAKhpQ=;
        b=PT96d0Nu9TC28594VjEim/teoQrEmbRs2tpUJKSplYjD0al+cWqQyqWP7TY1qwYfH+
         Oz/8slTc7s3x1xSx+JYxNBYo90GQjM5xsfIX2U0emghZhmIbm31Q7pkcFCmT/UNOeRD5
         otPlhHxLKMYAdhDARZt1g7+6nPD+8r2LjhA9tcB/n0oxwOQCW+v1v/ZYUV3ZhNv/7jea
         FB1AlGstHOpVaJN4cloZyEkSaVysYd8NyDiiz4Yw0dv2fq2hmOjr+uOBu2jVaRTWsbbc
         sx/zO84tAcJJt/Om6n3ucQ0tCLju8Wdzo2tWeX4aDzixHpGcWPlOABZVjMFVODVk1SLT
         dpDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id a22si1853945pgb.292.2019.06.12.21.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 21:44:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R291e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TU25N7U_1560401051;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU25N7U_1560401051)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 12:44:19 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: hughd@google.com,
	kirill.shutemov@linux.intel.com,
	mhocko@suse.com,
	vbabka@suse.cz,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 1/2] mm: thp: make transhuge_vma_suitable available for anonymous THP
Date: Thu, 13 Jun 2019 12:44:00 +0800
Message-Id: <1560401041-32207-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The transhuge_vma_suitable() was only available for shmem THP, but
anonymous THP has the same check except pgoff check.  And, it will be
used for THP eligible check in the later patch, so make it available for
all kind of THPs.  This also helps reduce code duplication slightly.

Since anonymous THP doesn't have to check pgoff, so make pgoff check
shmem vma only.

Cc: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/huge_memory.c |  2 +-
 mm/internal.h    | 25 +++++++++++++++++++++++++
 mm/memory.c      | 13 -------------
 3 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9f8bce9..4bc2552 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -691,7 +691,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 	struct page *page;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 
-	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+	if (!transhuge_vma_suitable(vma, haddr))
 		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
diff --git a/mm/internal.h b/mm/internal.h
index 9eeaf2b..7f096ba 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -555,4 +555,29 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 
 void setup_zone_pageset(struct zone *zone);
 extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
+static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
+		unsigned long haddr)
+{
+	/* Don't have to check pgoff for anonymous vma */
+	if (!vma_is_anonymous(vma)) {
+		if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
+			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
+			return false;
+	}
+
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+		return false;
+	return true;
+}
+#else
+static inline bool transhuge_vma_suitable(struct vma_area_struct *vma,
+		unsigned long haddr)
+{
+	return false;
+}
+#endif
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/memory.c b/mm/memory.c
index 96f1d47..2286424 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3205,19 +3205,6 @@ static vm_fault_t pte_alloc_one_map(struct vm_fault *vmf)
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
-
-#define HPAGE_CACHE_INDEX_MASK (HPAGE_PMD_NR - 1)
-static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
-		unsigned long haddr)
-{
-	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
-			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
-		return false;
-	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
-		return false;
-	return true;
-}
-
 static void deposit_prealloc_pte(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-- 
1.8.3.1

