Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5924C6B004D
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 04:36:10 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7A8WeXE011683
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 14:02:40 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7A8a5KO659580
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 14:06:06 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7A8a447026062
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 18:36:05 +1000
Date: Mon, 10 Aug 2009 14:06:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Help Resource Counters Scale Better (v3)
Message-ID: <20090810083602.GA7176@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090807221238.GJ9686@balbir.in.ibm.com> <39eafe409b85053081e9c6826005bb06.squirrel@webmail-b.css.fujitsu.com> <20090808060531.GL9686@balbir.in.ibm.com> <99f2a13990d68c34c76c33581949aefd.squirrel@webmail-b.css.fujitsu.com> <20090809121530.GA5833@balbir.in.ibm.com> <20090810093229.10db7185.kamezawa.hiroyu@jp.fujitsu.com> <20090810053025.GC5257@balbir.in.ibm.com> <20090810144559.ac5a3499.kamezawa.hiroyu@jp.fujitsu.com> <20090810152205.d37d8e2f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090810152205.d37d8e2f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, andi.kleen@intel.com, Prarit Bhargava <prarit@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-10 15:22:05]:

> On Mon, 10 Aug 2009 14:45:59 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > Do you agree?
> > 
> > Ok. Config is enough at this stage.
> > 
> > The last advice for merge is, it's better to show the numbers or
> > ask someone who have many cpus to measure benefits. Then, Andrew can
> > know how this is benefical.
> > (My box has 8 cpus. But maybe your IBM collaegue has some bigger one)
> > 
> > In my experience (in my own old trial),
> >  - lock contention itself is low. not high.
> >  - but cacheline-miss, pingpong is very very frequent.
> > 
> > Then, this patch has some benefit logically but, in general,
> > File-I/O, swapin-swapout, page-allocation/initalize etc..dominates
> > the performance of usual apps. You'll have to be careful to select apps
> > to measure the benfits of this patch by application performance.
> > (And this is why I don't feel so much emergency as you do)
> > 
> 
> Why I say "I want to see the numbers" again and again is that
> this is performance improvement with _bad side effect_.
> If this is an emergent trouble, and need fast-track, which requires us
> "fix small problems later", plz say so. 
>

OK... I finally got a bigger machine (24 CPUs). I ran a simple
program called parallel_pagefault, which does pagefault's in parallel
(runs on every other CPU) and allocates 10K pages and touches the
data allocated, unmaps and repeats the process. I ran the program
for 300 seconds. With the patch, I was able to fault in twice
the number of pages as I was able to without the patch. I used
perf tool from tools/perf in the kernel

With patch

 Performance counter stats for '/home/balbir/parallel_pagefault':

 7188177.405648  task-clock-msecs         #     23.926 CPUs 
         423130  context-switches         #      0.000 M/sec
            210  CPU-migrations           #      0.000 M/sec
       49851597  page-faults              #      0.007 M/sec
  5900210219604  cycles                   #    820.821 M/sec
   424658049425  instructions             #      0.072 IPC  
     7867744369  cache-references         #      1.095 M/sec
     2882370051  cache-misses             #      0.401 M/sec

  300.431591843  seconds time elapsed

Without Patch

 Performance counter stats for '/home/balbir/parallel_pagefault':

 7192804.124144  task-clock-msecs         #     23.937 CPUs 
         424691  context-switches         #      0.000 M/sec
            267  CPU-migrations           #      0.000 M/sec
       28498113  page-faults              #      0.004 M/sec
  5826093739340  cycles                   #    809.989 M/sec
   408883496292  instructions             #      0.070 IPC  
     7057079452  cache-references         #      0.981 M/sec
     3036086243  cache-misses             #      0.422 M/sec

  300.485365680  seconds time elapsed


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
