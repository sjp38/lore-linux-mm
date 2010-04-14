Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 578876B0216
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 23:12:19 -0400 (EDT)
Date: Wed, 14 Apr 2010 13:12:05 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414031205.GE2493@dastard>
References: <20100413142445.D0FE.A69D9226@jp.fujitsu.com>
 <20100413102938.GX2493@dastard>
 <20100413201635.D119.A69D9226@jp.fujitsu.com>
 <20100413143659.GA2493@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100413143659.GA2493@dastard>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 12:36:59AM +1000, Dave Chinner wrote:
> On Tue, Apr 13, 2010 at 08:39:29PM +0900, KOSAKI Motohiro wrote:
> > > FWIW, the biggest problem here is that I have absolutely no clue on
> > > how to test what the impact on lumpy reclaim really is. Does anyone
> > > have a relatively simple test that can be run to determine what the
> > > impact is?
> > 
> > So, can you please run two workloads concurrently?
> >  - Normal IO workload (fio, iozone, etc..)
> >  - echo $NUM > /proc/sys/vm/nr_hugepages
> 
> What do I measure/observe/record that is meaningful?

So, a rough as guts first pass - just run a large dd (8 times the
size of memory - 8GB file vs 1GB RAM) and repeated try to allocate
the entire of memory in huge pages (500) every 5 seconds. The IO
rate is roughly 100MB/s, so it takes 75-85s to complete the dd.

The script:

$ cat t.sh
#!/bin/bash

echo 0 > /proc/sys/vm/nr_hugepages
echo 3 > /proc/sys/vm/drop_caches

dd if=/dev/zero of=/mnt/scratch/test bs=1024k count=8000 > /dev/null 2>&1 &

(
for i in `seq 1 1 20`; do
        sleep 5
        /usr/bin/time --format="wall %e" sh -c "echo 500 > /proc/sys/vm/nr_hugepages" 2>&1
        grep HugePages_Total /proc/meminfo
done
) | awk '
        /wall/ { wall += $2; cnt += 1 }
        /Pages/ { pages[cnt] = $2 }
        END { printf "average wall time %f\nPages step: ", wall / cnt ;
                for (i = 1; i <= cnt; i++) {
                        printf "%d ", pages[i];
                }
        }'
----

And the output looks like:

$ sudo ./t.sh
average wall time 0.954500
Pages step: 97 101 101 121 173 173 173 173 173 173 175 194 195 195 202 220 226 419 423 426
$

Run 50 times in a loop, and the outputs averaged, the existing lumpy
reclaim resulted in:

dave@test-1:~$ cat current.txt | awk -f av.awk
av. wall = 0.519385 secs
av Pages step: 192 228 242 255 265 272 279 284 289 294 298 303 307 322 342 366 383 401 412 420

And with my patch that disables ->writepage:

dave@test-1:~$ cat no-direct.txt | awk -f av.awk
av. wall = 0.554163 secs
av Pages step: 231 283 310 316 323 328 336 340 345 351 356 359 364 377 388 397 413 423 432 439

Basically, with my patch lumpy reclaim was *substantially* more
effective with only a slight increase in average allocation latency
with this test case.

I need to add a marker to the output that records when the dd
completes, but from monitoring the writeback rates via PCP, they
were in the balllpark of 85-100MB/s for the existing code, and
95-110MB/s with my patch.  Hence it improved both IO throughput and
the effectiveness of lumpy reclaim.

On the down side, I did have an OOM killer invocation with my patch
after about 150 iterations - dd failed an order zero allocation
because there were 455 huge pages allocated and there were only
_320_ available pages for IO, all of which were under IO. i.e. lumpy
reclaim worked so well that the machine got into order-0 page
starvation.

I know this is a simple test case, but it shows much better results
than I think anyone (even me) is expecting...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
