Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id C6DE66B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 07:00:02 -0400 (EDT)
Date: Tue, 3 Jul 2012 11:59:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [MMTests] IO metadata on XFS
Message-ID: <20120703105951.GB14154@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120629112505.GF14154@suse.de>
 <20120701235458.GM19223@dastard>
 <20120702063226.GA32151@infradead.org>
 <20120702143215.GS14154@suse.de>
 <20120702193516.GX14154@suse.de>
 <20120703001928.GV19223@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120703001928.GV19223@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, dri-devel@lists.freedesktop.org, Keith Packard <keithp@keithp.com>, Eugeni Dodonov <eugeni.dodonov@intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>

On Tue, Jul 03, 2012 at 10:19:28AM +1000, Dave Chinner wrote:
> On Mon, Jul 02, 2012 at 08:35:16PM +0100, Mel Gorman wrote:
> > Adding dri-devel and a few others because an i915 patch contributed to
> > the regression.
> > 
> > On Mon, Jul 02, 2012 at 03:32:15PM +0100, Mel Gorman wrote:
> > > On Mon, Jul 02, 2012 at 02:32:26AM -0400, Christoph Hellwig wrote:
> > > > > It increases the CPU overhead (dirty_inode can be called up to 4
> > > > > times per write(2) call, IIRC), so with limited numbers of
> > > > > threads/limited CPU power it will result in lower performance. Where
> > > > > you have lots of CPU power, there will be little difference in
> > > > > performance...
> > > > 
> > > > When I checked it it could only be called twice, and we'd already
> > > > optimize away the second call.  I'd defintively like to track down where
> > > > the performance changes happend, at least to a major version but even
> > > > better to a -rc or git commit.
> > > > 
> > > 
> > > By all means feel free to run the test yourself and run the bisection :)
> > > 
> > > It's rare but on this occasion the test machine is idle so I started an
> > > automated git bisection. As you know the milage with an automated bisect
> > > varies so it may or may not find the right commit. Test machine is sandy so
> > > http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-xfs/sandy/comparison.html
> > > is the report of interest. The script is doing a full search between v3.3 and
> > > v3.4 for a point where average files/sec for fsmark-single drops below 25000.
> > > I did not limit the search to fs/xfs on the off-chance that it is an
> > > apparently unrelated patch that caused the problem.
> > > 
> > 
> > It was obvious very quickly that there were two distinct regression so I
> > ran two bisections. One led to a XFS and the other led to an i915 patch
> > that enables RC6 to reduce power usage.
> > 
> > [aa464191: drm/i915: enable plain RC6 on Sandy Bridge by default]
> 
> Doesn't seem to be the major cause of the regression. By itself, it
> has impact, but the majority comes from the XFS change...
> 

The fact it has an impact at all is weird but lets see what the DRI
folks think about it.

> > [c999a223: xfs: introduce an allocation workqueue]
> 
> Which indicates that there is workqueue scheduling issues, I think.
> The same amount of work is being done, but half of it is being
> pushed off into a workqueue to avoid stack overflow issues (*).  I
> tested the above patch in anger on an 8p machine, similar to the
> machine you saw no regressions on, but the workload didn't drive it
> to being completely CPU bound (only about 90%) so the allocation
> work was probably always scheduled quickly.
> 

What test were you using?

> How many worker threads have been spawned on these machines
> that are showing the regression?

20 or 21 generally. An example list as spotted by top looks like

kworker/0:0        
kworker/0:1        
kworker/0:2        
kworker/1:0        
kworker/1:1        
kworker/1:2        
kworker/2:0        
kworker/2:1        
kworker/2:2        
kworker/3:0        
kworker/3:1        
kworker/3:2        
kworker/4:0        
kworker/4:1        
kworker/5:0        
kworker/5:1        
kworker/6:0        
kworker/6:1        
kworker/6:2        
kworker/7:0        
kworker/7:1

There were 8 unbound workers.

> What is the context switch rate on the machines whenteh test is running?

This is vmstat from a vanilla kernel. The actual vmstat is after the --.
The information before that is recorded by mmtests to try and detect if
there was jitter in the vmstat output. It's showing that there is little
or no jitter in this test.

VANILLA
 1341306582.6713   1.8109     1.8109 --  0  0      0 16050784  11448 104056    0    0   376     0  209  526  0  0 99  1  0
 1341306584.6715   3.8112     2.0003 --  1  0      0 16050628  11448 104064    0    0     0     0  121  608  0  0 100  0  0
 1341306586.6718   5.8114     2.0003 --  0  0      0 16047432  11460 104288    0    0   102    45  227  999  0  0 99  1  0
 1341306588.6721   7.8117     2.0003 --  1  0      0 16046944  11460 104292    0    0     0     0  120  663  0  0 100  0  0
 1341306590.6723   9.8119     2.0002 --  0  2      0 16045788  11476 104296    0    0    12    40  190  754  0  0 99  0  0
 1341306592.6725  11.8121     2.0002 --  0  1      0 15990236  12600 141724    0    0 19054    30 1400 2937  2  1 88  9  0
 1341306594.6727  13.8124     2.0002 --  1  0      0 15907628  12600 186360    0    0  1653     0 3117 6406  2  9 88  1  0
 1341306596.6730  15.8127     2.0003 --  0  0      0 15825964  12608 226636    0    0    15 11024 3073 6350  2  9 89  0  0
 1341306598.6733  17.8130     2.0003 --  1  0      0 15730420  12608 271632    0    0     0  3072 3461 7179  2 10 88  0  0
 1341306600.6736  19.8132     2.0003 --  1  0      0 15686200  12608 310816    0    0     0 12416 3093 6198  2  9 89  0  0
 1341306602.6738  21.8135     2.0003 --  2  0      0 15593588  12616 354928    0    0     0    32 3482 7146  2 11 87  0  0
 1341306604.6741  23.8138     2.0003 --  2  0      0 15562032  12616 393772    0    0     0 12288 3129 6330  2 10 89  0  0
 1341306606.6744  25.8140     2.0002 --  1  0      0 15458316  12624 438004    0    0     0    26 3471 7107  2 11 87  0  0
 1341306608.6746  27.8142     2.0002 --  1  0      0 15432024  12624 474244    0    0     0 12416 3011 6017  1 10 89  0  0
 1341306610.6749  29.8145     2.0003 --  2  0      0 15343280  12624 517696    0    0     0    24 3393 6826  2 11 87  0  0
 1341306612.6751  31.8148     2.0002 --  1  0      0 15311136  12632 551816    0    0     0 16502 2818 5653  2  9 88  1  0
 1341306614.6754  33.8151     2.0003 --  1  0      0 15220648  12632 594936    0    0     0  3584 3451 6779  2 11 87  0  0
 1341306616.6755  35.8152     2.0001 --  4  0      0 15221252  12632 649296    0    0     0 38559 4846 8709  2 15 78  6  0
 1341306618.6758  37.8155     2.0003 --  1  0      0 15177724  12640 668476    0    0    20 40679 2204 4067  1  5 89  5  0
 1341306620.6761  39.8158     2.0003 --  1  0      0 15090204  12640 711752    0    0     0     0 3316 6788  2 11 88  0  0
 1341306622.6764  41.8160     2.0003 --  1  0      0 15005356  12640 748532    0    0     0 12288 3073 6132  2 10 89  0  0
 1341306624.6766  43.8163     2.0002 --  2  0      0 14913088  12648 791952    0    0     0    28 3408 6806  2 11 87  0  0
 1341306626.6769  45.8166     2.0003 --  1  0      0 14891512  12648 826328    0    0     0 12420 2906 5710  1  9 90  0  0
 1341306628.6772  47.8168     2.0003 --  1  0      0 14794316  12656 868936    0    0     0    26 3367 6798  2 11 87  0  0
 1341306630.6774  49.8171     2.0003 --  1  0      0 14769188  12656 905016    0    0    30 12324 3029 5876  2 10 89  0  0
 1341306632.6777  51.8173     2.0002 --  1  0      0 14679544  12656 947712    0    0     0     0 3399 6868  2 11 87  0  0
 1341306634.6780  53.8176     2.0003 --  1  0      0 14646156  12664 982032    0    0     0 14658 2987 5761  1 10 89  0  0
 1341306636.6782  55.8179     2.0003 --  1  0      0 14560504  12664 1023816    0    0     0  4404 3454 6876  2 11 87  0  0
 1341306638.6783  57.8180     2.0001 --  2  0      0 14533384  12664 1056812    0    0     0 15810 3002 5581  1 10 89  0  0
 1341306640.6785  59.8182     2.0002 --  1  0      0 14593332  12672 1027392    0    0     0 31790 3504 1811  1 13 78  8  0
 1341306642.6787  61.8183     2.0001 --  1  0      0 14686968  12672 1007604    0    0     0 14621 2434 1248  1 10 89  0  0
 1341306644.6789  63.8185     2.0002 --  1  1      0 15042476  12680 788104    0    0     0 36564 2809 1484  1 12 86  1  0
 1341306646.6790  65.8187     2.0002 --  1  0      0 15128292  12680 757948    0    0     0 26395 3050 1313  1 13 86  1  0
 1341306648.6792  67.8189     2.0002 --  1  0      0 15160036  12680 727964    0    0     0  5463 2752  910  1 12 87  0  0
 1341306650.6795  69.8192     2.0003 --  0  0      0 15633256  12688 332572    0    0  1156 12308 2117 2346  1  7 91  1  0
 1341306652.6797  71.8194     2.0002 --  0  0      0 15633892  12688 332652    0    0     0     0  224  758  0  0 100  0  0
 1341306654.6800  73.8197     2.0003 --  0  0      0 15633900  12688 332524    0    0     0     0  231 1009  0  0 100  0  0
 1341306656.6803  75.8199     2.0003 --  0  0      0 15637436  12696 332504    0    0     0    38  266  713  0  0 99  0  0
 1341306658.6805  77.8202     2.0003 --  0  0      0 15654180  12696 332352    0    0     0     0  270  821  0  0 100  0  0

