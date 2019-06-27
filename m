Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A2D4C48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54DF72085A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WhKnnvq+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54DF72085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06E168E0009; Thu, 27 Jun 2019 05:45:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3BA98E0002; Thu, 27 Jun 2019 05:45:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E29348E0009; Thu, 27 Jun 2019 05:45:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C14FD8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:45:20 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so1798213qtb.5
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:45:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=dExuKDG1Vocm7R5NxDrIVnD2CUOvxrQiPu2P2B60v+w=;
        b=Ky2zGBdtG6DclQoN7BnpessughNMxO0TQk7hT1LoVJaA35ptS6Q9dKuFJcOskR1pV4
         tHfVTJQrTrV3QHUPveps11bCmNUSxJYCOUHDIaL3ZnVIyVtOFPvVi0sh9e1vZpRd6Mrj
         2PUh5SEizi0xBiE1LoEiGynAwk9QFeHuH4NdDnFfoN94D8zNe/usAi6NZ6w6jKEteOht
         SmwqitY7LffYvLO8FYWL32zS9Qb+O0UCCLX+Ydp1j6fhm/8OREOoyMytuKwC+pFPRso7
         aITMbfJiTwmx60SuRiZxf3UedfHphmyJgkSVmArJs6s8gZVK6YiJlmKk/DSorM0rx7vi
         F3Ug==
X-Gm-Message-State: APjAAAXDvI0DvAru/BSNKVIMpLawLgW9M4kR1ySrqdMfZ091SG9WQhX1
	8z+tQt4pOYCvjAFsHZm7f8SbfjlgWvuCslCH1eicNFVSWwqU76cMQaWFUURfgqoxPYO2xxkTAWf
	7xhk2U2TeIX6FiBIduYjfobr18ZQJkuTZBtfBJPG8s6MRY/Qactb+hyBBseSUTaw28A==
X-Received: by 2002:a0c:983b:: with SMTP id c56mr2262768qvd.131.1561628720466;
        Thu, 27 Jun 2019 02:45:20 -0700 (PDT)
X-Received: by 2002:a0c:983b:: with SMTP id c56mr2262736qvd.131.1561628719911;
        Thu, 27 Jun 2019 02:45:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561628719; cv=none;
        d=google.com; s=arc-20160816;
        b=hmLSaFv7WGWwe8s/mGuMxp96WbC9aXn3lxO6TLliPivZJ9YK/+mQyJP8KHLcsXm7AS
         7OxFw/Fmhi7dvxBdljjz34iK2nKvYWhRLtNMh3xUQu9cJEx08SAg5Z/AewdXJ8jZlLp7
         6+M/J99XPthkJPyzwKbpzCHHy4SCQYmKjJCgrndXnbTnjLToj3UwjxvE3Uru9zhm/sPV
         frzG7iAo5GPEyRLqm4fRrOxkyPHnuUUyZyE4tB9AfgP+XhixccJrH5zneciL3lWVDfSV
         TAcnrLGc5XKBKAOGSPUUeP6uBOvU67aUdyHNNlCVyZemyYY5ZGPkSoUb3SyxaIPTDtw0
         85Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=dExuKDG1Vocm7R5NxDrIVnD2CUOvxrQiPu2P2B60v+w=;
        b=MwO5yi7quXI2Y2rx2ZgCQSxVXyhbIq5D+lMqA/yElF8teFow+JpQd2YodeMiyagNYk
         6ajAwWDq0AkBOLwudWnVG4tCr6+8Zr6/WYi1ACipXo2M74ZKv5dCYNT36/P6EZqZNGmB
         meF118HMbG062f0vaLxh3BLF3HX8ni2zR/ZfTdcMPc103yQVPKpmU9EhCM49jrSfFLvs
         Mtrk2I5EPhYsBycuWlzkDD2JCTUm/qjM81cNCn7Zos8YBRkgRdu3OnorUk+1cwluKrQg
         WHLD+5btnVuk6fqlK52ua98jAkHrItuz6G0b7ZVf/yVfPnY9BCulvpsFZGz/4+QMXn1r
         Lbvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WhKnnvq+;
       spf=pass (google.com: domain of 3l5auxqukcjay5fyb08805y.w86527eh-664fuw4.8b0@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3L5AUXQUKCJAy5FyB08805y.w86527EH-664Fuw4.8B0@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z4sor968616qkf.122.2019.06.27.02.45.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 02:45:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3l5auxqukcjay5fyb08805y.w86527eh-664fuw4.8b0@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WhKnnvq+;
       spf=pass (google.com: domain of 3l5auxqukcjay5fyb08805y.w86527eh-664fuw4.8b0@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3L5AUXQUKCJAy5FyB08805y.w86527EH-664Fuw4.8B0@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=dExuKDG1Vocm7R5NxDrIVnD2CUOvxrQiPu2P2B60v+w=;
        b=WhKnnvq+eH098gHUsu9ljm8u7NiCcoAvG7V0jrd0jshrongcUzOBhvAkJkf73ihZp+
         x3Y9xDvb/jKeuWHH2u6ckxKlX4aRRtMTvzfpLyoRC8ULamnLUoUk7RmzaQm3Pu+0A4e1
         TVRXpAoOz57i7ofZgEmZe1BUe1IKn0PYDS/TQatmUcXMJo3QYgnPKgaJ7aOyp490eCa5
         9/4AAlnsh7gejuJ1dXHGMgR2RQoI5pSXa+juORIs7YAWHwbX6FFBA3ntOIo9VgB1s9h6
         itvb8QOBVqFPE3dXzuyMQc+JONF1LgPbfJqic6PD68Aab3oqz8ROjmqia26Mp4ZETGOh
         eYSQ==
X-Google-Smtp-Source: APXvYqyL0gF7qx89YSATj6wfEvyEQdk9uqASJ2qWX9sOEiRzrIlqUKvFG2sTfdKb+6/6XSohTv4Fsmd10g==
X-Received: by 2002:a05:620a:1228:: with SMTP id v8mr1133045qkj.357.1561628719562;
 Thu, 27 Jun 2019 02:45:19 -0700 (PDT)
Date: Thu, 27 Jun 2019 11:44:45 +0200
In-Reply-To: <20190627094445.216365-1-elver@google.com>
Message-Id: <20190627094445.216365-6-elver@google.com>
Mime-Version: 1.0
References: <20190627094445.216365-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v4 5/5] mm/kasan: Add object validation in ksize()
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
	Kees Cook <keescook@chromium.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org
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
Cc: Kees Cook <keescook@chromium.org>
Cc: kasan-dev@googlegroups.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
v4:
* Prefer WARN_ON_ONCE() instead of BUG_ON().
---
 include/linux/kasan.h |  7 +++++--
 mm/slab_common.c      | 22 +++++++++++++++++++++-
 2 files changed, 26 insertions(+), 3 deletions(-)

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
index b7c6a40e436a..a09bb10aa026 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1613,7 +1613,27 @@ EXPORT_SYMBOL(kzfree);
  */
 size_t ksize(const void *objp)
 {
-	size_t size = __ksize(objp);
+	size_t size;
+
+	if (WARN_ON_ONCE(!objp))
+		return 0;
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

