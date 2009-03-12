Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9C9C26B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 20:56:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C0udri003986
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 09:56:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F015345DD7D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:56:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D09D345DD7B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:56:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B7D821DB8043
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:56:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78C021DB8044
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:56:38 +0900 (JST)
Date: Thu, 12 Mar 2009 09:55:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH 1/5] memcg use correct scan number at reclaim
Message-Id: <20090312095516.53a2d029.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrew, this [1/5] is a bug fix, others are not.

==
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Even when page reclaim is under mem_cgroup, # of scan page is determined by
status of global LRU. Fix that.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-2.6.29-Mar10/mm/vmscan.c
===================================================================
--- mmotm-2.6.29-Mar10.orig/mm/vmscan.c
+++ mmotm-2.6.29-Mar10/mm/vmscan.c
@@ -1470,7 +1470,7 @@ static void shrink_zone(int priority, st
 		int file = is_file_lru(l);
 		int scan;
 
-		scan = zone_page_state(zone, NR_LRU_BASE + l);
+		scan = zone_nr_pages(zone, sc, l);
 		if (priority) {
 			scan >>= priority;
 			scan = (scan * percent[file]) / 100;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
