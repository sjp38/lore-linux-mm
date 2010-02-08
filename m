Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BDE016B0047
	for <linux-mm@kvack.org>; Mon,  8 Feb 2010 02:20:45 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id o187Kg5w027120
	for <linux-mm@kvack.org>; Mon, 8 Feb 2010 07:20:42 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o187KZPw1478688
	for <linux-mm@kvack.org>; Mon, 8 Feb 2010 08:20:42 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o187KZEG013995
	for <linux-mm@kvack.org>; Mon, 8 Feb 2010 08:20:35 +0100
Message-ID: <4B6FBB3F.4010701@linux.vnet.ibm.com>
Date: Mon, 08 Feb 2010 08:20:31 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/11] readahead: bump up the default readahead size
References: <20100207041013.891441102@intel.com> <20100207041043.147345346@intel.com>
In-Reply-To: <20100207041043.147345346@intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is related to our discussion from October 09 e.g. 
http://lkml.indiana.edu/hypermail/linux/kernel/0910.1/01468.html

I work for s390 where - as mainframe - we only have environments that 
benefit from 512k readahead, but I still expect some embedded devices won't.
While my idea of making it configurable was not liked in the past, it 
may be still useful when introducing this default change to let some 
small devices choose without patching the src (a number field defaulting 
to 512 and explaining the past of that value would be really nice).

For the discussion of 512 vs. 128 I can add from my measurements that I 
have seen the following:
- 512 is by far superior to 128 for sequential reads
- improvements with iozone sequential read scaling from 1 to 64 parallel 
processes up to +35%
- readahead sizes larger than 512 reevealed to not be "more useful" but 
increasing the chance of trashing in low mem systems

So I appreciate this change with a little note that I would prefer a 
config option.
-> tested & acked-by Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

Wu Fengguang wrote:
 >
 > Use 512kb max readahead size, and 32kb min readahead size.
 >
 > The former helps io performance for common workloads.
 > The latter will be used in the thrashing safe context readahead.
 >
 > -- Rationals on the 512kb size --
 >
 > I believe it yields more I/O throughput without noticeably increasing
 > I/O latency for today's HDD.
 >
 > For example, for a 100MB/s and 8ms access time HDD, its random IO or
 > highly concurrent sequential IO would in theory be:
 >
 > io_size KB  access_time  transfer_time  io_latency   util%   