REVERT-XFS
 1341307733.8702   1.7941     1.7941 --  0  0      0 16050640  12036 103996    0    0   372     0  216  752  0  0 99  1  0
 1341307735.8704   3.7944     2.0002 --  0  0      0 16050864  12036 104028    0    0     0     0  132  857  0  0 100  0  0
 1341307737.8707   5.7946     2.0002 --  0  0      0 16047492  12048 104252    0    0   102    37  255  938  0  0 99  1  0
 1341307739.8709   7.7949     2.0003 --  0  0      0 16047600  12072 104324    0    0    32     2  129  658  0  0 100  0  0
 1341307741.8712   9.7951     2.0002 --  1  1      0 16046676  12080 104328    0    0     0    32  165  729  0  0 100  0  0
 1341307743.8714  11.7954     2.0003 --  0  1      0 15990840  13216 142612    0    0 19422    30 1467 3015  2  1 89  8  0
 1341307745.8717  13.7956     2.0002 --  0  0      0 15825496  13216 226396    0    0  1310 11214 2217 1348  2  8 89  1  0
 1341307747.8717  15.7957     2.0001 --  1  0      0 15677816  13224 314672    0    0     4 15294 2307 1173  2  9 89  0  0
 1341307749.8719  17.7959     2.0002 --  1  0      0 15524372  13224 409728    0    0     0 12288 2466  888  1 10 89  0  0
 1341307751.8721  19.7960     2.0002 --  1  0      0 15368424  13224 502552    0    0     0 12416 2312  878  1 10 89  0  0
 1341307753.8722  21.7962     2.0002 --  1  0      0 15225216  13232 593092    0    0     0 12448 2539 1380  1 10 88  0  0
 1341307755.8724  23.7963     2.0002 --  2  0      0 15163712  13232 664768    0    0     0 32160 2184 1177  1  8 90  0  0
 1341307757.8727  25.7967     2.0003 --  1  0      0 14973888  13240 755080    0    0     0 12316 2482 1219  1 10 89  0  0
 1341307759.8728  27.7968     2.0001 --  1  0      0 14883580  13240 840036    0    0     0 44471 2711 1234  2 10 88  0  0
 1341307761.8730  29.7970     2.0002 --  1  0      0 14800304  13240 920504    0    0     0 42554 2571 1050  1 10 89  0  0
 1341307763.8734  31.7973     2.0003 --  0  0      0 14642504  13248 995004    0    0     0  3232 2276 1081  1  8 90  0  0
 1341307765.8737  33.7976     2.0003 --  1  0      0 14545072  13248 1052536    0    0     0 18688 2628 1114  1  9 89  0  0
 1341307767.8739  35.7979     2.0003 --  1  0      0 14783848  13248 926824    0    0     0 59559 2409 1308  0 10 89  1  0
 1341307769.8740  37.7980     2.0001 --  2  0      0 14854800  13256 896832    0    0     0  9172 2419 1004  1 10 89  1  0
 1341307771.8742  39.7981     2.0002 --  2  0      0 14835084  13256 875612    0    0     0 12288 2524  812  0 11 89  0  0
 1341307773.8743  41.7983     2.0002 --  2  0      0 15126252  13256 745844    0    0     0 10297 2714 1163  1 12 88  0  0
 1341307775.8745  43.7985     2.0002 --  1  0      0 15108800  13264 724544    0    0     0 12316 2499  931  1 11 88  0  0
 1341307777.8746  45.7986     2.0001 --  2  0      0 15226236  13264 694580    0    0     0 12416 2700 1194  1 12 88  0  0
 1341307779.8750  47.7989     2.0003 --  1  0      0 15697632  13264 300716    0    0  1156     0  934 1701  0  2 96  1  0
 1341307781.8752  49.7992     2.0003 --  0  0      0 15697508  13272 300720    0    0     0    66  166  641  0  0 100  0  0
 1341307783.8755  51.7995     2.0003 --  0  0      0 15699008  13272 300524    0    0     0     0  248  865  0  0 100  0  0
 1341307785.8758  53.7997     2.0003 --  0  0      0 15702452  13272 300520    0    0     0     0  285  960  0  0 99  0  0
 1341307787.8760  55.7999     2.0002 --  0  0      0 15719404  13280 300436    0    0     0    26  136  590  0  0 99  0  0

Vanilla average context switch rate	4278.53
Revert average context switch rate	1095

> Can you run latencytop to see
> if there is excessive starvation/wait times for allocation
> completion?

I'm not sure what format you are looking for.  latencytop is shit for
capturing information throughout a test and it does not easily allow you to
record a snapshot of a test. You can record all the console output of course
but that's a complete mess. I tried capturing /proc/latency_stats over time
instead because that can be trivially sorted on a system-wide basis but
as I write this I find that latency_stats was bust. It was just spitting out

Latency Top version : v0.1

and nothing else.  Either latency_stats is broken or my config is. Not sure
which it is right now and won't get enough time on this today to pinpoint it.

> A pert top profile comparison might be informative,
> too...
> 

I'm not sure if this is what you really wanted. I thought an oprofile or
perf report would have made more sense but I recorded perf top over time
anyway and it's at the end of the mail.  The timestamp information is poor
because the perf top information was buffered so it would receive a bunch
of updates at once. Each sample should be roughly 2 seconds apart. This
buffering can be dealt with, I just failed to do it in advance and I do
not think it's necessary to rerun the tests for it.

> (*) The stack usage below submit_bio() can be more than 5k (DM, MD,
> SCSI, driver, memory allocation), so it's really not safe to do
> allocation anywhere below about 3k of kernel stack being used. e.g.
> on a relatively trivial storage setup without the above commit:
> 
> [142296.384921] flush-253:4 used greatest stack depth: 360 bytes left
> 
> Fundamentally, 8k stacks on x86-64 are too small for our
> increasingly complex storage layers and the 100+ function deep call
> chains that occur.
> 

I understand the patches motivation. For these tests I'm being deliberately
a bit of a dummy and just capturing information. This might allow me to
actually get through all the results and identify some of the problems
and spread them around a bit. Either that or I need to clone myself a few
times to tackle each of the problems in a reasonable timeframe :)

For just these XFS tests I've uploaded a tarball of the logs to
http://www.csn.ul.ie/~mel/postings/xfsbisect-20120703/xfsbisect-logs.tar.gz

For results with no monitor you can find them somewhere like this

default/no-monitor/sandy/fsmark-single-3.4.0-vanilla/noprofile/fsmark.log

Results with monitors attached are in run-monitor. You
can read the iostat logs for example from

default/run-monitor/sandy/iostat-3.4.0-vanilla-fsmark-single

Some of the monitor logs are gzipped.

This is perf top over time for the vanilla kernel

time: 1341306570

time: 1341306579
   PerfTop:       1 irqs/sec  kernel: 0.0%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    61.85%  [kernel]        [k] __rmqueue  
    38.15%  libc-2.11.3.so  [.] _IO_vfscanf

time: 1341306579
   PerfTop:       3 irqs/sec  kernel:66.7%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    19.88%  [kernel]        [k] _raw_spin_lock_irqsave  
    17.14%  [kernel]        [k] __rmqueue               
    16.96%  [kernel]        [k] format_decode           
    15.37%  libc-2.11.3.so  [.] __tzfile_compute        
    13.55%  [kernel]        [k] copy_user_generic_string
    10.57%  libc-2.11.3.so  [.] _IO_vfscanf             
     6.53%  [kernel]        [k] find_first_bit          

time: 1341306579
   PerfTop:       0 irqs/sec  kernel:-nan%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    17.51%  [kernel]        [k] _raw_spin_lock_irqsave  
    15.10%  [kernel]        [k] __rmqueue               
    14.94%  [kernel]        [k] format_decode           
    13.54%  libc-2.11.3.so  [.] __tzfile_compute        
    11.94%  [kernel]        [k] copy_user_generic_string
    11.90%  [kernel]        [k] _raw_spin_lock          
     9.31%  libc-2.11.3.so  [.] _IO_vfscanf             
     5.75%  [kernel]        [k] find_first_bit          

