Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7ED6B016A
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 06:16:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6F3A03EE081
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:16:51 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 585BC45DF48
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:16:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4217E45DF41
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:16:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 362011DB803F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:16:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F386F1DB802F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:16:50 +0900 (JST)
Date: Tue, 9 Aug 2011 19:09:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v5 2/6]  memcg: stop vmscan when enough done.
Message-Id: <20110809190933.d965888b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

memcg :avoid node fallback scan if possible.

Now, try_to_free_pages() scans all zonelist because the page allocator
should visit all zonelists...but that behavior is harmful for memcg.
Memcg just scans memory because it hits limit...no memory shortage
in pased zonelist.

For example, with following unbalanced nodes

     Node 0    Node 1
File 1G        0
Anon 200M      200M

memcg will cause swap-out from Node1 at every vmscan.

Another example, assume 1024 nodes system.
With 1024 node system, memcg will visit 1024 nodes
pages per vmscan... This is overkilling. 

This is why memcg's victim node selection logic doesn't work
as expected.

This patch is a help for stopping vmscan when we scanned enough.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: mmotm-Aug3/mm/vmscan.c
===================================================================
--- mmotm-Aug3.orig/mm/vmscan.c
+++ mmotm-Aug3/mm/vmscan.c
@@ -2124,6 +2124,16 @@ static void shrink_zones(int priority, s
 		}
 
 		shrink_zone(priority, zone, sc);
+		if (!scanning_global_lru(sc)) {
+			/*
+			 * When we do scan for memcg's limit, it's bad to do
+			 * fallback into more node/zones because there is no
+			 * memory shortage. We quit as much as possible when
+			 * we reache target.
+			 */
+			if (sc->nr_to_reclaim <= sc->nr_reclaimed)
+				break;
+		}
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
