Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B9DDC28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:50:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A03C25D0B
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:50:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="bLAFkJTI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A03C25D0B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C263E6B0275; Thu, 30 May 2019 00:50:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B88486B0274; Thu, 30 May 2019 00:50:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 940CC6B0275; Thu, 30 May 2019 00:50:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41CE66B0272
	for <linux-mm@kvack.org>; Thu, 30 May 2019 00:50:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 140so3672145pfa.23
        for <linux-mm@kvack.org>; Wed, 29 May 2019 21:50:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=wNjFOui7vuFEtKzXwg5aNy6ZEm6jbdXBcZyq2T1si6M=;
        b=kcYP9nSmOBOAHI9N4O0n3SiByufjoF+cCGXX+qiqiRuTp36NpPSUf7CXgxaRqqJYdr
         CKCn0GEMwx2v28dZfMlOrDWGgIiiibaCEHRFfI53qtxclBDWK/uX19XIxQVA9o6u4lGN
         x94oBw20cSSy8P/DVU2iCTVbX7Lsc9Cn8MQqYBz6gpp9sFn/w4Vj/USI5hqEhxOxpzZ1
         nYm8Q8avBka1ve9Xf0krIjDMLh9bF7f5Cs99henQNuJ99ckiYCIoSx8/a1IHuI2blqnH
         t73kuTD8s8tmMFwEP6R8wV62TcKBKXWOvwWNGB+ZtlXwNvTFPof9jn5dqLgsC6IEnfhb
         Cr7g==
X-Gm-Message-State: APjAAAW+9keUpUUt9K/FLToUFeGoD6eENhR/P5/fkTPPWrHQPdU5UyWE
	V7jrWHxgaJz2ZNIijOW+FYUcYE3i2VeFhmtiFiCKXMcKkHYKiPfgWc3B305FdPlH8BjGaNuE5oo
	0wRh40sV8bOF3hCKXWhh2VUI4BKkXx5YiHzjZ8xCvDU9Xcb77NjSevAeRzWRgMXxKTw==
X-Received: by 2002:a63:cb:: with SMTP id 194mr1923860pga.395.1559191827923;
        Wed, 29 May 2019 21:50:27 -0700 (PDT)
X-Received: by 2002:a63:cb:: with SMTP id 194mr1923826pga.395.1559191827184;
        Wed, 29 May 2019 21:50:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559191827; cv=none;
        d=google.com; s=arc-20160816;
        b=AkKkTJX1cZ+SI+24S2MlVET5w496HxF0c1IQigc6tQM6IMxWxYXeLk7Dawpa5w93YG
         mj/W7Zj78b/7036Va9FkkkJPamD0TpIcTnf3i0/jeopsmXeJr54i4196aelftDY+my4Q
         x8Oe0p7kMimh6DjwE/15Gi+VqOoxpGLaSDY/mY/4sWv0oVEpryvN1BW5jmHTliV12XP8
         Aad8bxyPNvNbc2HjzG08nR4Q1uUInjSY+LJN7pI3fa0xTwFPFg/Qy55967nKTw2OcBgu
         pJPTG1uU1oTqIn/IHoYiZ6kGB37DlxiItz6D//5bZNTtUSQA2XxTmuEuG18EYpPf5wn2
         IDFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=wNjFOui7vuFEtKzXwg5aNy6ZEm6jbdXBcZyq2T1si6M=;
        b=HDqRwsH6IkkYrIJmCcBpCrLZbbVdi03YKcxYCk43t6GGXwnJUHFlg5BbJanBjiRiVn
         e2y2TXhirKa6XZciu8kJAsKOqV0NhwkXsjlMfj8npwr0Q6H5UZ5NPuHdhkw6opa/uvWS
         tY1M2vlUFktOl26TxWJk1gmdQuWoZ5ob7PIXhhhMxVJ7MHTxBjOr6cgDkAvAdtPNei4I
         azmAK/tqo2PJ7rw7+wlVOjEOLO50+wwOIr+TRv/wsoljePXftKlqhgt6JjXCLWiExZIn
         V2ib5Kff/nCX3l+Wncn10Z3iOeu6mo8cuxw88QqnZNX3c9AHJaCZasrfk8idq2O83Iyb
         OvYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bLAFkJTI;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z135sor1940945pfc.19.2019.05.29.21.50.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 21:50:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bLAFkJTI;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=wNjFOui7vuFEtKzXwg5aNy6ZEm6jbdXBcZyq2T1si6M=;
        b=bLAFkJTIqPVDEut/wCVyU9k9uP9Dw1+jlD0akLvS9pLrMPMZksl5uHLJxCejeJdj27
         fdNCSAOKaQXtEbTCqgxLC96UX8hw8IWJTpfh3VeQscE8J+eOi5A46oWEmZzVDb5gO9Yu
         tv7gM97I5IOUlSQXxfAwAs+GLLp054KalnBrc=