throughput KB/s
 > 4           8             0.04           8.04        0.49%    497.57 
 > 8           8             0.08           8.08        0.97%    990.33 
 > 16          8             0.16           8.16        1.92%   1961.69
 > 32          8             0.31           8.31        3.76%   3849.62
 > 64          8             0.62           8.62        7.25%   7420.29
 > 128         8             1.25           9.25       13.51%  13837.84
 > 256         8             2.50          10.50       23.81%  24380.95
 > 512         8             5.00          13.00       38.46%  39384.62
 > 1024        8            10.00          18.00       55.56%  56888.89
 > 2048        8            20.00          28.00       71.43%  73142.86
 > 4096        8            40.00          48.00       83.33%  85333.33
 >
 > The 128KB => 512KB readahead size boosts IO throughput from ~13MB/s to
 > ~39MB/s, while merely increases (minimal) IO latency from 9.25ms to 13ms.
 >
 > As for SSD, I find that Intel X25-M SSD desires large readahead size
 > even for sequential reads:
 >
 >     rasize    1st run        2nd run
 >     ----------------------------------
 >       4k    123 MB/s    122 MB/s
 >      16k      153 MB/s    153 MB/s
 >      32k    161 MB/s    162 MB/s
 >      64k    167 MB/s    168 MB/s
 >     128k    197 MB/s    197 MB/s
 >     256k    217 MB/s    217 MB/s
 >     512k    238 MB/s    234 MB/s
 >       1M    251 MB/s    248 MB/s
 >       2M    259 MB/s    257 MB/s
 >          4M    269 MB/s    264 MB/s
 >       8M    266 MB/s    266 MB/s
 >
 > The two other impacts of an enlarged readahead size are
 >
 > - memory footprint (caused by readahead miss)
 >     Sequential readahead hit ratio is pretty high regardless of max
 >     readahead size; the extra memory footprint is mainly caused by
 >     enlarged mmap read-around.
 >     I measured my desktop:
 >     - under Xwindow:
 >         128KB readahead hit ratio = 143MB/230MB = 62%
 >         512KB readahead hit ratio = 138MB/248MB = 55%
 >           1MB readahead hit ratio = 130MB/253MB = 51%
 >     - under console: (seems more stable than the Xwindow data)
 >         128KB readahead hit ratio = 30MB/56MB   = 53%
 >           1MB readahead hit ratio = 30MB/59MB   = 51%
 >     So the impact to memory footprint looks acceptable.
 >
 > - readahead thrashing
 >     It will now cost 1MB readahead buffer per stream.  Memory tight
 >     systems typically do not run multiple streams; but if they do
 >     so, it should help I/O performance as long as we can avoid
 >     thrashing, which can be achieved with the following patches.
 >
 > -- Benchmarks by Vivek Goyal --
 >
 > I have got two paths to the HP EVA and got multipath device setup(dm-3).
 > I run increasing number of sequential readers. File system is ext3 and
 > filesize is 1G.
 > I have run the tests 3 times (3sets) and taken the average of it.
 >
 > Workload=bsr      iosched=cfq     Filesz=1G   bs=32K
 > ======================================================================
 >                     2.6.33-rc5                2.6.33-rc5-readahead
 > job   Set NR  ReadBW(KB/s)   MaxClat(us)    ReadBW(KB/s)   MaxClat(us)
 > ---   --- --  ------------   -----------    ------------   -----------
 > bsr   3   1   141768         130965         190302         97937.3   
 > bsr   3   2   131979         135402         185636         223286    
 > bsr   3   4   132351         420733         185986         363658    
 > bsr   3   8   133152         455434         184352         428478    
 > bsr   3   16  130316         674499         185646         594311    
 >
 > I ran same test on a different piece of hardware. There are few SATA 
disks
 > (5-6) in striped configuration behind a hardware RAID controller.
 >
 > Workload=bsr      iosched=cfq     Filesz=1G   bs=32K
 > ======================================================================
 >                     2.6.33-rc5                2.6.33-rc5-readahead
 > job   Set NR  ReadBW(KB/s)   MaxClat(us)    ReadBW(KB/s)   
MaxClat(us)   
 > ---   --- --  ------------   -----------    ------------   
-----------   
 > bsr   3   1   147569         14369.7        160191         
22752         
 > bsr   3   2   124716         243932         149343         
184698        
 > bsr   3   4   123451         327665         147183         
430875        
 > bsr   3   8   122486         455102         144568         
484045        
 > bsr   3   16  117645         1.03957e+06    137485         
1.06257e+06   
 >
 > Tested-by: Vivek Goyal <vgoyal@redhat.com>
 > CC: Jens Axboe <jens.axboe@oracle.com>
 > CC: Chris Mason <chris.mason@oracle.com>
 > CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
 > CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
 > CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
 > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
 > ---
 >  include/linux/mm.h |    4 ++--
 >  1 file changed, 2 insertions(+), 2 deletions(-)
 >
 > --- linux.orig/include/linux/mm.h    2010-01-30 17:38:49.000000000 +0800
 > +++ linux/include/linux/mm.h    2010-01-30 18:09:58.000000000 +0800
 > @@ -1184,8 +1184,8 @@ int write_one_page(struct page *page, in
 >  void task_dirty_inc(struct task_struct *tsk);
 >
 >  /* readahead.c */
 > -#define VM_MAX_READAHEAD    128    /* kbytes */
 > -#define VM_MIN_READAHEAD    16    /* kbytes (includes current page) */
 > +#define VM_MAX_READAHEAD    512    /* kbytes */
 > +#define VM_MIN_READAHEAD    32    /* kbytes (includes current page) */
 >
 >  int force_page_cache_readahead(struct address_space *mapping, struct 
file *filp,
 >              pgoff_t offset, unsigned long nr_to_read);
 >
 >

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, Open Virtualization 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
