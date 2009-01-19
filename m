Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A48116B00A1
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 04:56:21 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0J9uJS0018419
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 19 Jan 2009 18:56:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EBD3A45DE52
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:56:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BCBF445DE4F
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:56:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A2C621DB805F
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:56:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4205B1DB805A
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:56:18 +0900 (JST)
Date: Mon, 19 Jan 2009 18:55:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: NULL pointer dereference at rmdir on some
 NUMA systems
Message-Id: <20090119185514.f3681783.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49744499.2040101@cn.fujitsu.com>
References: <49744499.2040101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On NUMA, N_POSSIBLE doesn't means there is memory...and force_empty can
visit invalud node which have no pgdat.
This happens on some NUMA systems which defines memory-less-node, node-hotplug.

Note: memcg's its own controll structs are allocated against all POSSIBLE nodes.

To visit all valid pgdat, N_HIGH_MEMRY should be used.

Reporetd-by: Li Zefan <lizf@cn.fujitsu.com>
Tested-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Jan16/mm/memcontrol.c
@@ -1724,7 +1724,7 @@ move_account:
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
 		ret = 0;
-		for_each_node_state(node, N_POSSIBLE) {
+		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
 				enum lru_list l;
 				for_each_lru(l) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
