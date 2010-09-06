Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A39576B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 01:49:40 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o865nbAb031308
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 6 Sep 2010 14:49:37 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2574845DE52
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 14:49:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0187545DE4F
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 14:49:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DC1261DB8043
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 14:49:36 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 969D11DB803F
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 14:49:36 +0900 (JST)
Date: Mon, 6 Sep 2010 14:44:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/3] memory hotplug: fix set_migratetype_isolate wrong
 callback result check
Message-Id: <20100906144428.d6d4bfd3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Even if notifier cannot find any pages, it doesn't mean
no pages are available...And, if there are no notifiers registered,
this condition will be always true and memory hotplug will show -EBUSY.

Clarification:This is a bug but not critical

In most case, a pageblock which will be offlined is MIGRATE_MOVABLE
This "notifier" is called only when the pageblock is _not_ MIGRATE_MOVABLE.
If not MIGRATE_MOVABLE, it's common case that memory hotplug will fail.
So, no one notice this bug.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: kametest/mm/page_alloc.c
===================================================================
--- kametest.orig/mm/page_alloc.c
+++ kametest/mm/page_alloc.c
@@ -5313,7 +5313,7 @@ int set_migratetype_isolate(struct page 
 	 */
 	notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
 	notifier_ret = notifier_to_errno(notifier_ret);
-	if (notifier_ret || !arg.pages_found)
+	if (notifier_ret)
 		goto out;
 
 	for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
