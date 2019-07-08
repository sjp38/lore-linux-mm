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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BFBEC606C2
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:09:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9E4921479
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:09:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XOe4Irkl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9E4921479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EBBA8E0023; Mon,  8 Jul 2019 13:09:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 473448E0002; Mon,  8 Jul 2019 13:09:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 388148E0023; Mon,  8 Jul 2019 13:09:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1469C8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:09:02 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 5so17030966qki.2
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:09:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=RtWDjGUPs90JyASI41SwauSsXqiA2S8BXOwsZQtnu1I=;
        b=ZvU4Rg7kwNN8s5ViIV9/myAO8IdjudmlnCIJwKEWxVj60W+bRhxjgj+W8/IM/Y1Emd
         hZ5zhQ6R/VxsMv1wqgUMLrPtSxL1rcNluBeHeJfl4Pe1w3joFgsi012m0osUgxMkeqMw
         ZJ3nenOb/maaTdtUiFT+naaT7zzCXuHLFHUaQBjnb/z5R25zVG87EOJEv98TpboBtcE2
         0ZPql+qOcdBAW03GB+cNhT2ib3U16Ypra5vCgGKLippHghpJD2VJ89dweg32gEr1XKcL
         +w9GnRXtD06Xw1oySJ58wJabVPQu3XNBa6G0wdBmdt4vMoOkZoKmI6rdfwhWwEvEycTt
         Q52Q==
X-Gm-Message-State: APjAAAVNwctopG2xeTz28DEXB269pHlS0cO3ySxYbpsJS5qdv+B2OwNr
	/5kMfsou/Z4wdw9AG+0jMdxx0tWP5nk/gVmlESbZf8ZOGY8VHxZw+k+OBBLRLnJ6KzTH+JYYNAu
	Vtm8cJDvFy8r5dUcwugZaDVx54IgHFNUxevotAH36X784QJBXEqTELlL61Kef3hXClg==
X-Received: by 2002:ae9:ed4b:: with SMTP id c72mr14197022qkg.404.1562605741825;
        Mon, 08 Jul 2019 10:09:01 -0700 (PDT)
