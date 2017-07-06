Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 721786B0311
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 18:01:46 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p10so15509346pgr.6
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 15:01:46 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id n11si753373pfj.35.2017.07.06.15.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 15:01:45 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id c73so7205219pfk.2
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 15:01:45 -0700 (PDT)
From: Greg Hackmann <ghackmann@google.com>
Subject: [PATCH 4/4] kasan: add compiler support for clang
Date: Thu,  6 Jul 2017 15:01:14 -0700
Message-Id: <20170706220114.142438-5-ghackmann@google.com>
In-Reply-To: <20170706220114.142438-1-ghackmann@google.com>
References: <20170706220114.142438-1-ghackmann@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

For now we can hard-code ASAN ABI level 5, since historical clang builds
can't build the kernel anyway.  We also need to emulate gcc's
__SANITIZE_ADDRESS__ flag, or memset() calls won't be instrumented.

Signed-off-by: Greg Hackmann <ghackmann@google.com>
---
 include/linux/compiler-clang.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
index d614c5ea1b5e..8153f793b22a 100644
--- a/include/linux/compiler-clang.h
+++ b/include/linux/compiler-clang.h
@@ -23,3 +23,13 @@
  */
 #undef inline
 #define inline inline __attribute__((unused)) notrace
+
+/* all clang versions usable with the kernel support KASAN ABI version 5
+ */
+#define KASAN_ABI_VERSION 5
+
+/* emulate gcc's __SANITIZE_ADDRESS__ flag
+ */
+#if __has_feature(address_sanitizer)
+#define __SANITIZE_ADDRESS__
+#endif
-- 
2.13.2.725.g09c95d1e9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
