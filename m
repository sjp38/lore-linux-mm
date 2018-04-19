Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 010CC6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 05:48:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u56-v6so4437056wrf.18
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 02:48:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c24sor1079342wmi.69.2018.04.19.02.48.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 02:48:51 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] KASAN: prohibit KASAN+STRUCTLEAK combination
Date: Thu, 19 Apr 2018 11:48:47 +0200
Message-Id: <20180419094847.56737-1-dvyukov@google.com>
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
---
 arch/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 8e0d665c8d53..983578c44cca 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -464,6 +464,10 @@ config GCC_PLUGIN_LATENT_ENTROPY
 config GCC_PLUGIN_STRUCTLEAK
 	bool "Force initialization of variables containing userspace addresses"
 	depends on GCC_PLUGINS
+	# Currently STRUCTLEAK inserts initialization out of live scope of
+	# variables from KASAN point of view. This leads to KASAN false
+	# positive reports. Prohibit this combination for now.
+	depends on !KASAN
 	help
 	  This plugin zero-initializes any structures containing a
 	  __user attribute. This can prevent some classes of information
-- 
2.17.0.484.g0c8726318c-goog
