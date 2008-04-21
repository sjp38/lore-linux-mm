Date: Mon, 21 Apr 2008 21:07:48 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: OOM killer doesn't kill the right task....
Message-ID: <20080421110748.GN108924158@sgi.com>
References: <20080421070123.GM108924158@sgi.com> <20080421172255.C45A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080421172255.C45A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, xfs-oss <xfs@oss.sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 21, 2008 at 05:24:04PM +0900, KOSAKI Motohiro wrote:
> Hi David
> 
> > Running in a 512MB UML system without swap, XFSQA test 084 reliably
> > kills the kernel completely as the OOM killer is unable to find a
> > task to kill. log output is below.
> > 
> > I don't know when it started failing - ISTR this working just fine
> > on 2.6.24 kernels.
> 
> Can you reproduce it on non UML box?

Not exactly. On a 64k page size ia64 box it kills my ssh session and all
it's children which includes the errant process (log below).

It doesn't kill the machine, but if I cared enough I'd argue that
even that is killing the wrong process because it's pretty damn
clear that the only process on the box using more than a couple of
MB of memory is the resvtest program....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

resvtest invoked oom-killer: gfp_mask=0x1280d2, order=0, oomkilladj=0

Call Trace:
 [<a0000001000125e0>] show_stack+0x40/0xa0
                                sp=e000003022f0fb20 bsp=e000003022f01168
 [<a000000100012670>] dump_stack+0x30/0x60
                                sp=e000003022f0fcf0 bsp=e000003022f01150
 [<a000000100104060>] oom_kill_process+0x80/0x3a0
                                sp=e000003022f0fcf0 bsp=e000003022f010f8
 [<a000000100104ce0>] out_of_memory+0x4e0/0x660
                                sp=e000003022f0fd00 bsp=e000003022f010b0
 [<a00000010010bf00>] __alloc_pages+0x500/0x620
                                sp=e000003022f0fd90 bsp=e000003022f01040
 [<a000000100145020>] alloc_page_vma+0x1c0/0x200
                                sp=e000003022f0fda0 bsp=e000003022f01008
 [<a000000100122d00>] handle_mm_fault+0x3a0/0xe60
                                sp=e000003022f0fda0 bsp=e000003022f00f88
 [<a00000010085b700>] ia64_do_page_fault+0x2a0/0xaa0
                                sp=e000003022f0fda0 bsp=e000003022f00f30
 [<a000000100009e20>] ia64_leave_kernel+0x0/0x270
                                sp=e000003022f0fe30 bsp=e000003022f00f30
Mem-info:
Node 0 Normal per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
Active:5044 inactive:64 dirty:0 writeback:0 unstable:0
 free:34 slab:1110 mapped:6 pagetables:104 bounce:0
Node 0 Normal free:2176kB min:2880kB low:3584kB high:4288kB active:322816kB inactive:4096kB present:523776kB pages_scanned:32980 all_unreclaimable? yes
lowmem_reserve[]: 0 0
Node 0 Normal: 2*64kB 2*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB 0*65536kB 0*131072kB 0*262144kB 0*524288kB 0*1048576kB 0*2097152kB 0*4194304kB = 2432kB
76 total pagecache pages
Swap cache: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
Free swap:            0kB
Node memory in pages:
Node    0:  RAM:        8192, rsvd:     1327, shrd:        129, swpd:          0
Node    1:  RAM:           0, rsvd:        0, shrd:          0, swpd:          0
8192 pages of RAM
1327 reserved pages
129 pages shared
0 pages swap cached
Total of 45 pages in page table cache
8117 free buffer pages
Out of memory: kill process 2908 (sshd) score 379 or a child
Killed process 2909 (bash)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
