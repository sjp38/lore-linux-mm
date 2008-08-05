Date: Tue, 5 Aug 2008 12:14:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC:Patch: 000/008](memory hotplug) rough idea of pgdat removing
Message-ID: <20080805111450.GE20243@csn.ul.ie>
References: <20080802090335.D6C8.E1E9C6FF@jp.fujitsu.com> <4897032E.5020601@linux-foundation.org> <20080805150434.BF32.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080805150434.BF32.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On (05/08/08 15:39), Yasunori Goto didst pronounce:
> 
> > >> Duh. Then the use of RCU would also mean that all of reclaim must
> > >>  be in a rcu period. So  reclaim cannot sleep anymore.
> > > 
> > > I use srcu_read_lock() (sleepable rcu lock) if kernel must be sleep for
> > > page reclaim. So, my patch basic idea is followings.
> > 
> > But that introduces more overhead in __alloc_pages.
> 
> Hmmm. I think SRCU should be used when kernel has to sleep, and sleep time
> will be bigger than SRCU's overhead.....
> 
> The followings are results of unixbench and lmbench.
> I suppose my patch impacts lantency rather than throghput.
> In these results, 100fd select and page fault latencies of lmbench became worse.
> So I can't say there is no problem in my patches.
> 
> Anyway, I'll retry to find other less impact way if there is,
> and compare benchmark results with this way.
> 

Maybe I am missing something, but what is wrong with stop_machine during
memory hot-remove?

