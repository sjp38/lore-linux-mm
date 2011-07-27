Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E5B696B00EE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 01:56:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 161343EE0B5
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 14:56:13 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F0DD745DE58
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 14:56:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D90FC45DE56
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 14:56:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C776F1DB804C
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 14:56:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 90DE91DB8055
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 14:56:12 +0900 (JST)
Date: Wed, 27 Jul 2011 14:49:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v4 3/5] memcg : stop scanning if enough
Message-Id: <20110727144900.503a0afe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110727144438.a9fdfd5b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110727144438.a9fdfd5b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

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

Index: mmotm-0710/mm/vmscan.c
===================================================================
--- mmotm-0710.orig/mm/vmscan.c
+++ mmotm-0710/mm/vmscan.c
@@ -2058,6 +2058,16 @@ static void shrink_zones(int priority, s
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
