Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 372626B0261
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 14:17:45 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id h200so13424053itb.3
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 11:17:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h5sor6228204iob.346.2017.12.04.11.17.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 11:17:44 -0800 (PST)
From: Paul Lawrence <paullawrence@google.com>
Subject: [PATCH v4 1/5] kasan: add compiler support for clang
Date: Mon,  4 Dec 2017 11:17:31 -0800
Message-Id: <20171204191735.132544-2-paullawrence@google.com>
In-Reply-To: <20171204191735.132544-1-paullawrence@google.com>
References: <20171204191735.132544-1-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>

For now we can hard-code ASAN ABI level 5, since historical clang builds
can't build the kernel anyway.  We also need to emulate gcc's
__SANITIZE_ADDRESS__ flag, or memset() calls won't be instrumented.

Signed-off-by: Greg Hackmann <ghackmann@google.com>
Signed-off-by: Paul Lawrence <paullawrence@google.com>
---
 include/linux/compiler-clang.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
index 3b609edffa8f..d02a4df3f473 100644
--- a/include/linux/compiler-clang.h
+++ b/include/linux/compiler-clang.h
@@ -19,3 +19,11 @@
 
 #define randomized_struct_fields_start	struct {
 #define randomized_struct_fields_end	};
+
+/* all clang versions usable with the kernel support KASAN ABI version 5 */
+#define KASAN_ABI_VERSION 5
+
+/* emulate gcc's __SANITIZE_ADDRESS__ flag */
+#if __has_feature(address_sanitizer)
+#define __SANITIZE_ADDRESS__
+#endif
-- 
2.15.0.531.g2ccb3012c9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
