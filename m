Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B88B6B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 04:29:30 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d18so85724735pgh.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 01:29:30 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 1si6135367pgt.210.2017.03.02.01.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Mar 2017 01:29:29 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH] radix tree test suite: Fix build with --as-needed
Date: Thu,  2 Mar 2017 20:29:12 +1100
Message-Id: <1488446952-25342-1-git-send-email-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mawilcox@microsoft.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently the radix tree test suite doesn't build with toolchains that
use --as-needed by default, for example Ubuntu's:

  cc -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address -lpthread -lurcu main.o ... -o main
  /usr/bin/ld: regression1.o: undefined reference to symbol 'pthread_join@@GLIBC_2.17'
  /lib/powerpc64le-linux-gnu/libpthread.so.0: error adding symbols: DSO missing from command line
  collect2: error: ld returned 1 exit status

This is caused by the custom makefile rules placing LDFLAGS before the
.o files that need the libraries.

We could fix it by using --no-as-needed, or rewriting the custom rules.
But we can also just drop the custom rules and move the libraries to
LDLIBS, and then the default rules work correctly - with the one caveat
that we need to add -fsanitize=address to LDFLAGS because that must be
passed to the linker as well as the compiler.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 tools/testing/radix-tree/Makefile | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index ecea846e7660..4831cb89cbfb 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -1,6 +1,7 @@
 
 CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address
-LDFLAGS += -lpthread -lurcu
+LDFLAGS += -fsanitize=address
+LDLIBS += -lpthread -lurcu
 TARGETS = main idr-test multiorder
 CORE_OFILES := radix-tree.o idr.o linux.o test.o find_bit.o
 OFILES = main.o $(CORE_OFILES) regression1.o regression2.o regression3.o \
@@ -13,13 +14,10 @@ endif
 targets: $(TARGETS)
 
 main:	$(OFILES)
-	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o main
 
 idr-test: idr-test.o $(CORE_OFILES)
-	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o idr-test
 
 multiorder: multiorder.o $(CORE_OFILES)
-	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o multiorder
 
 clean:
 	$(RM) $(TARGETS) *.o radix-tree.c idr.c
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
