Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9CB6B005A
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 04:43:23 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7D8hK0k021808
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 14:13:20 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7D8hKP82539662
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 14:13:20 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7D8hJko028733
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 18:43:20 +1000
Date: Thu, 13 Aug 2009 14:13:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [UPDATED][PATCH][mmotm] Help Root Memory Cgroup Resource
	Counters Scale Better (v5)
Message-ID: <20090813084316.GI5087@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090813065504.GG5087@balbir.in.ibm.com> <20090813162640.fe2349e9.nishimura@mxp.nes.nec.co.jp> <20090813080206.GH5087@balbir.in.ibm.com> <20090813083524.GC21389@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090813083524.GC21389@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "menage@google.com" <menage@google.com>, xemul@openvz.org, prarit@redhat.com, andi.kleen@intel.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Ingo Molnar <mingo@elte.hu> [2009-08-13 10:35:24]:

> 
> * Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Without Patch
> > 
> >  Performance counter stats for '/home/balbir/parallel_pagefault':
> > 
> >   5826093739340  cycles                   #    809.989 M/sec
> >    408883496292  instructions             #      0.070 IPC
> >      7057079452  cache-references         #      0.981 M/sec
> >      3036086243  cache-misses             #      0.422 M/sec
> 
> > With this patch applied
> > 
> >  Performance counter stats for '/home/balbir/parallel_pagefault':
> > 
> >   5957054385619  cycles                   #    828.333 M/sec
> >   1058117350365  instructions             #      0.178 IPC
> >      9161776218  cache-references         #      1.274 M/sec
> >      1920494280  cache-misses             #      0.267 M/sec
> 
> Nice how the instruction count and the IPC value incraesed, and the 
> cache-miss count decreased.
> 
> Btw., a 'perf stat' suggestion: you can also make use of built-in 
> error bars via repeating parallel_pagefault N times:
> 
>   aldebaran:~> perf stat --repeat 3 /bin/ls
> 
>  Performance counter stats for '/bin/ls' (3 runs):
> 
>        1.108886  task-clock-msecs         #      0.875 CPUs    ( +-   4.316% )
>               0  context-switches         #      0.000 M/sec   ( +-   0.000% )
>               0  CPU-migrations           #      0.000 M/sec   ( +-   0.000% )
>             254  page-faults              #      0.229 M/sec   ( +-   0.000% )
>         3461896  cycles                   #   3121.958 M/sec   ( +-   3.508% )
>         3044445  instructions             #      0.879 IPC     ( +-   0.134% )
>           21213  cache-references         #     19.130 M/sec   ( +-   1.612% )
>            2610  cache-misses             #      2.354 M/sec   ( +-  39.640% )
> 
>     0.001267355  seconds time elapsed   ( +-   4.762% )
> 
> that way even small changes in metrics can be identified as positive 
> effects of a patch, if the improvement is beyond the error 
> percentage that perf reports.
> 
> For example in the /bin/ls numbers i cited above, the 'instructions' 
> value can be trusted up to 99.8% (with a ~0.13% noise), while say 
> the cache-misses value can not really be trusted, as it has 40% of 
> noise. (Increasing the repeat count will drive down the noise level 
> - at the cost of longer measurement time.)
> 
> For your patch the improvement is so drastic that this isnt needed - 
> but the error estimations can be quite useful for more borderline 
> improvements. (and they are also useful in finding and proving small 
> performance regressions)

Thanks for the tip, let me try and use the repeats feature. BTW, nice
work on the perf counters, I was pleasantly surprised to see a
wonderful tool in the kernel with a good set of options and detailed
analysis capabilities.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