time: 1341306579
   PerfTop:      41 irqs/sec  kernel:58.5%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    13.62%  [kernel]          [k] _raw_spin_lock_irqsave   
    11.02%  [kernel]          [k] __rmqueue                
    10.91%  [kernel]          [k] format_decode            
     9.89%  libc-2.11.3.so    [.] __tzfile_compute         
     8.72%  [kernel]          [k] copy_user_generic_string 
     8.69%  [kernel]          [k] _raw_spin_lock           
     7.15%  libc-2.11.3.so    [.] _IO_vfscanf              
     4.20%  [kernel]          [k] find_first_bit           
     1.47%  libc-2.11.3.so    [.] __strcmp_sse42           
     1.37%  libc-2.11.3.so    [.] __strchr_sse42           
     1.19%  sed               [.] 0x0000000000009f7d       
     0.90%  libc-2.11.3.so    [.] vfprintf                 
     0.84%  [kernel]          [k] hrtimer_interrupt        
     0.84%  libc-2.11.3.so    [.] re_string_realloc_buffers
     0.76%  [kernel]          [k] enqueue_entity           
     0.66%  [kernel]          [k] __switch_to              
     0.65%  libc-2.11.3.so    [.] _IO_default_xsputn       
     0.62%  [kernel]          [k] do_vfs_ioctl             
     0.59%  [kernel]          [k] perf_event_mmap_event    
     0.56%  gzip              [.] 0x0000000000007b96       
     0.55%  libc-2.11.3.so    [.] bsearch                  

time: 1341306579
   PerfTop:      35 irqs/sec  kernel:62.9%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.50%  [kernel]          [k] _raw_spin_lock_irqsave   
     9.22%  [kernel]          [k] __rmqueue                
     9.13%  [kernel]          [k] format_decode            
     8.27%  libc-2.11.3.so    [.] __tzfile_compute         
     7.92%  [kernel]          [k] copy_user_generic_string 
     7.74%  [kernel]          [k] _raw_spin_lock           
     6.21%  libc-2.11.3.so    [.] _IO_vfscanf              
     3.51%  [kernel]          [k] find_first_bit           
     1.44%  gzip              [.] 0x0000000000007b96       
     1.23%  libc-2.11.3.so    [.] __strcmp_sse42           
     1.15%  libc-2.11.3.so    [.] __strchr_sse42           
     1.06%  libc-2.11.3.so    [.] vfprintf                 
     0.99%  sed               [.] 0x0000000000009f7d       
     0.92%  [unknown]         [.] 0x00007f84a7766b99       
     0.70%  [kernel]          [k] hrtimer_interrupt        
     0.70%  libc-2.11.3.so    [.] re_string_realloc_buffers
     0.64%  [kernel]          [k] enqueue_entity           
     0.58%  libtcl8.5.so      [.] 0x000000000006fe86       
     0.55%  [kernel]          [k] __switch_to              
     0.54%  libc-2.11.3.so    [.] _IO_default_xsputn       
     0.53%  [kernel]          [k] __d_lookup_rcu           

time: 1341306585
   PerfTop:     100 irqs/sec  kernel:59.0%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     8.61%  [kernel]          [k] _raw_spin_lock_irqsave         
     5.92%  [kernel]          [k] __rmqueue                      
     5.86%  [kernel]          [k] format_decode                  
     5.31%  libc-2.11.3.so    [.] __tzfile_compute               
     5.30%  [kernel]          [k] copy_user_generic_string       
     5.27%  [kernel]          [k] _raw_spin_lock                 
     3.99%  libc-2.11.3.so    [.] _IO_vfscanf                    
     2.45%  [unknown]         [.] 0x00007f84a7766b99             
     2.26%  [kernel]          [k] find_first_bit                 
     1.68%  [kernel]          [k] page_fault                     
     1.45%  libc-2.11.3.so    [.] _int_malloc                    
     1.28%  gzip              [.] 0x0000000000007b96             
     1.13%  libc-2.11.3.so    [.] vfprintf                       
     1.06%  libc-2.11.3.so    [.] __strchr_sse42                 
     1.02%  perl              [.] 0x0000000000044505             
     0.79%  libc-2.11.3.so    [.] __strcmp_sse42                 
     0.79%  [kernel]          [k] do_task_stat                   
     0.77%  [kernel]          [k] zap_pte_range                  
     0.72%  libc-2.11.3.so    [.] __gconv_transform_utf8_internal
     0.70%  libc-2.11.3.so    [.] malloc                         
     0.70%  libc-2.11.3.so    [.] __mbrtowc                      

time: 1341306585
   PerfTop:      19 irqs/sec  kernel:78.9%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     7.97%  [kernel]          [k] _raw_spin_lock_irqsave         
     5.48%  [kernel]          [k] __rmqueue                      
     5.43%  [kernel]          [k] format_decode                  
     5.24%  [kernel]          [k] copy_user_generic_string       
     5.18%  [kernel]          [k] _raw_spin_lock                 
     4.92%  libc-2.11.3.so    [.] __tzfile_compute               
     4.25%  libc-2.11.3.so    [.] _IO_vfscanf                    
     2.33%  [unknown]         [.] 0x00007f84a7766b99             
     2.12%  [kernel]          [k] page_fault                     
     2.09%  [kernel]          [k] find_first_bit                 
     1.34%  libc-2.11.3.so    [.] _int_malloc                    
     1.19%  gzip              [.] 0x0000000000007b96             
     1.05%  libc-2.11.3.so    [.] vfprintf                       
     0.98%  libc-2.11.3.so    [.] __strchr_sse42                 
     0.94%  perl              [.] 0x0000000000044505             
     0.94%  libc-2.11.3.so    [.] _dl_addr                       
     0.91%  [kernel]          [k] zap_pte_range                  
     0.74%  [kernel]          [k] s_show                         
     0.73%  libc-2.11.3.so    [.] __strcmp_sse42                 
     0.73%  [kernel]          [k] do_task_stat                   
     0.67%  libc-2.11.3.so    [.] __gconv_transform_utf8_internal

time: 1341306585
   PerfTop:      38 irqs/sec  kernel:68.4%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     7.64%  [kernel]          [k] _raw_spin_lock_irqsave     
     4.89%  [kernel]          [k] _raw_spin_lock             
     4.77%  [kernel]          [k] __rmqueue                  
     4.72%  [kernel]          [k] format_decode              
     4.56%  [kernel]          [k] copy_user_generic_string   
     4.53%  libc-2.11.3.so    [.] _IO_vfscanf                
     4.28%  libc-2.11.3.so    [.] __tzfile_compute           
     2.52%  [unknown]         [.] 0x00007f84a7766b99         
no symbols found in /bin/sort, maybe install a debug package?
     2.10%  [kernel]          [k] page_fault                 
     1.82%  [kernel]          [k] find_first_bit             
     1.31%  libc-2.11.3.so    [.] _int_malloc                
     1.14%  libc-2.11.3.so    [.] vfprintf                   
     1.08%  libc-2.11.3.so    [.] _dl_addr                   
     1.07%  [kernel]          [k] s_show                     
     1.05%  libc-2.11.3.so    [.] __strchr_sse42             
     1.03%  gzip              [.] 0x0000000000007b96         
     0.82%  [kernel]          [k] do_task_stat               
     0.82%  perl              [.] 0x0000000000044505         
     0.79%  [kernel]          [k] zap_pte_range              
     0.70%  [kernel]          [k] seq_put_decimal_ull        
     0.69%  [kernel]          [k] find_busiest_group         

time: 1341306591
   PerfTop:      66 irqs/sec  kernel:59.1%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     6.52%  [kernel]          [k] _raw_spin_lock_irqsave         
     4.11%  libc-2.11.3.so    [.] _IO_vfscanf                    
     3.91%  [kernel]          [k] _raw_spin_lock                 
     3.50%  [kernel]          [k] copy_user_generic_string       
     3.41%  [kernel]          [k] __rmqueue                      
     3.38%  [kernel]          [k] format_decode                  
     3.06%  libc-2.11.3.so    [.] __tzfile_compute               
     2.90%  [unknown]         [.] 0x00007f84a7766b99             
     2.30%  [kernel]          [k] page_fault                     
     2.20%  perl              [.] 0x0000000000044505             
     1.83%  libc-2.11.3.so    [.] vfprintf                       
     1.61%  libc-2.11.3.so    [.] _int_malloc                    
     1.30%  [kernel]          [k] find_first_bit                 
     1.22%  libc-2.11.3.so    [.] _dl_addr                       
     1.19%  libc-2.11.3.so    [.] __gconv_transform_utf8_internal
     1.10%  libc-2.11.3.so    [.] __strchr_sse42                 
     1.01%  [kernel]          [k] zap_pte_range                  
     0.99%  [kernel]          [k] s_show                         
     0.98%  [kernel]          [k] __percpu_counter_add           
     0.86%  [kernel]          [k] __strnlen_user                 
     0.75%  ld-2.11.3.so      [.] do_lookup_x                    

