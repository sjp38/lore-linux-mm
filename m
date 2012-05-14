Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 6BCCD8D0001
	for <linux-mm@kvack.org>; Mon, 14 May 2012 07:58:25 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 06DBD3EE0AE
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:24 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E33CC45DE4D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C57E645DD74
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B68EA1DB803A
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 661991DB802C
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:23 +0900 (JST)
Message-ID: <4FB0F37E.2040805@jp.fujitsu.com>
Date: Mon, 14 May 2012 20:58:54 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [Patch 3/4] memblock: limit memory address from memblock
References: <4FACA79C.9070103@cn.fujitsu.com> <4FB0F174.1000400@jp.fujitsu.com>
In-Reply-To: <4FB0F174.1000400@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Setting kernelcore_max_pfn means all memory which is bigger than
the boot parameter is allocated as ZONE_MOVABLE. So memory which
is allocated by memblock also should be limited by the parameter.

The patch limits memory from memblock.

---
  include/linux/memblock.h |    1 +
  mm/memblock.c            |    5 ++++-
  mm/page_alloc.c          |    6 +++++-
  3 files changed, 10 insertions(+), 2 deletions(-)

Index: linux-3.4-rc6/include/linux/memblock.h
===================================================================
--- linux-3.4-rc6.orig/include/linux/memblock.h	2012-05-15 03:17:33.180555589 +0900
+++ linux-3.4-rc6/include/linux/memblock.h	2012-05-15 03:51:25.102153084 +0900
@@ -42,6 +42,7 @@ struct memblock {

  extern struct memblock memblock;
  extern int memblock_debug;
+extern phys_addr_t memblock_limit;

  #define memblock_dbg(fmt, ...) \
  	if (memblock_debug) printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
Index: linux-3.4-rc6/mm/memblock.c
===================================================================
--- linux-3.4-rc6.orig/mm/memblock.c	2012-05-15 03:17:33.180555589 +0900
+++ linux-3.4-rc6/mm/memblock.c	2012-05-15 03:51:25.104153055 +0900
@@ -876,7 +876,10 @@ int __init_memblock memblock_is_region_r

  void __init_memblock memblock_set_current_limit(phys_addr_t limit)
  {
-	memblock.current_limit = limit;
+	if (!memblock_limit || (memblock_limit > limit))
+		memblock.current_limit = limit;
+	else
+		memblock.current_limit = memblock_limit;
  }

  static void __init_memblock memblock_dump(struct memblock_type *type, char *name)
Index: linux-3.4-rc6/mm/page_alloc.c
===================================================================
--- linux-3.4-rc6.orig/mm/page_alloc.c	2012-05-15 03:17:33.179555602 +0900
+++ linux-3.4-rc6/mm/page_alloc.c	2012-05-15 03:51:25.107153013 +0900
@@ -205,6 +205,8 @@ static unsigned long __initdata required
  static unsigned long __initdata required_movablecore;
  static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];

+phys_addr_t memblock_limit;
+
  /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
  int movable_zone;
  EXPORT_SYMBOL(movable_zone);
@@ -4836,7 +4838,9 @@ static int __init cmdline_parse_core(cha
   */
  static int __init cmdline_parse_kernelcore_max_addr(char *p)
  {
-	return cmdline_parse_core(p, &required_kernelcore_max_pfn);
+	cmdline_parse_core(p, &required_kernelcore_max_pfn);
+	memblock_limit = required_kernelcore_max_pfn << PAGE_SHIFT;
+	return 0;
  }

  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