X-Google-Smtp-Source: APXvYqwP1CnFb/IRU8rVAJZSvTa5RJy0wsDR52/J/PPPSfS2jQkTxAG7Qw8Es+UFK9RLME6W5S2T5g==
X-Received: by 2002:aa7:9095:: with SMTP id i21mr156634pfa.119.1559191826897;
        Wed, 29 May 2019 21:50:26 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id w12sm1361214pfj.41.2019.05.29.21.50.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 21:50:24 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>,
	Matthew Wilcox <willy@infradead.org>,
	Alexander Popov <alex.popov@linux.com>,
	Alexander Potapenko <glider@google.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH 1/3] mm/slab: Validate cache membership under freelist hardening
Date: Wed, 29 May 2019 21:50:15 -0700
Message-Id: <20190530045017.15252-2-keescook@chromium.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190530045017.15252-1-keescook@chromium.org>
References: <20190530045017.15252-1-keescook@chromium.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When building under CONFIG_SLAB_FREELIST_HARDENING, it makes
sense to perform sanity-checking on the assumed slab cache during
kmem_cache_free() to make sure the kernel doesn't mix freelists across
slab caches and corrupt memory (as seen in the exploitation of flaws like
CVE-2018-9568[1]). Note that the prior code might WARN() but still corrupt
memory (i.e. return the assumed cache instead of the owned cache).

There is no noticeable performance impact (changes are within noise).
Measuring parallel kernel builds, I saw the following with
CONFIG_SLAB_FREELIST_HARDENED, before and after this patch:

before:

	Run times: 288.85 286.53 287.09 287.07 287.21
	Min: 286.53 Max: 288.85 Mean: 287.35 Std Dev: 0.79

after:

	Run times: 289.58 287.40 286.97 287.20 287.01
	Min: 286.97 Max: 289.58 Mean: 287.63 Std Dev: 0.99

Delta: 0.1% which is well below the standard deviation

[1] https://github.com/ThomasKing2014/slides/raw/master/Building%20universal%20Android%20rooting%20with%20a%20type%20confusion%20vulnerability.pdf

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/slab.h | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 43ac818b8592..4dafae2c8620 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -310,7 +310,7 @@ static inline bool is_root_cache(struct kmem_cache *s)
 static inline bool slab_equal_or_root(struct kmem_cache *s,
 				      struct kmem_cache *p)
 {
-	return true;
+	return s == p;
 }
 
 static inline const char *cache_name(struct kmem_cache *s)
@@ -363,18 +363,16 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 	 * will also be a constant.
 	 */
 	if (!memcg_kmem_enabled() &&
+	    !IS_ENABLED(CONFIG_SLAB_FREELIST_HARDENED) &&
 	    !unlikely(s->flags & SLAB_CONSISTENCY_CHECKS))
 		return s;
 
 	page = virt_to_head_page(x);
 	cachep = page->slab_cache;
-	if (slab_equal_or_root(cachep, s))
-		return cachep;
-
-	pr_err("%s: Wrong slab cache. %s but object is from %s\n",
-	       __func__, s->name, cachep->name);
-	WARN_ON_ONCE(1);
-	return s;
+	WARN_ONCE(!slab_equal_or_root(cachep, s),
+		  "%s: Wrong slab cache. %s but object is from %s\n",
+		  __func__, s->name, cachep->name);
+	return cachep;
 }
 
 static inline size_t slab_ksize(const struct kmem_cache *s)
-- 
2.17.1

