Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 525506B00C7
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 05:07:11 -0500 (EST)
Date: Wed, 17 Nov 2010 18:06:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/13] IO-less dirty throttling
Message-ID: <20101117100655.GA26501@localhost>
References: <20101117035821.000579293@intel.com>
 <20101117072538.GO22876@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20101117072538.GO22876@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 03:25:38PM +0800, Dave Chinner wrote:
> On Wed, Nov 17, 2010 at 11:58:21AM +0800, Wu Fengguang wrote:
> > Andrew,
> >
> > This is a revised subset of "[RFC] soft and dynamic dirty throttling limits"
> > <http://thread.gmane.org/gmane.linux.kernel.mm/52966>.
> >
> > The basic idea is to introduce a small region under the bdi dirty threshold.
> > The task will be throttled gently when stepping into the bottom of region,
> > and get throttled more and more aggressively as bdi dirty+writeback pages
> > goes up closer to the top of region. At some point the application will be
> > throttled at the right bandwidth that balances with the device write bandwidth.
> > (the first patch and documentation has more details)
> >
> > Changes from initial RFC:
> >
> > - adaptive ratelimiting, to reduce overheads when under throttle threshold
> > - prevent overrunning dirty limit on lots of concurrent dirtiers
> > - add Documentation/filesystems/writeback-throttling-design.txt
> > - lower max pause time from 200ms to 100ms; min pause time from 10ms to 1jiffy
> > - don't drop the laptop mode code
> > - update and comment the trace event
> > - benchmarks on concurrent dd and fs_mark covering both large and tiny files
> > - bdi->write_bandwidth updates should be rate limited on concurrent dirtiers,
> >   otherwise it will drift fast and fluctuate
> > - don't call balance_dirty_pages_ratelimit() when writing to already dirtied
> >   pages, otherwise the task will be throttled too much
> >
> > The patches are based on 2.6.37-rc2 and Jan's sync livelock patches. For easier
> > access I put them in
> >
> > git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v2
> 
> Great - just pulled it down and I'll start running some tests.
> 
> The tree that I'm testing has the vfs inode lock breakup in it, the
> inode cache SLAB_DESTROY_BY_RCU series, a large bunch of XFS lock
> breakup patches and now the above branch in it. It's here:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/dgc/xfsdev.git working
> 
> > On a simple test of 100 dd, it reduces the CPU %system time from 30% to 3%, and
> > improves IO throughput from 38MB/s to 42MB/s.
> 
> Excellent - I suspect that the reduction in contention on the inode
> writeback locks is responsible for dropping the CPU usage right down.
> 
> I'm seeing throughput for a _single_ large dd (100GB) increase from ~650MB/s
> to 700MB/s with your series. For other numbers of dd's:

Great! I didn't expect it to improve _throughput_ of single dd case.

I do noticed the reduction of CPU time for the single dd case, perhaps
due to no more contentions between the dd and flusher thread.

One big advantage of this IO-less implementation is that it does the
work without introducing any _extra_ bookkeeping data structures and
coordinations, and hence is very scalable.

>                                                         ctx switches
> # dd processes          total throughput         total        per proc
>    1                      700MB/s                   400/s       100/s
>    2                      700MB/s                   500/s       100/s
>    4                      700MB/s                   700/s       100/s
>    8                      690MB/s                 1,100/s       100/s
>   16                      675MB/s                 2,000/s       110/s
>   32                      675MB/s                 5,000/s       150/s
>  100                      650MB/s                22,000/s       210/s
> 1000                      600MB/s               160,000/s       160/s
> 
> A couple of things I noticed - firstly, the number of context
> switches scales roughly with the number of writing processes - is
> there any reason for waking every writer 100-200 times a second? At
> the thousand writer mark, we reach a context switch rate of more
> than one per page we complete IO on. Any idea on whether this can be
> improved at all?

It's simple to have the pause time stabilize at larger values.  I can
even easily detect that there are lots of concurrent dirtiers, and in
such cases adaptively enlarge it to no more than 200ms. Does that
value sound reasonable?

Precisely controlling pause time is the major capability pursued by
this implementation (comparing to the earlier attempts to wait on
write completions).

> Also, the system CPU usage while throttling stayed quite low but not
> constant. The more writing processes, the lower the system CPU usage
> (despite the increase in context switches). Further, if the dd's
> didn't all start at the same time, then system CPU usage would
> roughly double when the first dd's complete and cpu usage stayed
> high until all the writers completed. So there's some trigger when
> writers finish/exit there that is changing throttle behaviour.
> Increasing the number of writers does not seem to have any adverse
> affects.