X-Received: by 2002:ae9:ed4b:: with SMTP id c72mr14196984qkg.404.1562605741224;
        Mon, 08 Jul 2019 10:09:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562605741; cv=none;
        d=google.com; s=arc-20160816;
        b=Uf02m15CxoFD04S1B5KgmUusfxyiixVZsnFiPWEJ1XigAOnfhZTQSDEgPeFx7IOOIO
         fCK/ujER78bNZz87g901Ea3jb4Nck7+b5PuAnC3hEWOvyeWwxoJYRj/3Oldg7WqbrH/V
         WUBBo6njqVeZaT01O407RGFe/XiGFE19dE80ObKA0eiNOIZJuOsosTeINQpvJUeP2OPW
         afX3frDP5wmRRU/uNvRuxV6ptgK3n4ruhyTYTkkJDp9+KX3B7N8LZdbgl6M78LV1HVLa
         ejUtGpxa2UOTPO5NrHZKN+NP3HaCsUTJZ3+mOhBmJBgiEYg++3uSNTZoCWh2U3Z+Qp4F
         xP6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=RtWDjGUPs90JyASI41SwauSsXqiA2S8BXOwsZQtnu1I=;
        b=z2uwHPu+b8gMAJC2k3l1X7aNcngvm3afmyFsG9qK81/Avgbjy4l35GVfDA/FYfXFAb
         B00MvJDvzY8cCf1Q7qM/7lFoO9hE1aDfCqE3m+4r3RWtEuzXQq1wHXSLDiAV37fGEoym
         fjlO7Dsa//dmrxaGRTctxD24jJ3zA8AFGaUSFblMzInubRntTCyRi+7CLIRVIwnVSXcp
         ACQD67kkuBmvryeZRUCJ02Tu5xymGIgbe7WhgxhikxxowJyq4uPFcy3hQkKEaWqfHRIu
         3wXnymoXhaf9js/AAOVLVyaPqjPz7G2LHsAFVbxOBW/4QLWuMcf5298yaN0MniKU7XfW
         pZFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XOe4Irkl;
       spf=pass (google.com: domain of 3rhgjxqukcbs5cm5i7ff7c5.3fdc9elo-ddbm13b.fi7@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3rHgjXQUKCBs5CM5I7FF7C5.3FDC9ELO-DDBM13B.FI7@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z124sor10316014qkd.42.2019.07.08.10.09.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:09:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3rhgjxqukcbs5cm5i7ff7c5.3fdc9elo-ddbm13b.fi7@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XOe4Irkl;
       spf=pass (google.com: domain of 3rhgjxqukcbs5cm5i7ff7c5.3fdc9elo-ddbm13b.fi7@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3rHgjXQUKCBs5CM5I7FF7C5.3FDC9ELO-DDBM13B.FI7@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=RtWDjGUPs90JyASI41SwauSsXqiA2S8BXOwsZQtnu1I=;
        b=XOe4Irkl/KVbw9y5EerCSv8uURNZ0w5IOcfwYGUXv6rDuk8cm1Mtl43s6M4MXXkscS
         FeQSK/MGqhDc/1yw4EFvc6dCNBd+HnEmLChEi9T4tVZEVe4rTcG0ErUsi62cJve0WubA
         VlCjIh4I0UhfYnDVzBE6kqLlm0u6xBbQEolJUTHtXGJPwEUTrwc25iFyO5609USU2V7A
         N3yT+IvY/Z5qMzz2Q60w5BJnRNtsG1iiAhRMfQdD43LQDoFXPuB2dhgqe0dzOzYHYWKt
         JHV6ar2+53pKOzp7GX1zPs4TkYMK7BoPufoJdRoFfYEpWa5Y7y1HLry06eU2wAown11i
         nHiA==
X-Google-Smtp-Source: APXvYqxFjhJIMQeNNvWGa+cge8Nh7zJViMGZ5hev3WLcoFslzclVoXSP6GR0qdv5dHdL9E7iiFR6Rkk2RA==
X-Received: by 2002:a05:620a:1106:: with SMTP id o6mr14619312qkk.272.1562605740816;
 Mon, 08 Jul 2019 10:09:00 -0700 (PDT)
Date: Mon,  8 Jul 2019 19:07:04 +0200
In-Reply-To: <20190708170706.174189-1-elver@google.com>
Message-Id: <20190708170706.174189-3-elver@google.com>
Mime-Version: 1.0
References: <20190708170706.174189-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v5 2/5] mm/kasan: Change kasan_check_{read,write} to return boolean
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, kasan-dev@googlegroups.com, linux-mm@kvack.org
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
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: kasan-dev@googlegroups.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
v5:
* Rebase on top of v5 of preceding patch.
* Include types.h for bool.

v3:
* Fix Formatting and split introduction of __kasan_check_* and returning
  bool into 2 patches.
---
 include/linux/kasan-checks.h | 30 ++++++++++++++++++++----------
 mm/kasan/common.c            |  8 ++++----
 mm/kasan/generic.c           | 13 +++++++------
 mm/kasan/kasan.h             | 10 +++++++++-
 mm/kasan/tags.c              | 12 +++++++-----
 5 files changed, 47 insertions(+), 26 deletions(-)

diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
index 221f05fbddd7..ac6aba632f2d 100644
--- a/include/linux/kasan-checks.h
+++ b/include/linux/kasan-checks.h
@@ -2,19 +2,25 @@
 #ifndef _LINUX_KASAN_CHECKS_H
 #define _LINUX_KASAN_CHECKS_H
 
+#include <linux/types.h>
+
 /*
  * __kasan_check_*: Always available when KASAN is enabled. This may be used
  * even in compilation units that selectively disable KASAN, but must use KASAN
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
@@ -25,10 +31,14 @@ static inline void __kasan_check_write(const volatile void *p, unsigned int size
 #define kasan_check_read __kasan_check_read
 #define kasan_check_write __kasan_check_write
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

