Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5A98C606C2
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:09:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74BBE21479
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:09:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="B62llil3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74BBE21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DB198E0026; Mon,  8 Jul 2019 13:09:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18C108E0002; Mon,  8 Jul 2019 13:09:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A19F8E0026; Mon,  8 Jul 2019 13:09:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id D94348E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:09:11 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id t7so6835363vka.2
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:09:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=va2IqGms4zwARolaxGifymkA8dWqhnjJfJEjqFTqRUA=;
        b=kzgZNInZFz3EJD3d+4fK49pmnNMPxYNQvVD4l+EWsn2pvBjDIp8oLTFed5MSA0aXqs
         kbiSH81+IjR9iEWGaTy+6EYOamhQOv1m0gUH592fuaNgP5/TrdDeWfBVXHcA7FRihrfJ
         x/rUeF4shnvVX7cAwN7SJH0EZAHR9pDWop+//KPb+YNiKHYqO81iIPLTXqpEY3hwWjut
         gSdPcEAdxQ6ehqZIFW3Smuc/gCz9n+mNaDB2mnX3Gd7BMz6woWiKQ4gec0LwuCaY6GvL
         wSVQHBtYCwfVgO8RAQd4TqebSmjGZDxqBrDSiSuJ77UIpqQyzd3lZPMytEBLtpxyDdNq
         W57A==
X-Gm-Message-State: APjAAAUArccAxJ70TC+/rpaSJuUbBtuGtbfeLJ1i8pfuF5Lta1utotSr
	boZu5KEdZr04wbEZHeAqymuTsZbxV1yskg1Of1lIBt4bOgk/B/HjxKQg4zdCat44sGZHVljRQBF
	B1SJziDgbHD8r5eMmcAneeXwY3pB84aA2CVxc/yuf1dQ8uwL+/1CwcYTi4iTlm1hkWA==
X-Received: by 2002:ab0:7035:: with SMTP id u21mr10454483ual.26.1562605751616;
        Mon, 08 Jul 2019 10:09:11 -0700 (PDT)
X-Received: by 2002:ab0:7035:: with SMTP id u21mr10454448ual.26.1562605750887;
        Mon, 08 Jul 2019 10:09:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562605750; cv=none;
        d=google.com; s=arc-20160816;
        b=Sc8OuSOK00H9DPx3KFNNC4mHHKtFeGwlS+AWkXSVTGLwmsROgGp158z6Nt4koFnYI2
         GveJbho71pHh67AeqP6aByPAgkCv6zKmzvWBANMZNccOHmlCdhaY0OmfwbDviRAYiNvh
         tzdf9hqxQSpMIwjW7hTjneo7KuFJZBq+KAxtXLOhmtothCV/WMU7EirnNF3oHFHaSej9
         AldZP+mWZmCE/MPh8pk/pndj28VzO3Gcsy/XDoLyD3AnvdgCtVstbkzfNIxAL0Fkne8T
         R9EbVlDB5PZ8pm5vXpbU2vf/QqvLc/3yPiDpPgOt6yAsxW0WlK3KW1gjPP3uTluddjBK
         P54g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=va2IqGms4zwARolaxGifymkA8dWqhnjJfJEjqFTqRUA=;
        b=bhLnAM3uS/87E0HWyd7XMVlhUveVYFqjEGeqBPE81JAnmPY/z58xsve1CwM2t7vgJd
         Asy8jvf0awTFeN/GnGFfMnDcNPfv8Re5QdWWsnL2Y2DOWEOojnHeRI3zPCwJbNw43p4G
         fs17DsIQ4VUUYEtdKml/PoeVUQva+vnYZ8HoLBLQ631dnHaLkFil1zEX5hJgKkT4QTin
         f5aWrEnXVFUPineAtxyaXO0EPPaYPmPA64D1itJWwRIuo9ClCWNYSjbfXpLT+/aNvZQv
         1mnwcGIdy8k9nEqqoznmBiHZvSmDU+/smiXbf0l6F2qM/J1zOB82bnIp0YFso3ksEcIF
         oBPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B62llil3;
       spf=pass (google.com: domain of 3tngjxqukccufmwfshpphmf.dpnmjovy-nnlwbdl.psh@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tngjXQUKCCUFMWFSHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j8sor7303174uad.24.2019.07.08.10.09.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:09:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tngjxqukccufmwfshpphmf.dpnmjovy-nnlwbdl.psh@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B62llil3;
       spf=pass (google.com: domain of 3tngjxqukccufmwfshpphmf.dpnmjovy-nnlwbdl.psh@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tngjXQUKCCUFMWFSHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=va2IqGms4zwARolaxGifymkA8dWqhnjJfJEjqFTqRUA=;
        b=B62llil3Fe4KzeXZEaBbD+00lGLnt61xZThwbT0g6IZl70whfkLgUD6l34hNGVCkHT
         1XnLhu2ClICsG1ZP+VNktTAQx/P6j3YB6/j+5u70823Y2qvPdZJDEIRXRbOenMh1hpPP
         GSHE0OkiCT199jGkL1qB9jQVmf/D5xM3xl23+MYa2Z+ObxwJgvIxgeg+Qxu7/SXwDL7B
         FsNT+911aCa7KFAtwfmkM17dtznwJG3ibBxxM/tlmnyjdcoOIdyybcxyKNrZMUYmA9UV
         9YH2/5ecSLu43JAiNIRdh+iXemCTUQqtbW+fFY4QzbvLVelQ8VLKJWV1P7oHoBSpKz/0
         /BhQ==
X-Google-Smtp-Source: APXvYqx/AWhWyRiQYsh8A+R32YrMoMJUGisZJ17vs2U294DwY3kO8gA6cjJzosgpsyUF6ubvfQSzhfr+jg==
X-Received: by 2002:ab0:66d2:: with SMTP id d18mr10407237uaq.101.1562605750505;
 Mon, 08 Jul 2019 10:09:10 -0700 (PDT)
Date: Mon,  8 Jul 2019 19:07:07 +0200
In-Reply-To: <20190708170706.174189-1-elver@google.com>
Message-Id: <20190708170706.174189-6-elver@google.com>
Mime-Version: 1.0
References: <20190708170706.174189-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v5 5/5] mm/kasan: Add object validation in ksize()
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Alexander Potapenko <glider@google.com>, Andrey Konovalov <andreyknvl@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mark Rutland <mark.rutland@arm.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org
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
Acked-by: Kees Cook <keescook@chromium.org>
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