time: 1341306591
   PerfTop:      39 irqs/sec  kernel:69.2%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     6.26%  [kernel]          [k] _raw_spin_lock_irqsave         
     4.05%  [kernel]          [k] _raw_spin_lock                 
     3.86%  libc-2.11.3.so    [.] _IO_vfscanf                    
     3.21%  [kernel]          [k] copy_user_generic_string       
     3.03%  [kernel]          [k] __rmqueue                      
     3.00%  [kernel]          [k] format_decode                  
     2.93%  [unknown]         [.] 0x00007f84a7766b99             
     2.72%  libc-2.11.3.so    [.] __tzfile_compute               
     2.20%  [kernel]          [k] page_fault                     
     1.96%  perl              [.] 0x0000000000044505             
     1.77%  libc-2.11.3.so    [.] vfprintf                       
     1.43%  libc-2.11.3.so    [.] _int_malloc                    
     1.16%  [kernel]          [k] find_first_bit                 
     1.09%  libc-2.11.3.so    [.] _dl_addr                       
     1.06%  libc-2.11.3.so    [.] __gconv_transform_utf8_internal
     1.02%  [kernel]          [k] s_show                         
     0.98%  libc-2.11.3.so    [.] __strchr_sse42                 
     0.93%  gzip              [.] 0x0000000000007b96             
     0.90%  [kernel]          [k] zap_pte_range                  
     0.87%  [kernel]          [k] __percpu_counter_add           
     0.76%  [kernel]          [k] __strnlen_user                 

time: 1341306591
   PerfTop:     185 irqs/sec  kernel:70.8%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     4.81%  [kernel]          [k] _raw_spin_lock_irqsave         
     3.60%  [unknown]         [.] 0x00007f84a7766b99             
     3.10%  [kernel]          [k] _raw_spin_lock                 
     3.04%  [kernel]          [k] page_fault                     
     2.66%  libc-2.11.3.so    [.] _IO_vfscanf                    
     2.14%  [kernel]          [k] copy_user_generic_string       
     2.11%  [kernel]          [k] format_decode                  
     1.96%  [kernel]          [k] __rmqueue                      
     1.86%  libc-2.11.3.so    [.] _dl_addr                       
     1.76%  libc-2.11.3.so    [.] __tzfile_compute               
     1.26%  perl              [.] 0x0000000000044505             
     1.19%  libc-2.11.3.so    [.] __mbrtowc                      
     1.14%  libc-2.11.3.so    [.] vfprintf                       
     1.12%  libc-2.11.3.so    [.] _int_malloc                    
     1.09%  gzip              [.] 0x0000000000007b96             
     0.95%  libc-2.11.3.so    [.] __gconv_transform_utf8_internal
     0.88%  [kernel]          [k] _raw_spin_unlock_irqrestore    
     0.87%  [kernel]          [k] __strnlen_user                 
     0.82%  [kernel]          [k] clear_page_c                   
     0.77%  [kernel]          [k] __schedule                     
     0.76%  [kernel]          [k] find_get_page                  

time: 1341306595
   PerfTop:     385 irqs/sec  kernel:48.8%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    27.20%  cc1               [.] 0x0000000000210978         
     3.01%  [unknown]         [.] 0x00007f84a7766b99         
     2.18%  [kernel]          [k] page_fault                 
     1.96%  libbfd-2.21.so    [.] 0x00000000000b9cdd         
     1.95%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.91%  ld.bfd            [.] 0x000000000000e3b9         
     1.85%  [kernel]          [k] _raw_spin_lock             
     1.31%  [kernel]          [k] copy_user_generic_string   
     1.20%  libbfd-2.21.so    [.] bfd_hash_lookup            
     1.10%  libc-2.11.3.so    [.] __strcmp_sse42             
     0.93%  libc-2.11.3.so    [.] _IO_vfscanf                
     0.85%  [kernel]          [k] _raw_spin_unlock_irqrestore
     0.82%  libc-2.11.3.so    [.] _int_malloc                
     0.80%  [kernel]          [k] __rmqueue                  
     0.79%  [kernel]          [k] kmem_cache_alloc           
     0.74%  [kernel]          [k] format_decode              
     0.71%  libc-2.11.3.so    [.] _dl_addr                   
     0.62%  libbfd-2.21.so    [.] _bfd_final_link_relocate   
     0.61%  libc-2.11.3.so    [.] __tzfile_compute           
     0.61%  libc-2.11.3.so    [.] vfprintf                   
     0.59%  [kernel]          [k] find_busiest_group         

time: 1341306595
   PerfTop:    1451 irqs/sec  kernel:87.3%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     9.75%  cc1               [.] 0x0000000000210978         
     8.81%  [unknown]         [.] 0x00007f84a7766b99         
     4.62%  [kernel]          [k] page_fault                 
     3.61%  [kernel]          [k] _raw_spin_lock             
     2.67%  [kernel]          [k] memcpy                     
     2.03%  [kernel]          [k] _raw_spin_lock_irqsave     
     2.00%  [kernel]          [k] kmem_cache_alloc           
     1.64%  [xfs]             [k] _xfs_buf_find              
     1.31%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.16%  [kernel]          [k] kmem_cache_free            
     1.15%  [xfs]             [k] xfs_next_bit               
     0.98%  [kernel]          [k] __d_lookup                 
     0.89%  [xfs]             [k] xfs_da_do_buf              
     0.83%  [kernel]          [k] memset                     
     0.80%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.79%  [kernel]          [k] link_path_walk             
     0.76%  [xfs]             [k] xfs_buf_item_size          
no symbols found in /usr/bin/tee, maybe install a debug package?
no symbols found in /bin/date, maybe install a debug package?
     0.73%  [xfs]             [k] xfs_buf_offset             
     0.71%  [kernel]          [k] __kmalloc                  
     0.70%  [kernel]          [k] kfree                      
     0.70%  libbfd-2.21.so    [.] 0x00000000000b9cdd         

time: 1341306601
   PerfTop:    1267 irqs/sec  kernel:85.2%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    10.81%  [unknown]         [.] 0x00007f84a7766b99         
     5.98%  cc1               [.] 0x0000000000210978         
     5.20%  [kernel]          [k] page_fault                 
     3.54%  [kernel]          [k] _raw_spin_lock             
     3.37%  [kernel]          [k] memcpy                     
     2.03%  [kernel]          [k] kmem_cache_alloc           
     1.91%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.75%  [xfs]             [k] _xfs_buf_find              
     1.35%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.28%  [xfs]             [k] xfs_next_bit               
     1.14%  [kernel]          [k] kmem_cache_free            
     1.13%  [kernel]          [k] __kmalloc                  
     1.12%  [kernel]          [k] __d_lookup                 
     0.97%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.96%  [xfs]             [k] xfs_buf_offset             
     0.95%  [kernel]          [k] memset                     
     0.91%  [kernel]          [k] link_path_walk             
     0.88%  [xfs]             [k] xfs_da_do_buf              
     0.85%  [kernel]          [k] kfree                      
     0.84%  [xfs]             [k] xfs_buf_item_size          
     0.74%  [xfs]             [k] xfs_btree_lookup           

time: 1341306601
   PerfTop:    1487 irqs/sec  kernel:85.3%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.84%  [unknown]         [.] 0x00007f84a7766b99         
     5.15%  [kernel]          [k] page_fault                 
     3.93%  cc1               [.] 0x0000000000210978         
     3.76%  [kernel]          [k] _raw_spin_lock             
     3.50%  [kernel]          [k] memcpy                     
     2.13%  [kernel]          [k] kmem_cache_alloc           
     1.91%  [xfs]             [k] _xfs_buf_find              
     1.79%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.52%  [kernel]          [k] __kmalloc                  
     1.33%  [kernel]          [k] kmem_cache_free            
     1.32%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.29%  [kernel]          [k] __d_lookup                 
     1.27%  [xfs]             [k] xfs_next_bit               
     1.11%  [kernel]          [k] link_path_walk             
     1.01%  [xfs]             [k] xfs_buf_offset             
     1.00%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.98%  [xfs]             [k] xfs_da_do_buf              
     0.97%  [kernel]          [k] kfree                      
     0.96%  [kernel]          [k] memset                     
     0.84%  [xfs]             [k] xfs_btree_lookup           
     0.82%  [xfs]             [k] xfs_buf_item_format        

