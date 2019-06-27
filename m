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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22AEBC48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D541520843
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dTAP9e+5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D541520843
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85E268E0005; Thu, 27 Jun 2019 05:45:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E80C8E0002; Thu, 27 Jun 2019 05:45:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AEE08E0005; Thu, 27 Jun 2019 05:45:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 495858E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:45:08 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b75so2391233ywh.8
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:45:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=M/VKnz1BZ+rvrIeSdLI9RxXAlLGL/xX/aFhsrhXW1SI=;
        b=GZlCFvIY0qJMy+q0DogyyfdI48HuIjjAI0iR+ZdUTzrsbpd7tngrwLs9+0szmM5AbF
         5zDP5ehst0KJbAbG2xmixCq2dVuBgcEKT6gEI807XUzHSEEt/nAHzKiG1t8pI4oksR32
         7affOpRDiHKlojQP2NDg+g38M/PmrF0mNQO2EajD/EfU9CG1DLEELS40b2nMSNAAVCFN
         CAsX6EI6SBdjKKpTBQBIho5USWsLML3XDQOH2dF3OPdtiRD39KTgGQDC4oAxJ4P634gu
         anbmsJwpC3Wo1NLToEW0fhnMRSipNJo0yY3FhKR+siUcuz79xHaF11kQWr3nLlDl1+IX
         S1cg==
X-Gm-Message-State: APjAAAU3Wia3SjshqXhs+vQPIHkOOnANwHwK+BE8bPvd+PyhUqXwirGR
	7IgRjGhWQ1Qj9aY+qR8rXE+nh8/0Z13EYkJFNVSnINbCLpH10oDxJqeqZvDPIdnvBXEw63FEf3R
	W8wh7op0U/W/UOTzOWePH31dGDJcD7s9USJn0/mLyFLo30Uj+RLfXJFImX/NTyAQokw==
X-Received: by 2002:a81:32cc:: with SMTP id y195mr1665062ywy.195.1561628708026;
        Thu, 27 Jun 2019 02:45:08 -0700 (PDT)
X-Received: by 2002:a81:32cc:: with SMTP id y195mr1665040ywy.195.1561628707474;
        Thu, 27 Jun 2019 02:45:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561628707; cv=none;
        d=google.com; s=arc-20160816;
        b=M9J460MRoxrrw2wtC31V9iHh9M0hDJcPlgRfGqi3ZbfCC8xoy0501RavMiUNA4+yJG
         PBb+0EYuDlYpttkA1piG0c3NCwSVKb8nCjOHo8K6lA+X1DI9EoDncuSfmJgOW16WUwui
         TLjPCUvYwrjQH+02+zw8MtXq+BNhtvVOcB5bJEa4szlZTiZmuPhtnr/JGGxM0Sf94V4P
         UAMAjJ+BDxY/CSXF6363GMbMrhjHbdTtuOPPn21qpapBUOe5AA+zSy7bSutIjUNyY0Km
         hBgc1Ka2NKdgFNEZG0ezNjZbitVVup6rYfrM7Y6qbLTrO8MOHaHMoiHXFw1mYqh8oWif
         caiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=M/VKnz1BZ+rvrIeSdLI9RxXAlLGL/xX/aFhsrhXW1SI=;
        b=B82dsaSDWwjlQ7cUasp7mBvDOL2GvDvgz8E8BPt75Xjp42iRNVT+aGrT772Oy6Z5jT
         Z6UN/NPKzSKar3DVfLXtP2jzLB0yCU2KVyIC/DfAgSXE4pCN/pUK6f2/LhhvX/bqG3H1
         fthJBTnDBH4LeU0dyllL+r8wCp4uC/F1UAjoGgXHAD5h9BLXSZbmoZNFaA34gOj9tNDb
         yC4hTtVCmh4gIq/s+9SGJQMZOs8NLpeEB1JWLcmiFVEp5mvDYYlHMvPx0CMgLpESBwtj
         sOEjZXma9tJ0C5wczI40HfZFdk38f5dWSGypK3z8y1zRH1KsTjQFO3OE2gs1LYGp94N6
         ObnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dTAP9e+5;
       spf=pass (google.com: domain of 3i5auxqukciqmt3mzowwotm.kwutqv25-uus3iks.wzo@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3I5AUXQUKCIQmt3mzowwotm.kwutqv25-uus3iks.wzo@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i2sor900193ybe.188.2019.06.27.02.45.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 02:45:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3i5auxqukciqmt3mzowwotm.kwutqv25-uus3iks.wzo@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dTAP9e+5;
       spf=pass (google.com: domain of 3i5auxqukciqmt3mzowwotm.kwutqv25-uus3iks.wzo@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3I5AUXQUKCIQmt3mzowwotm.kwutqv25-uus3iks.wzo@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=M/VKnz1BZ+rvrIeSdLI9RxXAlLGL/xX/aFhsrhXW1SI=;
        b=dTAP9e+5cBvv1Fo1c9oAD6aT20tqv+ChITGWRAF6HBiV5h0A+cO/d3KW6e6bRHVLvG
         erLpdzNSnYBWnXbAlgOzQFymT1RWKDmLZwiJCIyx5PA/T5+1nmvNYgry/XQOnex69Uea
         jLWyToIrNx+PALPXS8zNvel0xSO6hmvfK2MHgRt7K1Dg/Km/TDLdJyfh4ZuBoL8aesNf
         rP3byfY8etaRRTUkuV1C1fUePUu4HjWIwxb3m+dYD8C+9D8ehGOQgMUHAYSQ4UddPvSk
         X3I0Blgf/z4Y6ytZeUMR5341999h9I4nU/8ggy7lRN8zBnWCOozRTxNtCa9uC6mOwamd
         m3Nw==
X-Google-Smtp-Source: APXvYqyrysKf0nY6MA4eBDonEeUr1VDkNdQueTw63xxmxnWHB5Hteblcrv3Ft6+bD+my9MMcpuiIIfeGYQ==
X-Received: by 2002:a25:c4c4:: with SMTP id u187mr1928035ybf.185.1561628707099;
 Thu, 27 Jun 2019 02:45:07 -0700 (PDT)
Date: Thu, 27 Jun 2019 11:44:41 +0200
In-Reply-To: <20190627094445.216365-1-elver@google.com>
Message-Id: <20190627094445.216365-2-elver@google.com>
Mime-Version: 1.0
References: <20190627094445.216365-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v4 1/5] mm/kasan: Introduce __kasan_check_{read,write}
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

This introduces __kasan_check_{read,write}. __kasan_check functions may
be used from anywhere, even compilation units that disable
instrumentation selectively.

This change eliminates the need for the __KASAN_INTERNAL definition.

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
v3:
* Fix Formatting and split introduction of __kasan_check_* and returning
  bool into 2 patches.
---
 include/linux/kasan-checks.h | 31 ++++++++++++++++++++++++++++---
 mm/kasan/common.c            | 10 ++++------
 2 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
index a61dc075e2ce..19a0175d2452 100644
--- a/include/linux/kasan-checks.h
+++ b/include/linux/kasan-checks.h
@@ -2,9 +2,34 @@
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
+static inline void kasan_check_read(const volatile void *p, unsigned int size)
+{
+	__kasan_check_read(p, size);
+}
+static inline void kasan_check_write(const volatile void *p, unsigned int size)
+{
+	__kasan_check_read(p, size);
+}
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