Depending on various conditions, the pause time will be stabilizing at
different point in the range [1 jiffy, 100 ms]. This is a very big
range and I made no attempt (although possible) to further control it.

The smaller pause time, the more overheads in context switches _as
well as_ global_page_state() costs (mainly cacheline bouncing) in
balance_dirty_pages().

I wonder whether or not the majority context switches indicate a
corresponding invocation of balance_dirty_pages()?

> BTW, killing a thousand dd's all stuck on the throttle is near
> instantaneous. ;)

Because the dd's no longer get stuck in D state in get_request_wait()
:)

> > The fs_mark benchmark is interesting. The CPU overheads are almost reduced by
> > half. Before patch the benchmark is actually bounded by CPU. After patch it's
> > IO bound, but strangely the throughput becomes slightly slower.
> 
> The "App Overhead" that is measured by fs_mark is the time it spends
> doing stuff in userspace rather than in syscalls. Changes in the app
> overhead typically implies a change in syscall CPU cache footprint. A
> substantial reduction in app overhead for the same amount of work
> is good. :)

Got it :)  This is an extra bonus, maybe because balance_dirty_pages()
no longer calls into the complex IO stack to writeout pages.

> [cut-n-paste from your comment about being io bound below]
> 
> > avg-cpu:  %user   %nice %system %iowait  %steal   %idle
> >            0.17    0.00   97.87    1.08    0.00    0.88
> 
> That looks CPU bound, not IO bound.

Yes, it's collected in vanilla kernel.

> > Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
> > sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
> > sdc               0.00    63.00    0.00  125.00     0.00  1909.33    30.55     3.88   31.65   6.57  82.13
> > sdd               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
> > sde               0.00    19.00    0.00  112.00     0.00  1517.17    27.09     3.95   35.33   8.00  89.60
> > sdg               0.00    92.67    0.33  126.00     2.67  1773.33    28.12    14.83  120.78   7.73  97.60
> > sdf               0.00    32.33    0.00   91.67     0.00  1408.17    30.72     4.84   52.97   7.72  70.80
> > sdh               0.00    17.67    0.00    5.00     0.00   124.00    49.60     0.07   13.33   9.60   4.80
> > sdi               0.00    44.67    0.00    5.00     0.00   253.33   101.33     0.15   29.33  10.93   5.47
> > sdl               0.00   168.00    0.00  135.67     0.00  2216.33    32.67     6.41   45.42   5.75  78.00
> > sdk               0.00   225.00    0.00  123.00     0.00  2355.83    38.31     9.50   73.03   6.94  85.33
> > sdj               0.00     1.00    0.00    2.33     0.00    26.67    22.86     0.01    2.29   1.71   0.40
> > sdb               0.00    14.33    0.00  101.67     0.00  1278.00    25.14     2.02   19.95   7.16  72.80
> > sdm               0.00   150.33    0.00  144.33     0.00  2344.50    32.49     5.43   33.94   5.39  77.73
> 
> And that's totalling ~1000 iops during the workload - you're right
> in that it doesn't look at all well balanced. The device my test
> filesystem is on is running at ~15,000 iops and 120MB/s for the same
> workload, but there is another layer of reordering on the host as
> well as 512MB of BBWC between the host and the spindles, so maybe
> you won't be able to get near that number with your setup....

OK.

> [.....]
> 
> > avg                                    1182.761      533488581.833
> >
> > 2.6.36+
> > FSUse%        Count         Size    Files/sec     App Overhead
> ....
> > avg                                    1146.768      294684785.143
> 
> The difference between the files/s numbers is pretty much within
> typical variation of the benchmark. I tend to time the running of
> the entire benchmark because the files/s output does not include the
> "App Overhead" time and hence you can improve files/s but increase
> the app overhead and the overall wall time can be significantly
> slower...

Got it.

> FWIW, I'd consider the throughput (1200 files/s) to quite low for 12
> disks and a number of CPUs being active. I'm not sure how you
> configured the storage/filesystem, but you should configure the
> filesystem with at least 2x as many AGs as there are CPUs, and run
> one create thread per CPU rather than one per disk.  Also, making
> sure you have a largish log (512MB in this case) is helpful, too.

The test machine has 16 CPUs and 12 disks. I used plain simple mkfs
commands. I don't have access to the test box now (it's running LKP
for the just released -rc2). I'll checkout the xfs configuration and
recreate it with more AGs and log. And yeah it's a good idea to
increase the number of threads, with "-t 16"? btw, is it a must to run
the test for one whole day? If not, which optarg can be decreased?
"-L 64"?

