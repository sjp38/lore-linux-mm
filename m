Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE34900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 03:54:26 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 83F363EE0C3
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:54:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 63E2D45DE59
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:54:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4951745DE54
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:54:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B861E38002
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:54:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D5E881DB8047
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:54:21 +0900 (JST)
Date: Wed, 13 Apr 2011 16:47:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3 0/7] memcg: per cgroup background reclaim
Message-Id: <20110413164747.0d4076d1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1302678187-24154-1-git-send-email-yinghan@google.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 13 Apr 2011 00:03:00 -0700
Ying Han <yinghan@google.com> wrote:

> The current implementation of memcg supports targeting reclaim when the
> cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
> Per cgroup background reclaim is needed which helps to spread out memory
> pressure over longer period of time and smoothes out the cgroup performance.
> 
> If the cgroup is configured to use per cgroup background reclaim, a kswapd
> thread is created which only scans the per-memcg LRU list. Two watermarks
> ("high_wmark", "low_wmark") are added to trigger the background reclaim and
> stop it. The watermarks are calculated based on the cgroup's limit_in_bytes.
> 
> I run through dd test on large file and then cat the file. Then I compared
> the reclaim related stats in memory.stat.
> 
> Step1: Create a cgroup with 500M memory_limit.
> $ mkdir /dev/cgroup/memory/A
> $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> $ echo $$ >/dev/cgroup/memory/A/tasks
> 
> Step2: Test and set the wmarks.
> $ cat /dev/cgroup/memory/A/memory.wmark_ratio
> 0
> 
> $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> low_wmark 524288000
> high_wmark 524288000
> 
> $ echo 90 >/dev/cgroup/memory/A/memory.wmark_ratio
> 
> $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> low_wmark 471859200
> high_wmark 470016000
> 
> $ ps -ef | grep memcg
> root     18126     2  0 22:43 ?        00:00:00 [memcg_3]
> root     18129  7999  0 22:44 pts/1    00:00:00 grep memcg
> 
> Step3: Dirty the pages by creating a 20g file on hard drive.
> $ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1
> 
> Here are the memory.stat with vs without the per-memcg reclaim. It used to be
> all the pages are reclaimed from direct reclaim, and now some of the pages are
> also being reclaimed at background.
> 
> Only direct reclaim                       With background reclaim:
> 
> pgpgin 5248668                            pgpgin 5248347
> pgpgout 5120678                           pgpgout 5133505
> kswapd_steal 0                            kswapd_steal 1476614
> pg_pgsteal 5120578                        pg_pgsteal 3656868
> kswapd_pgscan 0                           kswapd_pgscan 3137098
> pg_scan 10861956                          pg_scan 6848006
> pgrefill 271174                           pgrefill 290441
> pgoutrun 0                                pgoutrun 18047
> allocstall 131689                         allocstall 100179
> 
> real    7m42.702s                         real 7m42.323s
> user    0m0.763s                          user 0m0.748s
> sys     0m58.785s                         sys  0m52.123s
> 
> throughput is 44.33 MB/sec                throughput is 44.23 MB/sec
> 
> Step 4: Cleanup
> $ echo $$ >/dev/cgroup/memory/tasks
> $ echo 1 > /dev/cgroup/memory/A/memory.force_empty
> $ rmdir /dev/cgroup/memory/A
> $ echo 3 >/proc/sys/vm/drop_caches
> 
> Step 5: Create the same cgroup and read the 20g file into pagecache.
> $ cat /export/hdc3/dd/tf0 > /dev/zero
> 
> All the pages are reclaimed from background instead of direct reclaim with
> the per cgroup reclaim.
> 
> Only direct reclaim                       With background reclaim:
> pgpgin 5248668                            pgpgin 5248114
> pgpgout 5120678                           pgpgout 5133480
> kswapd_steal 0                            kswapd_steal 5133397
> pg_pgsteal 5120578                        pg_pgsteal 0
> kswapd_pgscan 0                           kswapd_pgscan 5133400
> pg_scan 10861956                          pg_scan 0
> pgrefill 271174                           pgrefill 0
> pgoutrun 0                                pgoutrun 40535
> allocstall 131689                         allocstall 0
> 
> real    7m42.702s                         real 6m20.439s
> user    0m0.763s                          user 0m0.169s
> sys     0m58.785s                         sys  0m26.574s
> 
> Note:
> This is the first effort of enhancing the target reclaim into memcg. Here are
> the existing known issues and our plan:
> 
> 1. there are one kswapd thread per cgroup. the thread is created when the
> cgroup changes its limit_in_bytes and is deleted when the cgroup is being
> removed. In some enviroment when thousand of cgroups are being configured on
> a single host, we will have thousand of kswapd threads. The memory consumption
> would be 8k*100 = 8M. We don't see a big issue for now if the host can host
> that many of cgroups.
> 

What's bad with using workqueue ? 

Pros.
  - we don't have to keep our own thread pool.
  - we don't have to see 'ps -elf' is filled by kswapd...
Cons.
  - because threads are shared, we can't put kthread to cpu cgroup.

Regardless of workqueue, can't we have moderate numbers of threads ?

I really don't like to have too much threads and thinks one-thread-per-memcg
is big enough to cause lock contension problem.

Anyway, thank you for your patches. I'll review.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
