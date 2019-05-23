Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A450FC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 13:32:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6319520863
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 13:32:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="u5oj3c9E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6319520863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13B756B0003; Thu, 23 May 2019 09:32:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0ECFE6B0005; Thu, 23 May 2019 09:32:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1E726B0006; Thu, 23 May 2019 09:32:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88FC36B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 09:32:51 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id p7so225811lfc.5
        for <linux-mm@kvack.org>; Thu, 23 May 2019 06:32:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-transfer-encoding;
        bh=1lShfxTWAZnn0xxmbff/egndjUhtx1mRABTy7i2apwY=;
        b=nTwgtj5Ort1QfmNR2fAZ73z+lenWMdgVSXSeTaVqRFkIp8GwQQmd6nV4cIKC5CaOJj
         B1CtWHmYWdG29YwyIVfiDaijBounUI0GZUcD4mJ3uqFSPQNe5v84SiCj5ro+DWjVxvTg
         WHCABQ60+bgqsV8l3lHKAlRUGu4XKG7RUz6CBnzFRuF6Ex5Bgi89OvmHvZLxm6aL1sXY
         Q40oEp8j04MsGPKO0KwxjMFEHbvHBgFAdYZjdZOyLtLJCgtNTB57s8NDYTns7BvkU7Dm
         MKztXzRvwpCJI26tyPcFd9MwU9OwTccEDOMZZzojAtTrCoAoSlTJqO/7nB+xpbT4TLB5
         9bWg==
X-Gm-Message-State: APjAAAWUEEYB65nHjAMZDYQNDaogG4bKBUWUC3EfR8qpHtYKKTjwrmPg
	Lvq9eg2RfxFQDF+exwoO7QaP+w4mCB8hDN2mfRAWak6sRUDYSthtNa7RncHCkPSdUpVsq3av2EI
	kfU3cgFDcEeyl58uhnAarkrUI7wgOmheUFjdwm0Vy4AaoiG4BJjWbvc0L+DspmHZPgg==
X-Received: by 2002:ac2:4313:: with SMTP id l19mr1371435lfh.124.1558618370728;
        Thu, 23 May 2019 06:32:50 -0700 (PDT)
X-Received: by 2002:ac2:4313:: with SMTP id l19mr1371387lfh.124.1558618369399;
        Thu, 23 May 2019 06:32:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558618369; cv=none;
        d=google.com; s=arc-20160816;
        b=edd1MhBn4rJo/NouJ0RidMb+Teydf5euQi9FevGi8f16TNoMzu0D60mfjPqU98xm8/
         URweQsU9r3O55vI5cKqkpHiA1fgwfFEkoFYq/tTg9STdyFW7yn3zF/fBZTiLL9wbN2ZZ
         E/ZE4sQxSYEH5Y37HpHv56OdrXxiYV7xWAFRoimknHL6hLFWKGwnod/iJdTdyLzAPOf4
         7J1iILIztc8HBfTxzYLefgusKmkf8fT/BfwSF88vlE+YGda3YLOYycgVVqZYK2xJNY9k
         HAuDNDSwzrm3GYU1Ul8+jtXn0Y3ox1qiTNx8O2HY/OSIlc3Z5hHpelTFlamMtVN0OZC7
         A3Ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:subject:cc:to
         :from:date:dkim-signature;
        bh=1lShfxTWAZnn0xxmbff/egndjUhtx1mRABTy7i2apwY=;
        b=r2n8Tl1mmfMh1fcAlq0hLmqhSYid46NykWT545NnWlsAHitTGadxOMWUGHMHeGPXKh
         aFG5p3dy3aiEQ12Ed3b0cTA+QPb8TZYjWi/IEVkdFQMjX9A2FQvZr5YWtjBVqtHYFtI1
         N+VQ0SADiJCvCuYSbZRZcEn1dPkegv2NbVSo1hl/BqhSPYj0ZaVJVC1821KlcJzGVKf0
         GsmXGHNBswXeBSAFSfIbT70i2tuFBvdlkC/+5Pf3aJ+1jxPsiq1XHVapZiNWwe0Hhlq+
         ceY3aVm1JGcDYR39XLI7x7YVNtZDxfW5djsluifoYj9DcVX2DDIP6Duvq+CNtHsTjhRv
         +pag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=u5oj3c9E;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor8201456lfn.7.2019.05.23.06.32.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 06:32:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=u5oj3c9E;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version
         :content-transfer-encoding;
        bh=1lShfxTWAZnn0xxmbff/egndjUhtx1mRABTy7i2apwY=;
        b=u5oj3c9EuRX/8mgsmB8f+22uOI2oYi8x5Itm62R6HZSQJv9DkeAbU44hmF/Vb6mGjK
         lnQGSVS5KcsYWTCRZapXhr3w7jx+6WoiQY3ww1nPedgx/AinwoobS42RShaxf2KwxcxO
         kbP8cF4yNnZLVcSz3JfVIEOLPuo5TvBihQtgzoKFcgRLnU7ckJw7Ar8mdA1zwFmh72fW
         ybwyAYGd6YDlw18clEXK/nTGKTmxOasfvqxNvrBsFkWJH5+VuzFRgrHeY847VcBtudlh
         ys5c3UNOA6hGYvGNIfyQE8xTkFG+ccmp6eI51gF8GgowatIsnOQP25NJNYZpODu7ikqr
         LO8w==
