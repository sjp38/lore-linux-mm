Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4268D6B0083
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 12:02:25 -0400 (EDT)
Received: by werj55 with SMTP id j55so3548262wer.14
        for <linux-mm@kvack.org>; Sat, 14 Apr 2012 09:02:23 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH] mm: fixup compilation error due to an asm write through a const pointer
Date: Sat, 14 Apr 2012 18:03:10 +0200
Message-Id: <1334419390-18961-1-git-send-email-daniel.vetter@ffwll.ch>
In-Reply-To: <CAMuHMdXBEiDGyJQ+szoBKxo0pS=n3xKfpb=F+rNkMQUv4SdTQA@mail.gmail.com>
References: <CAMuHMdXBEiDGyJQ+szoBKxo0pS=n3xKfpb=F+rNkMQUv4SdTQA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: DRI Development <dri-devel@lists.freedesktop.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Vetter <daniel.vetter@ffwll.ch>

This regression has been introduced in

commit f56f821feb7b36223f309e0ec05986bb137ce418
Author: Daniel Vetter <daniel.vetter@ffwll.ch>
Date:   Sun Mar 25 19:47:41 2012 +0200

    mm: extend prefault helpers to fault in more than PAGE_SIZE

I have failed to notice this because x86 asm seems to happily compile
things as-is.

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org
Signed-Off-by: Daniel Vetter <daniel.vetter@ffwll.ch>
---
 include/linux/pagemap.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index c93a9a9..efa26b4 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -461,7 +461,7 @@ static inline int fault_in_pages_readable(const char __user *uaddr, int size)
 static inline int fault_in_multipages_writeable(char __user *uaddr, int size)
 {
 	int ret;
-	const char __user *end = uaddr + size - 1;
+	char __user *end = uaddr + size - 1;
 
 	if (unlikely(size == 0))
 		return 0;
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
