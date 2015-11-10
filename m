Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C509F6B0254
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:33:43 -0500 (EST)
Received: by padhx2 with SMTP id hx2so226328676pad.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:33:43 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id gp3si5233367pbc.27.2015.11.10.05.33.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 05:33:43 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so210579678pac.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:33:43 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 1/3] tools/vm: fix Makefile multi-targets
Date: Tue, 10 Nov 2015 22:32:04 +0900
Message-Id: <1447162326-30626-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Build all of the $(TARGETS), not just the first one.

Without the patch (make -n)
==============================

make -C ../lib/api
gcc -Wall -Wextra -I../lib/ -o page-types page-types.c ...

Only 'page-types' target was built.

With the patch (make -n)
===========================

make -C ../lib/api
gcc -Wall -Wextra -O2 -I../lib/ -o page-types page-types.c ...
gcc -Wall -Wextra -O2 -I../lib/ -o slabinfo slabinfo.c ...
gcc -Wall -Wextra -O2 -I../lib/ -o page_owner_sort page_owner_sort.c ...

All 3 targets ('page-types', 'slabinfo', 'page_owner_sort') were
built.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 tools/vm/Makefile | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/vm/Makefile b/tools/vm/Makefile
index 93aadaf..51c3f8b 100644
--- a/tools/vm/Makefile
+++ b/tools/vm/Makefile
@@ -1,15 +1,15 @@
 # Makefile for vm tools
 #
-TARGETS=page-types slabinfo page_owner_sort
+TARGETS = page-types slabinfo page_owner_sort
 
 LIB_DIR = ../lib/api
 LIBS = $(LIB_DIR)/libapi.a
 
 CC = $(CROSS_COMPILE)gcc
-CFLAGS = -Wall -Wextra -I../lib/
+CFLAGS = -Wall -Wextra -O2 -I../lib/
 LDFLAGS = $(LIBS)
 
-$(TARGETS): $(LIBS)
+all: $(LIBS) $(TARGETS)
 
 $(LIBS):
 	make -C $(LIB_DIR)
@@ -18,5 +18,5 @@ $(LIBS):
 	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
 
 clean:
-	$(RM) page-types slabinfo page_owner_sort
+	$(RM) $(TARGETS)
 	make -C $(LIB_DIR) clean
-- 
2.6.2.280.g74301d6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
