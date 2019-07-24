Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48488C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05623218DA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gHoA3rLx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05623218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC5116B0269; Wed, 24 Jul 2019 02:53:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A78798E0003; Wed, 24 Jul 2019 02:53:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93E368E0002; Wed, 24 Jul 2019 02:53:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60D226B0269
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:53:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y66so27894026pfb.21
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:53:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jUagJle8tiqkx+fZcCE6Gfny4t7Azmd0YxZDCEv72fs=;
        b=L2b4E1BA6Kdel1eXEjCAJxHfvZEOwA8WHSRHmxInpSPCezcPguLK77YDsgbHjxY7rQ
         RD1M0/LnmH8dV/mAt+uVm57EOcdgoBwK/TAa5n7PKwEjwU30YMltamP7/vSzxTQCuaf4
         5yLCYgIxs0d5dEPgVSi19SI2VQaXycw71l60nn+va/LRDBkHL5EEiDdtpsmGG1DVS5la
         0fh3TkxrnT0+yYQ/MtNkMsUcix8g2GwC9FczzEqDFGeTywl58DYJQKBncoU0PLPlsLk/
         ELV/tYUtTzuxKmlcnPFtjHda7fi6D6hsSx9CFZhOOR1cAqJqJZXtw42hZQzNxIcOiwgZ
         PxSQ==
X-Gm-Message-State: APjAAAX5PDEiKJkJNbSelfQ8+BdO3/S6a4o5A0v//Vz1SL5vnuChSmml
	TNa8SRVs+/j7Ob4koI0MMh9QlPPxW4zUEBmaF4D820Ml5bh0xEnsyeGTov9e4P+V0tcwTQcZp9y
	tjCx5jRrVWYyjfCx0W82gGUfAah2rwfwf5rNytS1HVIVovwqFj87i74V9RaHkL0M=
X-Received: by 2002:a17:902:e582:: with SMTP id cl2mr84938964plb.60.1563951207104;
        Tue, 23 Jul 2019 23:53:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCHcYSPnsKKUpYPNHYt8J+wcmQjmDeFaaQuWNb9gdQw54WRWVTof9C+Gvth1/czIA4/AvF
X-Received: by 2002:a17:902:e582:: with SMTP id cl2mr84938936plb.60.1563951206507;
        Tue, 23 Jul 2019 23:53:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951206; cv=none;
        d=google.com; s=arc-20160816;
        b=t4zhHR6uu5ho50fwu8JqyHjOdRi5j0jnC+tJhKHppaB1+fFF+e8Xom5H+jX/t8nsUx
         igbR2LJLEdjo8/PQUpx/owCox50FV97rMozLpfztkAz5oSGj4p/xrtFA+HDzJy7hS5eT
         yqUJtqHrK4jbbR+plkTJaMEwO1Lhq6tj1eSDC1UFeGW7tQuqEGCmU8JYbomCmUJJSi8w
         Ez9b2Hly+jUaBRplvxKSNRMS+ivDB7UGbG8vo9gTaoHtDXl9cdOSWr2mccBdO1fWdVgW
         NNRNXcTR+vdIlfEWAaaSb0NUuY7HyKfRgkLFxts/DJZKOnemLqz6PmEQDd/sAsc1Ti1E
         vYGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=jUagJle8tiqkx+fZcCE6Gfny4t7Azmd0YxZDCEv72fs=;
        b=qAEB7NGlQfqoiWnAtVLA3pnUNgKRbLOWaP5MuXprghsXwZREfozeX/AayPGLhOwZm5
         lVLENkHjlLWoR/brlQVRCNz3HdHmmuAEomwBMJzp87MvSzg8Fy/vzjOurcinw4xCPonO
         QgvHv/7/2J2D1fFaG+mHVhYCgGZFKPTA1kCC9lcX8R5c1cEDwD7McPzPhgVnRgagIqiD
         kUgT+H5cK6Aoog332np0SFFAcRfKHs5klYEi4b4lj8J4g3AcxNptBA+XZsoHdsLNjnvT
         A/DSZoN7EotaYTvcVjrkOR8BllUSQJYHIQ6P+Xhrz2BFpf+3ze1OMKEQYSHLhYd1uqLK
         6Skw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gHoA3rLx;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r200si12394912pgr.518.2019.07.23.23.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 23:53:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gHoA3rLx;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=jUagJle8tiqkx+fZcCE6Gfny4t7Azmd0YxZDCEv72fs=; b=gHoA3rLxbbBb8a0isoL8eqDuAd
	5No71pHNiivV7f+CSgnKf/BnSlSNK6IHFCeFwtrWSRDbAHPCPDE3FP1zsCfMsYxHtJ90yYDlUxj2K
	HsjlpGb+HBDiw4pJkfZUt0rZPL3rR+vVkgO7MQ7aFVnbJ/dH6yr+BPTKxF7wdx1yMwjk0nxNfGN5a
	MeLw7sIA4cVOQlsewuFjuZ1oKKhb+BnYot7yxvtYabgThfnIv5HDf78+WbsMXOcknLuY5xH2VoJDX
	QIF4jW0Vtaeu3JTdStE89iThn0BlxErxbbHeDGs5EIrl76zsfFj/jdn5E2iKTaq3FlbL16zEG+dDX
	j7FGDjGg==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqB9P-0004Mo-Lp; Wed, 24 Jul 2019 06:53:24 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 7/7] mm: comment on VM_FAULT_RETRY semantics in handle_mm_fault
Date: Wed, 24 Jul 2019 08:52:58 +0200
Message-Id: <20190724065258.16603-8-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724065258.16603-1-hch@lst.de>
References: <20190724065258.16603-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

The magic dropping of mmap_sem when handle_mm_fault returns
VM_FAULT_RETRY is rather subtile.  Add a comment explaining it.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
[hch: wrote a changelog]
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 16b6731a34db..54b3a4162ae9 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -301,8 +301,10 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 	flags |= hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
 	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
 	ret = handle_mm_fault(vma, addr, flags);
-	if (ret & VM_FAULT_RETRY)
+	if (ret & VM_FAULT_RETRY) {
+		/* Note, handle_mm_fault did up_read(&mm->mmap_sem)) */
 		return -EAGAIN;
+	}
 	if (ret & VM_FAULT_ERROR) {
 		*pfn = range->values[HMM_PFN_ERROR];
 		return -EFAULT;
-- 
2.20.1

