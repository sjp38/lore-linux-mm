Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAA9dF3U026658
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 Nov 2008 18:39:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 82CE045DD7A
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 18:39:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6090745DD79
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 18:39:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D8BDE08003
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 18:39:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A4511DB803B
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 18:39:14 +0900 (JST)
Date: Mon, 10 Nov 2008 18:38:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: memory hotplug fix
Message-Id: <20081110183839.e551a52e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, pbadari@us.ibm.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is a bug fix reported against 2.6.28-rc3 from Badari.
Badari, could you give me Ack or Tested-by ?

Thanks,
-Kame
==
start pfn calculation of page_cgroup's memory hotplug notifier chain
is wrong.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/page_cgroup.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: mmotm-2.6.28-Oct30/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.28-Oct30.orig/mm/page_cgroup.c
+++ mmotm-2.6.28-Oct30/mm/page_cgroup.c
@@ -165,7 +165,7 @@ int online_page_cgroup(unsigned long sta
 	unsigned long start, end, pfn;
 	int fail = 0;
 
-	start = start_pfn & (PAGES_PER_SECTION - 1);
+	start = start_pfn & ~(PAGES_PER_SECTION - 1);
 	end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);
 
 	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
@@ -188,7 +188,7 @@ int offline_page_cgroup(unsigned long st
 {
 	unsigned long start, end, pfn;
 
-	start = start_pfn & (PAGES_PER_SECTION - 1);
+	start = start_pfn & ~(PAGES_PER_SECTION - 1);
 	end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);
 
 	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
