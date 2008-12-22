Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 907FB6B0044
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 01:27:52 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBM6RnoB016527
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 22 Dec 2008 15:27:50 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AAA8F45DE52
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 15:27:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FCDC45DE50
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 15:27:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 10F3F1DB8037
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 15:27:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B0ABB1DB803C
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 15:27:48 +0900 (JST)
Date: Mon, 22 Dec 2008 15:26:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][mmotm] memcg use css_tryget fix
Message-Id: <20081222152650.207cf149.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I'm sorry for that I'm still generating new bugs...sigh.
-Kame
=
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

root_mem->last_scanned_child can be NULL here.
This may cause NULL pointer access when hierarchy is used.
This is a fix for memcg-use-css-tryget-in-memcg.patch

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-2.6.28-Dec19/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec19.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec19/mm/memcontrol.c
@@ -656,7 +656,7 @@ mem_cgroup_get_first_node(struct mem_cgr
 
 	if (!root_mem->last_scanned_child || obsolete) {
 
-		if (obsolete)
+		if (obsolete && root_mem->last_scanned_child)
 			mem_cgroup_put(root_mem->last_scanned_child);
 
 		cgroup = list_first_entry(&root_mem->css.cgroup->children,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
