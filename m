Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0ACBC606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:08:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D210216FD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:08:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wOdsIHVM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D210216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 424308E0022; Mon,  8 Jul 2019 13:08:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FC888E0002; Mon,  8 Jul 2019 13:08:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3156C8E0022; Mon,  8 Jul 2019 13:08:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 139AC8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:08:59 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v4so16949735qkj.10
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:08:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Hwhk1enE9nNmmHHJ9NMKEqUFLaBrzoJTEH+x5otTjag=;
        b=fUSiGsF32vxTQxSxVaN6dHIdSpdO045LKClpTVRCVdf74U5jgkX8/r7+y6H4hl0wNQ
         2i2t8+CZkmwZBbv76pmP281hYNL9NjD/fTLnPeCSZ0HORvx6ze/q2GawibJ3gZVgpi2J
         9Z6QmgAqyu3koycSeIIoaiGP94cI5QqfLcyas+0j2iQjeWUGUotto4TmpAdYT9BeeAya
         VKXKQ7cEREjveNH7gsTx+o/hNHIWNueALxx75pUNxd7hlk5EGyNYdXnFAiJyuAQNuVqX
         dVI/wS1Ft2KTEAzFHTHyFmTk4d4TsbEEK3PM6As4pg8DiFj/sW4ixgp80yfI7NllplY0
         4tWg==
X-Gm-Message-State: APjAAAUKL70wfRlLl4/zy4jBqkTtbPLUbLgiN2nRTv2llxgIdQA3Fx38
	wHfZ2x3RJRYtAEGeZX8bhlJ3L6QYab8ypTBlv+XlH3X84RPHOzWaV1kBELX6rP4asPiwBRcy/Up
	MnpTPwKGGRaZSW+3ZhN2/NjMqVcODOOH3vIFynALctrBhCh4NQ0zpyMhYrH5V44SieA==
X-Received: by 2002:aed:3a24:: with SMTP id n33mr14789318qte.361.1562605738811;
        Mon, 08 Jul 2019 10:08:58 -0700 (PDT)
