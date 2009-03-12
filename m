Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E17EE6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 20:54:12 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C0s90V002987
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 09:54:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C1A045DD79
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:54:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 511E445DE57
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:54:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B57A1DB803A
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:54:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF3211DB803E
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:54:08 +0900 (JST)
Date: Thu, 12 Mar 2009 09:52:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/5] memcg softlimit (Another one) v4
Message-Id: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, this is a patch for implemnt softlimit to memcg.

I did some clean up and bug fixes. 

Anyway I have to look into details of "LRU scan algorithm" after this.

How this works:

 (1) Set softlimit threshold to memcg.
     #echo 400M > /cgroups/my_group/memory.softlimit_in_bytes.

 (2) Define priority as victim.
     #echo 3 > /cgroups/my_group/memory.softlimit_priority.
     0 is the lowest, 8 is the highest.
     If "8", softlimit feature ignore this group.
     default value is "8".

 (3) Add some memory pressure and make kswapd() work.
     kswapd will reclaim memory from victims paying regard to priority.

Simple test on my 2cpu 86-64 box with 1.6Gbytes of memory (...vmware)

  While a process malloc 800MB of memory and touch it and sleep in a group,
  run kernel make -j 16 under a victim cgroup with softlimit=300M, priority=3.

  Without softlimit => 400MB of malloc'ed memory are swapped out.
  With softlimit    =>  80MB of malloc'ed memory are swapped out. 

I think 80MB of swap is from direct memory reclaim path. And this
seems not to be terrible result.

I'll do more test on other hosts. Any comments are welcome.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
