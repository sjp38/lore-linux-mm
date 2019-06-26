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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B102C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:28:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19720216F4
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:28:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="b1IaFK1m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19720216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A89ED8E0012; Wed, 26 Jun 2019 10:28:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EBB98E0002; Wed, 26 Jun 2019 10:28:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88B7F8E0012; Wed, 26 Jun 2019 10:28:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 517BE8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:28:01 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e95so1538440plb.9
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 07:28:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Rln2FP6BOxdiVf8wORphr5UbX/lGN9PNgnvsQm0pxfA=;
        b=YgQYC/xZRMFSmiqmd8J0pCSa01vmbTCDih+WE1jS5gNouoEuNN+TAaRSs/4J3hrBRd
         /4FXoJ3jOlsSUL+shLX2fkt/fPcYVxuelOLz6QtG2CgG619Q0CbCK0vTRpGIrKMpagdr
         xkX4GzogE9FAlUcbShg3BdvL54nDLsCH4i+5FtaS1eNbaCyp1JIIVcFEJF9APSowyFU8
         Vg3E6i9c8roWv9CbkSmHPd29x/WtdKvzJrnYpZvXOr/f+A//UcMUgDuE0/m7ieSCfH09
         ZqhDVcVD3lVU46HoT4YJoeg1gp92L3JWnR8hp5E2wZTheeJu8t8+TgaWNM59IdCCQEXJ
         AXZA==
X-Gm-Message-State: APjAAAU+pOFDMo/vWbbp/FLS79KwDhppoPWk+yHWDqID9tYaq8sB7cAp
	l848ibw8F3oBsZRQKEnpE5fxVKxEdGz3wVU01wzk1iRzu/+apMS3tTBWSPvAhFldf6XCiABpqP7
	NZG7GlWCY5dzcLW3xFHhboGgHjHiYPpVg4M//qWHEUXq8EKPlytcov0wfIesLYDsYxA==
X-Received: by 2002:a17:902:aa8a:: with SMTP id d10mr5941623plr.154.1561559280860;
        Wed, 26 Jun 2019 07:28:00 -0700 (PDT)
