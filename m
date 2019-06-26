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
	by smtp.lore.kernel.org (Postfix) with ESMTP id B84BDC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61FFB204FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:23:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dr+4yvWO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61FFB204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FB738E0006; Wed, 26 Jun 2019 08:23:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AD538E0002; Wed, 26 Jun 2019 08:23:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB5E68E0006; Wed, 26 Jun 2019 08:23:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDC998E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:23:12 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id j128so2296260qkd.23
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:23:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=aEBIaaWYace9y+Mt2DPGrWS6yavzA5TNBst3S/YiRr8=;
        b=dVRFE9bw64RmqLHmo7Vaz69+KvXCEcH2RS+vVidV+I5jn/CwsXi5X6FH+8S68ZYqtf
         W5nnC5CczNMUTi3WVRUGjWrCJdUF9fWPgus0D7hFsc/lolPC4OfHcZ03GQ387HlfVDgD
         u6l22FcOd5jB9XSU7TIvcVjfTwiauAxe/jAUnMHGQDx+niEmPCu3SPL8BtYQ/jaTEbea
         uCv89Q8ly72/WdtCvp21T4+Q9qNqU7OclGyPHaLOIaBikes94c2qzqbV1RNoAJHWCoXB
         vmevN9A+Fbzjoo7bP1qeij7ZwtfEqbxzV41X6UXCG/kfz3N9M8VsH5VA5PCMX8B5G8eO
         DB4w==
X-Gm-Message-State: APjAAAU8O/mBJSCTLe8G27GNpVpb89ZpweT/1OHHz0Zom68oNNIUoHpN
	sBPzw6MTHZtU6Es88kgjsHH3S6+YZjBiM1SMTxvbQEQW168n3aajTd6AwbFHpCpJB/fHfWfZG08
	6nhjbtIyzD159x+UQbkvDxkA+AHHbcVytuntVtj1nH4WJs5ZBXNx/TDv53seortob4g==
X-Received: by 2002:aed:21c6:: with SMTP id m6mr3460892qtc.173.1561551792618;
        Wed, 26 Jun 2019 05:23:12 -0700 (PDT)
