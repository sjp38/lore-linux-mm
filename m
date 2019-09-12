Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B5C5C49ED6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 00:29:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9E312087E
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 00:29:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="emTzcJuX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9E312087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25E566B0272; Wed, 11 Sep 2019 20:29:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20EE06B0273; Wed, 11 Sep 2019 20:29:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1255F6B028B; Wed, 11 Sep 2019 20:29:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0220.hostedemail.com [216.40.44.220])
	by kanga.kvack.org (Postfix) with ESMTP id E10606B0272
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 20:29:35 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5F26E1F23D
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 00:29:35 +0000 (UTC)
X-FDA: 75924385110.06.trade30_1978b0747c30b
X-HE-Tag: trade30_1978b0747c30b
X-Filterd-Recvd-Size: 4072
Received: from mail-pl1-f201.google.com (mail-pl1-f201.google.com [209.85.214.201])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 00:29:34 +0000 (UTC)
Received: by mail-pl1-f201.google.com with SMTP id c14so13009396plo.12
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 17:29:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=M01d621+jXOeVOtLJvHlUCtiCRQEegusNaDlr2i35Sc=;
        b=emTzcJuXyc5nXp177ZHSHM8HRgJfjg3AKpTSMVLcZPdalmHovft+I1D/7rzfw7VwOh
         TlZYaA9+3FzgumZ+RmUsufI0V/n9gzRG3pZXqutN06yAcgJt/SV7SPgcD1uHe1bapO8t
         pcRbfp5fwduu7biTVNP4wRAtinetu06gIfYvCWzh2pfRxUg7mw2sWs5fnqof+qga3iIm
         Or/iDBDSWjDF+sv/XzgUN4QNq3Pw2/2ZKSs8PySJ2YSsGIJb+LAN/tFQRABq8+lH/lGv
         x4yNOaqzuMJa5G2QTcYWyZrq5ba+nKdHTZubsrpCMU3gPreVF2x1MyXKdSdRssDqBoRT
         rkVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=M01d621+jXOeVOtLJvHlUCtiCRQEegusNaDlr2i35Sc=;
        b=Id2hL92sxxjQ8rJ1WEd3/97wrpmDmT5ZccaFldyuSwXVEzvBlhPVehA23ll6lxFVI6
         rJLXMHL6C6ABjfxW+FkeZU7AZ4vRkOtvzOS9f9EO1bpbULnq4QBKDEyFGbkV2CYHnV+G
         xLRhM97adcW7KeDqKl/4UQakwaCVLmQ1A4IAsn81ecFkpyJrsWbkPlDbL8gQFwvzzy5a
         XR2MLp+OUy1d8CrPfgABYe4P91FAuu1mRri9finhJtSbVbEoZgPCrE0hlafSpSlgLi1+
         sFTKbM7gcVjhlkpKfHIeMuM9ztehfMjqGkMFz5wiLxXyduMXX3EfFyiJwYqpvkVt7OnE
         kaug==
X-Gm-Message-State: APjAAAUKI3gX+zbtnpm44Ui1RiOa0QeTgCRWqZ2VIoDiieyynF1yhkRZ
	68hPCgTMNRQ2sXG4sMnC/0qE0VQbhCE=
X-Google-Smtp-Source: APXvYqxShYmRyX+l6llhto+SBqnYvELJgOERr5ICSUVl9FZCgvwep6WW53CesQ7KOZtdnfKF0jdq059FEGo=
X-Received: by 2002:a63:3009:: with SMTP id w9mr36922043pgw.260.1568248173618;
 Wed, 11 Sep 2019 17:29:33 -0700 (PDT)
Date: Wed, 11 Sep 2019 18:29:27 -0600
In-Reply-To: <20190911071331.770ecddff6a085330bf2b5f2@linux-foundation.org>
Message-Id: <20190912002929.78873-1-yuzhao@google.com>
Mime-Version: 1.0
References: <20190911071331.770ecddff6a085330bf2b5f2@linux-foundation.org>
X-Mailer: git-send-email 2.23.0.162.g0b9fbb3734-goog
Subject: [PATCH 1/3] mm: correct mask size for slub page->objects
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


