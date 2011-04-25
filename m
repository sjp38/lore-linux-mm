Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEB68D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:32:39 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 597453EE0C8
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:32:36 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BD2445DE5C
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:32:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 229A845DE58
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:32:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 15E4EE08006
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:32:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D117DE08002
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:32:35 +0900 (JST)
Date: Mon, 25 Apr 2011 18:25:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/7] memcg background reclaim , yet another one.
Message-Id: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>


This patch is based on Ying Han's one....at its origin, but I changed too much ;)
Then, start this as new thread.

(*) This work is not related to the topic "rewriting global LRU using memcg"
    discussion, at all. This kind of hi/low watermark has been planned since
    memcg was born. 

At first, per-memcg background reclaim is used for
  - helping memory reclaim and avoid direct reclaim.
  - set a not-hard limit of memory usage.

For example, assume a memcg has its hard-limit as 500M bytes.
Then, set high-watermark as 400M. Here, memory usage can exceed 400M up to 500M
but memory usage will be reduced automatically to 400M as time goes by.

This is useful when a user want to limit memory usage to 400M but don't want to
see big performance regression by hitting limit when memory usage spike happens.

1) == hard limit = 400M ==
[root@rhel6-test hilow]# time cp ./tmpfile xxx                
real    0m7.353s
user    0m0.009s
sys     0m3.280s

2) == hard limit 500M/ hi_watermark = 400M ==
[root@rhel6-test hilow]# time cp ./tmpfile xxx

real    0m6.421s
user    0m0.059s
sys     0m2.707s

Above is a brief result on VM and needs more study. But my impression is positive.
I'd like to use bigger real machine in the next time.

Here is a short list of updates from Ying Han's one.

 1. use workqueue and visit memcg in round robin.
 2. only allow setting hi watermark. low-watermark is automatically determined.
    This is good for avoiding bad cpu usage by background reclaim.
 3. totally rewrite algorithm of shrink_mem_cgroup for round-robin.
 4. fixed get_scan_count() , this was problematic.
 5. added some statistics, which I think necessary.
 6. added documenation

Then, the algorithm is not a cut-n-paste from kswapd. I thought kswapd should be
updated...and 'priority' in vmscan.c seems to be an enemy of memcg ;)


Thanks
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
