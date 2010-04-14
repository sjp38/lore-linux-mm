Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 57E976B021D
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 02:52:37 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E6qZfi016882
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 14 Apr 2010 15:52:35 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A575C45DE54
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7405E45DE51
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0995F1DB8043
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:34 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A25C2E08006
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
In-Reply-To: <20100414031205.GE2493@dastard>
References: <20100413143659.GA2493@dastard> <20100414031205.GE2493@dastard>
Message-Id: <20100414155222.D150.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 14 Apr 2010 15:52:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Apr 14, 2010 at 12:36:59AM +1000, Dave Chinner wrote:
> > On Tue, Apr 13, 2010 at 08:39:29PM +0900, KOSAKI Motohiro wrote:
> > > > FWIW, the biggest problem here is that I have absolutely no clue on
> > > > how to test what the impact on lumpy reclaim really is. Does anyone
> > > > have a relatively simple test that can be run to determine what the
> > > > impact is?
> > > 
> > > So, can you please run two workloads concurrently?
> > >  - Normal IO workload (fio, iozone, etc..)
> > >  - echo $NUM > /proc/sys/vm/nr_hugepages
> > 
> > What do I measure/observe/record that is meaningful?
> 
> So, a rough as guts first pass - just run a large dd (8 times the
> size of memory - 8GB file vs 1GB RAM) and repeated try to allocate
> the entire of memory in huge pages (500) every 5 seconds. The IO
> rate is roughly 100MB/s, so it takes 75-85s to complete the dd.
> 
> The script:
> 
> $ cat t.sh
> #!/bin/bash
> 
> echo 0 > /proc/sys/vm/nr_hugepages
> echo 3 > /proc/sys/vm/drop_caches
> 
> dd if=/dev/zero of=/mnt/scratch/test bs=1024k count=8000 > /dev/null 2>&1 &
> 
> (
> for i in `seq 1 1 20`; do
>         sleep 5
>         /usr/bin/time --format="wall %e" sh -c "echo 500 > /proc/sys/vm/nr_hugepages" 2>&1
>         grep HugePages_Total /proc/meminfo
> done
> ) | awk '
>         /wall/ { wall += $2; cnt += 1 }
>         /Pages/ { pages[cnt] = $2 }
>         END { printf "average wall time %f\nPages step: ", wall / cnt ;
>                 for (i = 1; i <= cnt; i++) {
>                         printf "%d ", pages[i];
>                 }
>         }'
> ----
> 
> And the output looks like:
> 
> $ sudo ./t.sh
> average wall time 0.954500
> Pages step: 97 101 101 121 173 173 173 173 173 173 175 194 195 195 202 220 226 419 423 426
> $
> 
> Run 50 times in a loop, and the outputs averaged, the existing lumpy
> reclaim resulted in:
> 
> dave@test-1:~$ cat current.txt | awk -f av.awk
> av. wall = 0.519385 secs
> av Pages step: 192 228 242 255 265 272 279 284 289 294 298 303 307 322 342 366 383 401 412 420
> 
> And with my patch that disables ->writepage:
> 
> dave@test-1:~$ cat no-direct.txt | awk -f av.awk
> av. wall = 0.554163 secs
> av Pages step: 231 283 310 316 323 328 336 340 345 351 356 359 364 377 388 397 413 423 432 439
> 
> Basically, with my patch lumpy reclaim was *substantially* more
> effective with only a slight increase in average allocation latency
> with this test case.
> 
> I need to add a marker to the output that records when the dd
> completes, but from monitoring the writeback rates via PCP, they
> were in the balllpark of 85-100MB/s for the existing code, and
> 95-110MB/s with my patch.  Hence it improved both IO throughput and
> the effectiveness of lumpy reclaim.
> 
> On the down side, I did have an OOM killer invocation with my patch
> after about 150 iterations - dd failed an order zero allocation
> because there were 455 huge pages allocated and there were only
> _320_ available pages for IO, all of which were under IO. i.e. lumpy
> reclaim worked so well that the machine got into order-0 page
> starvation.
> 
> I know this is a simple test case, but it shows much better results
> than I think anyone (even me) is expecting...

Ummm...

Probably, I have to say I'm sorry. I guess my last mail give you
a misunderstand.
To be honest, I'm not interest this artificial non fragmentation case.
The above test-case does 1) discard all cache 2) fill pages by streaming
io. then, it makes artificial "file offset neighbor == block neighbor == PFN neighbor"
situation. then, file offset order writeout by flusher thread can make
PFN contenious pages effectively.

Why I dont interest it? because lumpy reclaim is a technique for
avoiding external fragmentation mess. IOW, it is for avoiding worst
case. but your test case seems to mesure best one.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
