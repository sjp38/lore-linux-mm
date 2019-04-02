Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 006A7C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A886C2084C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="J+ufpkhH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A886C2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 511846B0274; Tue,  2 Apr 2019 19:06:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C22B6B0275; Tue,  2 Apr 2019 19:06:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38AFC6B0276; Tue,  2 Apr 2019 19:06:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 194246B0274
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:06:40 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 77so13071273qkd.9
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:06:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3K2yhT+sszNfHiVNPV2b/RN3GQNa8ZJypdeBAdHjZ+U=;
        b=JmPI2WjD9Em3KsP5Qi0I6phtFuTvv5upX/WVxO+f0XJ0ULRrGdBi1eDSqVpYBdphYH
         Hcoae+hU7DTpm2/oIWyiiEAPoYWCySsa3qLfY+nzpxg23uWTfmILIcABlUBCltr5nZ/f
         pH5t4Z1IfRTOtXYd0pCPCEZ+NiWtFZ0kAFrg4hxR0xuqQJ9GN4g/HoFmKj+QeB55/Nw0
         KEYFgbaaiRHzERgRLhznEm6XEHD6DV/pqKQTsCSWmlbIX5jXvBqb5ApNsKopQFfFNC13
         dpFK77O1bhiMGbAX9qs77CtzNb+c211808WqG+dhGFHSuwURMzcotEzv9DYfKjBYsOYk
         FuIg==
X-Gm-Message-State: APjAAAUnBcgbeAs84U30wbHQTIXjqiwX8eQ5UCZv0clzA6CLcVD+X1jF
	i9rJXKPPbSIYJ3q3Z6P3yN/hvDOlBlPpP1oagDvRbrhOumO/QYRwja0pRhqlZgk3ab4V4zycAwm
	8bDxIhzGCshcd/9dThTwDiFWKGmdDfEZj8pdSZyjO3V6fq3V/Mwhi37qHXOdwQrU=
X-Received: by 2002:ac8:38b6:: with SMTP id f51mr39268301qtc.33.1554246399688;
        Tue, 02 Apr 2019 16:06:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkvm3MngK4miOCkknlamRol9qFCsHAVxReyimXzg/976gGUVc7Ts+Shvg+RaBlacmNoMN/
X-Received: by 2002:ac8:38b6:: with SMTP id f51mr39268198qtc.33.1554246398067;
        Tue, 02 Apr 2019 16:06:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554246398; cv=none;
        d=google.com; s=arc-20160816;
        b=VrKixVsuG1JJagqBD4jYglKvBcEoAYKR18lnEtNJA5EpS0XlYOFsiNAFFiP2oEirbN
         gqZFCLPEw74PDKvnxJzUYJKarQ7Axaj1QOGN+GV85ZNkMWWkflFJ+2EvR05IySRVOh+8
         fCT81UXVRMF4Vuacwb5uCnkL1cdBLweMNtELxH9Dfjs7wIOAQh7N1UCpTif5aYQWOAFE
         N3GMIeHrYRPzu1V2Gli6In4UE0ahbOTGKzsTD3X1QHOLlJVSUCUGEviOMKlmKHPLbCZ1
         FEAA092xWWQi6Bbh/R8Ux/ZKohJuQvgUY4mgCPKrUN9kyDELsl6+DVuxQN7scNk2JhW2
         imUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3K2yhT+sszNfHiVNPV2b/RN3GQNa8ZJypdeBAdHjZ+U=;
        b=GVpaxyz48HEw/0K0QywjsqSG6MxzEb4AsXb9PZUsNk4Y5MCKmRvAabpQqlbMWleo1i
         v5gqv+d03JgfikAvNE7hfheft5tzx1jKv8SwPmai7piEgZi+Z3Rk4B/mlzjzEYY4kDiT
         gy+KG4Bti+pJfeQzgeeLpiqFmuEAUN6ObL6MXRpUNB29KJKJ6Wirg1lrZrb0BvH7yDeK
         dL0C44xfx+SP2OPwdo7Eb6Ee5kQBQzdubefi9xFbt52BQXkc3sXQPAYkxeiWzcvfQ8BY
         yPn6AiH31jtcYb4lQq3cpa8YTVEiJduwRtutN0upokCdaXEj15q+2WYfSzmVpHeque5W
         nQ4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=J+ufpkhH;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id a2si1124641qkl.123.2019.04.02.16.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:06:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=J+ufpkhH;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id ACCEC21EF6;
	Tue,  2 Apr 2019 19:06:37 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Tue, 02 Apr 2019 19:06:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=3K2yhT+sszNfHiVNPV2b/RN3GQNa8ZJypdeBAdHjZ+U=; b=J+ufpkhH
	vZEfzYhN14fxy08UgL7zicdFN3w19iPwhvtvHDyyFGhp+th9Y4H+bs59zZ/lCEYf
	sAuMzO0kEdX0d6MrM7j3VVadRO79mpKP0OeBSX9X+7XR3fTJ2yz68brwxGaHSN7/
	D2xQ5Gzp5OpC+9JndF8XHSE37m6iEO2seUGEasvV+WqttsN3o24s6pa2VLPj8TSP
	Cpfyi7lPHhEFsybWnMCnfT/5akQtQ0uPXoTCed5EXmf51gCcEe07hzG7E6OEhOU2
	3GN76kSDFAZda6mmChVz1dzZRZlbm5d40Y35rHyhWSbQtkAo37gq3JbRjTmTVTn0
	Q+qfUXPIXyCO/Q==
