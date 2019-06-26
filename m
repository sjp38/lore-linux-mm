Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75737C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C182204FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="R3K/eMQJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C182204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C94298E0009; Wed, 26 Jun 2019 08:23:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C452B8E0002; Wed, 26 Jun 2019 08:23:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B35998E0009; Wed, 26 Jun 2019 08:23:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9323D8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:23:27 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id f125so819866vkc.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:23:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=VZ1Nu4TClKywlJIX2MtkIO8a/JcUzUmevX6rOfNTQ4s=;
        b=G9m3h4R4QgJir3xX5a48wfdXK0YF7xVqXPuncExL2ri10CAUDaMBaHjYASpxnrQtKW
         5ad4OBVjFjdaEHKp4UPIIkkEodSh/dgsulsWCH8zMdTqfNjBJN7DNSRNW0j52zzT3E7K
         r4CKzpeNWCuA6P7fzWku815kQKSAdPQyLOoraN/6pGwnIBa5BajCPKrd1fJse+c47oSa
         CO4RpumgqULYsUgYt20HJ95wSLUoVXB73B7dCzIZjFEf3MHh5hqUMG3vhnILjwyyN7Jr
         uKsYFavn+yWr6Jft2q5qAiAyFIbsh+adnrI5ZKAQaOg+pPpFXqHtcFEIy+KyTzTWyzj5
         i8dQ==
X-Gm-Message-State: APjAAAVzUF5qmKJCq2E44sSqSDguz+6J+zihF2xw5/GWnVT9p0ePMw4M
	gLCkitrDD1Vl2xqSkb1SdMJ5yba+0Yj8DrAVc1qjG4FmPW5juXt6CACGM95AdzvoRst+FLXIQe6
	F3M9FoO+g9g79XHGvh3+sPUnkCk6R78V6PyfWVA1oUiW1bXmnrCGHNbI38h8a+H60Bg==
X-Received: by 2002:ab0:23d6:: with SMTP id c22mr2228127uan.117.1561551807213;
        Wed, 26 Jun 2019 05:23:27 -0700 (PDT)
X-Received: by 2002:ab0:23d6:: with SMTP id c22mr2228105uan.117.1561551806656;
        Wed, 26 Jun 2019 05:23:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561551806; cv=none;
        d=google.com; s=arc-20160816;
        b=dJaJ5laDhJATXIZSK8maffRBhqN7GbaIPBT+HYArfNBFECBrv/xtHMDJhnw6WbK35S
         qTQlPzlwFVTb7xyefDFFerisFDKVNPrCySQiKEJwCb+DL4L6mt+YZlxoC4rcwYXzC7Ku
         MmyrnLgynNjJ7RfKa+5Wa0FXaFsLO5xA61s1JZ8y1uACWwceguUQ+DsqQAlF9KPETT+T
         EDQEDDq6rBoz8obn9ubG9b9bEZ1qFcsA5PaEjzG8qetfLBKDvUgM1V7+LjjR1ysxgylC
         daARE5jMAWP2Cxu0qsqoUj8yFihBFqttYYFTp9HbZ9eY5yZ/aaWwScmQ5hydrwqfCv1W
         yIoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=VZ1Nu4TClKywlJIX2MtkIO8a/JcUzUmevX6rOfNTQ4s=;
        b=PDLPInmP5FA+MhqYMxMrWu6Mx5TTfqXWc/t09JBXjmnGf6wRSxbt5htJbqh6psxfSB
         3kg2PVe43TVaQzNPJPoR1U8y6xfZjsfdHzUfklLKrP/6f0yk+91AA1DJf6/HIM/pq5fo
         q3oemwS6tcuSJzt3svJYXE1Zd55sZgiqgxNFZqNE1EPb8R/mHAm9nLes6pJ6Vmm/Dxa1
         xLxgOZdoiQhad+Hg0Qos4MlYKGXcxgMOT3Q1S2pY5nqYgB01hjt1jDUE6p8Ahw7XMDiH
         jpaos81zEobcnRS5V6PBdEBzAsThhE1GMA6ChSmwG8FRqeATbFMWTlGccU/K6ALJa1hL
         or6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="R3K/eMQJ";
       spf=pass (google.com: domain of 3vmmtxqukcmels2lynvvnsl.jvtspu14-ttr2hjr.vyn@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3vmMTXQUKCMEls2lynvvnsl.jvtspu14-ttr2hjr.vyn@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id s73sor5304125vkd.45.2019.06.26.05.23.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 05:23:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vmmtxqukcmels2lynvvnsl.jvtspu14-ttr2hjr.vyn@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="R3K/eMQJ";
       spf=pass (google.com: domain of 3vmmtxqukcmels2lynvvnsl.jvtspu14-ttr2hjr.vyn@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3vmMTXQUKCMEls2lynvvnsl.jvtspu14-ttr2hjr.vyn@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=VZ1Nu4TClKywlJIX2MtkIO8a/JcUzUmevX6rOfNTQ4s=;
        b=R3K/eMQJQRtikm1dkDPsjm0vASp36psrk0zphCIGzfzKdobUSKP98DNPLmE3jtTz36
         k53RvT9C4WPzIrAf7ogmvNgTJP4wcCVxNDiuaOfrQkNwQXRiv4gX3Sie3ymaWUgyagMg
         ySSkdoOWxJnKUXRr1FdQqhPlm4/2c1Z726b2YODRRqTL0VIS1JsdL1HX3mFeeiGmiAS/
         ZZ47BRrNaqaviL/MHAk9Lv7rCAqpfm6krL2+Cx/hFK5eUZ+FOWrS8SnUejWx9ZAUtqxA
         /FEM2bkxjkcXiLiaM5BfOOoQj6y2Tm4lRbVetJavA7nYiXeYRy5l25bLE/DfavSm0Web
         3Zfw==
X-Google-Smtp-Source: APXvYqygvrRZ1bPrPIv8ogsJy+NDtCh0yd5w8q0aP5/NTB15AyjhsuzojOb2uSDRovh5ehYjdR+FYjXA0w==
X-Received: by 2002:a1f:a887:: with SMTP id r129mr1048981vke.75.1561551806136;
 Wed, 26 Jun 2019 05:23:26 -0700 (PDT)
Date: Wed, 26 Jun 2019 14:20:19 +0200
In-Reply-To: <20190626122018.171606-1-elver@google.com>
Message-Id: <20190626122018.171606-5-elver@google.com>
Mime-Version: 1.0
References: <20190626122018.171606-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v2 4/4] mm/kasan: Add object validation in ksize()
From: Marco Elver <elver@google.com>
To: aryabinin@virtuozzo.com, dvyukov@google.com, glider@google.com, 
	andreyknvl@google.com
Cc: linux-kernel@vger.kernel.org, Marco Elver <elver@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	kasan-dev@googlegroups.com, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ksize() has been unconditionally unpoisoning the whole shadow memory region
associated with an allocation. This can lead to various undetected bugs,
for example, double-kzfree().

Specifically, kzfree() uses ksize() to determine the actual allocation
size, and subsequently zeroes the memory. Since ksize() used to just
unpoison the whole shadow memory region, no invalid free was detected.

This patch addresses this as follows:

1. Add a check in ksize(), and only then unpoison the memory region.

2. Preserve kasan_unpoison_slab() semantics by explicitly unpoisoning
   the shadow memory region using the size obtained from __ksize().

Tested:
1. With SLAB allocator: a) normal boot without warnings; b) verified the
   added double-kzfree() is detected.
