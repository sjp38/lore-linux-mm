Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB1CB2VA025329
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Dec 2008 21:11:03 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E3C645DE57
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:11:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D00845DE50
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:11:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB6A31DB8046
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:11:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 278011DB803C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:11:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 00/11] memcg: split-lru feature for memcg take2
Message-Id: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Dec 2008 21:10:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Recently, SplitLRU patch series dramatically improvement VM reclaim
logic.

it have following improvement.
 (1) splite lru per page type
 (2) introduce inactive/active anon balancing logic
 (3) introduce anon/file balancing logic

Unfortunately, the improvement of memcgroup reclaim is incomplete.
Currently, it only has (1), but doesn't have (2) and (3).


This patch introduce (2) and (3) improvements to memcgroup.
this implementation is straightforward porting from global reclaim.

Therefere
  - code is simple.
  - memcg reclaim become efficiency as global reclaim.
  - the logic is the same as global lru.
    then, memcg reclaim debugging become easily.


this patch series has five part.

[part 1: global lru clean up]
  [PATCH 01/11] inactive_anon_is_low() move to vmscan.c
  [PATCH 02/11] introduce zone_reclaim struct
  [PATCH 03/11] make zone_nr_pages() helper function
  [PATCH 04/11] make get_scan_ratio() to memcg safe

[part 2: memcg: trivial fix]
  [PATCH 05/11] memcg: add null check to page_cgroup_zoneinfo()

[part 3: memcg: inactive-anon vs active-anon balancing improvement]
  [PATCH 06/11] memcg: make inactive_anon_is_low()

[part 4: anon vs file balancing improvement]
  [PATCH 07/11] memcg: make mem_cgroup_zone_nr_pages()
  [PATCH 08/11] memcg: make zone_reclaim_stat
  [PATCH 09/11] memcg: remove mem_cgroup_calc_reclaim()

[part 5: add split-lru related statics field to /cgroup/memory.stat]
  [PATCH 10/11] memcg: show inactive_ratio
  [PATCH 11/11] memcg: show reclaim_stat


patch against: mmotm 29 Nov 2008

Andrew, could you please pick 01-04 up to -mm?
01-04 don't have any behavior change.
kamezawwa-san queue 05-11 to his memcg queueue awhile.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
