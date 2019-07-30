Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BE5DC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C777120679
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nv/Uk3iA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C777120679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618048E000A; Tue, 30 Jul 2019 01:52:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A0168E0002; Tue, 30 Jul 2019 01:52:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 490EE8E000A; Tue, 30 Jul 2019 01:52:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 138528E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:34 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u21so40096265pfn.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eS5S4KohR3irhWgtUfLvLexYfgHi/N0ae1QbGrg+MN8=;
        b=R51Yf+6vMh99E2YB6RWseyUdFEmv7S2IDE0ZGQrm6Vt9GHo87MkTP8JkbXhHPs45qb
         RjyL322zZAU12hoEvhk4I0WSiIRpw/EJTBoFkcVmHt4azeAFjLgIiku1AyZWB3pd3g2G
         99oUid7eSLBcT11yD0qMTvHhqq0NgRfPmSBn6ck1YUesmWEMfEF4fyt6uPa4DfR8aP0k
         F1Emq7J3vJLeclzFZASwRdlrVQBAdYQoWlugFbC7s0mymfaowKDHAlbxATczq+C7buyU
         IczoXqA99hgZLP3nBnvzXhC5ByNRfi5U8F9Hu0YERIt/RgpeYb9H2Mh1ZpmhqoMZ97sv
         w/HQ==
X-Gm-Message-State: APjAAAXvd3QTbNxbAONmYT1PtJX6w0tZNV0rfZC04m8vnb8/5rgEyGOa
	IAlHvqE9OJuP4Awm4bks+kg//k8y20Ewvrh51XSpY1qz1O9mxmgBLZNuDiWoWI1foTbmokg705K
	I6C1F8AA+BAIZextQFoExQhznn14ohI5CK8AVgbhTuuhL+E3AEFVq8lrQLHW0D9g=
X-Received: by 2002:a65:6497:: with SMTP id e23mr103634764pgv.89.1564465953659;
        Mon, 29 Jul 2019 22:52:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxH3BGsPEmsfiSc7ofekS3qUuDOOhdlPR9oo4Y2h1XyhQzEfxNnweYZgUrhzx1nMiW5F84L
X-Received: by 2002:a65:6497:: with SMTP id e23mr103634729pgv.89.1564465952642;
        Mon, 29 Jul 2019 22:52:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465952; cv=none;
        d=google.com; s=arc-20160816;
        b=vKocNOqEmlYv3t7ra01qEo538at0xpV8HQnXIXwRaBISGCgrDuQKc0pbryi4W/0kSF
         0bWysS0V4bghbgk7rIAMHCmxysEWGjOX3YjXTDHFGYj2csjHzJQlkAVBz8IgVLJvMMGQ
         kukLoflNSjzosd0HMf6OoteU5aJPbpn02i0mbvZ4n0BgpyZ1UoUIvJAbPYtdGx2y1X/A
         8tzR5BYbh97F2boy3wUfssBBDJdjLms9DYCDoOdfA8KbKKNixs+j21C387YLk6s2mm7E
         Ri3i0zxn5Po5h52y6k5A8G8pBynEDBKoxjAFKrHwhCCRfrG//SH+EVutkIf2Jh2wlFWX
         wSgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=eS5S4KohR3irhWgtUfLvLexYfgHi/N0ae1QbGrg+MN8=;
        b=0u4QHZzZMnXqsWHn5XntO0kwbSKXrw4tfM9aVaeF19Z/C8CUvL2ZDx0QU+zes4c9FI
         jWgeVNOlrcimfEjrYO2fi81KrHGTGbekg2ml3Gi4Rm3Yh+S5MWqJ9M6cNsFGGS5mS0V6
         HKiRUWHJYOK67ccZYkeVkuc0dvDaUX7aSr1FTMMux5Twlq1oEVqFTOLw0a23igOnPSmK
         v/MWOtqK033F0rvwKsNGsuciTaVejPvS8d8poFOS8AAnsz9Vz9SBnO+I5UmEz5Xqo+MD
         WKf+34iFSIKfeua9nGmX0WUnAdUrF1ystyMxIaeajXcyP/Lw+l7YMo/ZHDHOT79amGbq
         Rl8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="nv/Uk3iA";
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g90si27247816plb.282.2019.07.29.22.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="nv/Uk3iA";
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=eS5S4KohR3irhWgtUfLvLexYfgHi/N0ae1QbGrg+MN8=; b=nv/Uk3iAICQEpzysmQOiV3ryQv
	Gat/o6BVc3xRRsdrPwHSTMM2PMHHx6bU9QSukJm2PAurh78FQ6xcvWGwTwVe/vCRF8XF1u9iIfpFg
	3J91GH7pyOv19vBJ2W847BvEtuCSYnPFVfS6gjHMgFai+iGhE5jKeaX7ZjA2gHRqthFtkAG2vCK0m
	CmT9xHVXxhVaJu95LQDIP1xwx4JE6wMjVjSt4XgFBd1vs92KnozwLz39ze5LkRqyV0DWWRbdvUfKt
	37xLUeobKeP/aKEoCv2ZbxpUJT8lqkPzdAow/RTLlaRdVTvcnqTOqUpRZMSLcOSGa7xHRlobRix/L
	VaoUlOfQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL3l-0001D4-C6; Tue, 30 Jul 2019 05:52:29 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 05/13] mm: remove the unused vma argument to hmm_range_dma_unmap
Date: Tue, 30 Jul 2019 08:51:55 +0300
Message-Id: <20190730055203.28467-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055203.28467-1-hch@lst.de>
References: <20190730055203.28467-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/hmm.h | 1 -
 mm/hmm.c            | 2 --
 2 files changed, 3 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 82265118d94a..59be0aa2476d 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -422,7 +422,6 @@ long hmm_range_dma_map(struct hmm_range *range,
 		       dma_addr_t *daddrs,
 		       unsigned int flags);
 long hmm_range_dma_unmap(struct hmm_range *range,
-			 struct vm_area_struct *vma,
 			 struct device *device,
 			 dma_addr_t *daddrs,
 			 bool dirty);
diff --git a/mm/hmm.c b/mm/hmm.c
index d66fa29b42e0..3a3852660757 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1121,7 +1121,6 @@ EXPORT_SYMBOL(hmm_range_dma_map);
 /**
  * hmm_range_dma_unmap() - unmap range of that was map with hmm_range_dma_map()
  * @range: range being unmapped
- * @vma: the vma against which the range (optional)
  * @device: device against which dma map was done
  * @daddrs: dma address of mapped pages
  * @dirty: dirty page if it had the write flag set
@@ -1133,7 +1132,6 @@ EXPORT_SYMBOL(hmm_range_dma_map);
  * concurrent mmu notifier or sync_cpu_device_pagetables() to make progress.
  */
 long hmm_range_dma_unmap(struct hmm_range *range,
-			 struct vm_area_struct *vma,
 			 struct device *device,
 			 dma_addr_t *daddrs,
 			 bool dirty)
-- 
2.20.1