> For example, I've got a simple RAID0 of 12 disks that is 1.1TB in
> size when I stripe the outer 10% of the drives together (or 18TB if
> I stripe the larger inner partitions on the disks). The way I
> normally run it (on an 8p/4GB RAM VM) is:
> 
> In the host:
> 
> $ cat dmtab.fast.12drive
> 0 2264924160 striped  12 1024 /dev/sdb1 0 /dev/sdc1 0 /dev/sdd1 0 /dev/sde1 0 /dev/sdf1 0 /dev/sdg1 0 /dev/sdh1 0 /dev/sdi1 0 /dev/sdj1 0 /dev/sdk1 0 /dev/sdl1 0 /dev/sdm1 0
> $ sudo dmsetup create fast dmtab.fast.12drive
> $ sudo mount -o nobarrier,logbsize=262144,delaylog,inode64 /dev/mapper/fast /mnt/fast
> 
> [VM creation script uses fallocate to preallocate 1.1TB file as raw
> disk image inside /mnt/fast, appears to guest as /dev/vdb]
> 
> In the VM:
> 
> # mkfs.xfs -f -l size=131072b -d agcount=16 /dev/vdb
> ....
> # mount -o nobarrier,inode64,delaylog,logbsize=262144 /dev/vdb /mnt/scratch
> # /usr/bin/time ./fs_mark -D 10000 -S0 -n 100000 -s 1 -L 63 \
> >       -d /mnt/scratch/0 -d /mnt/scratch/1 \
> >       -d /mnt/scratch/2 -d /mnt/scratch/3 \
> >       -d /mnt/scratch/4 -d /mnt/scratch/5 \
> >       -d /mnt/scratch/6 -d /mnt/scratch/7
> 
> #  ./fs_mark  -D  10000  -S0  -n  100000  -s  1  -L  63  -d  /mnt/scratch/0  -d  /mnt/scratch/1  -d  /mnt/scratch/2  -d  /mnt/scratch/3  -d  /mnt/scratch/4  -d  /mnt/scratch/5  -d  /mnt/scratch/6  -d  /mnt/scratch/7
> #       Version 3.3, 8 thread(s) starting at Wed Nov 17 15:27:33 2010
> #       Sync method: NO SYNC: Test does not issue sync() or fsync() calls.
> #       Directories:  Time based hash between directories across 10000 subdirectories with 180 seconds per subdirectory.
> #       File names: 40 bytes long, (16 initial bytes of time stamp with 24 random bytes at end of name)
> #       Files info: size 1 bytes, written with an IO size of 16384 bytes per write
> #       App overhead is time in microseconds spent in the test not doing file writing related system calls.
> 
> FSUse%        Count         Size    Files/sec     App Overhead
>      0       800000            1      27825.7         11686554
>      0      1600000            1      22650.2         13199876
>      1      2400000            1      23606.3         12297973
>      1      3200000            1      23060.5         12474339
>      1      4000000            1      22677.4         12731120
>      2      4800000            1      23095.7         12142813
>      2      5600000            1      22639.2         12813812
>      2      6400000            1      23447.1         12330158
>      3      7200000            1      22775.8         12548811
>      3      8000000            1      22766.5         12169732
>      3      8800000            1      21685.5         12546771
>      4      9600000            1      22899.5         12544273
>      4     10400000            1      22950.7         12894856
> .....
> 
> The above numbers are without your patch series. The following
> numbers are with your patch series:
> 
> FSUse%        Count         Size    Files/sec     App Overhead
>      0       800000            1      26163.6         10492957
>      0      1600000            1      21960.4         10431605
>      1      2400000            1      22099.2         10971110
>      1      3200000            1      22052.1         10470168
>      1      4000000            1      21264.4         10398188
>      2      4800000            1      21815.3         10445699
>      2      5600000            1      21557.6         10504866
>      2      6400000            1      21856.0         10421309
>      3      7200000            1      21853.5         10613164
>      3      8000000            1      21309.4         10642358
>      3      8800000            1      22130.8         10457972
> .....
> 
> Ok, so throughput is also down by ~5% from ~23k files/s to ~22k
> files/s.

Hmm. The bad thing is I have no idea on how to avoid that. It's not
doing IO any more, so what can I do to influence the IO throughput? ;)

Maybe there are unnecessary sleep points in the writeout path?  Or
even one flusher thread is not enough _now_?  Anyway that seems not
the flaw of _this_ patchset, but problems exposed and unfortunately
made more imminent by it.

