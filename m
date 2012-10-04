Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 5BDC96B0109
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 08:36:33 -0400 (EDT)
Received: by mail-yx0-f169.google.com with SMTP id q11so96468yen.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 05:36:32 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH] lib: Use kmalloc_track_caller to get accurate traces for kvasprintf
Date: Thu,  4 Oct 2012 09:36:14 -0300
Message-Id: <1349354174-5560-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Tim Bird <tim.bird@am.sony.com>, Ezequiel Garcia <elezegarcia@gmail.com>, Sam Ravnborg <sam@ravnborg.org>, Andrew Morton <akpm@linux-foundation.org>

Previously kvasprintf allocation was being done through kmalloc,
thus producing an unaccurate trace report.

This is a common problem: in order to get accurate callsite tracing,
a lib/utils function shouldn't allocate kmalloc but instead
use kmalloc_track_caller.

Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 lib/kasprintf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/kasprintf.c b/lib/kasprintf.c
index ae0de80..32f1215 100644
--- a/lib/kasprintf.c
+++ b/lib/kasprintf.c
@@ -21,7 +21,7 @@ char *kvasprintf(gfp_t gfp, const char *fmt, va_list ap)
 	len = vsnprintf(NULL, 0, fmt, aq);
 	va_end(aq);
 
-	p = kmalloc(len+1, gfp);
+	p = kmalloc_track_caller(len+1, gfp);
 	if (!p)
 		return NULL;
 
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