X-Google-Smtp-Source: APXvYqw1rWwaalNTduK2+/sn9gsSAiOSi7BxDpd/1Ex1JIe/qGpx2Ax85hDl0z0zYMwZQTzjtBKQDA==
X-Received: by 2002:ac2:54af:: with SMTP id w15mr3011164lfk.8.1558618368247;
        Thu, 23 May 2019 06:32:48 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.40])
        by smtp.gmail.com with ESMTPSA id q28sm1035667lfp.3.2019.05.23.06.32.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 06:32:47 -0700 (PDT)
Date: Thu, 23 May 2019 15:32:45 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton
 <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] z3fold: fix sheduling while atomic
Message-Id: <20190523153245.119dfeed55927e8755250ddd@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.30; x86_64-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kmem_cache_alloc() may be called from z3fold_alloc() in atomic
context, so we need to pass correct gfp flags to avoid "scheduling
while atomic" bug.

Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
 mm/z3fold.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 99be52c5ca45..985732c8b025 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -190,10 +190,11 @@ static int size_to_chunks(size_t size)
 
 static void compact_page_work(struct work_struct *w);
 
-static inline struct z3fold_buddy_slots *alloc_slots(struct z3fold_pool *pool)
+static inline struct z3fold_buddy_slots *alloc_slots(struct z3fold_pool *pool,
+							gfp_t gfp)
 {
 	struct z3fold_buddy_slots *slots = kmem_cache_alloc(pool->c_handle,
-							GFP_KERNEL);
+							    gfp);
 
 	if (slots) {
 		memset(slots->slot, 0, sizeof(slots->slot));
@@ -295,10 +296,10 @@ static void z3fold_unregister_migration(struct z3fold_pool *pool)
 
 /* Initializes the z3fold header of a newly allocated z3fold page */
 static struct z3fold_header *init_z3fold_page(struct page *page,
-					struct z3fold_pool *pool)
+					struct z3fold_pool *pool, gfp_t gfp)
 {
 	struct z3fold_header *zhdr = page_address(page);
-	struct z3fold_buddy_slots *slots = alloc_slots(pool);
+	struct z3fold_buddy_slots *slots = alloc_slots(pool, gfp);
 
 	if (!slots)
 		return NULL;
@@ -912,7 +913,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	if (!page)
 		return -ENOMEM;
 
-	zhdr = init_z3fold_page(page, pool);
+	zhdr = init_z3fold_page(page, pool, gfp);
 	if (!zhdr) {
 		__free_page(page);
 		return -ENOMEM;
-- 
2.17.1

