Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AF9568D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:03:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C27153EE0BC
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:03:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A7BFC45DE55
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:03:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E18C45DE4D
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:03:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 80B5B1DB803C
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:03:36 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C04D1DB802C
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:03:36 +0900 (JST)
Date: Mon, 28 Mar 2011 17:57:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V2] Add the pagefault count into memcg stats
Message-Id: <20110328175701.51d49be3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1301282760-30730-1-git-send-email-yinghan@google.com>
References: <1301282760-30730-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

On Sun, 27 Mar 2011 20:26:00 -0700
Ying Han <yinghan@google.com> wrote:

> Two new stats in per-memcg memory.stat which tracks the number of
> page faults and number of major page faults.
> 
> "pgfault"
> "pgmajfault"
> 
> They are different from "pgpgin"/"pgpgout" stat which count number of
> pages charged/discharged to the cgroup and have no meaning of reading/
> writing page to disk.
> 
> It is valuable to track the two stats for both measuring application's
> performance as well as the efficiency of the kernel page reclaim path.
> Counting pagefaults per process is useful, but we also need the aggregated
> value since processes are monitored and controlled in cgroup basis in memcg.
> 
> Functional test: check the total number of pgfault/pgmajfault of all
> memcgs and compare with global vmstat value:
> 
> $ cat /proc/vmstat | grep fault
> pgfault 1070751
> pgmajfault 553
> 
> $ cat /dev/cgroup/memory.stat | grep fault
> pgfault 1071138
> pgmajfault 553
> total_pgfault 1071142
> total_pgmajfault 553
> 
> $ cat /dev/cgroup/A/memory.stat | grep fault
> pgfault 199
> pgmajfault 0
> total_pgfault 199
> total_pgmajfault 0
> 
> Performance test: run page fault test(pft) wit 16 thread on faulting in 15G
> anon pages in 16G container. There is no regression noticed on the "flt/cpu/s"
> 
> Sample output from pft:
> TAG pft:anon-sys-default:
>   Gb  Thr CLine   User     System     Wall    flt/cpu/s fault/wsec
>   15   16   1     0.69s   230.99s    14.62s   16972.539 268876.196
> 
> +-------------------------------------------------------------------------+
>     N           Min           Max        Median           Avg        Stddev
> x  10     16682.962     17344.027     16913.524     16928.812      166.5362
> +  10      16718.92     17023.453     16907.164     16902.399     88.468851
> No difference proven at 95.0% confidence
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
