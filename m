Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7A76B0070
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 18:50:35 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id s18so46499038lam.3
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 15:50:34 -0800 (PST)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com. [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id lv1si7803068lac.49.2015.02.02.15.50.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 15:50:33 -0800 (PST)
Received: by mail-la0-f52.google.com with SMTP id ge10so46424161lab.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 15:50:32 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 1/5] mm/internal.h: Don't split printk call in two
Date: Tue,  3 Feb 2015 00:50:12 +0100
Message-Id: <1422921016-27618-2-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1422921016-27618-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1422921016-27618-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

All users of mminit_dprintk pass a compile-time constant as level, so
this just makes gcc emit a single printk call instead of two.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---

Notes:
    Not a huge deal, since the only users are __init or __meminit
    functions, but even there saving 140 bytes may be worthwhile.

 mm/internal.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index efad241f7014..e1d8e05bcfff 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -329,8 +329,10 @@ extern int mminit_loglevel;
 #define mminit_dprintk(level, prefix, fmt, arg...) \
 do { \
 	if (level < mminit_loglevel) { \
-		printk(level <= MMINIT_WARNING ? KERN_WARNING : KERN_DEBUG); \
-		printk(KERN_CONT "mminit::" prefix " " fmt, ##arg); \
+		if (level <= MMINIT_WARNING) \
+			printk(KERN_WARNING "mminit::" prefix " " fmt, ##arg); \
+		else \
+			printk(KERN_DEBUG "mminit::" prefix " " fmt, ##arg); \
 	} \
 } while (0)
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
