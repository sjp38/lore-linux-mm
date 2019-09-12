Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2A22C5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:31:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E7992082C
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="POAOLSgR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E7992082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2E8B6B0003; Wed, 11 Sep 2019 22:31:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B052E6B0005; Wed, 11 Sep 2019 22:31:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F52D6B0006; Wed, 11 Sep 2019 22:31:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0203.hostedemail.com [216.40.44.203])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC3B6B0003
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:31:16 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 23B58824376D
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:31:16 +0000 (UTC)
X-FDA: 75924691752.01.music96_453af081ca33b
X-HE-Tag: music96_453af081ca33b
X-Filterd-Recvd-Size: 4025
Received: from mail-pf1-f201.google.com (mail-pf1-f201.google.com [209.85.210.201])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:31:15 +0000 (UTC)
Received: by mail-pf1-f201.google.com with SMTP id f2so17204283pfk.13
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 19:31:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=M01d621+jXOeVOtLJvHlUCtiCRQEegusNaDlr2i35Sc=;
        b=POAOLSgRgwPfDzOISo1MKH/2QLeqTomKY/wS1QotRgVb+fnKfk6pEqTsN/5no3Yb3S
         Q5gAVgxxV+ZQKy+l3JYU/B1KiQJSM9FrAz+2rSwbmQm+8ozbJxvc6yf9QD2AWui2kVQF
         IHnCKQWi3MGZhSBAFzveRDOPGWpx/LU/lf39HC0SpCVhsnAg+l9peNmmIjSehuOq1RVW
         M/MRonGRnTVovm/fmrHgANDs4dtA5VQw1clG8EniSSFxLN36ZtbuwWeoVt164qoMELUZ
         X/rjZ1tQSHJA/LTXAUcXSM2SQMofSmH/P5odvUxHBR6hhvJsflCDHFpxxx5hCHaSOMcp
         tEvw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=M01d621+jXOeVOtLJvHlUCtiCRQEegusNaDlr2i35Sc=;
        b=eHQTctRjdico+T8g5+x7Pla0dR01J5JC/+J7E8G+d0R4q/NGbWoP3H2c6QqJ4w35AY
         FFRbvHqA27qpv6hzo9Ci8mNBkmEZSMK0zBPdj8yceq+/4gPVduoJroLs/xfAvErbbuiL
         VoA/I3IP8rY4cqxnRN+dHZPxeTiktqnK0ku3SiWtIAfgH5I+QTLnQHyuxkmsfa89/qWs
         uAnPRncuT+V1AzfRclV1lUW7ckCmvqRYuqQo3sOVGkTTf24ZRWnMWnt1USUgqGrvhvg5
         3qVMe8qX2CG/RKgs29PDZHy8TNNFGRJwoiJvuzQMZLWxDWMu1V2MPTfAISgLQFyVFlqN
         t54Q==
X-Gm-Message-State: APjAAAUzuiagoyqhlMSt6SUNQjf+QG22wIvo1CqhIQXgoZ3rV8zVR6Qc
	Ej9DGj1/MAuNJZC+tDzTmNcxbXlRZ5E=
X-Google-Smtp-Source: APXvYqyWlP3NAwE+jBFawlowdpRiaR5zP9SQNymsUcqOg03NykdEEjCnMCVUr+qahjil0jS9sKtiPxp+PvI=
X-Received: by 2002:a65:6546:: with SMTP id a6mr36882579pgw.220.1568255474084;
 Wed, 11 Sep 2019 19:31:14 -0700 (PDT)
Date: Wed, 11 Sep 2019 20:31:08 -0600
In-Reply-To: <20190912004401.jdemtajrspetk3fh@box>
Message-Id: <20190912023111.219636-1-yuzhao@google.com>
Mime-Version: 1.0
References: <20190912004401.jdemtajrspetk3fh@box>
X-Mailer: git-send-email 2.23.0.162.g0b9fbb3734-goog
Subject: [PATCH v2 1/4] mm: correct mask size for slub page->objects
From: Yu Zhao <yuzhao@google.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mask of slub objects per page shouldn't be larger than what
page->objects can hold.

It requires more than 2^15 objects to hit the problem, and I don't
think anybody would. It'd be nice to have the mask fixed, but not
really worth cc'ing the stable.

Fixes: 50d5c41cd151 ("slub: Do not use frozen page flag but a bit in the page counters")
Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/slub.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8834563cdb4b..62053ceb4464 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -187,7 +187,7 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
  */
 #define DEBUG_METADATA_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
 
-#define OO_SHIFT	16
+#define OO_SHIFT	15
 #define OO_MASK		((1 << OO_SHIFT) - 1)
 #define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
 
@@ -343,6 +343,8 @@ static inline unsigned int oo_order(struct kmem_cache_order_objects x)
 
 static inline unsigned int oo_objects(struct kmem_cache_order_objects x)
 {
+	BUILD_BUG_ON(OO_MASK > MAX_OBJS_PER_PAGE);
+
 	return x.x & OO_MASK;
 }
 
-- 
2.23.0.162.g0b9fbb3734-goog


