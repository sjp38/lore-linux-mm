Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MISSING_HEADERS,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23F86C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:31:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1D472147A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:31:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pG6EmB4J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1D472147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 694A38E0006; Wed, 26 Jun 2019 09:31:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6443F8E0002; Wed, 26 Jun 2019 09:31:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 533018E0006; Wed, 26 Jun 2019 09:31:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0378E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:31:41 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i196so2526573qke.20
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 06:31:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:cc;
        bh=8bjGnzvOk0trS3dq8ct7j5ULGWMU+cY7HdYXHhHb7Yo=;
        b=XwitDBE3tbWnaWjEkW9CKmawo2aCdWUFZPX5tUz2RC8aPSs7O2Fad1nIuOq/3ih4lQ
         QuTVed1X+Vv550ElKCyoYA46yZz0vbL4Rq+/pDJfsi8DfhUg0OAtmAQt4GYtZcr2YRA7
         L8L84/MFFdMFG+Oc/rUIkJlHRLBY8P5CicnM51lHj+UUCLbR0YopigAEoIWeKmDI5u+F
         yqRPjJv4X1a9O2b0rE/Fb9ZRPt8/sa+44ZYKPx4g9642iAPvlRNg+rLKNYieicHZ08SJ
         Z9jYAz6OHvC8e+bcZL6uiBcfxr96gqHjP0b49Gc4dncjEbMjDFAErhrJ1g96daAbMKMO
         jBXA==
X-Gm-Message-State: APjAAAW54GpVuclra9Ous0vL+Sm0yl6svtTSk4ZOKTeo5nfRGROQo2GC
	YT93JGaymtITSu1Q41L1Hxg5IuVE+zZKalj3yVr/bf0fFkPi2nmvTMsiKnz9xCRMjugYNESbTXn
	l1OJLPRan7s/Du9Y0wycHbHhSQUIwhtf9ckO17nL4C3dRrcKCRk20EoMJrbGTfT64gw==
X-Received: by 2002:a37:be41:: with SMTP id o62mr3942171qkf.356.1561555900858;
        Wed, 26 Jun 2019 06:31:40 -0700 (PDT)
