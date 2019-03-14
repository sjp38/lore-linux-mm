Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7593AC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28D0C2087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FTUT+ROK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28D0C2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0F398E0006; Thu, 14 Mar 2019 01:32:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C96AC8E0001; Thu, 14 Mar 2019 01:32:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE8C18E0006; Thu, 14 Mar 2019 01:32:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9898E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:32:18 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s8so4235337qth.18
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:32:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2eN7lydm96kcUslXdltVZiRHDPn/FxigSb7w12z8+Ik=;
        b=LfZeRSoIO2UhUxgsFnVLioFVO9U4P1uqOaggfcxJFuDJEkVYnGShSJhXbqeCWyB1eq
         fT/V4N2+lUUqdLnfSVmAE/3IAqFgEz7c9S8ooEDYfwC5OPR23g89woi7h2qLPGmZfJEP
         OUnQG6wLCBVce36q17LWYEv66GqB2diDy4RQXESVtxf62ZQOJTZ6HOrwaurowM+UY3yI
         /l9EXV9T4g8ESYV2irx/ZF0V4KnxJdoA5JPpw+45PVR8+PMdafmUB5MlfE2vdCmZwWFM
         noXy1Be2VUurAvybb2RJVkv89QPBFJn0GotJzClF7hMBWbXoaoLGLXCgI5fldphfX1Qo
         iJpg==
X-Gm-Message-State: APjAAAVRNtFwr4adh2tYYUjmu6/yLLsA/Z1A9hx9OI4kaSjgb511wZ+e
	/iYSKehvng5BC0o1TkzKFhs246tYKzAOjTTU+qZlcbpELAAwV/bgnxERFe8WGRwDPtLTmoO5Xut
	8zZZZFNi2iF68T+DFLDztr+QeWloEM+bOXvLPj3CKvXTNMZK/tDItHPgF1McrgWo=
X-Received: by 2002:a37:4887:: with SMTP id v129mr36963536qka.100.1552541538279;
        Wed, 13 Mar 2019 22:32:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZOS6Xdl4laGRZ2+c/aWSl+7x5fjriyswGvmziIiFU1R58AfFy54n/fyTZuRBGbTQx4eC0
X-Received: by 2002:a37:4887:: with SMTP id v129mr36963494qka.100.1552541537070;
        Wed, 13 Mar 2019 22:32:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552541537; cv=none;
        d=google.com; s=arc-20160816;
        b=XelfduTVWo0xobeVTwc+R5IySIfpp0JRd1o/QwrMtEu4QsvqxwPO0AEeCyAFUVZK6N
         D1xcdzw/NAfgiS1GtnVBpc+/oRAZNiDWyozg+HU5Hta0UeC1+oCiHPlCIjSutKGG7byn
         xInHEYkGMx7vydxluR5fTq30JmYJZwFDT/us0tfaGwy8P2NMCfYpJ63AzROD9ECsyy1R
         olQgK94f8MxO/+GmmvJZSP5L5+OYuemFu7YbPFvwTPmA4KTM6jqRSDHP0NI2eK2l3D/S
         J5sLxMkzU2qSEl6SlHWJnMCmEbejP98UuFnN9mD9OQsEke47weNgwUEbSyZR45z5d+Wk
         6BZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2eN7lydm96kcUslXdltVZiRHDPn/FxigSb7w12z8+Ik=;
        b=qThHasFaJlygbjXW+ARDRsn0dfhvwVedNouogLyAXxzZTfkhsHhgL8uYc4IN94nSr3
         HKuYV4c4U4kABF+ZbeyKp2smCY15FLxVigbT04AckJVVoNudIY0DmxjNfu03iI6qALOw
         d1yJDAncUNntTwfrdzR3nBB+OgR3O5aUGjHnt6CKh9q6n7AU2ZZfW3uud16t1AZSYeRn
         NtbuDUkHsWvIoybKmngLWqJDKR5bTSLaegKbiPmpwItETZhdFdCXTw24RadnbCBG3Qbx
         zG4oUkZ+ugyS3JpjaqxZp8At4RPKCnvrlUy93dx4RHyo3YMbtLWir6tXLE6atYw1k9BK
         1MLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FTUT+ROK;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id n89si1018945qte.53.2019.03.13.22.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:32:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FTUT+ROK;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id B4D962073F;
	Thu, 14 Mar 2019 01:32:16 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 14 Mar 2019 01:32:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=2eN7lydm96kcUslXdltVZiRHDPn/FxigSb7w12z8+Ik=; b=FTUT+ROK
	r7cdMFF2w62zmsE8vApTYJq9L8QrVsuNfDtT9fhKrKpLxkN2CX61Mddximwx9i1W
	VAISGqfybF8Ug6tna24R7iuAQx/Vc+79zTb8wKhHAy5wuL7O+IsHs6dOXD0Aejy2
	352XtRpl7RUevrbaK1t2IcqyTeBaP3N0Y06mf60HfN9SJ7NpEx6Y+1z+WUEZgPn1
	p910s13PA3qc2/26aw4YACDhrbpkHIOdkMZJZxidWQ/w/sudwK4sPmnhrGoUea3i
	70/Tw9nxOXh21VGK2PLrFpYbogNU4zvCCl0xDSsouLB+urfyJZ2XW4JvPKwZllVf
	y+WLfpABG0V1OA==