X-ME-Sender: <xms:_eqjXJy3zwZs_ahB6UQ_BEvLuU6tdjzStnCRjXsV4eea_IMhqYefNw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdduieculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpedu
X-ME-Proxy: <xmx:_eqjXBMMLhXtM191LHPlc4_z5CufHr_QDkcw19WD646QXhHTuarIvg>
    <xmx:_eqjXKg_nhTplalxG3T6P8xEKtsoaX9MuVjpKCLNX9UUMNTMsCebrQ>
    <xmx:_eqjXB9oVWjAUi1xIHpRutQ89xoEYYdYgEcy_ls15zqPBPWacqSiMw>
    <xmx:_eqjXI4-vMRehLp7b2vI8NnJALmfgnTlWWcxqVudcSRMNOefiOOiFA>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 212961031A;
	Tue,  2 Apr 2019 19:06:33 -0400 (EDT)
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
Subject: [PATCH v5 3/7] slob: Use slab_list instead of lru
Date: Wed,  3 Apr 2019 10:05:41 +1100
Message-Id: <20190402230545.2929-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402230545.2929-1-tobin@kernel.org>
References: <20190402230545.2929-1-tobin@kernel.org>
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
 mm/slob.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 07356e9feaaa..84aefd9b91ee 100644
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
 
@@ -298,7 +298,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
-	list_for_each_entry(sp, slob_list, lru) {
+	list_for_each_entry(sp, slob_list, slab_list) {
 		bool page_removed_from_list = false;
 #ifdef CONFIG_NUMA
 		/*
@@ -328,8 +328,8 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 			 * search time by starting our next search here. (see
 			 * Knuth vol 1, sec 2.5, pg 449)
 			 */
-			if (!list_is_first(&sp->lru, slob_list))
-				list_rotate_to_front(&sp->lru, slob_list);
+			if (!list_is_first(&sp->slab_list, slob_list))
+				list_rotate_to_front(&sp->slab_list, slob_list);
 		}
 		break;
 	}
@@ -346,7 +346,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
 		sp->freelist = b;
-		INIT_LIST_HEAD(&sp->lru);
+		INIT_LIST_HEAD(&sp->slab_list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
 		b = slob_page_alloc(sp, size, align, &_unused);
-- 
2.21.0

