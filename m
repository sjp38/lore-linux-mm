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
	by smtp.lore.kernel.org (Postfix) with ESMTP id B545BC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B2E6204FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bEoviPlE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B2E6204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A9268E0007; Wed, 26 Jun 2019 08:23:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 280948E0002; Wed, 26 Jun 2019 08:23:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 170718E0007; Wed, 26 Jun 2019 08:23:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA7398E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:23:17 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t196so2379893qke.0
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:23:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=XRvnKModUVHTmFHrHwuo1MwyIF32UbSI8S8OvJKLAFg=;
        b=ANG3GLgOIJ4kGdCxkhSJP7cIxn+XEWl0Jf8DxAOUhr09xXESYoACRAtYX6uA24yNpi
         nXt0L8YFEDeReCWVZU9jWf5mR9ygr/pxwZw1hPBFfbaw7R3sMLMd865a7TagAFWX9dvd
         ZRbr8iXAB+FBFj0m2BXKVrddlUObVHojltyzHV7U2urOQ6B5Cj+an7BpB9l5RbQ+p4MN
         M+eM806TDxbjl/1fEtfz54/8djGw8k8N9fEKS1MH6CmuIb51Ngu8dLyTLQAXKdqa7Nta
         Qqg031sOOowojYwzYEDViBPpyYLV4VRJSI5DuEwmr53+nOqtsRFJDZLu18sSROq0tU6J
         U8Jg==
X-Gm-Message-State: APjAAAWPoAotxeXO9yFALRZaoSjJCsuyWSjkUDbp/2Y8RdhwmCB3wH59
	loX50jirhORkdEBuwTGX2tMMwKH3UHepuOWBRC+mLNTyE4XV884tZfmiL4iHv1Yu8YZnr5Bu83t
	RUF1wycmmFIIkriQOvwU8nqrb4sXCb5spve/RwFXub2I8M5TROggQd3vREHYS2+EIuw==
X-Received: by 2002:aed:254c:: with SMTP id w12mr3594919qtc.127.1561551797759;
        Wed, 26 Jun 2019 05:23:17 -0700 (PDT)
X-Received: by 2002:aed:254c:: with SMTP id w12mr3594887qtc.127.1561551797293;
        Wed, 26 Jun 2019 05:23:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561551797; cv=none;
        d=google.com; s=arc-20160816;
        b=yjOdG9nJXYmoW0xbxBob6QJlrfOktZPz0ppvNgJW4zAAYVifGn9yxqXfpQuuEGaaNP
         n+AQpq7rCHkCslWNySB09sr11x3n1aTFCoZOIJKcepxiEdvvUeVN/tRZ5fs0q7+jxfOg
         qlgMbCq5DOpbJSC/OeNJ2eVEULcO42+hCNU9zGC/JBgAs7IUfLHPcuc3H33UCO/GNcrn
         MpFg4xvTjNgn8LXZoAqA99XhLPxMTddZf7z6gQaQHORYG7CsUC4R7Q/9sKcF/DqrGo+P
         rlENh8UXy3UUcoopWnzBtTqKQ0SErhIO+tNydHsx4anI3+i1qRcjtpvYByEZH1UON2cV
         lKxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=XRvnKModUVHTmFHrHwuo1MwyIF32UbSI8S8OvJKLAFg=;
        b=Yt0DDaLXE3Q9v10G3YL2v0En3kDVhZ2DLAu8OB0vqGkNZ0vG/z11aPfucV6D4QFeT0
         yQNWlx3QlAxiaFnUTQn31V51lglxWw23Y7OUp9m5AqzpJ/Ht3Tb3qT3Axlk8YmiFoHaR
         c/mYUBZfTeYfRohF5XZnBPeWiVVnRA41uJoBvRvfLNQKZtSneGHUsXdX3xhbRgh1ZV9E
         jEijp10XMGe5kksCKERO2I/NEi7V8Ztn+ocsg0heEMU45+GHUKbKpj+DuL1NDDFKdbe6
         /goSxTvO6juCZJcEVuccFzT4KrVFa7sq/Lbbth5it2Zy/2Hfh1Xs0JX30MAY02Nl88Xj
         rbnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bEoviPlE;
       spf=pass (google.com: domain of 3tgmtxqukclcbisbodlldib.zljifkru-jjhsxzh.lod@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tGMTXQUKCLcbisbodlldib.Zljifkru-jjhsXZh.lod@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id u36sor15088087qvg.34.2019.06.26.05.23.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 05:23:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tgmtxqukclcbisbodlldib.zljifkru-jjhsxzh.lod@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bEoviPlE;
       spf=pass (google.com: domain of 3tgmtxqukclcbisbodlldib.zljifkru-jjhsxzh.lod@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tGMTXQUKCLcbisbodlldib.Zljifkru-jjhsXZh.lod@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=XRvnKModUVHTmFHrHwuo1MwyIF32UbSI8S8OvJKLAFg=;
        b=bEoviPlExN6sDh8KZFRQ1yCXcZkyNNLzW3u1pAVA2H1orVPnCYqlhFimU4rLGIWu1f
         CJpOGN2nBuRm6aQ1agx42bRuCEsvMeS+lSGPOVCQj83C+TNfcSHS6b2Q9MsbfNJHxa4b
         gl8xVU7JgPgG0I+Idoe82XDGV7mWty68PWMWXPDSHvW+eZwnURw531ZE7Ph55/H3ZEz8
         LkKIW3ZgaUPS+I6NBRIMeSLBUT/MyQcadnDaa6eKlh1dKhvqdg0M0hkmoiwKNWT8b2oz
         r9Tq8XeSManWCswYnmY3NMckuTA9wL4+t5btPnUG6Uy+XvcGYD+kTQy2Dq6NB5BUq40T
         /i7g==
X-Google-Smtp-Source: APXvYqyIgp9AlDPLRM1loC21o7i15mfv90NTnLoH2+tcZhHtyFvzp4P95svuux+9O3VuzMVNE7vsIN1kvw==
X-Received: by 2002:a0c:d604:: with SMTP id c4mr3199153qvj.27.1561551796862;
 Wed, 26 Jun 2019 05:23:16 -0700 (PDT)
Date: Wed, 26 Jun 2019 14:20:17 +0200
In-Reply-To: <20190626122018.171606-1-elver@google.com>
Message-Id: <20190626122018.171606-3-elver@google.com>
Mime-Version: 1.0
References: <20190626122018.171606-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v2 2/4] lib/test_kasan: Add test for double-kzfree detection
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

Adds a simple test that checks if double-kzfree is being detected
correctly.

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
 lib/test_kasan.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index e3c593c38eff..dda5da9f5bd4 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -619,6 +619,22 @@ static noinline void __init kasan_strings(void)
 	strnlen(ptr, 1);
 }
 
+static noinline void __init kmalloc_double_kzfree(void)
+{
+	char *ptr;
+	size_t size = 16;
+
+	pr_info("double-free (kzfree)\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	kzfree(ptr);
+	kzfree(ptr);
+}
+
 static int __init kmalloc_tests_init(void)
 {
 	/*
@@ -660,6 +676,7 @@ static int __init kmalloc_tests_init(void)
 	kasan_memchr();
 	kasan_memcmp();
 	kasan_strings();
+	kmalloc_double_kzfree();
 
 	kasan_restore_multi_shot(multishot);
 
-- 
2.22.0.410.gd8fdbe21b5-goog

