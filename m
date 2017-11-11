Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1FEB440D4B
	for <linux-mm@kvack.org>; Sat, 11 Nov 2017 08:26:38 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p87so10145315pfj.21
        for <linux-mm@kvack.org>; Sat, 11 Nov 2017 05:26:38 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d8si10711790pgt.286.2017.11.11.05.26.35
        for <linux-mm@kvack.org>;
        Sat, 11 Nov 2017 05:26:37 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 4/5] locking/Documentation: Add an example to help crossrelease.txt more readable
Date: Sat, 11 Nov 2017 22:26:31 +0900
Message-Id: <1510406792-28676-5-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
References: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

Add an example explaining the rationale that the limitation that old
lockdep implies, can be relaxed.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 Documentation/locking/crossrelease.txt | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/Documentation/locking/crossrelease.txt b/Documentation/locking/crossrelease.txt
index bb449e8..dac56f4 100644
--- a/Documentation/locking/crossrelease.txt
+++ b/Documentation/locking/crossrelease.txt
@@ -281,6 +281,29 @@ causes a deadlock. The more lockdep adds dependencies, the more it
 thoroughly works. Thus, lockdep has to do its best to detect and add as
 many true dependencies to the graph as possible.
 
+For example:
+
+   CONTEXT X			   CONTEXT Y
+   ---------			   ---------
+				   acquire A
+   acquire B /* A dependency 'A -> B' exists */
+   release B
+   release A held by Y
+
+   where A and B are different lock classes.
+
+In this case, a dependency 'A -> B' exists since:
+
+   1. A waiter for A and a waiter for B might exist when acquiring B.
+   2. The only way to wake up each is to release what it waits for.
+   3. Whether the waiter for A can be woken up depends on whether the
+      other can. In other words, CONTEXT X cannot release A if it fails
+      to acquire B.
+
+Considering only typical locks, lockdep builds nothing. However,
+relaxing the limitation, a dependency 'A -> B' can be added, giving us
+more chances to check circular dependencies.
+
 However, it might suffer performance degradation since
 relaxing the limitation, with which design and implementation of lockdep
 can be efficient, might introduce inefficiency inevitably. So lockdep
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
