Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3446B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:24:57 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 47-v6so5956354wru.19
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:24:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n17sor1342345wmi.16.2018.04.19.10.24.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 10:24:55 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v2] KASAN: prohibit KASAN+STRUCTLEAK combination
Date: Thu, 19 Apr 2018 19:24:51 +0200
Message-Id: <20180419172451.104700-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@google.com>

Currently STRUCTLEAK inserts initialization out of live scope of
variables from KASAN point of view. This leads to KASAN false
positive reports. Prohibit this combination for now.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org
Cc: kasan-dev@googlegroups.com
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Kees Cook <keescook@google.com>

---

This combination leads to periodic confusion
and pointless debugging:

https://marc.info/?l=linux-kernel&m=151991367323082
https://marc.info/?l=linux-kernel&m=151992229326243
https://lkml.org/lkml/2017/11/30/33

Changes since v1:
 - replace KASAN with KASAN_EXTRA
   Only KASAN_EXTRA enables variable scope checking
---
 arch/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 8e0d665c8d53..75dd23acf133 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -464,6 +464,10 @@ config GCC_PLUGIN_LATENT_ENTROPY
 config GCC_PLUGIN_STRUCTLEAK
 	bool "Force initialization of variables containing userspace addresses"
 	depends on GCC_PLUGINS
+	# Currently STRUCTLEAK inserts initialization out of live scope of
+	# variables from KASAN point of view. This leads to KASAN false
+	# positive reports. Prohibit this combination for now.
+	depends on !KASAN_EXTRA
 	help
 	  This plugin zero-initializes any structures containing a
 	  __user attribute. This can prevent some classes of information
-- 
2.17.0.484.g0c8726318c-goog
