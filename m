Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAP4Uw6P022687
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 25 Nov 2008 13:30:58 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B4AB945DE4F
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:30:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A63745DD72
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:30:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E0AC1DB8037
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:30:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 32CE61DB8041
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:30:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: make vread() and vwrite() declaration
In-Reply-To: <20081125131942.26CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081125131942.26CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081125132959.26E2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 25 Nov 2008 13:30:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Sparse output following warnings.

mm/vmalloc.c:1436:6: warning: symbol 'vread' was not declared. Should it be static?
mm/vmalloc.c:1474:6: warning: symbol 'vwrite' was not declared. Should it be static?


However, it is used by /dev/kmem. fixed here.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 drivers/char/mem.c      |    3 ---
 include/linux/vmalloc.h |    4 ++++
 2 files changed, 4 insertions(+), 3 deletions(-)

Index: b/drivers/char/mem.c
===================================================================
--- a/drivers/char/mem.c	2008-11-05 01:10:59.000000000 +0900
+++ b/drivers/char/mem.c	2008-11-22 22:09:49.000000000 +0900
@@ -425,9 +425,6 @@ static ssize_t read_oldmem(struct file *
 }
 #endif
 
-extern long vread(char *buf, char *addr, unsigned long count);
-extern long vwrite(char *buf, char *addr, unsigned long count);
-
 #ifdef CONFIG_DEVKMEM
 /*
  * This function reads the *virtual* memory as seen by the kernel.
Index: b/include/linux/vmalloc.h
===================================================================
--- a/include/linux/vmalloc.h	2008-11-05 01:11:55.000000000 +0900
+++ b/include/linux/vmalloc.h	2008-11-22 22:09:28.000000000 +0900
@@ -97,6 +97,10 @@ extern void unmap_kernel_range(unsigned 
 extern struct vm_struct *alloc_vm_area(size_t size);
 extern void free_vm_area(struct vm_struct *area);
 
+/* for /dev/kmem */
+extern long vread(char *buf, char *addr, unsigned long count);
+extern long vwrite(char *buf, char *addr, unsigned long count);
+
 /*
  *	Internals.  Dont't use..
  */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
