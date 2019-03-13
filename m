Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14FA2C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:17:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE724217F5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:17:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="oIMmuhhG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE724217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C5AD8E0017; Wed, 13 Mar 2019 15:17:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69F6F8E0001; Wed, 13 Mar 2019 15:17:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58CD88E0017; Wed, 13 Mar 2019 15:17:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8618E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:17:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f10so3287802pgp.13
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:17:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=t5w34QpCEbzhCQ+YrFo30ZEJWvD/GkMyXx4NH/dUUcM=;
        b=DeN2A14LfIf6EBWPwu0sDXEB5tTDSKdwafp3Wy7B0ut1Ryz3XV46AY33Cr7vCMJf0v
         Z7LjitzwGCCEV+fZnzgM2vgHVHPt6EXpeP8M64uMSGf2noOe4o2L0OHFVrqXEI+yJsw4
         kOc+0cHp82kQlx84q2E0RPON71tvscdBNKn8OwjvOacTY8T4FR62yWNt4SPu9uVa6DG0
         I9YIPQOs2GAsr2vRU5YaCvqz9svmvm6nojtHpU9cdaqWFT14J2NtBVR1L7Ir71pZGGgE
         ttffPct38iw7TH9NWXU86d9gc6f7XFNFATrIBW7wZVgp1VWF/a3CdHJY5UEydX08ME80
         U1MQ==
X-Gm-Message-State: APjAAAVOFiwyBBrwv34px8wyQtBJlmZ3FAcihgVSURYty05Gar8n2ZEa
	0aW5uvpaFHu3jjpAeRyANV+uvWvnINa22hkXWIwglBaWWVfuHu8gcDzGBUCZ+XDWBvd9rAGxrNt
	lUSTOm0T9TxiBpUDHHwaeeYi0tH86bbJbgI1dhjVxndbhiyystqc4Hk06Fo3GIC7AvQ==
X-Received: by 2002:a63:fb45:: with SMTP id w5mr20794802pgj.118.1552504655735;
        Wed, 13 Mar 2019 12:17:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/ekFHir7Uvjh67Fi28pADMHiZRx58GE+K3/3IO7poJV9mxuHBKohYUBDix/IIb4zU67sa
X-Received: by 2002:a63:fb45:: with SMTP id w5mr20794755pgj.118.1552504655076;
        Wed, 13 Mar 2019 12:17:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504655; cv=none;
        d=google.com; s=arc-20160816;
        b=l8g3R/6lTPT7FS+vyL94kTTc8KUujtY787eG47dfercIsF8rGCcLgWx82dF59KBfOK
         z5HFHSz4+TrkSRk3F/3vh6oPm1xidOGeSReCaboe1t2rpE4vLWZQIbgUsrUFi5cHHZaK
         1ApE6q8ExnWhDB8CxLRLEtU3a4sZAePqym/JjjnYNZl3BUglc53GXOWWXMm1fgWaZyRv
         VRIB6ieUmWoMWieT6PddW2DgFaiVufSmX2yXu+BfqZ2zTE/3QQyLcH6tErGHB8rHNrm6
         7QUNY5dHHyIh6ybS5iX/opJCSyx0AfoWsqryaYegIAo0tI4Kpo7nz8ixSrlTBCrnrcxx
         F6mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=t5w34QpCEbzhCQ+YrFo30ZEJWvD/GkMyXx4NH/dUUcM=;
        b=mIptd8kijHoLzMs9VOOL83fG2pUJrpE/jaS+1iZ7gzCjjMJHbbCwW+IiToJcyUqU6p
         QCAda6qkVbO8EmcnErFZ/Pmxw1eRuDS9rQgcbO1wGOv7boKKM2k0kYzdKY6VEiLHWPJe
         /rd78ih57N93bRPA5OtwCKyvHIpVKL+uGHMXA5OZ1MRK9ZsPx4THHpaBSINOXJzgN1Lm
         GsMuNsW5Oul/BuossYhT7b0q0TTJzfqHusAffi27l4Fkby6rVSXf1PspWtD988YOEgEn
         QNn4eUjye5Vwnudts1ZX0p4EXGsmaPr0VvKNG/gJpwofa/q5N239YA4aLbUcazpwNli3
         IgVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oIMmuhhG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w12si11253151pfn.95.2019.03.13.12.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:17:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oIMmuhhG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BA963213A2;
	Wed, 13 Mar 2019 19:17:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504654;
	bh=HUMTtwvfTqJ22EdxNG0wvhC1euHrxFtWHrrrAVFLCUM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=oIMmuhhGfSCg3rqpjx0dPbnQ/OZmG6p+ELNpxYy9AZcjMAefIlkR6Nt+GkxunvdoV
	 L1V3/Vku9ntYPViiJlXWBfYEHngJMh/yqhVUOBfiTdPIhLqZEePyTL2Kz4fu+qlzdo
	 tNwqsAk+0vreAglCoIabl+OhnbbUsFn46h16oiVw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 15/24] kasan, slab: make freelist stored without tags
Date: Wed, 13 Mar 2019 15:16:38 -0400
Message-Id: <20190313191647.160171-15-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191647.160171-1-sashal@kernel.org>
References: <20190313191647.160171-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit 51dedad06b5f6c3eea7ec1069631b1ef7796912a ]

Similarly to "kasan, slub: move kasan_poison_slab hook before
page_address", move kasan_poison_slab() before alloc_slabmgmt(), which
calls page_address(), to make page_address() return value to be
non-tagged.  This, combined with calling kasan_reset_tag() for off-slab
slab management object, leads to freelist being stored non-tagged.

Link: http://lkml.kernel.org/r/dfb53b44a4d00de3879a05a9f04c1f55e584f7a1.1550602886.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Qian Cai <cai@lca.pw>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index b30b58de793b..cb1f38e72b4e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2405,6 +2405,7 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
+		freelist = kasan_reset_tag(freelist);
 		if (!freelist)
 			return NULL;
 	} else {
@@ -2717,6 +2718,13 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
 	offset *= cachep->colour_off;
 
+	/*
+	 * Call kasan_poison_slab() before calling alloc_slabmgmt(), so
+	 * page_address() in the latter returns a non-tagged pointer,
+	 * as it should be for slab pages.
+	 */
+	kasan_poison_slab(page);
+
 	/* Get slab management. */
 	freelist = alloc_slabmgmt(cachep, page, offset,
 			local_flags & ~GFP_CONSTRAINT_MASK, page_node);
@@ -2725,7 +2733,6 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 
 	slab_map_pages(cachep, page, freelist);
 
-	kasan_poison_slab(page);
 	cache_init_objs(cachep, page);
 
 	if (gfpflags_allow_blocking(local_flags))
-- 
2.19.1

