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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DB98C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:28:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BA602133F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:28:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Rpe/+hhA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BA602133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 929588E0015; Wed, 26 Jun 2019 10:28:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DB2F8E0002; Wed, 26 Jun 2019 10:28:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F17D8E0015; Wed, 26 Jun 2019 10:28:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5C08E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:28:10 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id o135so5227093ywo.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 07:28:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=faSJHauNDZMNHqAQEQyENlJrk267vkTV0fUxMXAvovc=;
        b=NkSZdG46pCZ3UC3MWeRkRkfXYwm2zPE2HhZpB3jB9ykMABzCzI6t1N9VM76a0KDZ5r
         onjNd69YtaCqEji1WGcD30WtIWhkOsTvbyVQabWnrOodoXWSwfa7o9pSiKh2bPhEU/9H
         INs6EDFh/sF2DfIgFEg7xVxKi1LAs/0Ew/MQssI11gIegvtjtYdMBrUgK1jCgjz6mZFJ
         KVTtm72XGzTTaMpK2ULOxDtLyxlMrKMIH7dKJ9e+dHi9y5xYP/6/PhHNSKMC4ZuPOqWo
         CO4ClsL5YAs8tEVesqIlRmZZOG83XUAASIb3H0ekUD5HJSbZ13s5d8ixCx/tP+4POn+b
         T2Ag==
X-Gm-Message-State: APjAAAV/FQCrDmNAa7KoWMg8pRgG466R/96x/whveqB3Qx7F5BqkBYkZ
	zwe5yhAeP0YAci/42PFfjyD41pVjsQm1ZptzDGi0g+q6hX9MTOXyrr0vwWoNkX3XXbeEOXmcY2c
	mG0fgzwf1KHSmHbrPAlhgHYhFs+nkwdxp1gsLPFUfkSKMDAnHJWp2vWcpa+YFZNzZvQ==
X-Received: by 2002:a25:2f90:: with SMTP id v138mr3016504ybv.238.1561559290080;
        Wed, 26 Jun 2019 07:28:10 -0700 (PDT)
X-Received: by 2002:a25:2f90:: with SMTP id v138mr3016469ybv.238.1561559289442;
        Wed, 26 Jun 2019 07:28:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561559289; cv=none;
        d=google.com; s=arc-20160816;
        b=RyrmvlCJ5iuDYZP9xmG5/CjCozqNJCdAvMKu6WyYAD7SlWXv3NYFKyiHpvL6OyRV0n
         xI/Zo9eFD5lf22yCfeBy6z7CdthtWXIAMqAijY4myB2Oa9192udzbB23tNfugObTuI/k
         mhLMCVrHOOQOjSaEns7tid6z9QkjeqYxHuz+JY6WYCG2Qq3c9MTbZ8zkbO6RaJWOArPv
         uNWVcsLzsVBwCjswUB9LZfRM53W8UG21Oq4yNXB+L0aCSUU/h8f4NXwu/G3o970SNSla
         +u+ShlZ2UC9W5N67H+pZicSAnlh+fVCxW5FQum0cHbG4mv/HPfGWm2SgG/0tEhR0Iip2
         nF1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=faSJHauNDZMNHqAQEQyENlJrk267vkTV0fUxMXAvovc=;
        b=yn564ySOLH7CmRxDF3Mtv0JliRXUYXbUZUs+CoVWQwJmtwrWJlVflLrCQf0fsRhadP
         hZdr7Ra4GYK36c7F77+G62rUqJucwdHV1G7SjDDUNmRzzYpYZtzhwyNI9TPrwenEJQSU
         0eA89y4MjK5LRi/beQCU9Isp0MLJeLPCMX8L/COKwbwXtGWeIqn3I6sGiN/SqtL5vyiw
         n6vt9TyQ/0+FWzP5j6TKgnE+GUki1Qq7pFjoQU4rBSpxlu/0o8f53t2aG5Co9VeOmcfC
         3Hb0fwIvcbWVBRmYJQw1WC4bUja/EGuc2vnQJ5IOJskZNDAKuj5Nb3NCDqnvVGY0x2oQ
         5/wA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Rpe/+hhA";
       spf=pass (google.com: domain of 3-yatxqukcdgyfpylaiiafy.wigfchor-ggepuwe.ila@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3-YATXQUKCDgYfpYlaiiafY.Wigfchor-ggepUWe.ila@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 127sor9863854ybg.106.2019.06.26.07.28.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 07:28:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3-yatxqukcdgyfpylaiiafy.wigfchor-ggepuwe.ila@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Rpe/+hhA";
       spf=pass (google.com: domain of 3-yatxqukcdgyfpylaiiafy.wigfchor-ggepuwe.ila@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3-YATXQUKCDgYfpYlaiiafY.Wigfchor-ggepUWe.ila@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=faSJHauNDZMNHqAQEQyENlJrk267vkTV0fUxMXAvovc=;
        b=Rpe/+hhAuik4wEKF7ZnhSFTzCJWomnStiupdaRm5p3WH78LIhaqN01wh0/La2gPWd0
         GiWq87RjANNNVjijGXlI/D5fMC4N2f3aQ6pFE1DkTOd5HtLbPcPyYUoZAXnRJDsX1bUI
         HqUFzIbq50jIdzQAGS74aQswueJLB6Gj1rTKk9dLogJ+8knw6wW5Dq2QR5NV7avh8n5D
         CPnMn+dJ4Gy6aUdvTo04WvF/Hj8UgmAZmMypmXnFNRO0cyKFQCWldDBg7rbeuKvkIu2f
         3x75GlN+HPPBvLh1hinwDSnWPmtIEZ3O5tvDaGybq/sHn4keSYz0bdMNtEu2NdTPDdeQ
         Eocw==
X-Google-Smtp-Source: APXvYqyJYKdUcCtVZqyt4moVcnw2f3kYsOmTBBGDeGBkbTpjuw8th3J9bd9qALY9ZOos9usZ38iNTR3hyg==
X-Received: by 2002:a25:4d55:: with SMTP id a82mr2984762ybb.383.1561559289029;
 Wed, 26 Jun 2019 07:28:09 -0700 (PDT)
Date: Wed, 26 Jun 2019 16:20:14 +0200
In-Reply-To: <20190626142014.141844-1-elver@google.com>
Message-Id: <20190626142014.141844-6-elver@google.com>
Mime-Version: 1.0
References: <20190626142014.141844-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v3 5/5] mm/kasan: Add object validation in ksize()
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
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
Cc: Mark Rutland <mark.rutland@arm.com>
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