X-Received: by 2002:aed:3a24:: with SMTP id n33mr14789277qte.361.1562605738209;
        Mon, 08 Jul 2019 10:08:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562605738; cv=none;
        d=google.com; s=arc-20160816;
        b=wukoT6ZU7xqj9mnX9uguw/0hKw/f5D7OMy1QUwxt7vQlgc6ksVg5HKTxVT53l1IKHg
         MPIPw1+ghi/7+7jtxgJtJwW9FWwhgw+Yk3MNDxq20xie6MAuuoEQATiNyq14kmK2Sjvk
         C8qMbvyi6AoJdcT+qlCxwMZYLNxlBsRJVxcx8Nw2zcMtxn68xuSkuUfplYdDh5AQYkXB
         qYrTdRa2X2YEjlziSrRx8LjW6Jjv/dX8X3kMsiD1AYA/OXB5KQjQ2x1mNVAhTO45c/+Q
         SN8F6EuCxJmPCm0PbL5p7+plnpmlFvBN9X+uz/d3RC4qxbLDfkOUaZ568/Vzo54bu55f
         TiNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Hwhk1enE9nNmmHHJ9NMKEqUFLaBrzoJTEH+x5otTjag=;
        b=IBWMzJu2Udf52gAtVwK1/boGyHNYud+7tc05mndK/n6BQ2OEadQOww1XD/z2vNvuwp
         EMAvufAXrTV/Fvp6r+V6SpiugV9MK876qeZZFvqQFFDKeCWV0okM/nUZKcMXrFycw+bt
         dusPkZvBPMa4Ap010cjdIcGhuFwC4pDRR0L1323Wd5ReZ/hh7itG7+oDM7VAftjJoAFX
         vF6Bo78Hy1lPbs3WVch9UEvMKrP5YWVDZugQQaqWpnr7t++EuRiePZjC5y2yD9WbDIhM
         iLrqdP4kIUAOLvGMNMM+EfOtW399KS0P1UhrUa521OM4KSW+es4VYXP8+SfUQ42afNWK
         qk8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wOdsIHVM;
       spf=pass (google.com: domain of 3qxgjxqukcbg29j2f4cc492.0ca96bil-aa8jy08.cf4@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3qXgjXQUKCBg29J2F4CC492.0CA96BIL-AA8Jy08.CF4@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k5sor23508489qtp.61.2019.07.08.10.08.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:08:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3qxgjxqukcbg29j2f4cc492.0ca96bil-aa8jy08.cf4@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wOdsIHVM;
       spf=pass (google.com: domain of 3qxgjxqukcbg29j2f4cc492.0ca96bil-aa8jy08.cf4@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3qXgjXQUKCBg29J2F4CC492.0CA96BIL-AA8Jy08.CF4@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Hwhk1enE9nNmmHHJ9NMKEqUFLaBrzoJTEH+x5otTjag=;
        b=wOdsIHVMZamkOSYuWNiQFHyAqqlxUMC9zzgAfqihPagHPuNYqfImiffF9t9yl+cgN2
         FPO8yjuPBzh/cfI4a1HrVyKbDJNfD4KrSCxvHyuvK/AbBqouiF1uRJTO1HwPpEuIyFcx
         AJc3IVdMD8Qt8q5nf8e66WhTsJDBCW1aZOkRPP2tLJs1xVqhzSoOWpFmRPQrjzjwxWtM
         H/HV/bEP6ByYcFCoS52/X+xSXFdBum+Qdxno/6mk/WKN618Yc9OPo5Asuos1EpFJb+oD
         oIN2XuhitBq1hb5zsTPK1rUZes7bC8iFz/W3aHiaBjRlbpeJjT9aX2btjK5cntLk6L6g
         GJLQ==
X-Google-Smtp-Source: APXvYqzqzU+7VOFTLnajYW2WtzqGbE36eBpzdkyAewvRtPAu/83hx5E2taIq76Yx29VuC7PM2wMXFbOWfQ==
X-Received: by 2002:ac8:32c8:: with SMTP id a8mr10978860qtb.47.1562605737784;
 Mon, 08 Jul 2019 10:08:57 -0700 (PDT)
Date: Mon,  8 Jul 2019 19:07:03 +0200
In-Reply-To: <20190708170706.174189-1-elver@google.com>
Message-Id: <20190708170706.174189-2-elver@google.com>
Mime-Version: 1.0
References: <20190708170706.174189-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v5 1/5] mm/kasan: Introduce __kasan_check_{read,write}
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Alexander Potapenko <glider@google.com>, Andrey Konovalov <andreyknvl@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Qian Cai <cai@lca.pw>, kasan-dev@googlegroups.com, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This introduces __kasan_check_{read,write}. __kasan_check functions may
be used from anywhere, even compilation units that disable
instrumentation selectively.

This change eliminates the need for the __KASAN_INTERNAL definition.

Signed-off-by: Marco Elver <elver@google.com>
Acked-by: Mark Rutland <mark.rutland@arm.com>
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
Cc: Qian Cai <cai@lca.pw>
Cc: kasan-dev@googlegroups.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
v5:
* Use #define for kasan_check_* in the __SANITIZE_ADDRESS__ case, as the
  inline functions conflict with the __no_sanitize_address attribute.
  Reported-by: kbuild test robot <lkp@intel.com>

v3:
* Fix Formatting and split introduction of __kasan_check_* and returning
  bool into 2 patches.
---
 include/linux/kasan-checks.h | 25 ++++++++++++++++++++++---
 mm/kasan/common.c            | 10 ++++------
 2 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
index a61dc075e2ce..221f05fbddd7 100644
--- a/include/linux/kasan-checks.h
+++ b/include/linux/kasan-checks.h
@@ -2,9 +2,28 @@
 #ifndef _LINUX_KASAN_CHECKS_H
 #define _LINUX_KASAN_CHECKS_H
 
-#if defined(__SANITIZE_ADDRESS__) || defined(__KASAN_INTERNAL)
-void kasan_check_read(const volatile void *p, unsigned int size);
-void kasan_check_write(const volatile void *p, unsigned int size);
+/*
+ * __kasan_check_*: Always available when KASAN is enabled. This may be used
+ * even in compilation units that selectively disable KASAN, but must use KASAN
+ * to validate access to an address.   Never use these in header files!
+ */
+#ifdef CONFIG_KASAN
+void __kasan_check_read(const volatile void *p, unsigned int size);
+void __kasan_check_write(const volatile void *p, unsigned int size);
+#else
+static inline void __kasan_check_read(const volatile void *p, unsigned int size)
+{ }
+static inline void __kasan_check_write(const volatile void *p, unsigned int size)
+{ }
+#endif
+
+/*
+ * kasan_check_*: Only available when the particular compilation unit has KASAN
+ * instrumentation enabled. May be used in header files.
+ */
+#ifdef __SANITIZE_ADDRESS__
+#define kasan_check_read __kasan_check_read
+#define kasan_check_write __kasan_check_write
 #else
 static inline void kasan_check_read(const volatile void *p, unsigned int size)
 { }
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 242fdc01aaa9..6bada42cc152 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -14,8 +14,6 @@
  *
  */
 
-#define __KASAN_INTERNAL
-
 #include <linux/export.h>
 #include <linux/interrupt.h>
 #include <linux/init.h>
@@ -89,17 +87,17 @@ void kasan_disable_current(void)
 	current->kasan_depth--;
 }
 
-void kasan_check_read(const volatile void *p, unsigned int size)
+void __kasan_check_read(const volatile void *p, unsigned int size)
 {
 	check_memory_region((unsigned long)p, size, false, _RET_IP_);
 }
-EXPORT_SYMBOL(kasan_check_read);
+EXPORT_SYMBOL(__kasan_check_read);
 
-void kasan_check_write(const volatile void *p, unsigned int size)
+void __kasan_check_write(const volatile void *p, unsigned int size)
 {
 	check_memory_region((unsigned long)p, size, true, _RET_IP_);
 }
-EXPORT_SYMBOL(kasan_check_write);
+EXPORT_SYMBOL(__kasan_check_write);
 
 #undef memset
 void *memset(void *addr, int c, size_t len)
-- 
2.22.0.410.gd8fdbe21b5-goog

