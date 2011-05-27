Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D54136B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 20:12:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F17273EE0AE
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:12:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D757D2AEB7D
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:12:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9C9A2E68C2
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:12:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AAB3DE08003
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:12:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 69C45EF8002
	for <linux-mm@kvack.org>; Fri, 27 May 2011 09:12:00 +0900 (JST)
Date: Fri, 27 May 2011 09:05:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: add pgfault latency histograms
Message-Id: <20110527090506.357698e3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1306444069-5094-1-git-send-email-yinghan@google.com>
References: <1306444069-5094-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 26 May 2011 14:07:49 -0700
Ying Han <yinghan@google.com> wrote:

> This adds histogram to capture pagefault latencies on per-memcg basis. I used
> this patch on the memcg background reclaim test, and figured there could be more
> usecases to monitor/debug application performance.
> 
> The histogram is composed 8 bucket in ns unit. The last one is infinite (inf)
> which is everything beyond the last one. To be more flexible, the buckets can
> be reset and also each bucket is configurable at runtime.
> 
> memory.pgfault_histogram: exports the histogram on per-memcg basis and also can
> be reset by echoing "reset". Meantime, all the buckets are writable by echoing
> the range into the API. see the example below.
> 
> /proc/sys/vm/pgfault_histogram: the global sysfs tunablecan be used to turn
> on/off recording the histogram.
> 
> Functional Test:
> Create a memcg with 10g hard_limit, running dd & allocate 8g anon page.
> Measure the anon page allocation latency.
> 
> $ mkdir /dev/cgroup/memory/B
> $ echo 10g >/dev/cgroup/memory/B/memory.limit_in_bytes
> $ echo $$ >/dev/cgroup/memory/B/tasks
> $ dd if=/dev/zero of=/export/hdc3/dd/tf0 bs=1024 count=20971520 &
> $ allocate 8g anon pages
> 
> $ echo 1 >/proc/sys/vm/pgfault_histogram
> 
> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> pgfault latency histogram (ns):
> < 600            2051273
> < 1200           40859
> < 2400           4004
> < 4800           1605
> < 9600           170
> < 19200          82
> < 38400          6
> < inf            0
> 
> $ echo reset >/dev/cgroup/memory/B/memory.pgfault_histogram
> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> pgfault latency histogram (ns):
> < 600            0
> < 1200           0
> < 2400           0
> < 4800           0
> < 9600           0
> < 19200          0
> < 38400          0
> < inf            0
> 
> $ echo 500 520 540 580 600 1000 5000 >/dev/cgroup/memory/B/memory.pgfault_histogram
> $ cat /dev/cgroup/memory/B/memory.pgfault_histogram
> pgfault latency histogram (ns):
> < 500            50
> < 520            151
> < 540            3715
> < 580            1859812
> < 600            202241
> < 1000           25394
> < 5000           5875
> < inf            186
> 
> Performance Test:
> I ran through the PageFaultTest (pft) benchmark to measure the overhead of
> recording the histogram. There is no overhead observed on both "flt/cpu/s"
> and "fault/wsec".
> 
> $ mkdir /dev/cgroup/memory/A
> $ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
> $ echo $$ >/dev/cgroup/memory/A/tasks
> $ ./pft -m 15g -t 8 -T a
> 
> Result:
> "fault/wsec"
> 
> $ ./ministat no_histogram histogram
> x no_histogram
> + histogram
> +--------------------------------------------------------------------------+
>    N           Min           Max        Median           Avg        Stddev
> x   5     813404.51     824574.98      821661.3     820470.83     4202.0758
> +   5     821228.91     825894.66     822874.65     823374.15     1787.9355
> 
> "flt/cpu/s"
> 
> $ ./ministat no_histogram histogram
> x no_histogram
> + histogram
> +--------------------------------------------------------------------------+
>    N           Min           Max        Median           Avg        Stddev
> x   5     104951.93     106173.13     105142.73      105349.2     513.78158
> +   5     104697.67      105416.1     104943.52     104973.77     269.24781
> No difference proven at 95.0% confidence
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Hmm, interesting....but isn't it very very very complicated interface ?
Could you make this for 'perf' ? Then, everyone (including someone who don't use memcg)
will be happy.
Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