X-Received: by 2002:aed:21c6:: with SMTP id m6mr3460832qtc.173.1561551792008;
        Wed, 26 Jun 2019 05:23:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561551792; cv=none;
        d=google.com; s=arc-20160816;
        b=iE9rhV59F3FesY7JtRhszWwvehFKdbC38jUE3zh1ZA6qY0yK4bR1jYEH3ssAMAGRz4
         74wcDSbZNr3vEP9M3k156UlKNfAki5IFj8yAnFezgjMja5BEEP5iRNGyMnj1iWjRgtTw
         LJ74pbgTTclOCgNQwGlwMNlKwYQJRe8Z05Vyfgf3xOHJuGSNYV2gTZHjtOL88IyP16z2
         l/WIqOZy/uY2sjxb5X1vFISQW3TU1lXDGQ/SPG9POlW5vhidTLoBGUKbMhXklx7f+WGT
         1OEcK/3EqDLft/b8b88BO8pAdTukJMXKJtzB8TNox71pQKshEA3tMrRryMjoE5mKXmN7
         Xxow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=aEBIaaWYace9y+Mt2DPGrWS6yavzA5TNBst3S/YiRr8=;
        b=by4jXrkdwyaaySWqSPOfku5hkwikKvW5QD7yKhEtVbgiUc2E68VWCDOL4V25QsNpAE
         uOwEt77Bqwki9E7vkazSBk9DsQ6E3kQGIj92ox/hyRzeBUvTcYBhpeuCF6tzf4UG4m/A
         Xb3/Gi/0nnX6227Qu5ndB9TY7cTSJ8sKYQpeZ+lWTvYNNzm3ifE6HLiZEFDBUt/YZSrm
         GYTe5XXXIxi+Blx3gCWaEdPIJSr4H9oWnU6/GGqwI+sjafjztIW0zOhZJdotGcIp9sUH
         YWg01FxgfIPRndgEvfYajidt0Cty5ZJW/7tDVTXBxflWvzFEsW2SCQoAj+hgaczLhSP/
         afFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dr+4yvWO;
       spf=pass (google.com: domain of 3r2mtxqukcliwdnwjyggydw.ugedafmp-eecnsuc.gjy@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3r2MTXQUKCLIWdnWjYggYdW.Ugedafmp-eecnSUc.gjY@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v31sor23796225qtj.59.2019.06.26.05.23.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 05:23:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3r2mtxqukcliwdnwjyggydw.ugedafmp-eecnsuc.gjy@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dr+4yvWO;
       spf=pass (google.com: domain of 3r2mtxqukcliwdnwjyggydw.ugedafmp-eecnsuc.gjy@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3r2MTXQUKCLIWdnWjYggYdW.Ugedafmp-eecnSUc.gjY@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=aEBIaaWYace9y+Mt2DPGrWS6yavzA5TNBst3S/YiRr8=;
        b=dr+4yvWO8HKtBnImTSl+5RFoaisRmPyXQjXtuLieYwMP39/noqW8cVheUwz6irESV0
         3TfgWgfZhjmOr/wFcdgoRLZSv92Fyr0xK3mm5fwriKMI8R1088jct+j7hVvdqWc87MU9
         Nr67s0LKq5dzkWLUc5ztAJ9wpuvDlDTp8IACsm8hvZvF4NCxIYuxZFEg6atsfKWVNrTU
         E1B8cGpMonffJtkYxB7FLkqEi0gSbZTKuamnOvlLOp20etfu/XVDck85GJBgOFfSpzw7
         L/i/NguP+nb/lETpV0WxTBasvmPBJfBB0lM2qo11MyoBTaWBZsjLOw5AQ0ek/E9lI2qG
         YCAA==
X-Google-Smtp-Source: APXvYqzETn5PY7FFyGmJvrRKA+sP74ceYGu7ts+eCFNX7RzZ7aUQNYUrOWTneyaX/VgClEMR/LX/E+7tfQ==
X-Received: by 2002:ac8:25d9:: with SMTP id f25mr3394375qtf.256.1561551791675;
 Wed, 26 Jun 2019 05:23:11 -0700 (PDT)
Date: Wed, 26 Jun 2019 14:20:16 +0200
In-Reply-To: <20190626122018.171606-1-elver@google.com>
Message-Id: <20190626122018.171606-2-elver@google.com>
Mime-Version: 1.0
References: <20190626122018.171606-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v2 1/4] mm/kasan: Introduce __kasan_check_{read,write}
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

This introduces __kasan_check_{read,write} which return a bool if the
access was valid or not. __kasan_check functions may be used from
anywhere, even compilation units that disable instrumentation
selectively. For consistency, kasan_check_{read,write} have been changed
to also return a bool.

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
Cc: kasan-dev@googlegroups.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/kasan-checks.h | 35 ++++++++++++++++++++++++++++-------
 mm/kasan/common.c            | 14 ++++++--------
 mm/kasan/generic.c           | 13 +++++++------
 mm/kasan/kasan.h             | 10 +++++++++-
 mm/kasan/tags.c              | 12 +++++++-----
 5 files changed, 57 insertions(+), 27 deletions(-)

diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
index a61dc075e2ce..b8cf8a7cad34 100644
--- a/include/linux/kasan-checks.h
+++ b/include/linux/kasan-checks.h
@@ -2,14 +2,35 @@
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
+bool __kasan_check_read(const volatile void *p, unsigned int size);
+bool __kasan_check_write(const volatile void *p, unsigned int size);
 #else
-static inline void kasan_check_read(const volatile void *p, unsigned int size)
-{ }
-static inline void kasan_check_write(const volatile void *p, unsigned int size)
-{ }
+static inline bool __kasan_check_read(const volatile void *p, unsigned int size)
+{ return true; }
+static inline bool __kasan_check_write(const volatile void *p, unsigned int size)
+{ return true; }
+#endif
+
+/*
+ * kasan_check_*: Only available when the particular compilation unit has KASAN
+ * instrumentation enabled. May be used in header files.
+ */
+#ifdef __SANITIZE_ADDRESS__
+static inline bool kasan_check_read(const volatile void *p, unsigned int size)
+{ return __kasan_check_read(p, size); }
+static inline bool kasan_check_write(const volatile void *p, unsigned int size)
+{ return __kasan_check_read(p, size); }
+#else
+static inline bool kasan_check_read(const volatile void *p, unsigned int size)
+{ return true; }
+static inline bool kasan_check_write(const volatile void *p, unsigned int size)
+{ return true; }
 #endif
 
 #endif
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 242fdc01aaa9..2277b82902d8 100644
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
+bool __kasan_check_read(const volatile void *p, unsigned int size)
 {
-	check_memory_region((unsigned long)p, size, false, _RET_IP_);
+	return check_memory_region((unsigned long)p, size, false, _RET_IP_);
 }
-EXPORT_SYMBOL(kasan_check_read);
+EXPORT_SYMBOL(__kasan_check_read);
 
-void kasan_check_write(const volatile void *p, unsigned int size)
+bool __kasan_check_write(const volatile void *p, unsigned int size)
 {
-	check_memory_region((unsigned long)p, size, true, _RET_IP_);
+	return check_memory_region((unsigned long)p, size, true, _RET_IP_);
 }
-EXPORT_SYMBOL(kasan_check_write);
+EXPORT_SYMBOL(__kasan_check_write);
 
 #undef memset
 void *memset(void *addr, int c, size_t len)
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

