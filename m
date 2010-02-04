Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6C2F16004A5
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 08:44:22 -0500 (EST)
Date: Thu, 4 Feb 2010 21:44:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] [RFC] 512K readahead size with thrashing safe
	readahead
Message-ID: <20100204134406.GB26442@localhost>
References: <20100202152835.683907822@intel.com> <20100202223803.GF3922@redhat.com> <20100203062756.GB22890@localhost> <20100203152454.GA17059@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100203152454.GA17059@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Vivek,

> I have got two paths to the HP EVA and got multipath device setup(dm-3). I
> noticed with vanilla kernel read_ahead_kb=128 after boot but with your patches
> applied it is set to 4. So looks like something went wrong with device
> size/capacity detection hence wrong defaults. Manually setting
> read_ahead_kb=512, got me better performance as compare to vanilla kernel.
> 
> AVERAGE[bsr]    
> ------- 
> job       Set NR  ReadBW(KB/s)   MaxClat(us)    WriteBW(KB/s)  MaxClat(us)    
> ---       --- --  ------------   -----------    -------------  -----------    
> bsr       3   1   190302         97937.3        0              0              
> bsr       3   2   185636         223286         0              0              
> bsr       3   4   185986         363658         0              0              
> bsr       3   8   184352         428478         0              0              
> bsr       3   16  185646         594311         0              0              

This looks good, thank you for the data!  I added them to the changelog :)

Thanks,
Fengguang
---
readahead: bump up the default readahead size

Use 512kb max readahead size, and 32kb min readahead size.

The former helps io performance for common workloads.
The latter will be used in the thrashing safe context readahead.

-- Rationals on the 512kb size --

I believe it yields more I/O throughput without noticeably increasing
I/O latency for today's HDD.

For example, for a 100MB/s and 8ms access time HDD:

io_size KB  access_time  transfer_time  io_latency   util%   throughput KB/s
4           8             0.04           8.04        0.49%    497.57  
8           8             0.08           8.08        0.97%    990.33  
16          8             0.16           8.16        1.92%   1961.69 
32          8             0.31           8.31        3.76%   3849.62 
64          8             0.62           8.62        7.25%   7420.29 
128         8             1.25           9.25       13.51%  13837.84
256         8             2.50          10.50       23.81%  24380.95
512         8             5.00          13.00       38.46%  39384.62
1024        8            10.00          18.00       55.56%  56888.89
2048        8            20.00          28.00       71.43%  73142.86
4096        8            40.00          48.00       83.33%  85333.33

The 128KB => 512KB readahead size boosts IO throughput from ~13MB/s to
~39MB/s, while merely increases (minimal) IO latency from 9.25ms to 13ms.

As for SSD, I find that Intel X25-M SSD desires large readahead size
even for sequential reads:

	rasize	1st run		2nd run
	----------------------------------
	  4k	123 MB/s	122 MB/s
	 16k  	153 MB/s	153 MB/s
	 32k	161 MB/s	162 MB/s
	 64k	167 MB/s	168 MB/s
	128k	197 MB/s	197 MB/s
	256k	217 MB/s	217 MB/s
	512k	238 MB/s	234 MB/s
	  1M	251 MB/s	248 MB/s
	  2M	259 MB/s	257 MB/s
   	  4M	269 MB/s	264 MB/s
	  8M	266 MB/s	266 MB/s

The two other impacts of an enlarged readahead size are

- memory footprint (caused by readahead miss)
	Sequential readahead hit ratio is pretty high regardless of max
	readahead size; the extra memory footprint is mainly caused by
	enlarged mmap read-around.
	I measured my desktop:
	- under Xwindow:
		128KB readahead hit ratio = 143MB/230MB = 62%
		512KB readahead hit ratio = 138MB/248MB = 55%
		  1MB readahead hit ratio = 130MB/253MB = 51%
	- under console: (seems more stable than the Xwindow data)
		128KB readahead hit ratio = 30MB/56MB   = 53%
		  1MB readahead hit ratio = 30MB/59MB   = 51%
	So the impact to memory footprint looks acceptable.

- readahead thrashing
	It will now cost 1MB readahead buffer per stream.  Memory tight
	systems typically do not run multiple streams; but if they do
	so, it should help I/O performance as long as we can avoid
	thrashing, which can be achieved with the following patches.

-- Benchmarks by Vivek Goyal --

I have got two paths to the HP EVA and got multipath device setup(dm-3).
I run increasing number of sequential readers. File system is ext3 and
filesize is 1G.
I have run the tests 3 times (3sets) and taken the average of it.

Workload=bsr      iosched=cfq     Filesz=1G   bs=32K
======================================================================
                    2.6.33-rc5                2.6.33-rc5-readahead
job   Set NR  ReadBW(KB/s)   MaxClat(us)    ReadBW(KB/s)   MaxClat(us)
---   --- --  ------------   -----------    ------------   -----------
bsr   3   1   141768         130965         190302         97937.3    
bsr   3   2   131979         135402         185636         223286     
bsr   3   4   132351         420733         185986         363658     
bsr   3   8   133152         455434         184352         428478     
bsr   3   16  130316         674499         185646         594311     

I ran same test on a different piece of hardware. There are few SATA disks
(5-6) in striped configuration behind a hardware RAID controller.

Workload=bsr      iosched=cfq     Filesz=1G   bs=32K
======================================================================
                    2.6.33-rc5                2.6.33-rc5-readahead
job   Set NR  ReadBW(KB/s)   MaxClat(us)    ReadBW(KB/s)   MaxClat(us)    
---   --- --  ------------   -----------    ------------   -----------    
bsr   3   1   147569         14369.7        160191         22752          
bsr   3   2   124716         243932         149343         184698         
bsr   3   4   123451         327665         147183         430875         
bsr   3   8   122486         455102         144568         484045         
bsr   3   16  117645         1.03957e+06    137485         1.06257e+06    

Tested-by: Vivek Goyal <vgoyal@redhat.com>
CC: Jens Axboe <jens.axboe@oracle.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/mm.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux.orig/include/linux/mm.h	2010-01-30 17:38:49.000000000 +0800
+++ linux/include/linux/mm.h	2010-01-30 18:09:58.000000000 +0800
@@ -1184,8 +1184,8 @@ int write_one_page(struct page *page, in
 void task_dirty_inc(struct task_struct *tsk);
 
 /* readahead.c */
-#define VM_MAX_READAHEAD	128	/* kbytes */
-#define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
+#define VM_MAX_READAHEAD	512	/* kbytes */
+#define VM_MIN_READAHEAD	32	/* kbytes (includes current page) */
 
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
