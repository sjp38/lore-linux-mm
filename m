Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C55F8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:17:00 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 67E0C3EE0BB
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:16:57 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CCE945DE4E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:16:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 321A745DE68
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:16:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 225311DB803F
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:16:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DE1F91DB803E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:16:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V3] Add the pagefault count into memcg stats
In-Reply-To: <1301419953-2282-1-git-send-email-yinghan@google.com>
References: <1301419953-2282-1-git-send-email-yinghan@google.com>
Message-Id: <20110330101716.E921.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Mar 2011 10:16:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Hi

sorry, I didn't see past discussion of this thread. then, I may be missing
something.

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

Currently, memory cgroup don't restrict number of page fault. And we already have
this feature by CONFIG_CGROUP_PERF if my understanding is correct. Why don't you
use perf cgroup?

In the other words, after your patch, we have four pagefault counter. Do we
really need *four*? Can't we consolidate them?

1. tsk->maj_flt
2. perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ)
3. count_vm_event(PGMAJFAULT);
4. mem_cgroup_count_vm_event(PGMAJFAULT);





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