X-Received: by 2002:a37:be41:: with SMTP id o62mr3942120qkf.356.1561555900281;
        Wed, 26 Jun 2019 06:31:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561555900; cv=none;
        d=google.com; s=arc-20160816;
        b=zgtk6Rwy1o2qQmPOofMGlO8ZxXM71DzIc2F3Tgy+DU4+2YfT986FjIB0m7xXrrlftK
         0px3TiPy10aCZbKGt+VBPLnK55f4RnG4yM1agk08qAA61Vd0SWxWtRN2UqsqxzmjQY+C
         ka1ercZSFBmZaQ8LLHuoh9cqS5DceD8R1d06i0w5ESKXG7NipXvvXTZ4RSx4LDCsmmjr
         BfAXyEcflET2A4i6uTb1y3RpZo09z8D9my30sqwTjyL/J6X/85s0KnVk2j2VTZsbrDjj
         LzlfOaUwLwnH+tamA5EkxLgRuXv44BZO750rbSuoaalH8gZHY/L/h2F7wYsUJBZ07TbV
         by2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:from:subject:mime-version:message-id:date:dkim-signature;
        bh=8bjGnzvOk0trS3dq8ct7j5ULGWMU+cY7HdYXHhHb7Yo=;
        b=yQha2ToKrHAibt7lLYpZeiUXzenWCOPuRwXcZJy8TXUg4DQkcZDLWcvVuyKgK4XVBX
         4y5zt1f/ZlyWkocqD03PI7pYQVDrjMju8BGq5ZBZVVeDXYwUwq3R2bSooePj3twoBJ8K
         hIHBUpX3YHxtUWebPLYXEzHnRijZJyxJvEbZpPTHHp9oahKDY6yS+sX+iBmA8qwBw1IH
         fRa5IDWE26GnLgKu4UKXuv5/exD1FB4nm2XKx5dBtKcXPJ4KCKtuaq3JeIdXFShP0V43
         ImVIjYsRlZOSWSw4QpA2jJUtGqGUh6eyu9sl+lxtTQtjiyTbbZo2S+CaCGPThHO/l5ll
         jVSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pG6EmB4J;
       spf=pass (google.com: domain of 3u3mtxqykcn4glidergoogle.comlinux-mmkvack.org@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3u3MTXQYKCN4GLIDERGOOGLE.COMLINUX-MMKVACK.ORG@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c65sor10204184qkd.151.2019.06.26.06.31.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 06:31:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3u3mtxqykcn4glidergoogle.comlinux-mmkvack.org@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pG6EmB4J;
       spf=pass (google.com: domain of 3u3mtxqykcn4glidergoogle.comlinux-mmkvack.org@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3u3MTXQYKCN4GLIDERGOOGLE.COMLINUX-MMKVACK.ORG@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:cc;
        bh=8bjGnzvOk0trS3dq8ct7j5ULGWMU+cY7HdYXHhHb7Yo=;
        b=pG6EmB4JyWmb1xBAf71wnFZRfTMBOLKKP1buQyedLYPmy3OgnfGjTqVah/y+AtnzUe
         1jzOcT03HyL44N/OrE62gMeCUQtoLSFDrD7s1TuFuP271zhW4LyRFKwJ/Xbq+3zimkQA
         0nSmNQEEdyt+sbmYsZ5hDsPQpaMMpXgqy8EATd+ipYF+uBuXUZyQ/GwsXxQ6F8xWyr+F
         GXHXkgB/3KDiH4c6JoGGCcoUarzNKAvKtumFSpKu63NY6oGrEhViKOGhssVsqZCdfmP+
         gY6YK8x40gtSAM3kawrbKEWIChliyTNrWN7l1+2nDdO4oSrmAONs9WdstcaeoyK/+D2J
         6F4A==
X-Google-Smtp-Source: APXvYqxQcn10wQs1sqlKnB2gKgagcYTcFN97IdeWXQoWtcdiXTGMnsrqjypknQqr9cfXU5NWRFOtwZzCCx0=
X-Received: by 2002:a05:620a:1310:: with SMTP id o16mr3746849qkj.196.1561555899983;
 Wed, 26 Jun 2019 06:31:39 -0700 (PDT)
Date: Wed, 26 Jun 2019 15:31:35 +0200
Message-Id: <20190626133135.217355-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v1] lib/test_meminit.c: minor test fixes
From: Alexander Potapenko <glider@google.com>
Cc: Alexander Potapenko <glider@google.com>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, 
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fix the following issues in test_meminit.c:
 - |size| in fill_with_garbage_skip() should be signed so that it
 doesn't overflow if it's not aligned on sizeof(*p);
 - fill_with_garbage_skip() should actually skip |skip| bytes;
 - do_kmem_cache_size() should deallocate memory in the RCU case.

Fixes: 7e659650cbda ("lib: introduce test_meminit module")
Fixes: 94e8988d91c7 ("lib/test_meminit.c: fix -Wmaybe-uninitialized false positive")
Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
---

This patch is relative to the -mm tree
---
 lib/test_meminit.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/test_meminit.c b/lib/test_meminit.c
index 7ae2183ff1f4..62d19f270cad 100644
--- a/lib/test_meminit.c
+++ b/lib/test_meminit.c
@@ -38,15 +38,14 @@ static int __init count_nonzero_bytes(void *ptr, size_t size)
 }
 
 /* Fill a buffer with garbage, skipping |skip| first bytes. */
-static void __init fill_with_garbage_skip(void *ptr, size_t size, size_t skip)
+static void __init fill_with_garbage_skip(void *ptr, int size, size_t skip)
 {
-	unsigned int *p = (unsigned int *)ptr;
+	unsigned int *p = (unsigned int *)((char *)ptr + skip);
 	int i = 0;
 
-	if (skip) {
-		WARN_ON(skip > size);
-		p += skip;
-	}
+	WARN_ON(skip > size);
+	size -= skip;
+
 	while (size >= sizeof(*p)) {
 		p[i] = GARBAGE_INT;
 		i++;
@@ -227,6 +226,7 @@ static int __init do_kmem_cache_size(size_t size, bool want_ctor,
 		if (buf_copy)
 			memcpy(buf_copy, buf, size);
 
+		kmem_cache_free(c, buf);
 		/*
 		 * Check that |buf| is intact after kmem_cache_free().
 		 * |want_zero| is false, because we wrote garbage to
-- 
2.22.0.410.gd8fdbe21b5-goog

