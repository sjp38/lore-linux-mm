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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99B67C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:27:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 617E72133F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:27:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="r6nw3M8i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 617E72133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED2878E0011; Wed, 26 Jun 2019 10:27:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E328D8E0002; Wed, 26 Jun 2019 10:27:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D216E8E0011; Wed, 26 Jun 2019 10:27:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB7408E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:27:57 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id 64so236374uam.22
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 07:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=M/VKnz1BZ+rvrIeSdLI9RxXAlLGL/xX/aFhsrhXW1SI=;
        b=IKT6s9OLy6x7RD4qazO0KiNBQt1NXE6RIs+3cGNKQA/axLOAnYIcK499tMzF20nZ9w
         antK98R7kA7sORddHQ4kJbGsBOaAWNSJKmjo9GU1oZacoo0l3ODIut6bbS0B3plMhp8p
         bCi797DE9ln0MRIz1K57bm5MFn3F8f3xYPT65gWfsi9fAcKg+qAJi6BuiivJ1XYm6tmJ
         xFYWGl8DQNF0G76J1bfLhLFYj6YhMKlMTp/fTL+LqgLjV4bw/TxAK8G9W1YPvl58a+iK
         PJBQoCjqnbx7weGLw5yQ9+xibuT3J6YdvUR3QNtuXHM3Ner8UOA5KBwXAsVEiQnFCrU+
         Xpgw==
X-Gm-Message-State: APjAAAV6Bt+PLC8A3L9NBBou23KpT05Z+mxRF4tWP+AyFjsLPlmCLrbX
	Ayj/s+/ZgGqFMSEBlZz7TBTqztWf1CGgHB42DT7I74BnmOF+Uk8GHyT2hxbflPId+wrpaiOfUkn
	FSZe0a0rFa3v+Qq5llxCAWsngvRNkpYujN9SzmzG/6x9Zrhevi/lpUlgtll1jqMng+w==
X-Received: by 2002:a9f:21d6:: with SMTP id 80mr2707672uac.60.1561559277327;
        Wed, 26 Jun 2019 07:27:57 -0700 (PDT)
X-Received: by 2002:a9f:21d6:: with SMTP id 80mr2707640uac.60.1561559276706;
        Wed, 26 Jun 2019 07:27:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561559276; cv=none;
        d=google.com; s=arc-20160816;
        b=f6MzmS6PPqosmkh/52uTzRCFUThF6HALNxSHMwO6o/6vNUF/rtmN7cR/ThRl+9niEh
         oUp3gA4CyLIPGYRcejXofh1FUsrTAe3k2uQqJEYWjA/lLiEtjZtJXFG3x+6Rr2iepO70
         yxMzkIx1UK0UXQkZX/YNijk01bxLAojyEUCZ7G9eDaT00qD7ksOU9cpFz66TKjaDmL7q
         wi4Ua32hXv4zo/bpZHZj6qQRar7FIU5VNdb+XSCvcMBOFc8Jqaxb3fWFnsACEDwboIZe
         9sflyaXJIJUK79MX5KiqkH5I1J1gitDYmalOE2m/Ewin3fcH1B2P9Lkvux8idmD7HVzA
         jOdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=M/VKnz1BZ+rvrIeSdLI9RxXAlLGL/xX/aFhsrhXW1SI=;
        b=Gh459f7vRCohanbjq9/I26wbFa6c2khb7nJ12yEjDf3i4Hw4dk60WLoCJXeF+6h45L
         ZIzLP1js6+oKIMS3nz+8qAMPFVCQr062Y3+vMS4zWMiSAtkZm6KJ/iiGt4FnvYv3ahz6
         JJa4jHPsRnuEBuZpxYE1QBCGGYD6yFrZKXNpB3IXNR8xWYKlSRSnKbOB2Mq/Qw5Y7bQx
         XfMOGgX21hOLW9fjNWiGcEgTlk1245E/7l58JYQfLbHHmrLGbYLbDe86TFWf4wlxN2RM
         JwA1sUUK7Cay6vjKmzv9H8S7bcC0IBXFiYLaH7o37GdT9s4LNWXN6TzOoie2+PDKeG1h
         f/zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=r6nw3M8i;
       spf=pass (google.com: domain of 37iatxqukccslsclynvvnsl.jvtspube-ttrchjr.vyn@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37IATXQUKCCsLScLYNVVNSL.JVTSPUbe-TTRcHJR.VYN@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n16sor9197549uao.69.2019.06.26.07.27.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 07:27:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of 37iatxqukccslsclynvvnsl.jvtspube-ttrchjr.vyn@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=r6nw3M8i;
       spf=pass (google.com: domain of 37iatxqukccslsclynvvnsl.jvtspube-ttrchjr.vyn@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37IATXQUKCCsLScLYNVVNSL.JVTSPUbe-TTRcHJR.VYN@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=M/VKnz1BZ+rvrIeSdLI9RxXAlLGL/xX/aFhsrhXW1SI=;
        b=r6nw3M8iBdMMdDsQCi4kz+gaKEu4VgLdto3uR/Hb+x3jWuYlTLr6ifrsToJKF86GHa
         qA78Fzg+q3rah9Tq3+HC4NgmeJxeMXRi6X+mqSx2fMh7EN9mNVJho6xtgRDF+fgO/vzZ
         ph3SX/j0XxKhGizyKrKnGHNigwW1uJl5IV9Uvjv8Nz6URFk0B2IZ5ts9Ue3zzcY9MHh/
         BX7duW0QkAb0oIPz7Dhyy5UTlbci3X/d+MHSSpHlmE4LnN2rjqdhj9HwTgqMEq4YFAay
         T924yXwtHmyBk/42sVazqXLxX0pT73ZH6McGBQ9WAhVmi56I2JeIk3VnKvW7e34FBVDz
         ZwxA==
X-Google-Smtp-Source: APXvYqyMLyo8aALGSXk8URhLTy8rPMv7ukPLiXQ5MQebePn4ydKU3VHhJTmrxX7/WLals9YL9eTyAQQfXg==
X-Received: by 2002:ab0:70c8:: with SMTP id r8mr2695528ual.89.1561559276181;
 Wed, 26 Jun 2019 07:27:56 -0700 (PDT)
Date: Wed, 26 Jun 2019 16:20:10 +0200
In-Reply-To: <20190626142014.141844-1-elver@google.com>
Message-Id: <20190626142014.141844-2-elver@google.com>
Mime-Version: 1.0
References: <20190626142014.141844-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v3 1/5] mm/kasan: Introduce __kasan_check_{read,write}
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