X-Received: by 2002:a17:902:aa8a:: with SMTP id d10mr5941565plr.154.1561559280189;
        Wed, 26 Jun 2019 07:28:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561559280; cv=none;
        d=google.com; s=arc-20160816;
        b=XXaRuENJ5yeOegFuroJy/F5I0GfaGTZhMm/ulPsUijflBfwOz0ODyQZvPTzrXP3Kis
         sjVyD4YwD1rnpn8Q1rH8rxSlQs0EWjC0vCWb+/FhUXGopFQKls/rEYY32KGXifkwxpdE
         ugIeGZnrmIQuNX9eVj6rxCCMrjfi4YbrEp2zJr590Q9SKVaaC+TxVP0EiKvXkBGxsK5n
         9r8rEbf6zqcoeJEPQYqp1b4VAd+SJacM7ElEFXoTTy8UjzSH/VJKBCJRE4LLNzrKavTO
         jxsRJCwR6GiqyiOlzq+p2O9ZT77ZBTV7vT4KqF38lzdL4RrKVjUDhbS+bJ35GN7E2Jpt
         B3Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Rln2FP6BOxdiVf8wORphr5UbX/lGN9PNgnvsQm0pxfA=;
        b=qUTVYVlrMUSuiiPX8F95Zp9csEUTPi4OxkRsHHmwjkBdmteSdoM06XFfUxWkBl+382
         FNr8xZz81w+fnxZZ9SKmvCZROxSgngAiigVKlQ+55onhQnwDxgGMYY8MfiDGH629kYxr
         P+ttAYzjdmifITLfnPOus+IeLPT0CAjd8SNRUlFBnqugLsdiF3jNeiDZI6GL2WgI5hLP
         MnYxciizP9dugMw9pDjwwlTNhSUB6CTOVMWqpC2MXfv6KMlfrfIhTSCPflULmUT0hK47
         8AYP3nvhvnxDPPNQtJkoY14Rv+T3kq3L9EKfCd4PzE0XyAFVG/ijTYzQPYliLUTl0cAA
         Wo5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=b1IaFK1m;
       spf=pass (google.com: domain of 374atxqukcc4ovfobqyyqvo.mywvsxeh-wwufkmu.ybq@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=374ATXQUKCC4OVfObQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r27sor10786032pfg.42.2019.06.26.07.28.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 07:28:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 374atxqukcc4ovfobqyyqvo.mywvsxeh-wwufkmu.ybq@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=b1IaFK1m;
       spf=pass (google.com: domain of 374atxqukcc4ovfobqyyqvo.mywvsxeh-wwufkmu.ybq@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=374ATXQUKCC4OVfObQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Rln2FP6BOxdiVf8wORphr5UbX/lGN9PNgnvsQm0pxfA=;
        b=b1IaFK1mLKquMHrwUdq8QS9ugryrRPvq91UQ0Uq6LFY+c2JG0h8vOnQRBq9Y4iBHrd
         17LsoajCwmnclKkY2LGLzmZK9jswwvQ8KphGCaAcqDw3Y5nANf73MjW7Cdyza3VWGCrS
         zpMj+JpcmgUaOeIauUqJJoduT7cgP35I/T6J0lq7MXm+xBM7VbsrPucsTC/qhyGJNYqj
         Jq0SH14PhfI7POH8+ntsXeZlQLTimCrlHvzHDw1oHqI66dDTIlPptw8JxI9T+XhR2DNf
         D9MpYcQLyK6spvA7kZWNLDDdjpLaHgbAIKd/hbGa6ghj3SUJRGWYatvWEVeUYYzWX5l9
         DKaA==
X-Google-Smtp-Source: APXvYqwQ22+0NkxIaX9CnqzWtnR2UzcffAGPuQ8MCIc490y2qHEX39KgAM5Jw+zu+rhdlMT/dvmAxkp4nA==
X-Received: by 2002:a65:4387:: with SMTP id m7mr3168635pgp.287.1561559279316;
 Wed, 26 Jun 2019 07:27:59 -0700 (PDT)
Date: Wed, 26 Jun 2019 16:20:11 +0200
In-Reply-To: <20190626142014.141844-1-elver@google.com>
Message-Id: <20190626142014.141844-3-elver@google.com>
Mime-Version: 1.0
References: <20190626142014.141844-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v3 2/5] mm/kasan: Change kasan_check_{read,write} to return boolean
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

This changes {,__}kasan_check_{read,write} functions to return a boolean
denoting if the access was valid or not.

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
 include/linux/kasan-checks.h | 36 ++++++++++++++++++++++--------------
 mm/kasan/common.c            |  8 ++++----
 mm/kasan/generic.c           | 13 +++++++------
 mm/kasan/kasan.h             | 10 +++++++++-
 mm/kasan/tags.c              | 12 +++++++-----
 5 files changed, 49 insertions(+), 30 deletions(-)

diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
index 19a0175d2452..2c7f0b6307b2 100644
--- a/include/linux/kasan-checks.h
+++ b/include/linux/kasan-checks.h
@@ -8,13 +8,17 @@
  * to validate access to an address.   Never use these in header files!
  */
 #ifdef CONFIG_KASAN
-void __kasan_check_read(const volatile void *p, unsigned int size);
-void __kasan_check_write(const volatile void *p, unsigned int size);
+bool __kasan_check_read(const volatile void *p, unsigned int size);
+bool __kasan_check_write(const volatile void *p, unsigned int size);
 #else
-static inline void __kasan_check_read(const volatile void *p, unsigned int size)
-{ }
-static inline void __kasan_check_write(const volatile void *p, unsigned int size)
-{ }
+static inline bool __kasan_check_read(const volatile void *p, unsigned int size)
+{
+	return true;
+}
+static inline bool __kasan_check_write(const volatile void *p, unsigned int size)
+{
+	return true;
+}
 #endif
 
 /*
@@ -22,19 +26,23 @@ static inline void __kasan_check_write(const volatile void *p, unsigned int size
  * instrumentation enabled. May be used in header files.
  */
 #ifdef __SANITIZE_ADDRESS__
-static inline void kasan_check_read(const volatile void *p, unsigned int size)
+static inline bool kasan_check_read(const volatile void *p, unsigned int size)
 {
-	__kasan_check_read(p, size);
+	return __kasan_check_read(p, size);
 }
-static inline void kasan_check_write(const volatile void *p, unsigned int size)
+static inline bool kasan_check_write(const volatile void *p, unsigned int size)
 {
-	__kasan_check_read(p, size);
+	return __kasan_check_read(p, size);
 }
 #else
-static inline void kasan_check_read(const volatile void *p, unsigned int size)
-{ }
-static inline void kasan_check_write(const volatile void *p, unsigned int size)
-{ }
+static inline bool kasan_check_read(const volatile void *p, unsigned int size)
+{
+	return true;
+}
+static inline bool kasan_check_write(const volatile void *p, unsigned int size)
+{
+	return true;
+}
 #endif
 
 #endif
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 6bada42cc152..2277b82902d8 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -87,15 +87,15 @@ void kasan_disable_current(void)
 	current->kasan_depth--;
 }
 
