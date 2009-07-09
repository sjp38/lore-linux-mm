Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8141B6B00A3
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 23:15:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n693Sru3018394
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Jul 2009 12:28:53 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2120C45DE4E
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:28:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 02CBE45DD76
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:28:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DBCF91DB8037
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:28:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 996291DB8038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:28:49 +0900 (JST)
Date: Thu, 9 Jul 2009 12:27:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] ZERO PAGE config
Message-Id: <20090709122702.0a8c432b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Only x86 config is inculded because I can test only x86...
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Kconfig for using ZERO_PAGE. Using ZERO_PAGE or not is depends on
 - arch has pte_special() or not.
 - arch allows to use ZERO_PAGE or not.

In this patch, generic-config for /mm and arch-specific config for x86
is added. Other archs ? AFAIK, powerpc and s390 has pte_special().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/x86/Kconfig |    3 +++
 mm/Kconfig       |   15 +++++++++++++++
 2 files changed, 18 insertions(+)

Index: zeropage-trialv3/mm/Kconfig
===================================================================
--- zeropage-trialv3.orig/mm/Kconfig
+++ zeropage-trialv3/mm/Kconfig
@@ -214,6 +214,21 @@ config HAVE_MLOCKED_PAGE_BIT
 config MMU_NOTIFIER
 	bool
 
+config SUPPORT_ANON_ZERO_PAGE
+	bool "use anon zero page"
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
Index: zeropage-trialv3/arch/x86/Kconfig
===================================================================
--- zeropage-trialv3.orig/arch/x86/Kconfig
+++ zeropage-trialv3/arch/x86/Kconfig
@@ -161,6 +161,9 @@ config ARCH_HIBERNATION_POSSIBLE
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
