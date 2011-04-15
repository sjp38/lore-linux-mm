Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E55D4900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 01:11:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8714A3EE0C0
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:17 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67A3745DE67
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 50F2845DE4E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 434D9E18007
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A6801DB8038
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] define __must_be_array() for __CHECKER__
In-Reply-To: <20110415140952.F7AE.A69D9226@jp.fujitsu.com>
References: <20110415121424.F7A6.A69D9226@jp.fujitsu.com> <20110415140952.F7AE.A69D9226@jp.fujitsu.com>
Message-Id: <20110415141110.F7B2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 15 Apr 2011 14:11:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

This fixes another sparse splat.


=46rom 711131e2e16925970a67103156af1296993dbc93 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 15 Apr 2011 13:28:16 +0900
Subject: [PATCH] define __must_be_array() for __CHECKER__

commit c5e631cf65f (ARRAY_SIZE: check for type) added __must_be_array().
but sparse can't parse this gcc extention.

Then, now make C=3D2 makes following sparse errors a lot.

  kernel/futex.c:2699:25: error: No right hand side of '+'-expression

Because __must_be_array() is used for ARRAY_SIZE() macro and it is
used very widely.

This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/compiler-gcc.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
index cb4c1eb..59e4028 100644
--- a/include/linux/compiler-gcc.h
+++ b/include/linux/compiler-gcc.h
@@ -34,8 +34,12 @@
     __asm__ ("" : "=3Dr"(__ptr) : "0"(ptr));		\
     (typeof(ptr)) (__ptr + (off)); })
=20
+#ifdef __CHECKER__
+#define __must_be_array(arr) 0
+#else
 /* &a[0] degrades to a pointer: a different type from an array */
 #define __must_be_array(a) BUILD_BUG_ON_ZERO(__same_type((a), &(a)[0]))
+#endif
=20
 /*
  * Force always-inline if the user requests it so via the .config,
--=20
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
