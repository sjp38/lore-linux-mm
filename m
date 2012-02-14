Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 743F26B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:28:38 -0500 (EST)
Received: by iagz16 with SMTP id z16so11613521iag.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 23:28:37 -0800 (PST)
From: Yang Bai <hamo.by@gmail.com>
Subject: [PATCH] slab: warning if total alloc size overflow
Date: Tue, 14 Feb 2012 15:28:19 +0800
Message-Id: <1329204499-2671-1-git-send-email-hamo.by@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yang Bai <hamo.by@gmail.com>

Before, if the total alloc size is overflow,
we just return NULL like alloc fail. But they
are two different type problems. The former looks
more like a programming problem. So add a warning
here.

Signed-off-by: Yang Bai <hamo.by@gmail.com>
---
 include/linux/slab.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 573c809..5865237 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -242,8 +242,10 @@ size_t ksize(const void *);
  */
 static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
 {
-	if (size != 0 && n > ULONG_MAX / size)
+	if (size != 0 && n > ULONG_MAX / size) {
+		WARN(1, "Alloc memory size (%lu * %lu) overflow.", n, size);
 		return NULL;
+	}
 	return __kmalloc(n * size, flags | __GFP_ZERO);
 }
 
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