X-ME-Sender: <xms:YOeJXFXs9ogZ3iWR1b8kNUXTxZIMe-qdn-I-nPlFlDgRRFr5fk4LDA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrhedugdekgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedv
X-ME-Proxy: <xmx:YOeJXMhNH-KQMkjuMxmetz-GsilhhQZa7pehEkX9kUnr0BI8SgVcQg>
    <xmx:YOeJXGjqXE1WkIH06M5CFegSr1p2h5xxJfVA-MMm2s1bvtVytJM5xw>
    <xmx:YOeJXMvMIWilkq_XeqtB89ropeqjP1JVFvyelGgzO-My1KRpTAzh4Q>
    <xmx:YOeJXIUkJVC4FIz5lRC4yxrrIIy3vjCsn_ffeRORijt-klO8lXc2nw>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 28FD1E415C;
	Thu, 14 Mar 2019 01:32:12 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 3/7] slob: Use slab_list instead of lru
Date: Thu, 14 Mar 2019 16:31:31 +1100
Message-Id: <20190314053135.1541-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190314053135.1541-1-tobin@kernel.org>
References: <20190314053135.1541-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we use the page->lru list for maintaining lists of slabs.  We
have a list_head in the page structure (slab_list) that can be used for
this purpose.  Doing so makes the code cleaner since we are not
overloading the lru list.

The slab_list is part of a union within the page struct (included here
stripped down):

	union {
		struct {	/* Page cache and anonymous pages */
			struct list_head lru;
			...
		};
		struct {
			dma_addr_t dma_addr;
		};
		struct {	/* slab, slob and slub */
			union {
				struct list_head slab_list;
				struct {	/* Partial pages */
					struct page *next;
					int pages;	/* Nr of pages left */
					int pobjects;	/* Approximate count */
				};
			};
		...

Here we see that slab_list and lru are the same bits.  We can verify
that this change is safe to do by examining the object file produced from
slob.c before and after this patch is applied.

Steps taken to verify:

 1. checkout current tip of Linus' tree

    commit a667cb7a94d4 ("Merge branch 'akpm' (patches from Andrew)")

 2. configure and build (select SLOB allocator)

    CONFIG_SLOB=y
    CONFIG_SLAB_MERGE_DEFAULT=y

 3. dissasemble object file `objdump -dr mm/slub.o > before.s
 4. apply patch
 5. build
 6. dissasemble object file `objdump -dr mm/slub.o > after.s
 7. diff before.s after.s

Use slab_list list_head instead of the lru list_head for maintaining
lists of slabs.

Reviewed-by: Roman Gushchin <guro@fb.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slob.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 39ad9217ffea..94486c32e0ff 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -112,13 +112,13 @@ static inline int slob_page_free(struct page *sp)
 
 static void set_slob_page_free(struct page *sp, struct list_head *list)
 {
-	list_add(&sp->lru, list);
+	list_add(&sp->slab_list, list);
 	__SetPageSlobFree(sp);
 }
 
 static inline void clear_slob_page_free(struct page *sp)
 {
-	list_del(&sp->lru);
+	list_del(&sp->slab_list);
 	__ClearPageSlobFree(sp);
 }
 
@@ -282,7 +282,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
-	list_for_each_entry(sp, slob_list, lru) {
+	list_for_each_entry(sp, slob_list, slab_list) {
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
@@ -331,7 +331,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
 		sp->freelist = b;
-		INIT_LIST_HEAD(&sp->lru);
+		INIT_LIST_HEAD(&sp->slab_list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
 		b = slob_page_alloc(sp, size, align);
-- 
2.21.0