-void __kasan_check_read(const volatile void *p, unsigned int size)
+bool __kasan_check_read(const volatile void *p, unsigned int size)
 {
-	check_memory_region((unsigned long)p, size, false, _RET_IP_);
+	return check_memory_region((unsigned long)p, size, false, _RET_IP_);
 }
 EXPORT_SYMBOL(__kasan_check_read);
 
-void __kasan_check_write(const volatile void *p, unsigned int size)
+bool __kasan_check_write(const volatile void *p, unsigned int size)
 {
-	check_memory_region((unsigned long)p, size, true, _RET_IP_);
+	return check_memory_region((unsigned long)p, size, true, _RET_IP_);
 }
 EXPORT_SYMBOL(__kasan_check_write);
 
diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
index 504c79363a34..616f9dd82d12 100644
--- a/mm/kasan/generic.c
+++ b/mm/kasan/generic.c
@@ -166,29 +166,30 @@ static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
 	return memory_is_poisoned_n(addr, size);
 }
 
-static __always_inline void check_memory_region_inline(unsigned long addr,
+static __always_inline bool check_memory_region_inline(unsigned long addr,
 						size_t size, bool write,
 						unsigned long ret_ip)
 {
 	if (unlikely(size == 0))
-		return;
+		return true;
 
 	if (unlikely((void *)addr <
 		kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
 		kasan_report(addr, size, write, ret_ip);
-		return;
+		return false;
 	}
 
 	if (likely(!memory_is_poisoned(addr, size)))
-		return;
+		return true;
 
 	kasan_report(addr, size, write, ret_ip);
+	return false;
 }
 
-void check_memory_region(unsigned long addr, size_t size, bool write,
+bool check_memory_region(unsigned long addr, size_t size, bool write,
 				unsigned long ret_ip)
 {
-	check_memory_region_inline(addr, size, write, ret_ip);
+	return check_memory_region_inline(addr, size, write, ret_ip);
 }
 
 void kasan_cache_shrink(struct kmem_cache *cache)
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 3ce956efa0cb..e62ea45d02e3 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -123,7 +123,15 @@ static inline bool addr_has_shadow(const void *addr)
 
 void kasan_poison_shadow(const void *address, size_t size, u8 value);
 
-void check_memory_region(unsigned long addr, size_t size, bool write,
+/**
+ * check_memory_region - Check memory region, and report if invalid access.
+ * @addr: the accessed address
+ * @size: the accessed size
+ * @write: true if access is a write access
+ * @ret_ip: return address
+ * @return: true if access was valid, false if invalid
+ */
+bool check_memory_region(unsigned long addr, size_t size, bool write,
 				unsigned long ret_ip);
 
 void *find_first_bad_addr(void *addr, size_t size);
diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
index 63fca3172659..0e987c9ca052 100644
--- a/mm/kasan/tags.c
+++ b/mm/kasan/tags.c
@@ -76,7 +76,7 @@ void *kasan_reset_tag(const void *addr)
 	return reset_tag(addr);
 }
 
-void check_memory_region(unsigned long addr, size_t size, bool write,
+bool check_memory_region(unsigned long addr, size_t size, bool write,
 				unsigned long ret_ip)
 {
 	u8 tag;
@@ -84,7 +84,7 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
 	void *untagged_addr;
 
 	if (unlikely(size == 0))
-		return;
+		return true;
 
 	tag = get_tag((const void *)addr);
 
@@ -106,22 +106,24 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
 	 * set to KASAN_TAG_KERNEL (0xFF)).
 	 */
 	if (tag == KASAN_TAG_KERNEL)
-		return;
+		return true;
 
 	untagged_addr = reset_tag((const void *)addr);
 	if (unlikely(untagged_addr <
 			kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
 		kasan_report(addr, size, write, ret_ip);
-		return;
+		return false;
 	}
 	shadow_first = kasan_mem_to_shadow(untagged_addr);
 	shadow_last = kasan_mem_to_shadow(untagged_addr + size - 1);
 	for (shadow = shadow_first; shadow <= shadow_last; shadow++) {
 		if (*shadow != tag) {
 			kasan_report(addr, size, write, ret_ip);
-			return;
+			return false;
 		}
 	}
+
+	return true;
 }
 
 #define DEFINE_HWASAN_LOAD_STORE(size)					\
-- 
2.22.0.410.gd8fdbe21b5-goog

