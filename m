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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A96C48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E34BA2080C
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dkNaHYpO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E34BA2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94BAA8E0006; Thu, 27 Jun 2019 05:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F9A48E0002; Thu, 27 Jun 2019 05:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C2048E0006; Thu, 27 Jun 2019 05:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 538278E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:45:11 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id p64so515393vkp.13
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:45:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Rln2FP6BOxdiVf8wORphr5UbX/lGN9PNgnvsQm0pxfA=;
        b=lqKeMXWQddaxDW2qg0cZDMk8xAHJjJL8r0rulDzs+Q9C+ELm6r39ZzdH2trwg8Dmdz
         XivZJhbhd2cjR+YsuTynUukuFrb+wucAnuNhRDK1NbmyWGW0ENNC7GOKoIHqvCo3wpwO
         RuC5zt0+uvKCR5OqYOpR6gjc/Sqj/UDqHiHLQNvzIWH1V90XAsVZt7icxQ8hgc+/AFBW
         CX46zOo1IELNmQOG9HwB7Iz1n21ShMwOcryYmdiB/AcD6Eff1bdIs5h3lBCOERHKqpH9
         QGx8NZskxBzrGBAV3S45jrYQ0Y93f6g0bUIO5IsamULZvf6qI/vU3b2cmAVj5A6LKfLM
         awow==
X-Gm-Message-State: APjAAAWOHQ7Tw7A4IIOsYkT7t4VA9POeZgSyneXDMDw58bVgE96WE97R
	1AY5cLweDF8rwfXm6trWeh8C1DLR0vi8sxULpIqb8ATY5hYyheeT+5Wg+p35SBhNJ0xSTQpsuJz
	lus3JmnNKKZW3U0HSV0ms6ipAJhbaouMTVRFblmqhu/hxNx6gWKvS5unXaqJingNoEQ==
X-Received: by 2002:a67:f6cb:: with SMTP id v11mr2146576vso.16.1561628711089;
        Thu, 27 Jun 2019 02:45:11 -0700 (PDT)
X-Received: by 2002:a67:f6cb:: with SMTP id v11mr2146557vso.16.1561628710504;
        Thu, 27 Jun 2019 02:45:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561628710; cv=none;
        d=google.com; s=arc-20160816;
        b=iZkopEnLPJZjCcsqx6nbr3Q4FZmg1bQNSqzZlrxXBHOkFOi7yJDsxpEascmW6tXjIp
         mFMeCeR1BgJ4TTrLAyIvOqpUdOnAoiFNXSfREnkFfNmRbOhYVaJo3ehm8+oTE/mF44Nr
         P+oNszSFjkSgDz2SU3VwX9ThyARLTjhiyRVxYv8bdNryRlj2/ptZp0e/m+aQmBvj5K7c
         k7exVyXptW6CuPGxpB6t1aIO+Kv5X5duUOfiQdWh23NUnta/oLyaRZR85WDEyZHzm7RV
         c9RtpkSoICou/AyH4GBQL7GmOLrqpqLGSWk5PmS1uFoencatYRnVzptvGP4Okt4/RczP
         6Yug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Rln2FP6BOxdiVf8wORphr5UbX/lGN9PNgnvsQm0pxfA=;
        b=M8YYck6mM2FNi55BtvBrgJdd9pPyqm9vMMKOs5Sb+75gFuUH5OYlxc7DimUJrReN3L
         y12D/B89dJMdIi8yN7ORktsPwpxxl3v+ga3TLj7NBqKtzYsvzLyQ04l8rJPd1MnaWgPF
         W6lEI9nv6nvD0+yB1bkwj9/EAGfF9r6vU6oJazLlTJ4Wci/kIvhyg8Ghj/tKo1o0Zlt8
         hLq4Wt7bgipOC0faCyBwe4P7rCKku7FZoQXygiIsGInrtCHTLCiDs9/Rg+keR+7spBmf
         okQzHGMLLIxQsq9lId/FcFjYWngCtRHFL5eRzuHopXNi1zwBuV2o0NM8A62MFMw70OMo
         GNyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dkNaHYpO;
       spf=pass (google.com: domain of 3jpauxqukcicpw6p2rzzrwp.nzxwty58-xxv6lnv.z2r@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3JpAUXQUKCIcpw6p2rzzrwp.nzxwty58-xxv6lnv.z2r@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h2sor459958vkf.39.2019.06.27.02.45.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 02:45:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3jpauxqukcicpw6p2rzzrwp.nzxwty58-xxv6lnv.z2r@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dkNaHYpO;
       spf=pass (google.com: domain of 3jpauxqukcicpw6p2rzzrwp.nzxwty58-xxv6lnv.z2r@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3JpAUXQUKCIcpw6p2rzzrwp.nzxwty58-xxv6lnv.z2r@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Rln2FP6BOxdiVf8wORphr5UbX/lGN9PNgnvsQm0pxfA=;
        b=dkNaHYpOwXYyjcEZP1bf6vT67gxnv61V5DkhsO3AvQB28nuMDnRgRztKsctxAk0fDo
         NF32HjYsnqwZeGB+JEy2xa/dmqzW1mxPdUDFx7RXJVh2ipYHy5fnjonuEq6XUmiBG10T
         edYVhu7z6vHZNK+2jf6spBkHacLTAuucYbW84sLTHHnVhC9z9Ckyaqo78A2GxVsoBy9a
         60BirHmL2WU6muKj4oTpBp6rHMrp1CyZBClJ3vfto474veb5rZoPrqSZRWnOiUWogqhe
         ThWoTx3eK0RFvnlUy6amT3ORupTvUYcuf02zw72/XpsTh8chI/4twuFgieVHJm9L48no
         2XaQ==
X-Google-Smtp-Source: APXvYqyWZdgw2CsKA/62O2rW6VnwFiC7Kav89HOU1EeWitGXntN39ZV6iBcDXpaWPwEMg60FmsqhSoFJlA==
X-Received: by 2002:a1f:3c82:: with SMTP id j124mr982314vka.47.1561628710024;
 Thu, 27 Jun 2019 02:45:10 -0700 (PDT)
Date: Thu, 27 Jun 2019 11:44:42 +0200
In-Reply-To: <20190627094445.216365-1-elver@google.com>
Message-Id: <20190627094445.216365-3-elver@google.com>
Mime-Version: 1.0
References: <20190627094445.216365-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v4 2/5] mm/kasan: Change kasan_check_{read,write} to return boolean
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

