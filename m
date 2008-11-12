Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC0dZwX007671
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 09:39:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90CA045DD7A
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 09:39:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6741045DD7B
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 09:39:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 325671DB8037
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 09:39:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D6059E08006
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 09:39:34 +0900 (JST)
Date: Wed, 12 Nov 2008 09:38:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RESEND][PATCH] memcg: bugfix for memory hotplug
Message-Id: <20081112093856.eb91f53c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, pbadari@us.ibm.com
List-ID: <linux-mm.kvack.org>

Although Badari reported another? bug on rc4, this patch is necessary, anyway.
I still chasing that bug but I haven't reproduced yet.
 
I'm now asking Badari for more information and to try mmotm.
(memcg's migration code is much simplified.)

If it's better to stack this on my queue until all problems are fixed,
I'll do so.

Thanks,
-Kame
==
start pfn calculation of page_cgroup's memory hotplug notifier chain
is wrong.

Tested-by: Badari Pulavarty <pbadari@us.ibm.com>
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