time: 1341306601
   PerfTop:    1291 irqs/sec  kernel:85.9%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    12.21%  [unknown]         [.] 0x00007f84a7766b99         
     5.18%  [kernel]          [k] page_fault                 
     3.83%  [kernel]          [k] _raw_spin_lock             
     3.67%  [kernel]          [k] memcpy                     
     2.92%  cc1               [.] 0x0000000000210978         
     2.28%  [kernel]          [k] kmem_cache_alloc           
     2.18%  [xfs]             [k] _xfs_buf_find              
     1.66%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.56%  [kernel]          [k] __kmalloc                  
     1.43%  [kernel]          [k] __d_lookup                 
     1.43%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.40%  [kernel]          [k] kmem_cache_free            
     1.29%  [xfs]             [k] xfs_next_bit               
     1.13%  [xfs]             [k] xfs_buf_offset             
     1.07%  [kernel]          [k] link_path_walk             
     1.04%  [xfs]             [k] xfs_da_do_buf              
     1.01%  [kernel]          [k] memset                     
     1.01%  [kernel]          [k] kfree                      
     1.00%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.87%  [xfs]             [k] xfs_buf_item_size          
     0.84%  [xfs]             [k] xfs_btree_lookup           

time: 1341306607
   PerfTop:    1435 irqs/sec  kernel:87.9%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    12.06%  [unknown]         [.] 0x00007f84a7766b99         
     5.40%  [kernel]          [k] page_fault                 
     3.88%  [kernel]          [k] _raw_spin_lock             
     3.83%  [kernel]          [k] memcpy                     
     2.41%  [xfs]             [k] _xfs_buf_find              
     2.35%  [kernel]          [k] kmem_cache_alloc           
     2.19%  cc1               [.] 0x0000000000210978         
     1.68%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.55%  [kernel]          [k] __kmalloc                  
     1.48%  [kernel]          [k] __d_lookup                 
     1.43%  [kernel]          [k] kmem_cache_free            
     1.42%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.37%  [xfs]             [k] xfs_next_bit               
     1.27%  [xfs]             [k] xfs_buf_offset             
     1.12%  [kernel]          [k] link_path_walk             
     1.09%  [kernel]          [k] kfree                      
     1.08%  [kernel]          [k] memset                     
     1.04%  [xfs]             [k] xfs_da_do_buf              
     0.99%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.92%  [xfs]             [k] xfs_buf_item_size          
     0.89%  [xfs]             [k] xfs_btree_lookup           

time: 1341306607
   PerfTop:    1281 irqs/sec  kernel:87.0%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    12.00%  [unknown]         [.] 0x00007f84a7766b99         
     5.44%  [kernel]          [k] page_fault                 
     4.04%  [kernel]          [k] _raw_spin_lock             
     3.94%  [kernel]          [k] memcpy                     
     2.51%  [xfs]             [k] _xfs_buf_find              
     2.32%  [kernel]          [k] kmem_cache_alloc           
     1.75%  cc1               [.] 0x0000000000210978         
     1.66%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.58%  [kernel]          [k] __d_lookup                 
     1.56%  [kernel]          [k] __kmalloc                  
     1.46%  [xfs]             [k] xfs_next_bit               
     1.44%  [kernel]          [k] kmem_cache_free            
     1.41%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.34%  [xfs]             [k] xfs_buf_offset             
     1.20%  [kernel]          [k] link_path_walk             
     1.16%  [kernel]          [k] kfree                      
     1.11%  [kernel]          [k] memset                     
     1.04%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.94%  [xfs]             [k] xfs_da_do_buf              
     0.92%  [xfs]             [k] xfs_btree_lookup           
     0.89%  [xfs]             [k] xfs_buf_item_size          

time: 1341306607
   PerfTop:    1455 irqs/sec  kernel:86.8%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    12.14%  [unknown]         [.] 0x00007f84a7766b99         
     5.36%  [kernel]          [k] page_fault                 
     4.12%  [kernel]          [k] _raw_spin_lock             
     4.02%  [kernel]          [k] memcpy                     
     2.54%  [xfs]             [k] _xfs_buf_find              
     2.41%  [kernel]          [k] kmem_cache_alloc           
     1.69%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.56%  [kernel]          [k] __kmalloc                  
     1.49%  [xfs]             [k] xfs_next_bit               
     1.47%  [kernel]          [k] __d_lookup                 
     1.42%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.39%  [xfs]             [k] xfs_buf_offset             
     1.39%  cc1               [.] 0x0000000000210978         
     1.37%  [kernel]          [k] kmem_cache_free            
     1.24%  [kernel]          [k] link_path_walk             
     1.17%  [kernel]          [k] memset                     
     1.16%  [kernel]          [k] kfree                      
     1.07%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.99%  [xfs]             [k] xfs_buf_item_size          
     0.92%  [xfs]             [k] xfs_da_do_buf              
     0.91%  [xfs]             [k] xfs_btree_lookup           

time: 1341306613
   PerfTop:    1245 irqs/sec  kernel:87.3%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    12.05%  [unknown]         [.] 0x00007f84a7766b99         
     5.40%  [kernel]          [k] page_fault                 
     4.10%  [kernel]          [k] _raw_spin_lock             
     4.06%  [kernel]          [k] memcpy                     
     2.74%  [xfs]             [k] _xfs_buf_find              
     2.40%  [kernel]          [k] kmem_cache_alloc           
     1.64%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.58%  [xfs]             [k] xfs_next_bit               
     1.54%  [kernel]          [k] __kmalloc                  
     1.49%  [kernel]          [k] __d_lookup                 
     1.45%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.41%  [kernel]          [k] kmem_cache_free            
     1.35%  [xfs]             [k] xfs_buf_offset             
     1.25%  [kernel]          [k] link_path_walk             
     1.22%  [kernel]          [k] kfree                      
     1.16%  [kernel]          [k] memset                     
     1.15%  cc1               [.] 0x0000000000210978         
     1.02%  [xfs]             [k] xfs_buf_item_size          
     1.00%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.92%  [xfs]             [k] xfs_btree_lookup           
     0.91%  [xfs]             [k] xfs_da_do_buf              

time: 1341306613
   PerfTop:    1433 irqs/sec  kernel:87.2%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    12.04%  [unknown]         [.] 0x00007f84a7766b99         
     5.30%  [kernel]          [k] page_fault                 
     4.08%  [kernel]          [k] memcpy                     
     4.07%  [kernel]          [k] _raw_spin_lock             
     2.88%  [xfs]             [k] _xfs_buf_find              
     2.50%  [kernel]          [k] kmem_cache_alloc           
     1.72%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.68%  [xfs]             [k] xfs_next_bit               
     1.56%  [kernel]          [k] __d_lookup                 
     1.54%  [kernel]          [k] __kmalloc                  
     1.48%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.46%  [kernel]          [k] kmem_cache_free            
     1.40%  [xfs]             [k] xfs_buf_offset             
     1.25%  [kernel]          [k] link_path_walk             
     1.21%  [kernel]          [k] memset                     
     1.18%  [kernel]          [k] kfree                      
     1.04%  [xfs]             [k] xfs_buf_item_size          
     1.02%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.95%  [xfs]             [k] xfs_btree_lookup           
     0.94%  cc1               [.] 0x0000000000210978         
     0.90%  [xfs]             [k] xfs_da_do_buf              

time: 1341306613
   PerfTop:    1118 irqs/sec  kernel:87.2%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

no symbols found in /usr/bin/vmstat, maybe install a debug package?
    12.03%  [unknown]         [.] 0x00007f84a7766b99         
     5.48%  [kernel]          [k] page_fault                 
     4.21%  [kernel]          [k] memcpy                     
     4.11%  [kernel]          [k] _raw_spin_lock             
     2.98%  [xfs]             [k] _xfs_buf_find              
     2.47%  [kernel]          [k] kmem_cache_alloc           
     1.81%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.72%  [xfs]             [k] xfs_next_bit               
     1.51%  [kernel]          [k] __kmalloc                  
     1.48%  [kernel]          [k] kmem_cache_free            
     1.48%  [kernel]          [k] __d_lookup                 
     1.47%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.39%  [xfs]             [k] xfs_buf_offset             
     1.23%  [kernel]          [k] link_path_walk             
     1.19%  [kernel]          [k] memset                     
     1.19%  [kernel]          [k] kfree                      
     1.07%  [xfs]             [k] xfs_dir2_node_addname_int  
     1.01%  [xfs]             [k] xfs_buf_item_size          
     0.98%  [xfs]             [k] xfs_btree_lookup           
     0.93%  [xfs]             [k] xfs_buf_item_format        
     0.91%  [xfs]             [k] xfs_da_do_buf              

