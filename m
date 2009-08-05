Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C1016B0085
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 06:19:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n75AJfMe031036
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 5 Aug 2009 19:19:41 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E9EAE45DE57
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:19:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B3DAD45DE54
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:19:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C23E1DB8040
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:19:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A4BF0E08004
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:19:38 +0900 (JST)
Date: Wed, 5 Aug 2009 19:17:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] ZERO_PAGE config
Message-Id: <20090805191750.a6d10776.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090805191643.2b11ae78.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090805191643.2b11ae78.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, hugh.dickins@tiscali.co.uk, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

no changes from v4.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Kconfig for using ZERO_PAGE or not. Using ZERO_PAGE or not is depends on
 - arch has pte_special() or not.
 - arch allows to use ZERO_PAGE or not.

In this patch, generic-config for /mm and arch-specific config for x86
is added. Other archs ?

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/x86/Kconfig |    3 +++
 mm/Kconfig       |   18 ++++++++++++++++++
 2 files changed, 21 insertions(+)

Index: mmotm-2.6.31-Aug4/mm/Kconfig
===================================================================
--- mmotm-2.6.31-Aug4.orig/mm/Kconfig
+++ mmotm-2.6.31-Aug4/mm/Kconfig
@@ -225,6 +225,24 @@ config KSM
 	  saving memory until one or another app needs to modify the content.
 	  Recommended for use with KVM, or with other duplicative applications.
 
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
+	  To developper:
+	  This ZERO_PAGE changes behavior of follow_page(). please check
+	  usage of follow_page() in your arch before supporting this.
+
 config DEFAULT_MMAP_MIN_ADDR
         int "Low address space to protect from user allocation"
         default 4096
Index: mmotm-2.6.31-Aug4/arch/x86/Kconfig
===================================================================
--- mmotm-2.6.31-Aug4.orig/arch/x86/Kconfig
+++ mmotm-2.6.31-Aug4/arch/x86/Kconfig
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
