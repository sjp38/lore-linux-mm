Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A101A6B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 03:07:00 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so798425lbj.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 00:06:58 -0700 (PDT)
Subject: [PATCH v2 1/2] bug: introduce BUILD_BUG_ON_INVALID() macro
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 28 Apr 2012 11:06:54 +0400
Message-ID: <20120428070654.21258.25380.stgit@zurg>
In-Reply-To: <20120425112623.26927.43229.stgit@zurg>
References: <20120425112623.26927.43229.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, "H. Peter Anvin" <hpa@zytor.com>, Cong Wang <xiyou.wangcong@gmail.com>

Sometimes we want to check some expressions correctness in compile-time.
"(void)(e);" or "if (e);" can be dangerous if expression has side-effects, and
gcc sometimes generates a lot of code, even if the expression has no effect.

This patch introduces macro BUILD_BUG_ON_INVALID() for such checks,
it forces a compilation error if expression is invalid without any extra code.

[Cast to "long" required because sizeof does not work for bit-fields.]

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/bug.h |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/bug.h b/include/linux/bug.h
index 72961c3..aaac4bb 100644
--- a/include/linux/bug.h
+++ b/include/linux/bug.h
@@ -30,6 +30,13 @@ struct pt_regs;
 #define BUILD_BUG_ON_ZERO(e) (sizeof(struct { int:-!!(e); }))
 #define BUILD_BUG_ON_NULL(e) ((void *)sizeof(struct { int:-!!(e); }))
 
+/*
+ * BUILD_BUG_ON_INVALID() permits the compiler to check the validity of the
+ * expression but avoids the generation of any code, even if that expression
+ * has side-effects.
+ */
+#define BUILD_BUG_ON_INVALID(e) ((void)(sizeof((__force long)(e))))
+
 /**
  * BUILD_BUG_ON - break compile if a condition is true.
  * @condition: the condition which the compiler should know is false.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