time: 1341306617
   PerfTop:    1454 irqs/sec  kernel:87.6%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.93%  [unknown]         [.] 0x00007f84a7766b99         
     5.42%  [kernel]          [k] page_fault                 
     4.28%  [kernel]          [k] memcpy                     
     4.20%  [kernel]          [k] _raw_spin_lock             
     3.15%  [xfs]             [k] _xfs_buf_find              
     2.52%  [kernel]          [k] kmem_cache_alloc           
     1.76%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.72%  [xfs]             [k] xfs_next_bit               
     1.59%  [kernel]          [k] __d_lookup                 
     1.51%  [kernel]          [k] __kmalloc                  
     1.49%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.48%  [kernel]          [k] kmem_cache_free            
     1.40%  [xfs]             [k] xfs_buf_offset             
     1.29%  [kernel]          [k] memset                     
     1.20%  [kernel]          [k] link_path_walk             
     1.17%  [kernel]          [k] kfree                      
     1.09%  [xfs]             [k] xfs_dir2_node_addname_int  
     1.01%  [xfs]             [k] xfs_buf_item_size          
     0.95%  [xfs]             [k] xfs_btree_lookup           
     0.94%  [xfs]             [k] xfs_da_do_buf              
     0.91%  [xfs]             [k] xfs_buf_item_format        

time: 1341306617
   PerfTop:    1758 irqs/sec  kernel:90.2%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    10.99%  [unknown]         [.] 0x00007f84a7766b99         
     5.40%  [kernel]          [k] _raw_spin_lock             
     4.82%  [kernel]          [k] page_fault                 
     4.04%  [kernel]          [k] memcpy                     
     3.86%  [xfs]             [k] _xfs_buf_find              
     2.31%  [kernel]          [k] kmem_cache_alloc           
     2.03%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.67%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.60%  [kernel]          [k] __d_lookup                 
     1.60%  [xfs]             [k] xfs_next_bit               
     1.44%  [kernel]          [k] __kmalloc                  
     1.36%  [xfs]             [k] xfs_buf_offset             
     1.35%  [kernel]          [k] kmem_cache_free            
     1.17%  [kernel]          [k] kfree                      
     1.16%  [kernel]          [k] memset                     
     1.08%  [kernel]          [k] link_path_walk             
     0.98%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.97%  [xfs]             [k] xfs_btree_lookup           
     0.92%  [xfs]             [k] xfs_perag_put              
     0.90%  [xfs]             [k] xfs_buf_item_size          
     0.84%  [xfs]             [k] xfs_da_do_buf              

time: 1341306623
   PerfTop:    1022 irqs/sec  kernel:88.6%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    10.93%  [unknown]         [.] 0x00007f84a7766b99         
     5.34%  [kernel]          [k] _raw_spin_lock             
     4.82%  [kernel]          [k] page_fault                 
     4.01%  [kernel]          [k] memcpy                     
     4.01%  [xfs]             [k] _xfs_buf_find              
     2.28%  [kernel]          [k] kmem_cache_alloc           
     2.00%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.68%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.60%  [xfs]             [k] xfs_next_bit               
     1.59%  [kernel]          [k] __d_lookup                 
     1.41%  [kernel]          [k] __kmalloc                  
     1.39%  [kernel]          [k] kmem_cache_free            
     1.35%  [xfs]             [k] xfs_buf_offset             
     1.15%  [kernel]          [k] kfree                      
     1.15%  [kernel]          [k] memset                     
     1.09%  [kernel]          [k] link_path_walk             
     0.98%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.98%  [xfs]             [k] xfs_btree_lookup           
     0.91%  [xfs]             [k] xfs_perag_put              
     0.88%  [xfs]             [k] xfs_buf_item_size          
     0.86%  [xfs]             [k] xfs_da_do_buf              

time: 1341306623
   PerfTop:    1430 irqs/sec  kernel:87.6%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.05%  [unknown]         [.] 0x00007f84a7766b99         
     5.24%  [kernel]          [k] _raw_spin_lock             
     4.89%  [kernel]          [k] page_fault                 
     4.13%  [kernel]          [k] memcpy                     
     3.96%  [xfs]             [k] _xfs_buf_find              
     2.35%  [kernel]          [k] kmem_cache_alloc           
     1.95%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.77%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.63%  [kernel]          [k] __d_lookup                 
     1.54%  [xfs]             [k] xfs_next_bit               
     1.42%  [kernel]          [k] __kmalloc                  
     1.41%  [kernel]          [k] kmem_cache_free            
     1.32%  [xfs]             [k] xfs_buf_offset             
     1.16%  [kernel]          [k] memset                     
     1.11%  [kernel]          [k] kfree                      
     1.10%  [kernel]          [k] link_path_walk             
     1.05%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.99%  [xfs]             [k] xfs_btree_lookup           
     0.91%  [xfs]             [k] xfs_buf_item_size          
     0.87%  [xfs]             [k] xfs_da_do_buf              
     0.87%  [xfs]             [k] xfs_perag_put              

time: 1341306623
   PerfTop:    1267 irqs/sec  kernel:87.1%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.20%  [unknown]         [.] 0x00007f84a7766b99         
     5.08%  [kernel]          [k] _raw_spin_lock             
     4.85%  [kernel]          [k] page_fault                 
     4.12%  [kernel]          [k] memcpy                     
     3.96%  [xfs]             [k] _xfs_buf_find              
     2.41%  [kernel]          [k] kmem_cache_alloc           
     1.94%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.77%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.61%  [kernel]          [k] __d_lookup                 
     1.50%  [xfs]             [k] xfs_next_bit               
     1.44%  [kernel]          [k] __kmalloc                  
     1.40%  [kernel]          [k] kmem_cache_free            
     1.31%  [xfs]             [k] xfs_buf_offset             
no symbols found in /usr/bin/iostat, maybe install a debug package?
     1.16%  [kernel]          [k] memset                     
     1.11%  [kernel]          [k] kfree                      
     1.06%  [kernel]          [k] link_path_walk             
     1.04%  [xfs]             [k] xfs_dir2_node_addname_int  
     1.01%  [xfs]             [k] xfs_btree_lookup           
     0.95%  [xfs]             [k] xfs_buf_item_size          
     0.90%  [xfs]             [k] xfs_da_do_buf              
     0.84%  [xfs]             [k] xfs_perag_put              

time: 1341306629
   PerfTop:    1399 irqs/sec  kernel:88.3%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.12%  [unknown]         [.] 0x00007f84a7766b99         
     5.13%  [kernel]          [k] _raw_spin_lock             
     4.85%  [kernel]          [k] page_fault                 
     4.23%  [kernel]          [k] memcpy                     
     4.03%  [xfs]             [k] _xfs_buf_find              
     2.37%  [kernel]          [k] kmem_cache_alloc           
     1.96%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.69%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.63%  [kernel]          [k] __d_lookup                 
     1.50%  [xfs]             [k] xfs_next_bit               
     1.45%  [kernel]          [k] __kmalloc                  
     1.35%  [kernel]          [k] kmem_cache_free            
     1.32%  [xfs]             [k] xfs_buf_offset             
     1.17%  [kernel]          [k] memset                     
     1.09%  [kernel]          [k] kfree                      
     1.07%  [xfs]             [k] xfs_dir2_node_addname_int  
     1.07%  [kernel]          [k] link_path_walk             
     1.04%  [xfs]             [k] xfs_btree_lookup           
     1.02%  [xfs]             [k] xfs_buf_item_size          
     0.93%  [xfs]             [k] xfs_da_do_buf              
     0.84%  [xfs]             [k] xfs_buf_item_format        

time: 1341306629
   PerfTop:    1225 irqs/sec  kernel:87.5%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.15%  [unknown]         [.] 0x00007f84a7766b99         
     5.02%  [kernel]          [k] _raw_spin_lock             
     4.85%  [kernel]          [k] page_fault                 
     4.22%  [kernel]          [k] memcpy                     
     4.19%  [xfs]             [k] _xfs_buf_find              
     2.32%  [kernel]          [k] kmem_cache_alloc           
     1.94%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.71%  [kernel]          [k] __d_lookup                 
     1.68%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.54%  [xfs]             [k] xfs_next_bit               
     1.51%  [kernel]          [k] __kmalloc                  
     1.36%  [kernel]          [k] kmem_cache_free            
     1.28%  [xfs]             [k] xfs_buf_offset             
     1.14%  [kernel]          [k] memset                     
     1.09%  [kernel]          [k] kfree                      
     1.06%  [kernel]          [k] link_path_walk             
     1.02%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.99%  [xfs]             [k] xfs_buf_item_size          
     0.99%  [xfs]             [k] xfs_btree_lookup           
     0.92%  [xfs]             [k] xfs_da_do_buf              
     0.86%  [kernel]          [k] s_show                     

time: 1341306629
   PerfTop:    1400 irqs/sec  kernel:87.4%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.23%  [unknown]         [.] 0x00007f84a7766b99         
     5.07%  [kernel]          [k] _raw_spin_lock             
     4.87%  [kernel]          [k] page_fault                 
     4.27%  [xfs]             [k] _xfs_buf_find              
     4.18%  [kernel]          [k] memcpy                     
     2.31%  [kernel]          [k] kmem_cache_alloc           
     1.94%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.73%  [kernel]          [k] __d_lookup                 
     1.66%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.49%  [xfs]             [k] xfs_next_bit               
     1.49%  [kernel]          [k] __kmalloc                  
     1.40%  [kernel]          [k] kmem_cache_free            
     1.29%  [xfs]             [k] xfs_buf_offset             
     1.11%  [kernel]          [k] kfree                      
     1.07%  [kernel]          [k] memset                     
     1.07%  [kernel]          [k] link_path_walk             
     1.05%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.99%  [xfs]             [k] xfs_buf_item_size          
     0.97%  [xfs]             [k] xfs_btree_lookup           
     0.93%  [xfs]             [k] xfs_da_do_buf              
     0.89%  [kernel]          [k] s_show                     

