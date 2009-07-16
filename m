Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 84DCF6B005A
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 05:04:51 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G94pMr006213
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Jul 2009 18:04:51 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 28CDF45DE7A
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 18:04:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E975845DE6F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 18:04:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C717D1DB803B
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 18:04:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7853C1DB803F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 18:04:50 +0900 (JST)
Date: Thu, 16 Jul 2009 18:03:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] ZERO PAGE again v4.
Message-Id: <20090716180303.bc9c887d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
	<20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

no changes since v3


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Kconfig for using ZERO_PAGE or not. Using ZERO_PAGE or not is depends on
 - arch has pte_special() or not.
 - arch allows to use ZERO_PAGE or not.

In this patch, generic-config for /mm and arch-specific config for x86
is added. 

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.31-Jul15/mm/Kconfig
===================================================================
--- mmotm-2.6.31-Jul15.orig/mm/Kconfig
+++ mmotm-2.6.31-Jul15/mm/Kconfig
@@ -214,6 +214,21 @@ config HAVE_MLOCKED_PAGE_BIT
 config MMU_NOTIFIER
 	bool
 
+config SUPPORT_ANON_ZERO_PAGE
+	bool "Use anon zero page"
+	default y if ARCH_SUPPORT_ANON_ZERO_PAGE
+	help
+	  In anonymous private mapping (MAP_ANONYMOUS and /dev/zero), a read
+	  page fault will allocate a new zero-cleared page. If the first page
+	  fault is write, allocating a new page is necessary. But if it is
+	  read, we can use ZERO_PAGE until a write comes. If you set this to y,
+	  the kernel use ZERO_PAGE and delays allocating new memory in private
+	  anon mapping until the first write. If applications use large mmap
+	  and most of accesses are read, this reduces memory usage and cache
+	  usage to some extent. To support this, your architecture should have
+	  _PAGE_SPECIAL bit in pte. And this will be no help to cpu cache if
+	  the arch's cache is virtually tagged.
+
 config DEFAULT_MMAP_MIN_ADDR
         int "Low address space to protect from user allocation"
         default 4096
Index: mmotm-2.6.31-Jul15/arch/x86/Kconfig
===================================================================
--- mmotm-2.6.31-Jul15.orig/arch/x86/Kconfig
+++ mmotm-2.6.31-Jul15/arch/x86/Kconfig
@@ -158,6 +158,9 @@ config ARCH_HIBERNATION_POSSIBLE
 config ARCH_SUSPEND_POSSIBLE
 	def_bool y
 
+config ARCH_SUPPORT_ANON_ZERO_PAGE
+	def_bool y
+
 config ZONE_DMA32
 	bool
 	default X86_64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
