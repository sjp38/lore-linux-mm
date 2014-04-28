Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C5E866B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:48:02 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so6297806pab.26
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 16:48:02 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id gr5si11413408pac.442.2014.04.28.16.47.59
        for <linux-mm@kvack.org>;
        Mon, 28 Apr 2014 16:48:01 -0700 (PDT)
Date: Tue, 29 Apr 2014 09:47:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf] Postgresql performance problems with IO latency,
 especially during fsync()
Message-ID: <20140428234756.GM15995@dastard>
References: <20140326191113.GF9066@alap3.anarazel.de>
 <20140409092009.GA27519@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409092009.GA27519@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: andres@2ndquadrant.com, rhaas@alap3.anarazel.de, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>

ping?

On Wed, Apr 09, 2014 at 07:20:09PM +1000, Dave Chinner wrote:
> On Wed, Mar 26, 2014 at 08:11:13PM +0100, Andres Freund wrote:
> > Hi,
> > 
> > At LSF/MM there was a slot about postgres' problems with the kernel. Our
> > top#1 concern is frequent slow read()s that happen while another process
> > calls fsync(), even though we'd be perfectly fine if that fsync() took
> > ages.
> > The "conclusion" of that part was that it'd be very useful to have a
> > demonstration of the problem without needing a full blown postgres
> > setup. I've quickly hacked something together, that seems to show the
> > problem nicely.
> > 
> > For a bit of context: lwn.net/SubscriberLink/591723/940134eb57fcc0b8/
> > and the "IO Scheduling" bit in
> > http://archives.postgresql.org/message-id/20140310101537.GC10663%40suse.de
> > 
> > The tools output looks like this:
> > gcc -std=c99 -Wall -ggdb ~/tmp/ioperf.c -o ioperf && ./ioperf
> > ...
> > wal[12155]: avg: 0.0 msec; max: 0.0 msec
> > commit[12155]: avg: 0.2 msec; max: 15.4 msec
> > wal[12155]: avg: 0.0 msec; max: 0.0 msec
> > read[12157]: avg: 0.2 msec; max: 9.4 msec
> > ...
> > read[12165]: avg: 0.2 msec; max: 9.4 msec
> > wal[12155]: avg: 0.0 msec; max: 0.0 msec
> > starting fsync() of files
> > finished fsync() of files
> > read[12162]: avg: 0.6 msec; max: 2765.5 msec
> > 
> > So, the average read time is less than one ms (SSD, and about 50% cached
> > workload). But once another backend does the fsync(), read latency
> > skyrockets.
> > 
> > A concurrent iostat shows the problem pretty clearly:
> > Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s	avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
> > sda               1.00     0.00 6322.00  337.00    51.73     4.38	17.26     2.09    0.32    0.19    2.59   0.14  90.00
> > sda               0.00     0.00 6016.00  303.00    47.18     3.95	16.57     2.30    0.36    0.23    3.12   0.15  94.40
> > sda               0.00     0.00 6236.00 1059.00    49.52    12.88	17.52     5.91    0.64    0.20    3.23   0.12  88.40
> > sda               0.00     0.00  105.00 26173.00     0.89   311.39	24.34   142.37    5.42   27.73    5.33   0.04 100.00
> > sda               0.00     0.00   78.00 27199.00     0.87   324.06	24.40   142.30    5.25   11.08    5.23   0.04 100.00
> > sda               0.00     0.00   10.00 33488.00     0.11   399.05	24.40   136.41    4.07  100.40    4.04   0.03 100.00
> > sda               0.00     0.00 3819.00 10096.00    31.14   120.47	22.31    42.80    3.10    0.32    4.15   0.07  96.00
> > sda               0.00     0.00 6482.00  346.00    52.98     4.53	17.25     1.93    0.28    0.20    1.80   0.14  93.20
> > 
> > While the fsync() is going on (or the kernel decides to start writing
> > out aggressively for some other reason) the amount of writes to the disk
> > is increased by two orders of magnitude. Unsurprisingly with disastrous
> > consequences for read() performance. We really want a way to pace the
> > writes issued to the disk more regularly.
> 
> Hi Andreas,
> 
> I've finally dug myself out from under the backlog from LSFMM far
> enough to start testing this on my local IO performance test rig.
> 
> tl;dr: I can't reproduce this peaky behaviour on my test rig.
> 
> I'm running in a 16p VM with 16GB RAM (in 4 nodes via fake-numa) and
> an unmodified benchmark on a current 3.15-linus tree. All storage
> (guest and host) is XFS based, guest VMs use virtio and direct IO to
> the backing storage.  The host is using noop IO scheduling.
> 
> The first IO setup I ran was a 100TB XFS filesystem in the guest.
> The backing file is a sparse file on an XFS filesystem on a pair of
> 240GB SSDs (Samsung 840 EVO) in RAID 0 via DM.  The SSDs are
> exported as JBOD from a RAID controller which has 1GB of FBWC.  The
> guest is capable of sustaining around 65,000 random read IOPS and
> 40,000 write IOPS through this filesystem depending on the tests
> being run.
> 
> The iostat output looks like this:
> 
> Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
> vdc               0.00     0.00 1817.00  315.40    18.80     6.93    24.71     0.80    0.38    0.38    0.37   0.31  66.24
> vdc               0.00     0.00 2094.20  323.20    21.82     7.10    24.50     0.81    0.33    0.34    0.27   0.28  68.48
> vdc               0.00     0.00 1989.00 4500.20    20.50    56.64    24.34    24.82    3.82    0.43    5.32   0.12  80.16
> vdc               0.00     0.00 2019.80  320.80    20.83     7.05    24.39     0.83    0.35    0.36    0.32   0.29  69.04
> vdc               0.00     0.00 2206.60  323.20    22.57     7.10    24.02     0.87    0.34    0.34    0.33   0.28  71.92
> vdc               0.00     0.00 2437.20  329.60    25.79     7.24    24.45     0.83    0.30    0.30    0.27   0.26  71.76
> vdc               0.00     0.00 1224.40 11263.80    12.88   136.38    24.48    64.90    5.20    0.69    5.69   0.07  84.96
> vdc               0.00     0.00 2074.60  319.40    21.03     7.01    23.99     0.84    0.35    0.36    0.30   0.29  68.96
> vdc               0.00     0.00 1999.00  881.60    20.81    13.61    24.47     4.23    1.43    0.35    3.88   0.23  67.36
> vdc               0.00     0.00 1193.40 2273.00    12.42    29.68    24.87    11.70    3.40    0.53    4.91   0.18  60.96
> vdc               0.00     0.00 1724.00  314.40    17.80     6.91    24.83     0.74    0.36    0.36    0.35   0.30  61.52
> vdc               0.00     0.00 2605.20  325.60    24.67     7.15    22.24     0.90    0.31    0.31    0.25   0.25  72.72
> vdc               0.00     0.00 2340.60  324.40    23.85     7.12    23.80     0.83    0.31    0.31    0.29   0.26  68.96
> vdc               0.00     0.00 2749.60  329.40    28.51     7.24    23.78     0.90    0.29    0.30    0.25   0.24  75.04
> vdc               0.00     0.00 2619.60  324.60    27.72     7.13    24.24     0.88    0.30    0.30    0.28   0.24  71.76
> vdc               0.00     0.00 1608.60 4532.40    17.17    56.40    24.54    25.78    4.20    0.50    5.51   0.12  75.36
> vdc               0.00     0.00 2361.00  326.40    23.62     7.17    23.47     0.87    0.33    0.33    0.30   0.26  69.92
> vdc               0.00     0.00 2460.00  326.00    25.89     7.16    24.30     0.88    0.32    0.32    0.26   0.26  72.72
> vdc               0.00     0.00 2519.00  325.40    25.96     7.14    23.83     0.90    0.32    0.32    0.30   0.26  74.32
> vdc               0.00     0.00 2709.80  326.20    28.91     7.17    24.34     0.94    0.31    0.30    0.36   0.25  75.52
> vdc               0.00     0.00 2676.65  329.74    28.82     7.24    24.56     0.86    0.28    0.29    0.25   0.24  71.22
> vdc               0.00     0.00 1788.40 4506.80    18.77    56.66    24.54    23.22    3.69    0.45    4.97   0.12  74.88
> vdc               0.00     0.00 1850.40  319.60    19.76     7.02    25.28     0.80    0.37    0.37    0.34   0.30  64.80
> 
> Its obvious where the fsyncs are hitting, but they are making
> almost no impact on the read performance. The benchmark is
> simple not generating enough dirty data to overload the IO
> subsystem, and hence there's no latency spikes to speak of.
> 
> Benchmark output across fsyncs also demonstrates that:
> 
> ....
> read[12494]: avg: 0.4 msec; max: 9.8 msec
> read[12499]: avg: 0.4 msec; max: 9.8 msec
> read[12495]: avg: 0.4 msec; max: 9.8 msec
> commit[12491]: avg: 0.0 msec; max: 6.3 msec
> wal[12491]: avg: 0.0 msec; max: 0.0 msec
> wal[12491]: avg: 0.0 msec; max: 0.0 msec
> starting fsync() of files
> finished fsync() of files
> wal[12491]: avg: 0.0 msec; max: 0.7 msec
> commit[12491]: avg: 0.1 msec; max: 15.8 msec
> wal[12491]: avg: 0.0 msec; max: 0.1 msec
> wal[12491]: avg: 0.0 msec; max: 0.1 msec
> read[12492]: avg: 0.6 msec; max: 10.0 msec
> read[12496]: avg: 0.6 msec; max: 10.0 msec
> read[12507]: avg: 0.6 msec; max: 10.0 msec
> read[12505]: avg: 0.6 msec; max: 10.0 msec
> ....
> 
> So, I though switching to spinning disks might show the problem.
> Same VM, this time using a 17TB linearly preallocated image file on
> an 18TB XFS filesystem on the host (virtio in the guest again) on a
> 12 disk RAID-0 (DM again) using a 12x2TB SAS drives exported as JBOD
> from a RAID controller with 512MB of BBWC. This is capable of about
> 2,000 random read IOPs, and write IOPS is dependent on the BBWC
> flushing behaviour (peaks at about 15,000, sustains 1500).
> 
> Again, I don't see any bad behaviour:
> 
> Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
> vdd               0.00     0.00  128.00  154.20     1.46     6.02    54.24     1.02    3.62    7.22    0.62   3.17  89.44
> vdd               0.00     0.00  133.80  154.40     1.43     6.03    53.04     1.08    3.76    7.42    0.59   3.05  87.84
> vdd               0.00     0.00  132.40  751.60     1.36    12.75    32.70     7.26    8.21    7.90    8.27   1.06  93.76
> vdd               0.00     0.00  138.60  288.60     1.47     7.62    43.57     2.69    6.30    7.24    5.85   2.15  91.68
> vdd               0.00     0.00  141.20  157.00     1.51     6.12    52.36     1.12    3.75    7.26    0.59   3.11  92.64
> vdd               0.00     0.00  136.80  154.00     1.52     6.02    53.09     1.04    3.57    6.92    0.60   3.10  90.08
> vdd               0.00     0.00  135.00  154.20     1.46     6.02    52.99     1.04    3.60    7.00    0.62   3.03  87.68
> vdd               0.00     0.00  147.20  155.80     1.50     6.09    51.26     1.19    3.92    7.45    0.59   3.06  92.72
> vdd               0.00     0.00  139.60  154.00     1.50     6.02    52.43     1.03    3.53    6.79    0.58   2.97  87.28
> vdd               0.00     0.00  126.80  913.80     1.27    14.81    31.63     7.87    7.56    9.02    7.36   0.89  92.16
> vdd               0.00     0.00  148.20  156.80     1.51     6.11    51.15     1.17    3.83    7.25    0.59   3.03  92.32
> vdd               0.00     0.00  142.60  155.80     1.49     6.09    52.03     1.12    3.76    7.23    0.60   3.05  90.88
> vdd               0.00     0.00  146.00  156.60     1.49     6.12    51.48     1.16    3.84    7.32    0.60   3.03  91.76
> vdd               0.00     0.00  148.80  157.20     1.56     6.14    51.54     1.10    3.58    6.78    0.54   2.92  89.36
> vdd               0.00     0.00  149.80  156.80     1.52     6.12    51.05     1.14    3.73    7.10    0.52   2.96  90.88
> vdd               0.00     0.00  127.20  910.60     1.29    14.82    31.80     8.17    7.87    8.62    7.77   0.88  91.44
> vdd               0.00     0.00  150.80  157.80     1.58     6.15    51.27     1.09    3.53    6.67    0.52   2.91  89.92
> vdd               0.00     0.00  153.00  156.60     1.53     6.12    50.56     1.17    3.80    7.07    0.60   2.95  91.20
> vdd               0.00     0.00  161.20  157.00     1.54     6.13    49.36     1.27    4.00    7.36    0.55   2.97  94.48
> vdd               0.00     0.00  152.10  157.09     1.55     6.14    50.91     1.15    3.73    7.06    0.50   2.98  92.22
> vdd               0.00     0.00  154.80  157.80     1.50     6.16    50.18     1.19    3.82    7.14    0.57   2.88  90.00
> vdd               0.00     0.00  122.20  922.80     1.24    14.93    31.70     8.30    7.94    8.81    7.83   0.90  93.68
> vdd               0.00     0.00  139.80  153.60     1.46     5.98    51.98     1.09    3.74    7.14    0.65   3.02  88.48
> vdd               0.00     0.00  134.60  153.60     1.44     6.00    52.87     1.09    3.78    7.38    0.63   3.15  90.88
> vdd               0.00     0.00  141.00  153.40     1.55     5.99    52.49     1.05    3.57    6.79    0.60   3.04  89.44
> vdd               0.00     0.00  130.20  154.20     1.44     6.02    53.76     1.04    3.65    7.28    0.59   3.14  89.44
> vdd               0.00     0.00  136.60  154.20     1.30     6.02    51.52     1.19    4.07    8.02    0.58   3.03  88.24
> vdd               0.00     0.00  119.00  872.20     1.29    14.29    32.20     7.98    8.05    8.59    7.98   0.93  92.64
> vdd               0.00     0.00  139.00  154.00     1.58     6.00    53.01     1.06    3.62    6.95    0.61   3.12  91.52
> vdd               0.00     0.00  146.00  155.40     1.52     6.07    51.60     1.12    3.71    7.05    0.57   3.01  90.72
> vdd               0.00     0.00  145.20  156.60     1.55     6.12    52.01     1.13    3.73    7.10    0.60   3.07  92.80
> vdd               0.00     0.00  147.80  156.80     1.51     6.12    51.36     1.13    3.72    7.07    0.56   2.97  90.56
> vdd               0.00     0.00  142.80  157.00     1.48     6.12    51.98     1.11    3.70    7.20    0.52   3.02  90.56
> vdd               0.00     0.00  125.20  922.00     1.36    14.92    31.85     8.34    7.96    8.47    7.90   0.88  92.56
> 
> Again, you can see exactly where the fsyncs are hitting, and again
> they are not massive spikes of write IO. And read latencies are showing:
> 
> read[12711]: avg: 6.1 msec; max: 182.2 msec
> ...
> read[12711]: avg: 6.0 msec; max: 198.8 msec
> ....
> read[12711]: avg: 5.9 msec; max: 158.8 msec
> ....
> read[12711]: avg: 6.1 msec; max: 127.5 msec
> ....
> read[12711]: avg: 5.9 msec; max: 355.6 msec
> ....
> read[12711]: avg: 6.0 msec; max: 262.8 msec
> ....
> 
> No significant outliers. The same for commits and wal:
> 
> wal[12701]: avg: 0.0 msec; max: 0.2 msec
> wal[12701]: avg: 0.0 msec; max: 0.1 msec
> commit[12701]: avg: 0.0 msec; max: 1.0 msec
> wal[12701]: avg: 0.0 msec; max: 0.1 msec
> wal[12701]: avg: 0.0 msec; max: 0.1 msec
> starting fsync() of files
> finished fsync() of files
> wal[12701]: avg: 0.0 msec; max: 0.1 msec
> commit[12701]: avg: 0.1 msec; max: 129.2 msec
> wal[12701]: avg: 0.0 msec; max: 0.1 msec
> wal[12701]: avg: 0.0 msec; max: 0.1 msec
> commit[12701]: avg: 0.0 msec; max: 0.9 msec
> wal[12701]: avg: 0.0 msec; max: 0.2 msec
> wal[12701]: avg: 0.0 msec; max: 0.1 msec
> wal[12701]: avg: 0.0 msec; max: 0.1 msec
> commit[12701]: avg: 0.0 msec; max: 23.1 msec
> 
> I'm not sure how you were generating the behaviour you reported, but
> the test program as it stands does not appear to be causing any
> problems at all on the sort of storage I'd expect large databases to
> be hosted on....
> 
> I've tried a few tweaks to the test program, but I haven't been able
> to make it misbehave. What do I need to tweak in the test program or
> my test VM to make the kernel misbehave like you reported?
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com`
> _______________________________________________
> Lsf mailing list
> Lsf@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/lsf
> 

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
