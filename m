Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DEBC06B00EE
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 05:28:55 -0400 (EDT)
Received: by pzk6 with SMTP id 6so801535pzk.36
        for <linux-mm@kvack.org>; Sun, 07 Aug 2011 02:28:54 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] slub: fix check_bytes() for slub debugging
Date: Sun,  7 Aug 2011 18:30:38 +0900
Message-Id: <1312709438-7608-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

The check_bytes() function is used by slub debugging.  It returns a pointer
to the first unmatching byte for a character in the given memory area.

If the character for matching byte is greater than 0x80, check_bytes()
doesn't work.  Becuase 64-bit pattern is generated as below.

	value64 = value | value << 8 | value << 16 | value << 24;
	value64 = value64 | value64 << 32;

The integer promotions are performed and sign-extended as the type of value
is u8.  The upper 32 bits of value64 is 0xffffffff in the first line, and
the second line has no effect.

This fixes the 64-bit pattern generation.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index eb5a8f9..5695f92 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -701,7 +701,7 @@ static u8 *check_bytes(u8 *start, u8 value, unsigned int bytes)
 		return check_bytes8(start, value, bytes);
 
 	value64 = value | value << 8 | value << 16 | value << 24;
-	value64 = value64 | value64 << 32;
+	value64 = (value64 & 0xffffffff) | value64 << 32;
 	prefix = 8 - ((unsigned long)start) % 8;
 
 	if (prefix) {
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
