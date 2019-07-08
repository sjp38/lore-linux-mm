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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AD9FC606C2
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:09:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7A1F21479
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:09:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PgglRjVj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7A1F21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 907B48E0024; Mon,  8 Jul 2019 13:09:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B7448E0002; Mon,  8 Jul 2019 13:09:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A52B8E0024; Mon,  8 Jul 2019 13:09:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58D0A8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:09:05 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id t18so7276671ybp.13
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:09:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/Bjb3ErsQTLw+YrlSLkjBcr6K+fvu3f9fORDBwR/vbU=;
        b=WgLhQpz1bw5GU+Lv6x36GlyPCp/adnDxCyo0a/a2fVJIWZxBAmWdJxdMfO2kY44/qf
         4FUvJRQ059Rv2z6Q3WjK6L+OrzOSqj7DHAzP5EgoCGujTS8Wg3sV6NMXA22RpBDyAMR4
         nu0Sy9/aEkINwR6HPtVh8hMo/9z29fRnPeSUzieAyAprLqI5PuXGGZjqXoZpoUdUn9jS
         SRa1gCObt4jaAGfyegp5AZJ7aIZnBW953uOlbaJaiD7JFb4dCZ5m5E//i83S1XQfKYRN
         WaYD+MKPUYfOxqcIGOEyKTfYYoKvRzJAKA49RCDMLfyrj1gH84U0RHwLaJc4tAGZih7N
         xN2A==
X-Gm-Message-State: APjAAAWr2gLTFOs8igBQkI56+sj+H1oMAkl1ST7ZVZxgKkTSE4Edv+1n
	0YNoJEggha1Prn1F59/Gk0MZKx+Atgxxt4biWZ85CGKqw1omI8UlpL6eLgmaWLgCjBfHBF8fN0z
	Sg/QGaQhC9YISBfRqHsKzWb2x78Xwh3bWi1l8andQXgzdaPGV2pAt2B7t/AAG+a0qRw==
X-Received: by 2002:a25:488:: with SMTP id 130mr11814132ybe.67.1562605744961;
        Mon, 08 Jul 2019 10:09:04 -0700 (PDT)
X-Received: by 2002:a25:488:: with SMTP id 130mr11814098ybe.67.1562605744385;
        Mon, 08 Jul 2019 10:09:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562605744; cv=none;
        d=google.com; s=arc-20160816;
        b=1DDWmQ94BSFdyk19uezxySj4+Pa6XispupQZQI3K5huuwTSF4DLZnvE35o6J1ix9aY
         vLwbz5PDGcDpRw1FsGheY4qmyr35nT0AVQMiFwDsL2vFY4oTxOIkL7OoYZIYCEEzya+7
         mB952Qaa0nJjrfxv8evrsFotGIsHDS59ZPxB493/+bIXL3duK2He/VPm7EpqIXN91Oty
         RlUZByEOvsgUdpuOtHvyh/vUppN7ZbAivytDUMtbrvqs+30csCgnF/vc4/1R5v24R8HY
         Y0rknDhggTwFJQ4gbvGZHbkQl8EAgbYsP7KU4IVw9F7leZFq9UYZFJj/7/yeq6/SBpzZ
         /c/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/Bjb3ErsQTLw+YrlSLkjBcr6K+fvu3f9fORDBwR/vbU=;
        b=JNwyfDgSTmhAWhxCLAPdub45xw2Skn4EjgO2jjzCGWXgD6aZnxrv9rhiUYMXI27Y/g
         NG/11LmZqwZ8SD95zAIHJQ02VS5rC/tBvm06AgCDKrSwGv7GrCQX3BhycZANGauNAThB
         J2BcATdALt9oFqJRVjpSCvP2i4n300ur/BQZUcvkBrKkETzyJHwFNN6pMa2HC1Q+Wj4N
         XvNfsvgDtRR/0PVaPMOe40IZPq2mDqD4KSSYqvKZAOCaCzjxoMldTxdXHUhLOTtX4lBM
         JXrN5kuDNJM1B3drXTfMz8EZe2Es9WBT/z8jj0G3F6IHYbFVEENE+u8ccIZ0xaEu3Tzt
         PWuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PgglRjVj;
       spf=pass (google.com: domain of 3r3gjxqukcb48fp8laiiaf8.6igfchor-ggep46e.ila@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3r3gjXQUKCB48FP8LAIIAF8.6IGFCHOR-GGEP46E.ILA@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e3sor9865896ywe.143.2019.07.08.10.09.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:09:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3r3gjxqukcb48fp8laiiaf8.6igfchor-ggep46e.ila@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PgglRjVj;
       spf=pass (google.com: domain of 3r3gjxqukcb48fp8laiiaf8.6igfchor-ggep46e.ila@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3r3gjXQUKCB48FP8LAIIAF8.6IGFCHOR-GGEP46E.ILA@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/Bjb3ErsQTLw+YrlSLkjBcr6K+fvu3f9fORDBwR/vbU=;
        b=PgglRjVjhE72uthaYPgUkIA+L8Ic1IQKCjcb8XRTj87DCO10kaCcE306+6CbVNMvau
         SM1ka9Ic90hEIZxLQuIrW1jY3Vm6ESsEkj4IYF0TQ3+Fb38HOfRfZ6jc+goC1Vp402VA
         kMjKtNquIeLszR/h3t7e1dLItihhLNJ7YiN1g5fRoFKUsgOzwMwZ8toOK/16ArpBe9tF
         grBf339F217k5k/S6+fB3KbnXoO2Q0m6y/mS9TLUd2/nhXEGmHLG7x/xDi7tzYoCXGpA
         afNpmmQHXf9ZbTj7qJiAD426/t1VpxFKdDNos9FKE3egTSIsrvnwFas4LujNH5/S9+iA
         q5IA==
X-Google-Smtp-Source: APXvYqxP+FPSf7rO7/ibi5Fz8cPbpk061VoEiwZkeVQq8DuTHnSF07hV2+HQ/wDAVE8vywm9H1aztfDkIA==
X-Received: by 2002:a81:a95:: with SMTP id 143mr12306291ywk.279.1562605743974;
 Mon, 08 Jul 2019 10:09:03 -0700 (PDT)
Date: Mon,  8 Jul 2019 19:07:05 +0200
In-Reply-To: <20190708170706.174189-1-elver@google.com>
Message-Id: <20190708170706.174189-4-elver@google.com>
Mime-Version: 1.0
References: <20190708170706.174189-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v5 3/5] lib/test_kasan: Add test for double-kzfree detection
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
Cc: Mark Rutland <mark.rutland@arm.com>
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