time: 1341306635
   PerfTop:    1251 irqs/sec  kernel:87.9%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.20%  [unknown]         [.] 0x00007f84a7766b99         
     5.10%  [kernel]          [k] _raw_spin_lock             
     4.82%  [kernel]          [k] page_fault                 
     4.29%  [xfs]             [k] _xfs_buf_find              
     4.19%  [kernel]          [k] memcpy                     
     2.26%  [kernel]          [k] kmem_cache_alloc           
     1.87%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.83%  [kernel]          [k] __d_lookup                 
     1.64%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.53%  [kernel]          [k] __kmalloc                  
     1.49%  [xfs]             [k] xfs_next_bit               
     1.41%  [kernel]          [k] kmem_cache_free            
     1.32%  [xfs]             [k] xfs_buf_offset             
     1.10%  [kernel]          [k] link_path_walk             
     1.09%  [kernel]          [k] memset                     
     1.08%  [kernel]          [k] kfree                      
     1.03%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.99%  [xfs]             [k] xfs_buf_item_size          
     0.98%  [xfs]             [k] xfs_btree_lookup           
     0.96%  [kernel]          [k] s_show                     
     0.93%  [xfs]             [k] xfs_da_do_buf              

time: 1341306635
   PerfTop:    1429 irqs/sec  kernel:88.3%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.18%  [unknown]         [.] 0x00007f84a7766b99         
     5.13%  [kernel]          [k] _raw_spin_lock             
     4.82%  [kernel]          [k] page_fault                 
     4.28%  [xfs]             [k] _xfs_buf_find              
     4.21%  [kernel]          [k] memcpy                     
     2.23%  [kernel]          [k] kmem_cache_alloc           
     1.90%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.83%  [kernel]          [k] __d_lookup                 
     1.67%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.52%  [kernel]          [k] __kmalloc                  
     1.52%  [xfs]             [k] xfs_next_bit               
     1.36%  [kernel]          [k] kmem_cache_free            
     1.34%  [xfs]             [k] xfs_buf_offset             
     1.11%  [kernel]          [k] link_path_walk             
     1.11%  [kernel]          [k] memset                     
     1.08%  [kernel]          [k] kfree                      
     1.03%  [xfs]             [k] xfs_buf_item_size          
     1.03%  [xfs]             [k] xfs_dir2_node_addname_int  
     1.01%  [kernel]          [k] s_show                     
     0.98%  [xfs]             [k] xfs_btree_lookup           
     0.94%  [xfs]             [k] xfs_da_do_buf              

time: 1341306635
   PerfTop:    1232 irqs/sec  kernel:88.9%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.11%  [unknown]         [.] 0x00007f84a7766b99         
     5.13%  [kernel]          [k] _raw_spin_lock             
     4.87%  [kernel]          [k] page_fault                 
     4.33%  [xfs]             [k] _xfs_buf_find              
     4.16%  [kernel]          [k] memcpy                     
     2.24%  [kernel]          [k] kmem_cache_alloc           
     1.84%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.82%  [kernel]          [k] __d_lookup                 
     1.65%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.50%  [xfs]             [k] xfs_next_bit               
     1.49%  [kernel]          [k] __kmalloc                  
     1.34%  [kernel]          [k] kmem_cache_free            
     1.32%  [xfs]             [k] xfs_buf_offset             
     1.13%  [kernel]          [k] link_path_walk             
     1.13%  [kernel]          [k] kfree                      
     1.11%  [kernel]          [k] memset                     
     1.06%  [kernel]          [k] s_show                     
     1.03%  [xfs]             [k] xfs_buf_item_size          
     1.02%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.98%  [xfs]             [k] xfs_btree_lookup           
     0.94%  [xfs]             [k] xfs_da_do_buf              

time: 1341306639
   PerfTop:    1444 irqs/sec  kernel:87.3%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    11.19%  [unknown]         [.] 0x00007f84a7766b99         
     5.10%  [kernel]          [k] _raw_spin_lock             
     4.95%  [kernel]          [k] page_fault                 
     4.40%  [xfs]             [k] _xfs_buf_find              
     4.10%  [kernel]          [k] memcpy                     
     2.20%  [kernel]          [k] kmem_cache_alloc           
     1.93%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.81%  [kernel]          [k] __d_lookup                 
     1.59%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.50%  [xfs]             [k] xfs_next_bit               
     1.48%  [kernel]          [k] __kmalloc                  
     1.37%  [kernel]          [k] kmem_cache_free            
     1.36%  [xfs]             [k] xfs_buf_offset             
     1.15%  [kernel]          [k] memset                     
     1.12%  [kernel]          [k] s_show                     
     1.12%  [kernel]          [k] link_path_walk             
     1.10%  [kernel]          [k] kfree                      
     1.02%  [xfs]             [k] xfs_buf_item_size          
     0.99%  [xfs]             [k] xfs_btree_lookup           
     0.97%  [xfs]             [k] xfs_dir2_node_addname_int  
     0.94%  [xfs]             [k] xfs_da_do_buf              

time: 1341306639
   PerfTop:    1195 irqs/sec  kernel:90.9%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

    10.00%  [unknown]         [.] 0x00007f84a7766b99         
     5.17%  [kernel]          [k] _raw_spin_lock             
     4.44%  [xfs]             [k] _xfs_buf_find              
     4.37%  [kernel]          [k] page_fault                 
     4.37%  [kernel]          [k] memcpy                     
     2.30%  [kernel]          [k] kmem_cache_alloc           
     1.90%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.63%  [kernel]          [k] __d_lookup                 
     1.62%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.59%  [xfs]             [k] xfs_buf_offset             
     1.50%  [kernel]          [k] kmem_cache_free            
     1.50%  [kernel]          [k] __kmalloc                  
     1.49%  [xfs]             [k] xfs_next_bit               
     1.33%  [kernel]          [k] memset                     
     1.28%  [kernel]          [k] kfree                      
     1.11%  [xfs]             [k] xfs_buf_item_size          
     1.07%  [kernel]          [k] s_show                     
     1.07%  [kernel]          [k] link_path_walk             
     0.93%  [xfs]             [k] xfs_btree_lookup           
     0.90%  [xfs]             [k] xfs_da_do_buf              
     0.84%  [xfs]             [k] xfs_dir2_node_addname_int  

time: 1341306645
   PerfTop:    1097 irqs/sec  kernel:95.8%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     7.51%  [unknown]         [.] 0x00007f84a7766b99         
     5.02%  [kernel]          [k] _raw_spin_lock             
     4.63%  [kernel]          [k] memcpy                     
     4.51%  [xfs]             [k] _xfs_buf_find              
     3.32%  [kernel]          [k] page_fault                 
     2.37%  [kernel]          [k] kmem_cache_alloc           
     1.87%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.77%  [xfs]             [k] xfs_buf_offset             
     1.75%  [kernel]          [k] __kmalloc                  
     1.73%  [xfs]             [k] xfs_next_bit               
     1.65%  [kernel]          [k] memset                     
     1.60%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.53%  [kernel]          [k] kfree                      
     1.52%  [kernel]          [k] kmem_cache_free            
     1.44%  [xfs]             [k] xfs_trans_ail_cursor_first 
     1.26%  [kernel]          [k] __d_lookup                 
     1.26%  [xfs]             [k] xfs_buf_item_size          
     1.05%  [kernel]          [k] s_show                     
     1.03%  [xfs]             [k] xfs_buf_item_format        
     0.92%  [kernel]          [k] __d_lookup_rcu             
     0.87%  [kernel]          [k] link_path_walk             

time: 1341306645
   PerfTop:    1038 irqs/sec  kernel:95.2%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     5.89%  [unknown]         [.] 0x00007f84a7766b99         
     5.18%  [kernel]          [k] memcpy                     
     4.60%  [xfs]             [k] _xfs_buf_find              
     4.52%  [kernel]          [k] _raw_spin_lock             
     2.60%  [kernel]          [k] page_fault                 
     2.42%  [kernel]          [k] kmem_cache_alloc           
     1.99%  [kernel]          [k] __kmalloc                  
     1.96%  [xfs]             [k] xfs_next_bit               
     1.93%  [xfs]             [k] xfs_buf_offset             
     1.84%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.83%  [kernel]          [k] memset                     
     1.80%  [kernel]          [k] kmem_cache_free            
     1.68%  [kernel]          [k] kfree                      
     1.47%  [xfs]             [k] xfs_buf_item_size          
     1.45%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.18%  [kernel]          [k] __d_lookup_rcu             
     1.13%  [xfs]             [k] xfs_trans_ail_cursor_first 
     1.12%  [xfs]             [k] xfs_buf_item_format        
     1.04%  [kernel]          [k] s_show                     
     1.01%  [kernel]          [k] __d_lookup                 
     0.93%  [xfs]             [k] xfs_da_do_buf              

