Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B62F16B007D
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 04:02:21 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8382JX3008161
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Sep 2010 17:02:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E1D845DE5A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 17:02:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C501F45DE4F
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 17:02:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CF6E1DB803F
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 17:02:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F1D6E18004
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 17:02:18 +0900 (JST)
Date: Fri, 3 Sep 2010 16:57:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/2][BUGFIX] fix memory isolation notifier return value
 check
Message-Id: <20100903165713.88249349.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100901121951.GC6663@tiehlicka.suse.cz>
	<20100901124138.GD6663@tiehlicka.suse.cz>
	<20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902082829.GA10265@tiehlicka.suse.cz>
	<20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902092454.GA17971@tiehlicka.suse.cz>
	<AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
	<20100902131855.GC10265@tiehlicka.suse.cz>
	<AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
	<20100902143939.GD10265@tiehlicka.suse.cz>
	<20100902150554.GE10265@tiehlicka.suse.cz>
	<20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Sorry, the 3rd patch for this set.
==

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Even if notifier cannot find any pages, it doesn't mean
no pages are available...(For example, there is no notifier.)
Anyway, we check all pages in the range, later.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-0827/mm/page_alloc.c
===================================================================
--- mmotm-0827.orig/mm/page_alloc.c
+++ mmotm-0827/mm/page_alloc.c
@@ -5360,7 +5360,7 @@ int set_migratetype_isolate(struct page 
 	 */
 	notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
 	notifier_ret = notifier_to_errno(notifier_ret);
-	if (notifier_ret || !arg.pages_found)
+	if (notifier_ret)
 		goto out;
 	immobile = __count_unmovable_pages(zone ,page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
