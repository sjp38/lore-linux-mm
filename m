Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A95546B0207
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:27:46 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7K0RhTI010364
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 20 Aug 2010 09:27:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4840045DE55
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:27:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C79745DE4E
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:27:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 00E4EE08001
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:27:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ADD4B1DB803C
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:27:42 +0900 (JST)
Date: Fri, 20 Aug 2010 09:22:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] vmstat : update zone stat threshold at onlining a cpu
Message-Id: <20100820092251.2ca67f66.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100820084908.10e55b76.kamezawa.hiroyu@jp.fujitsu.com>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
	<1281951733-29466-3-git-send-email-mel@csn.ul.ie>
	<20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008181050230.4025@router.home>
	<20100819090740.3f46aecf.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008191359400.1839@router.home>
	<20100820084908.10e55b76.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


refresh_zone_stat_thresholds() calculates parameter based on
the number of online cpus. It's called at cpu offlining but
needs to be called at onlining, too.

Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmstat.c |    1 +
 1 file changed, 1 insertion(+)

Index: mmotm-0811/mm/vmstat.c
===================================================================
--- mmotm-0811.orig/mm/vmstat.c
+++ mmotm-0811/mm/vmstat.c
@@ -998,6 +998,7 @@ static int __cpuinit vmstat_cpuup_callba
 	switch (action) {
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
+		refresh_zone_stat_thresholds();
 		start_cpu_timer(cpu);
 		node_set_state(cpu_to_node(cpu), N_CPU);
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