> Bye.
> 
> ------------
> 
> Unixbench
> -----
> 
> Normal 2.6.27-rc1-mm1
> 
> 
>   BYTE UNIX Benchmarks (Version 4.1.0)
>   System -- Linux localhost.localdomain 2.6.27-rc1-mm1 #1 SMP Mon Aug 4 16:08:48 JST 2008 ia64 ia64 ia64 GNU/Linux
>   Start Benchmark Run: 2008?$BG/  8?$B7n  5?$BF| ?$B2PMKF| 10:24:35 JST
>    1 interactive users.
>    10:24:35 up 9 min,  1 user,  load average: 0.16, 0.08, 0.03
>   lrwxrwxrwx 1 root root 4 2008-02-25 15:48 /bin/sh -> bash
>   /bin/sh: symbolic link to `bash'
>   /dev/sda5             33792348  18360424  13687672  58% /home
> Execl Throughput                           2954.0 lps   (29.8 secs, 3 samples)
> File Read 1024 bufsize 2000 maxblocks    1211570.0 KBps  (30.0 secs, 3 samples)
> File Write 1024 bufsize 2000 maxblocks   281599.0 KBps  (30.0 secs, 3 samples)
> File Copy 1024 bufsize 2000 maxblocks    218859.0 KBps  (30.0 secs, 3 samples)
> File Read 256 bufsize 500 maxblocks      328725.0 KBps  (30.0 secs, 3 samples)
> File Write 256 bufsize 500 maxblocks      72850.0 KBps  (30.0 secs, 3 samples)
> File Copy 256 bufsize 500 maxblocks       57095.0 KBps  (30.0 secs, 3 samples)
> File Read 4096 bufsize 8000 maxblocks    3883690.0 KBps  (30.0 secs, 3 samples)
> File Write 4096 bufsize 8000 maxblocks   1050752.0 KBps  (30.0 secs, 3 samples)
> File Copy 4096 bufsize 8000 maxblocks    564703.0 KBps  (30.0 secs, 3 samples)
> Pipe Throughput                          462027.5 lps   (10.0 secs, 10 samples)
> Pipe-based Context Switching             105824.3 lps   (10.0 secs, 10 samples)
> Process Creation                           2242.9 lps   (30.0 secs, 3 samples)
> System Call Overhead                     1320907.8 lps   (10.0 secs, 10 samples)
> Shell Scripts (1 concurrent)               4442.1 lpm   (60.0 secs, 3 samples)
> Shell Scripts (8 concurrent)               1810.0 lpm   (60.0 secs, 3 samples)
> Shell Scripts (16 concurrent)              1042.7 lpm   (60.0 secs, 3 samples)
> 
> 
>                      INDEX VALUES            
> TEST                                        BASELINE     RESULT      INDEX
> 
> Execl Throughput                                43.0     2954.0      687.0
> File Copy 1024 bufsize 2000 maxblocks         3960.0   218859.0      552.7
> File Copy 256 bufsize 500 maxblocks           1655.0    57095.0      345.0
> File Copy 4096 bufsize 8000 maxblocks         5800.0   564703.0      973.6
> Pipe Throughput                              12440.0   462027.5      371.4
> Pipe-based Context Switching                  4000.0   105824.3      264.6
> Process Creation                               126.0     2242.9      178.0
> Shell Scripts (8 concurrent)                     6.0     1810.0     3016.7
> System Call Overhead                         15000.0  1320907.8      880.6
>                                                                  =========
>      FINAL SCORE                                                     565.6
> 
> 
> 
> 2.6.27-rc1-mm1 with my patch 
> 
> 
>   BYTE UNIX Benchmarks (Version 4.1.0)
>   System -- Linux localhost.localdomain 2.6.27-rc1-mm1-goto-test #2 SMP Mon Aug 4 18:50:56 JST 2008 ia64 ia64 ia64 GNU/Linux
>   Start Benchmark Run: 2008?$BG/  8?$B7n  4?$BF| ?$B7nMKF| 20:35:11 JST
>    1 interactive users.
>    20:35:11 up  1:37,  1 user,  load average: 0.00, 0.29, 0.71
>   lrwxrwxrwx 1 root root 4 2008-02-25 15:48 /bin/sh -> bash
>   /bin/sh: symbolic link to `bash'
>   /dev/sda5             33792348  18360420  13687676  58% /home
> Execl Throughput                           2949.0 lps   (29.7 secs, 3 samples)
> File Read 1024 bufsize 2000 maxblocks    1317211.0 KBps  (30.0 secs, 3 samples)
> File Write 1024 bufsize 2000 maxblocks   282643.0 KBps  (30.0 secs, 3 samples)
> File Copy 1024 bufsize 2000 maxblocks    220360.0 KBps  (30.0 secs, 3 samples)
> File Read 256 bufsize 500 maxblocks      361448.0 KBps  (30.0 secs, 3 samples)
> File Write 256 bufsize 500 maxblocks      73172.0 KBps  (30.0 secs, 3 samples)
> File Copy 256 bufsize 500 maxblocks       57489.0 KBps  (30.0 secs, 3 samples)
> File Read 4096 bufsize 8000 maxblocks    3819448.0 KBps  (30.0 secs, 3 samples)
> File Write 4096 bufsize 8000 maxblocks   1026563.0 KBps  (30.0 secs, 3 samples)
> File Copy 4096 bufsize 8000 maxblocks    585218.0 KBps  (30.0 secs, 3 samples)
> Pipe Throughput                          482681.7 lps   (10.0 secs, 10 samples)
> Pipe-based Context Switching             101437.7 lps   (10.0 secs, 10 samples)
> Process Creation                           2237.5 lps   (30.0 secs, 3 samples)
> System Call Overhead                     1282198.4 lps   (10.0 secs, 10 samples)
> Shell Scripts (1 concurrent)               4447.7 lpm   (60.0 secs, 3 samples)
> Shell Scripts (8 concurrent)               1812.7 lpm   (60.0 secs, 3 samples)
> Shell Scripts (16 concurrent)              1041.7 lpm   (60.0 secs, 3 samples)
> 
> 
>                      INDEX VALUES            
> TEST                                        BASELINE     RESULT      INDEX
> 
> Execl Throughput                                43.0     2949.0      685.8
> File Copy 1024 bufsize 2000 maxblocks         3960.0   220360.0      556.5
> File Copy 256 bufsize 500 maxblocks           1655.0    57489.0      347.4
> File Copy 4096 bufsize 8000 maxblocks         5800.0   585218.0     1009.0
> Pipe Throughput                              12440.0   482681.7      388.0
> Pipe-based Context Switching                  4000.0   101437.7      253.6
> Process Creation                               126.0     2237.5      177.6
> Shell Scripts (8 concurrent)                     6.0     1812.7     3021.2
> System Call Overhead                         15000.0  1282198.4      854.8
>                                                                  =========
>      FINAL SCORE                                                     566.8
> 
> 
> 
> 
> 
> LMBENCH
> 
> The first lines are results of normal 2.6.27-rc1-mm1.
> The second lines are results with my patch.
> 
> 
> 
>                  L M B E N C H  3 . 0   S U M M A R Y
>                  ------------------------------------
>                  (Alpha software, do not distribute)
> 
> Basic system parameters
> ------------------------------------------------------------------------------
> Host                 OS Description              Mhz  tlb  cache  mem   scal
>                                                      pages line   par   load
>                                                            bytes  
> --------- ------------- ----------------------- ---- ----- ----- ------ ----
> localhost Linux 2.6.27-          ia64-linux-gnu 1600         128           1
> localhost Linux 2.6.27-          ia64-linux-gnu 1600         128           1
> 
> Processor, Processes - times in microseconds - smaller is better
> ------------------------------------------------------------------------------
> Host                 OS  Mhz null null      open slct sig  sig  fork exec sh  
>                              call  I/O stat clos TCP  inst hndl proc proc proc
> --------- ------------- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
> localhost Linux 2.6.27- 1600 0.03 0.23 3.12 4.45 6.73 0.27 1.75 227. 463. 2219
> localhost Linux 2.6.27- 1600 0.03 0.23 3.13 4.44 6.74 0.27 1.73 207. 448. 2230
> 
> Context switching - times in microseconds - smaller is better
> -------------------------------------------------------------------------
> Host                 OS  2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
>                          ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
> --------- ------------- ------ ------ ------ ------ ------ ------- -------
> localhost Linux 2.6.27-   11.3   11.4   11.5   11.5   12.7    11.8    14.6
> localhost Linux 2.6.27-   11.5   11.4   11.5   11.6   12.8    11.9    14.7
> 
> *Local* Communication latencies in microseconds - smaller is better
> ---------------------------------------------------------------------
> Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
>                         ctxsw       UNIX         UDP         TCP conn
> --------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
> localhost Linux 2.6.27-  11.3 8.464 28.3  13.4        28.7        46.
> localhost Linux 2.6.27-  11.5 8.470 28.3  13.4        32.2        46.
> 
> File & VM system latencies in microseconds - smaller is better
> -------------------------------------------------------------------------------
> Host                 OS   0K File      10K File     Mmap    Prot   Page   100fd
>                         Create Delete Create Delete Latency Fault  Fault  selct
> --------- ------------- ------ ------ ------ ------ ------- ----- ------- -----
> localhost Linux 2.6.27-   15.1   13.4   45.6   25.4   24.0K 0.384 0.23850 2.804
> localhost Linux 2.6.27-   15.8   13.3   43.0   26.0   24.1K 0.401 0.25150 2.835
> 
> *Local* Communication bandwidths in MB/s - bigger is better
> ------------------------------------------------------------------------------
> Host                 OS Description              Mhz  tlb  cache  mem   scal
>                                                      pages line   par   load
>                                                            bytes  
> --------- ------------- ----------------------- ---- ----- ----- ------ ----
> localhost Linux 2.6.27-          ia64-linux-gnu 1600         128           1
> localhost Linux 2.6.27-          ia64-linux-gnu 1600         128           1
> 
> Processor, Processes - times in microseconds - smaller is better
> ------------------------------------------------------------------------------
> Host                 OS  Mhz null null      open slct sig  sig  fork exec sh  
>                              call  I/O stat clos TCP  inst hndl proc proc proc
> --------- ------------- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
> localhost Linux 2.6.27- 1600 0.03 0.23 3.12 4.45 6.73 0.27 1.75 227. 463. 2219
> localhost Linux 2.6.27- 1600 0.03 0.23 3.13 4.44 6.74 0.27 1.73 207. 448. 2230
> 
> Context switching - times in microseconds - smaller is better
> -------------------------------------------------------------------------
> Host                 OS  2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
>                          ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
> --------- ------------- ------ ------ ------ ------ ------ ------- -------
> localhost Linux 2.6.27-   11.3   11.4   11.5   11.5   12.7    11.8    14.6
> localhost Linux 2.6.27-   11.5   11.4   11.5   11.6   12.8    11.9    14.7
> 
> *Local* Communication latencies in microseconds - smaller is better
> ---------------------------------------------------------------------
> Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
>                         ctxsw       UNIX         UDP         TCP conn
> --------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
> localhost Linux 2.6.27-  11.3 8.464 28.3  13.4        28.7        46.
> localhost Linux 2.6.27-  11.5 8.470 28.3  13.4        32.2        46.
> 
> File & VM system latencies in microseconds - smaller is better
> -------------------------------------------------------------------------------
> Host                 OS   0K File      10K File     Mmap    Prot   Page   100fd
>                         Create Delete Create Delete Latency Fault  Fault  selct
> --------- ------------- ------ ------ ------ ------ ------- ----- ------- -----
> localhost Linux 2.6.27-   15.1   13.4   45.6   25.4   24.0K 0.384 0.23850 2.804  <---!!!
> localhost Linux 2.6.27-   15.8   13.3   43.0   26.0   24.1K 0.401 0.25150 2.835  <----!!!
> 
> *Local* Communication bandwidths in MB/s - bigger is better
> -----------------------------------------------------------------------------
> Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
>                              UNIX      reread reread (libc) (hand) read write
> --------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
> localhost Linux 2.6.27- 4814 4100 1188 2087.4  523.2  549.6  274.9 458. 523.5
> localhost Linux 2.6.27- 4811 4111 1219 2090.8  523.1  549.4  276.1 458. 523.5
> (END) 
> 
> 
> 
> -- 
> Yasunori Goto 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
