Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3136B0022
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:09:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3D8173EE0BC
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:08:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DD5A45DE51
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:08:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC4AE45DE4E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:08:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A68E3E78008
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:08:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CCA41DB8042
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:08:57 +0900 (JST)
Date: Tue, 10 May 2011 19:02:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/7] memcg async reclaim
Message-Id: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

Hi, thank you for all comments on previous patches for watermarks for memcg.

This is a new series as 'async reclaim', no watermark.
This version is a RFC again and I don't ask anyone to test this...but
comments/review are appreciated. 

Major changes are
  - no configurable watermark
  - hierarchy support
  - more fix for static scan rate round robin scanning of memcg.

(assume x86-64 in following.)

'async reclaim' works when
   - usage > limit - 4MB.
until
   - usage < limit - 8MB.

when the limit is larger than 128MB. This value of margin to limit
has some purpose for helping to reduce page fault latency at using
Transparent hugepage.

Considering THP, we need to reclaim HPAGE_SIZE(2MB) of pages when we hit
limit and consume HPAGE_SIZE(2MB) immediately. Then, the application need to
scan 2MB per each page fault and get big latency. So, some margin > HPAGE_SIZE
is required. I set it as 2*HPAGE_SIZE/4*HPAGE_SIZE, here. The kernel
will do async reclaim and reduce usage to limit - 8MB in background.

BTW, when an application gets a page, it tend to do some action to fill the
gotton page. For example, reading data from file/network and fill buffer.
This implies the application will have a wait or consumes cpu other than
reclaiming memory. So, if the kernel can help memory freeing in background
while application does another jobs, application latency can be reduced.
Then, this kind of asyncronous reclaim of memory will be a help for reduce
memory reclaim latency by memcg. But the total amount of cpu time consumed
will not have any difference.

This patch series implements
  - a logic for trigger async reclaim
  - help functions for async reclaim
  - core logic for async reclaim, considering memcg's hierarchy.
  - static scan rate memcg reclaim.
  - workqueue for async reclaim.

Some concern is that I didn't implement a code for handle the case
most of pages are mlocked or anon memory in swapless system. I need some
detection logic to avoid hopless async reclaim.

Any comments are welcome.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
