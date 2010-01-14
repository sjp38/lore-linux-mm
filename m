Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6CF676B0089
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 00:54:48 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0E5sjcL018934
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 14:54:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5087045DE60
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:54:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 27A0845DE6E
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:54:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D7E1E18003
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:54:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A8B8F1DB8040
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:54:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] [mmotm 0113] memcg: fix compile error
Message-Id: <20100114145006.672D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Jan 2010 14:54:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


This issue was introduced by memcg-move-charges-of-anonymous-swap.patch.

=================================
Now, ia64 can't compile page_cgroup.c.
because it include asm/cmpxhg.h but almost arch don't have arch specific
cmpxhg.h. they use asm-generic/cmpxhg.h.

Then, following errror occur.

  CC      mm/page_cgroup.o
  mm/page_cgroup.c:12:25: error: asm/cmpxchg.h: No such file or
  directory
  make[1]: *** [mm/page_cgroup.o] Error 1
  make: *** [mm] Error 2

Fortunately, memcg code don't use low layer cmpxchg directly. thus
this patch remove this include line simply.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_cgroup.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 213b0ee..3dd8853 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -9,7 +9,6 @@
 #include <linux/vmalloc.h>
 #include <linux/cgroup.h>
 #include <linux/swapops.h>
-#include <asm/cmpxchg.h>
 
 static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
