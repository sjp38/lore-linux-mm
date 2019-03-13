Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B862C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E60822183F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ftXOAe4I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E60822183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 939DE8E0006; Wed, 13 Mar 2019 15:14:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E95E8E0001; Wed, 13 Mar 2019 15:14:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D8608E0006; Wed, 13 Mar 2019 15:14:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37A5F8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:14:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id i13so3280063pgb.14
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:14:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bnR/+Q2B+Ln7a3YRW7s2LMIlvsj8zmvXBJW7jZWP30A=;
        b=H+LJq5Pn7w7BtHE/LMjutX/aUEqPP1JfTIXK/IzSAPcxiZFDoCmUQISJAUgXxqfgp4
         orq0esadavXFuPNsh3z9d5KKVpgTLAbaSUyCNRzZu1xUmFP7C5H0zRUVa8j4+IY/x+bO
         wz47OTWagraniiN+UyUCD/drPCeXiJ0ziOSFC8DHOzIvM7/qS1fKoGcTjftlmLEmr2Dm
         s5HHaW4o8kId34toi4wv3im4sbgoIEJ7N6avkMSGnAfUzlqfflfSSeHFKCBagdgQq5sF
         okDn3W015/vOHWiCSwPb+m/WR+2avgbdL2tX5WWsQdVeNZ9vAzXZQdPLRkUbnMSO8rnw
         URfw==
X-Gm-Message-State: APjAAAUsOYefjN3byhTr/EK/6t7ybowyg9/FcVgqJ5B7MWmaeIV3NLA2
	e0IiFffOwPLg+1EIRA2ZvqDvbve+EukQ23GX0+d7V+PpjiCoXlYVMYS6Twn8N6TR+xOSy66fKCp
	Mwo2biMwypesEf9BW/KwSGVBqUh0TTDymjxn7BsH0XFbOsYLrBlJdwE0qXBin/kHpeg==
X-Received: by 2002:a65:64d5:: with SMTP id t21mr40840652pgv.266.1552504442842;
        Wed, 13 Mar 2019 12:14:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFainfUhf3RPrVXcD7ubGqZqN7s61Hb9+Fu+fV0rol9CGyTLySGGmBUfNgayP40PoW9K7D
X-Received: by 2002:a65:64d5:: with SMTP id t21mr40840598pgv.266.1552504442138;
        Wed, 13 Mar 2019 12:14:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504442; cv=none;
        d=google.com; s=arc-20160816;
        b=NytzdAsgBWHAcNBFlsK1IccC9yDKG9rM1SQIJgWYuzZi4FENlQ3gg8IaL+1KxlyOWO
         rJxTHS3jNmkWWsA5FzxextGainl0uEwpd3t/CE160tS8JORnrUieNrWyFVZRuu+2AqzN
         YO0Sq1DHE10KF+1203wZY5FYh9vE7I4WDN++cR/IhweWBnMyBQcPbL1/t/WhwnwHqDWA
         +QcgNrYXX6hsTs673xnIW9SP2ABe9wTuCEHQVVX9O4fJAgBitze9eR8QhkG1e95uBKdE
         uNdW2tTYcFxwcnL976r4gvmCvo0gmBXg6kuUuKXolxcQYeNB2o8yys3HZCQtD6acwhk0
         MbLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bnR/+Q2B+Ln7a3YRW7s2LMIlvsj8zmvXBJW7jZWP30A=;
        b=B6lf3UAtmor0XDz9Oyi7YVPEurRRb84YR1zrz7Bt40/SsXNcflh1EeAghboRjI1Mcy
         cY/d9Vga35+lQww0x7B83/mvF5mH+WJdnr/qsjdrBbgKIwMO5dBCUr4VxrnQoCQLNl8q
         qxR2jT7kdlys/DYQ/WOeenlFU/hoiDn7nh+deX7yA5iU3aFNfQYPA4Bjj5nGm1GN42va
         nbu5lVnmS2fPKNTGxaUegKjdFWixQ0FxaeYSUA91ciATwGFwa1t8uBQksuKFEpJbF81P
         HYQbhQ8wCuCaCgA99Q48c4ZtzbINkRwwBU7vWW2uEsbxBjDJOczytfoElM6P6LeL4pdR
         tHmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ftXOAe4I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n19si10759389pff.18.2019.03.13.12.14.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:14:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ftXOAe4I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A1FFC20693;
	Wed, 13 Mar 2019 19:13:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504441;
	bh=XHGEPbGuaK4DL9Q7qpktUVxi1JR42d6V4AQz9eyM60k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ftXOAe4IcT4USdQ9SXlqEU6H72A5aNLg9cb5/AJwhf949eYMmqK/tWHvutys/9AbW
	 xuzxAt4Uahu60/txNlrD9GCGyTdpM3+/nPbJ4/ZDWFCryaVxlfz68xEq6X9UJo6TGG
	 qisO51Ps9eOPvIGWRahlRyoXC7Zlm4GxuK6Ej1xw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Kostya Serebryany <kcc@google.com>,
	Pekka Enberg <penberg@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 27/48] kasan, slub: move kasan_poison_slab hook before page_address
Date: Wed, 13 Mar 2019 15:12:29 -0400
Message-Id: <20190313191250.158955-27-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191250.158955-1-sashal@kernel.org>
References: <20190313191250.158955-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit a71012242837fe5e67d8c999cfc357174ed5dba0 ]

With tag based KASAN page_address() looks at the page flags to see whether
the resulting pointer needs to have a tag set.  Since we don't want to set
a tag when page_address() is called on SLAB pages, we call
page_kasan_tag_reset() in kasan_poison_slab().  However in allocate_slab()
page_address() is called before kasan_poison_slab().  Fix it by changing
the order.

[andreyknvl@google.com: fix compilation error when CONFIG_SLUB_DEBUG=n]
  Link: http://lkml.kernel.org/r/ac27cc0bbaeb414ed77bcd6671a877cf3546d56e.1550066133.git.andreyknvl@google.com
Link: http://lkml.kernel.org/r/cd895d627465a3f1c712647072d17f10883be2a1.1549921721.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Qian Cai <cai@lca.pw>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slub.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8da34a8af53d..7666cff34bfb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1075,6 +1075,16 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
 	init_tracking(s, object);
 }
 
+static void setup_page_debug(struct kmem_cache *s, void *addr, int order)
+{
+	if (!(s->flags & SLAB_POISON))
+		return;
+
+	metadata_access_enable();
+	memset(addr, POISON_INUSE, PAGE_SIZE << order);
+	metadata_access_disable();
+}
+
 static inline int alloc_consistency_checks(struct kmem_cache *s,
 					struct page *page,
 					void *object, unsigned long addr)
@@ -1292,6 +1302,8 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
 #else /* !CONFIG_SLUB_DEBUG */
 static inline void setup_object_debug(struct kmem_cache *s,
 			struct page *page, void *object) {}
+static inline void setup_page_debug(struct kmem_cache *s,
+			void *addr, int order) {}
 
 static inline int alloc_debug_processing(struct kmem_cache *s,
 	struct page *page, void *object, unsigned long addr) { return 0; }
@@ -1602,12 +1614,11 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (page_is_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 
-	start = page_address(page);
+	kasan_poison_slab(page);
 
-	if (unlikely(s->flags & SLAB_POISON))
-		memset(start, POISON_INUSE, PAGE_SIZE << order);
+	start = page_address(page);
 
-	kasan_poison_slab(page);
+	setup_page_debug(s, start, order);
 
 	shuffle = shuffle_freelist(s, page);
 
-- 
2.19.1