btw, do you have the total elapsed time before/after patch? As you
said it's the final criterion :)

> On the plus side:
> 
> avg-cpu:  %user   %nice %system %iowait  %steal   %idle
>            1.91    0.00   43.45   46.56    0.00    8.08
> 
> Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await  svctm  %util
> vda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
> vdb               0.00 12022.20    1.60 11431.60     0.01   114.09    20.44    32.34    2.82   0.08  94.64
> sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
> 
> The number of write IOs has dropped N?ignificantly and CPU usage is
> more than halved - this was running at ~98% system time!  So for a
> ~5% throughput reduction, CPU usage has dropped by ~55% and the
> number of write IOs have dropped by ~25%. That's a pretty good
> result - it's the single biggest drop in CPU usage as a result of
> preventing lock contention I've seen on an 8p machine in the past 6
> months. Very promising - I guess it's time to look at the code again. :)

Thanks. The code is vastly rewrote, fortunately you didn't read it
before. I have good feelings on the current code. In V3 it may be
rebased onto the memcg works by Greg, but the basic algorithms will
remain the same.

> Hmmm - looks like the probably bottleneck is that the flusher thread
> is close to CPU bound:
> 
>   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
>  2215 root      20   0     0    0    0 R   86  0.0   2:16.43 flush-253:16
> 
>              samples  pcnt function                        DSO
>              _______ _____ _______________________________ _________________
> 
>             32436.00  5.8% _xfs_buf_find                   [kernel.kallsyms]
>             26119.00  4.7% kmem_cache_alloc                [kernel.kallsyms]
>             17700.00  3.2% __ticket_spin_lock              [kernel.kallsyms]
>             14592.00  2.6% xfs_log_commit_cil              [kernel.kallsyms]
>             14341.00  2.6% _raw_spin_unlock_irqrestore     [kernel.kallsyms]
>             12537.00  2.2% __kmalloc                       [kernel.kallsyms]
>             12098.00  2.2% writeback_single_inode          [kernel.kallsyms]
>             12078.00  2.2% xfs_iunlock                     [kernel.kallsyms]
>             10712.00  1.9% redirty_tail                    [kernel.kallsyms]
>             10706.00  1.9% __make_request                  [kernel.kallsyms]
>             10469.00  1.9% bit_waitqueue                   [kernel.kallsyms]
>             10107.00  1.8% kfree                           [kernel.kallsyms]
>             10028.00  1.8% _cond_resched                   [kernel.kallsyms]
>              9244.00  1.7% xfs_fs_write_inode              [kernel.kallsyms]
>              8759.00  1.6% xfs_iflush_cluster              [kernel.kallsyms]
>              7944.00  1.4% queue_io                        [kernel.kallsyms]
>              7924.00  1.4% radix_tree_gang_lookup_tag_slot [kernel.kallsyms]
>              7468.00  1.3% kmem_cache_free                 [kernel.kallsyms]
>              7454.00  1.3% xfs_bmapi                       [kernel.kallsyms]
>              7149.00  1.3% writeback_sb_inodes             [kernel.kallsyms]
>              5882.00  1.1% xfs_btree_lookup                [kernel.kallsyms]
>              5811.00  1.0% __memcpy                        [kernel.kallsyms]
>              5446.00  1.0% xfs_alloc_ag_vextent_near       [kernel.kallsyms]
>              5346.00  1.0% xfs_trans_buf_item_match        [kernel.kallsyms]
>              4704.00  0.8% xfs_perag_get                   [kernel.kallsyms]
> 
> That's looking like it's XFS overhead flushing inodes, so that's not
> an issue caused by this patch. Indeed, I'm used to seeing 30-40% of
> the CPU time here in __ticket_spin_lock, so it certainly appears
> that most of the CPU time saving comes from the removal of
> contention on the inode_wb_list_lock. I guess it's time for me to
> start looking at multiple bdi-flusher threads again....

Heh.

> > I noticed that
> >
> > 1) BdiWriteback can grow very large. For example, bdi 8:16 has 72960KB
> >    writeback pages, however the disk IO queue can hold at most
> >    nr_request*max_sectors_kb=128*512kb=64MB writeback pages. Maybe xfs manages
> >    to create perfect sequential layouts and writes, and the other 8MB writeback
> >    pages are flying inside the disk?
> 
> There's a pretty good chance that this is exactly what is happening.

That's amazing! It's definitely running at the ultimate optimization
goal (for the sequential part).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
