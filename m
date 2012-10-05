Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 5745F6B0099
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 22:32:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DCB033EE0C0
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:32:51 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C431445DE5E
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:32:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A58B445DE5B
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:32:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 952461DB804F
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:32:51 +0900 (JST)
Received: from g01jpexchkw03.g01.fujitsu.local (g01jpexchkw03.g01.fujitsu.local [10.0.194.42])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E5BC1DB8047
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:32:51 +0900 (JST)
Message-ID: <506E46B6.3060502@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 11:32:22 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 5/10] memory-hotplug : memory-hotplug: check page type in
 get_page_bootmem
References: <506E43E0.70507@jp.fujitsu.com>
In-Reply-To: <506E43E0.70507@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

The function get_page_bootmem() may be called more than one time to the same
page. There is no need to set page's type, private if the function is not
the first time called to the page.

Note: the patch is just optimization and does not fix any problem.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/memory_hotplug.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-04 18:29:58.284676075 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-04 18:30:03.454680542 +0900
@@ -95,10 +95,17 @@ static void release_memory_resource(stru
 static void get_page_bootmem(unsigned long info,  struct page *page,
 			     unsigned long type)
 {
-	page->lru.next = (struct list_head *) type;
-	SetPagePrivate(page);
-	set_page_private(page, info);
-	atomic_inc(&page->_count);
+	unsigned long page_type;
+
+	page_type = (unsigned long)page->lru.next;
+	if (page_type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
+	    page_type > MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE){
+		page->lru.next = (struct list_head *)type;
+		SetPagePrivate(page);
+		set_page_private(page, info);
+		atomic_inc(&page->_count);
+	} else
+		atomic_inc(&page->_count);
 }
 
 /* reference to __meminit __free_pages_bootmem is valid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
