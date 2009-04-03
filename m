Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0E2F46B003D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:09:59 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n338A6gQ001587
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Apr 2009 17:10:06 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 098C145DE51
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:10:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE47845DE4E
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:10:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9868EE08001
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:10:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C6561DB803E
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:10:02 +0900 (JST)
Date: Fri, 3 Apr 2009 17:08:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/9] memcg soft limit v2 (new design)
Message-Id: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

Memory cgroup's soft limit feature is a feature to tell global LRU 
"please reclaim from this memcg at memory shortage".

This is v2. Fixed some troubles under hierarchy. and increase soft limit
update hooks to proper places.

This patch is on to
  mmotom-Mar23 + memcg-cleanup-cache_charge.patch
  + vmscan-fix-it-to-take-care-of-nodemask.patch

So, not for wide use ;)

This patch tries to avoid to use existing memcg's reclaim routine and
just tell "Hints" to global LRU. This patch is briefly tested and shows
good result to me. (But may not to you. plz brame me.)

Major characteristic is.
 - memcg will be inserted to softlimit-queue at charge() if usage excess
   soft limit.
 - softlimit-queue is a queue with priority. priority is detemined by size
   of excessing usage.
 - memcg's soft limit hooks is called by shrink_xxx_list() to show hints.
 - Behavior is affected by vm.swappiness and LRU scan rate is determined by
   global LRU's status.

In this v2.
 - problems under use_hierarchy=1 case are fixed.
 - more hooks are added.
 - codes are cleaned up.

Shows good results on my private box test under several work loads.

But in special artificial case, when victim memcg's Active/Inactive ratio of
ANON is very different from global LRU, the result seems not very good.
i.e.
  under vicitm memcg, ACTIVE_ANON=100%, INACTIVE=0% (access memory in busy loop)
  under global, ACTIVE_ANON=10%, INACTIVE=90% (almost all processes are sleeping.)
memory can be swapped out from global LRU, not from vicitm.
(If there are file cache in victims, file cacahes will be out.)

But, in this case, even if we successfully swap out anon pages under victime memcg,
they will come back to memory soon and can show heavy slashing.

While using soft limit, I felt this is useful feature :)
But keep this RFC for a while. I'll prepare Documentation until the next post.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
