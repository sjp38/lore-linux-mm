Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 24E836B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 23:55:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B8A573EE0C1
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:55:19 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DF7C3A63B3
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:55:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 742533E60C4
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:55:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6214C1DB8051
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:55:19 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 254321DB804E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:55:19 +0900 (JST)
Date: Thu, 16 Jun 2011 12:47:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/7] memcg numa node scan update.
Message-Id: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>


In the last month, I added round-robin scan of numa nodes at
hittling limit, and wrote "a better algorithm is needed."

Here is update. Because some of patches are bugfixes, I may
cut out them as independent patch.

Pathc 6-7/7 implements a selection logic.

==
Tested on 8cpu/24GB system, which has 2 nodes.
limit memory to 300MB and run httpd under it.
httpd's working set is 4096files/600MB.

Then, do 40960 access by apache-bench. and see how memory reclaim costs.
Because a thread of httpd doesn't consume cpu much, the number of
working threads are not balanced between numa nodes and file caches
will be not balanced.

[round-robin]
 [kamezawa@bluextal ~]$ cat /cgroup/memory/test/memory.scan_stat
  scanned_pages_by_limit 550740
  freed_pages_by_limit 206473
  elapsed_ns_by_limit 9485418834

[After patch]
  scanned_pages_by_limit 521520
  freed_pages_by_limit 199330
  elapsed_ns_by_limit 7904913234

I can see elapsed time is decreased.
Test on big machine is welcomed.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
