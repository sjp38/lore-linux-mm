Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C16B66B0038
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 11:34:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r141so6746257wmg.4
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 08:34:32 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.73])
        by mx.google.com with ESMTPS id o136si21841878wmd.27.2017.02.01.08.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 08:34:31 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [RFC] sched: make DECLARE_COMPLETION_ONSTACK() work with clang
Date: Wed,  1 Feb 2017 17:34:14 +0100
Message-Id: <20170201163426.2287910-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@elte.hu>

Building with clang, we get a warning for each use of COMPLETION_INITIALIZER_ONSTACK, e.g.:

block/blk-exec.c:103:29: warning: variable 'wait' is uninitialized when used within its own initialization [-Wuninitialized]
include/linux/completion.h:61:58: note: expanded from macro 'DECLARE_COMPLETION_ONSTACK'
include/linux/completion.h:34:29: note: expanded from macro 'COMPLETION_INITIALIZER_ONSTACK'

This seems to be a problem in clang, but it's relatively easy to work around
by changing the assignment.

I filed a bug against clang for the warning, but if we want to support old versions,
we may want this change as well.

I have not yet checked if the new version produces worse object code.

Link: https://llvm.org/bugs/show_bug.cgi?id=31829
Cc: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/completion.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/completion.h b/include/linux/completion.h
index fa5d3efaba56..5d5aaae3af43 100644
--- a/include/linux/completion.h
+++ b/include/linux/completion.h
@@ -31,7 +31,7 @@ struct completion {
 	{ 0, __WAIT_QUEUE_HEAD_INITIALIZER((work).wait) }
 
 #define COMPLETION_INITIALIZER_ONSTACK(work) \
-	(*init_completion(&work))
+	({ init_completion(&work); work; })
 
 /**
  * DECLARE_COMPLETION - declare and initialize a completion structure
@@ -70,11 +70,10 @@ struct completion {
  * This inline function will initialize a dynamically created completion
  * structure.
  */
-static inline struct completion *init_completion(struct completion *x)
+static inline void init_completion(struct completion *x)
 {
 	x->done = 0;
 	init_waitqueue_head(&x->wait);
-	return x;
 }
 
 /**
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
