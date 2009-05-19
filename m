Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F1E6A6B004D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 00:41:04 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4J4ffue001649
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 May 2009 13:41:41 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E3C4545DE58
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:41:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B94D245DE54
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:41:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F1901DB8037
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:41:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EB6C1DB803A
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:41:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class citizen
In-Reply-To: <20090519032759.GA7608@localhost>
References: <alpine.DEB.1.10.0905181045340.20244@qirst.com> <20090519032759.GA7608@localhost>
Message-Id: <20090519133422.4ECC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 May 2009 13:41:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi

Thanks for great works.


> SUMMARY
> =======
> The patch decreases the number of major faults from 50 to 3 during 10% cache hot reads.
> 
> 
> SCENARIO
> ========
> The test scenario is to do 100000 pread(size=110 pages, offset=(i*100) pages),
> where 10% of the pages will be activated:
> 
>         for i in `seq 0 100 10000000`; do echo $i 110;  done > pattern-hot-10
>         iotrace.rb --load pattern-hot-10 --play /b/sparse


Which can I download iotrace.rb?


> and monitor /proc/vmstat during the time. The test box has 2G memory.
> 
> 
> ANALYZES
> ========
> 
> I carried out two runs on fresh booted console mode 2.6.29 with the VM_EXEC
> patch, and fetched the vmstat numbers on
> 
> (1) begin:   shortly after the big read IO starts;
> (2) end:     just before the big read IO stops;
> (3) restore: the big read IO stops and the zsh working set restored
> 
>         nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
> begin:       2481             2237             8694              630                0           574299
> end:          275           231976           233914              633           776271         20933042
> restore:      370           232154           234524              691           777183         20958453
> 
> begin:       2434             2237             8493              629                0           574195
> end:          284           231970           233536              632           771918         20896129
> restore:      399           232218           234789              690           774526         20957909
> 
> and another run on 2.6.30-rc4-mm with the VM_EXEC logic disabled:

I don't think it is proper comparision.
you need either following comparision. otherwise we insert many guess into the analysis.

 - 2.6.29 with and without VM_EXEC patch
 - 2.6.30-rc4-mm with and without VM_EXEC patch


> 
> begin:       2479             2344             9659              210                0           579643
> end:          284           232010           234142              260           772776         20917184
> restore:      379           232159           234371              301           774888         20967849
> 
> The numbers show that
> 
> - The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
>   I'd attribute that improvement to the mmap readahead improvements :-)
> 
> - The pgmajfault increment during the file copy is 633-630=3 vs 260-210=50.
>   That's a huge improvement - which means with the VM_EXEC protection logic,
>   active mmap pages is pretty safe even under partially cache hot streaming IO.
> 
> - when active:inactive file lru size reaches 1:1, their scan rates is 1:20.8
>   under 10% cache hot IO. (computed with formula Dpgdeactivate:Dpgfree)
>   That roughly means the active mmap pages get 20.8 more chances to get
>   re-referenced to stay in memory.
> 
> - The absolute nr_mapped drops considerably to 1/9 during the big IO, and the
>   dropped pages are mostly inactive ones. The patch has almost no impact in
>   this aspect, that means it won't unnecessarily increase memory pressure.
>   (In contrast, your 20% mmap protection ratio will keep them all, and
>   therefore eliminate the extra 41 major faults to restore working set
>   of zsh etc.)

I'm surprised this.
Why your patch don't protect mapped page from streaming io?

I strongly hope reproduce myself, please teach me reproduce way.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