2. With SLUB allocator: a) normal boot without warnings; b) verified the
   added double-kzfree() is detected.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=199359
Signed-off-by: Marco Elver <elver@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: kasan-dev@googlegroups.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/kasan.h |  7 +++++--
 mm/slab_common.c      | 21 ++++++++++++++++++++-
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index b40ea104dd36..cc8a03cc9674 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -76,8 +76,11 @@ void kasan_free_shadow(const struct vm_struct *vm);
 int kasan_add_zero_shadow(void *start, unsigned long size);
 void kasan_remove_zero_shadow(void *start, unsigned long size);
 
-size_t ksize(const void *);
-static inline void kasan_unpoison_slab(const void *ptr) { ksize(ptr); }
+size_t __ksize(const void *);
+static inline void kasan_unpoison_slab(const void *ptr)
+{
+	kasan_unpoison_shadow(ptr, __ksize(ptr));
+}
 size_t kasan_metadata_size(struct kmem_cache *cache);
 
 bool kasan_save_enable_multi_shot(void);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b7c6a40e436a..ba4a859261d5 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1613,7 +1613,26 @@ EXPORT_SYMBOL(kzfree);
  */
 size_t ksize(const void *objp)
 {
-	size_t size = __ksize(objp);
+	size_t size;
+
+	BUG_ON(!objp);
+	/*
+	 * We need to check that the pointed to object is valid, and only then
+	 * unpoison the shadow memory below. We use __kasan_check_read(), to
+	 * generate a more useful report at the time ksize() is called (rather
+	 * than later where behaviour is undefined due to potential
+	 * use-after-free or double-free).
+	 *
+	 * If the pointed to memory is invalid we return 0, to avoid users of
+	 * ksize() writing to and potentially corrupting the memory region.
+	 *
+	 * We want to perform the check before __ksize(), to avoid potentially
+	 * crashing in __ksize() due to accessing invalid metadata.
+	 */
+	if (unlikely(objp == ZERO_SIZE_PTR) || !__kasan_check_read(objp, 1))
+		return 0;
+
+	size = __ksize(objp);
 	/*
 	 * We assume that ksize callers could use whole allocated area,
 	 * so we need to unpoison this area.
-- 
2.22.0.410.gd8fdbe21b5-goog