time: 1341306645
   PerfTop:    1087 irqs/sec  kernel:96.0%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     5.27%  [kernel]          [k] memcpy                     
     4.77%  [unknown]         [.] 0x00007f84a7766b99         
     4.69%  [xfs]             [k] _xfs_buf_find              
     4.56%  [kernel]          [k] _raw_spin_lock             
     2.47%  [kernel]          [k] kmem_cache_alloc           
     2.18%  [xfs]             [k] xfs_next_bit               
     2.11%  [kernel]          [k] page_fault                 
     2.00%  [xfs]             [k] xfs_buf_offset             
     1.99%  [kernel]          [k] __kmalloc                  
     1.96%  [kernel]          [k] kmem_cache_free            
     1.85%  [kernel]          [k] kfree                      
     1.82%  [kernel]          [k] memset                     
     1.75%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.58%  [xfs]             [k] xfs_buf_item_size          
     1.41%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.23%  [kernel]          [k] __d_lookup_rcu             
     1.21%  [xfs]             [k] xfs_buf_item_format        
     0.99%  [kernel]          [k] s_show                     
     0.97%  [xfs]             [k] xfs_perag_put              
     0.92%  [xfs]             [k] xfs_da_do_buf              
     0.92%  [xfs]             [k] xfs_trans_ail_cursor_first 

time: 1341306651
   PerfTop:    1157 irqs/sec  kernel:96.5%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     5.53%  [kernel]          [k] memcpy                     
     4.61%  [xfs]             [k] _xfs_buf_find              
     4.40%  [kernel]          [k] _raw_spin_lock             
     3.83%  [unknown]         [.] 0x00007f84a7766b99         
     2.67%  [kernel]          [k] kmem_cache_alloc           
     2.32%  [xfs]             [k] xfs_next_bit               
     2.21%  [kernel]          [k] __kmalloc                  
     2.21%  [xfs]             [k] xfs_buf_offset             
     2.19%  [kernel]          [k] kmem_cache_free            
     1.92%  [kernel]          [k] memset                     
     1.89%  [kernel]          [k] kfree                      
     1.80%  [xfs]             [k] xfs_buf_item_size          
     1.70%  [kernel]          [k] page_fault                 
     1.62%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.50%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.30%  [xfs]             [k] xfs_buf_item_format        
     1.27%  [kernel]          [k] __d_lookup_rcu             
     0.97%  [xfs]             [k] xfs_da_do_buf              
     0.96%  [xfs]             [k] xlog_cil_prepare_log_vecs  
     0.93%  [kernel]          [k] s_show                     
     0.93%  [xfs]             [k] xfs_perag_put              

time: 1341306651
   PerfTop:    1073 irqs/sec  kernel:95.5%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     5.76%  [kernel]          [k] memcpy                     
     4.54%  [xfs]             [k] _xfs_buf_find              
     4.32%  [kernel]          [k] _raw_spin_lock             
     3.15%  [unknown]         [.] 0x00007f84a7766b99         
     2.77%  [kernel]          [k] kmem_cache_alloc           
     2.49%  [xfs]             [k] xfs_next_bit               
     2.36%  [kernel]          [k] __kmalloc                  
     2.27%  [kernel]          [k] kmem_cache_free            
     2.20%  [xfs]             [k] xfs_buf_offset             
     1.88%  [kernel]          [k] memset                     
     1.88%  [kernel]          [k] kfree                      
     1.77%  [xfs]             [k] xfs_buf_item_size          
     1.62%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.48%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.42%  [xfs]             [k] xfs_buf_item_format        
     1.40%  [kernel]          [k] page_fault                 
     1.39%  [kernel]          [k] __d_lookup_rcu             
     0.99%  [xfs]             [k] xfs_da_do_buf              
     0.96%  [xfs]             [k] xlog_cil_prepare_log_vecs  
     0.88%  [kernel]          [k] s_show                     
     0.87%  [xfs]             [k] xfs_perag_put              

time: 1341306651
   PerfTop:     492 irqs/sec  kernel:85.6%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     5.74%  [kernel]          [k] memcpy                     
     4.48%  [xfs]             [k] _xfs_buf_find              
     4.27%  [kernel]          [k] _raw_spin_lock             
     3.00%  [unknown]         [.] 0x00007f84a7766b99         
     2.76%  [kernel]          [k] kmem_cache_alloc           
     2.54%  [xfs]             [k] xfs_next_bit               
     2.39%  [kernel]          [k] __kmalloc                  
     2.30%  [kernel]          [k] kmem_cache_free            
     2.20%  [xfs]             [k] xfs_buf_offset             
no symbols found in /bin/ps, maybe install a debug package?
     1.96%  [kernel]          [k] kfree                      
     1.92%  [kernel]          [k] memset                     
     1.75%  [xfs]             [k] xfs_buf_item_size          
     1.56%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.48%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.44%  [xfs]             [k] xfs_buf_item_format        
     1.39%  [kernel]          [k] __d_lookup_rcu             
     1.36%  [kernel]          [k] page_fault                 
     0.99%  [xfs]             [k] xlog_cil_prepare_log_vecs  
     0.96%  [xfs]             [k] xfs_da_do_buf              
     0.86%  [kernel]          [k] s_show                     
     0.85%  [xfs]             [k] xfs_perag_put              

time: 1341306657
   PerfTop:      70 irqs/sec  kernel:72.9%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     5.73%  [kernel]          [k] memcpy                     
     4.47%  [xfs]             [k] _xfs_buf_find              
     4.27%  [kernel]          [k] _raw_spin_lock             
     2.99%  [unknown]         [.] 0x00007f84a7766b99         
     2.75%  [kernel]          [k] kmem_cache_alloc           
     2.53%  [xfs]             [k] xfs_next_bit               
     2.39%  [kernel]          [k] __kmalloc                  
     2.30%  [kernel]          [k] kmem_cache_free            
     2.20%  [xfs]             [k] xfs_buf_offset             
     1.96%  [kernel]          [k] kfree                      
     1.92%  [kernel]          [k] memset                     
     1.75%  [xfs]             [k] xfs_buf_item_size          
     1.56%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.49%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.43%  [xfs]             [k] xfs_buf_item_format        
     1.38%  [kernel]          [k] __d_lookup_rcu             
     1.37%  [kernel]          [k] page_fault                 
     0.98%  [xfs]             [k] xlog_cil_prepare_log_vecs  
     0.96%  [xfs]             [k] xfs_da_do_buf              
     0.89%  [kernel]          [k] s_show                     
     0.85%  [xfs]             [k] xfs_perag_put              

time: 1341306657
   PerfTop:      87 irqs/sec  kernel:71.3%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     5.72%  [kernel]          [k] memcpy                     
     4.45%  [xfs]             [k] _xfs_buf_find              
     4.25%  [kernel]          [k] _raw_spin_lock             
     2.99%  [unknown]         [.] 0x00007f84a7766b99         
     2.74%  [kernel]          [k] kmem_cache_alloc           
     2.52%  [xfs]             [k] xfs_next_bit               
     2.38%  [kernel]          [k] __kmalloc                  
     2.29%  [kernel]          [k] kmem_cache_free            
     2.19%  [xfs]             [k] xfs_buf_offset             
     1.95%  [kernel]          [k] kfree                      
     1.91%  [kernel]          [k] memset                     
     1.74%  [xfs]             [k] xfs_buf_item_size          
     1.56%  [kernel]          [k] _raw_spin_lock_irqsave     
     1.48%  [kernel]          [k] _raw_spin_unlock_irqrestore
     1.43%  [xfs]             [k] xfs_buf_item_format        
     1.38%  [kernel]          [k] page_fault                 
     1.38%  [kernel]          [k] __d_lookup_rcu             
     0.98%  [xfs]             [k] xlog_cil_prepare_log_vecs  
     0.96%  [xfs]             [k] xfs_da_do_buf              
     0.93%  [kernel]          [k] s_show                     
     0.84%  [xfs]             [k] xfs_perag_put              

time: 1341306657
   PerfTop:      88 irqs/sec  kernel:68.2%  exact:  0.0% [1000Hz cycles],  (all, 8 CPUs)
-------------------------------------------------------------------------------

     5.69%  [kernel]          [k] memcpy                     
     4.42%  [xfs]             [k] _xfs_buf_find              
     4.25%  [kernel]          [k] _raw_spin_lock             
     2.98%  [unknown]         [.] 0x00007f84a7766b99         

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
