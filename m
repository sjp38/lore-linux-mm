Date: Fri, 14 Dec 2007 15:05:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22-stable causes oomkiller to be invoked
Message-Id: <20071214150533.aa30efd4.akpm@linux-foundation.org>
In-Reply-To: <20071214182802.GC2576@linux.vnet.ibm.com>
References: <20071213132326.GC16905@linux.vnet.ibm.com>
	<20071213151847.GB5676@linux.vnet.ibm.com>
	<20071213162936.GA7635@suse.de>
	<20071213164658.GA30865@linux.vnet.ibm.com>
	<20071213175423.GA2977@linux.vnet.ibm.com>
	<476295FF.1040202@gmail.com>
	<20071214154711.GD23670@linux.vnet.ibm.com>
	<4762A721.7080400@gmail.com>
	<20071214161637.GA2687@linux.vnet.ibm.com>
	<20071214095023.b5327703.akpm@linux-foundation.org>
	<20071214182802.GC2576@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: htejun@gmail.com, gregkh@suse.de, stable@kernel.org, linux-kernel@vger.kernel.org, maneesh@linux.vnet.ibm.com, vatsa@linux.vnet.ibm.com, balbir@in.ibm.com, ego@in.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Dec 2007 23:58:02 +0530
Dhaval Giani <dhaval@linux.vnet.ibm.com> wrote:

> On Fri, Dec 14, 2007 at 09:50:23AM -0800, Andrew Morton wrote:
> > On Fri, 14 Dec 2007 21:46:37 +0530 Dhaval Giani <dhaval@linux.vnet.ibm.com> wrote:
> > 
> > > On Sat, Dec 15, 2007 at 12:54:09AM +0900, Tejun Heo wrote:
> > > > Dhaval Giani wrote:
> > > > > XXX sysfs_page_cnt=1
> > > > 
> > > > Hmm.. so, sysfs r/w buffer wasn't the culprit.  I'm curious what eats up
> > > > all your low memory.  Please do the following.
> > > > 
> > > > 1. Right after boot, record /proc/meminfo and slabinfo.
> > > > 
> > > > 2. After or near OOM, record /proc/meminfo and slabinfo.  This can be
> > > > tricky but if your machine reliably OOMs after 10mins, run it for 9mins
> > > > and capturing the result should show enough.
> > > > 
> > > 
> > > Attached. The results are after oom, but i think about a min or so after
> > > that. I missed the oom point.
> > 
> > Looking back at your original oom-killer output: something has consumed all
> > your ZONE_NORMAL memory and we cannot tell what it is.
> > 
> > Please run 2.6.24-rc5-mm1 again (with CONFIG_PAGE_OWNER=y) and take a peek
> > at the changelog in
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc5/2.6.24-rc5-mm1/broken-out/page-owner-tracking-leak-detector.patch.
> > 
> > Build up Documentation/page_owner.c then cause the leak to happen then
> > execute page_owner.
> > 
> Hi Andrew
> 
> This is a peek during the leak.
> 
> ...
> 
> [sorted_page_owner.txt  text/plain (100.2KB)]
> 51957 times:
> Page allocated via order 0, mask 0x80d0
> [0xc015b9aa] __alloc_pages+706
> [0xc015b9f0] __get_free_pages+60
> [0xc011b7c9] pgd_alloc+60
> [0xc0122b9e] mm_init+196
> [0xc0122e06] dup_mm+101
> [0xc0122eda] copy_mm+104
> [0xc0123b8c] copy_process+1149
> [0xc0124229] do_fork+141
> 
> 12335 times:
> Page allocated via order 0, mask 0x84d0
> [0xc015b9aa] __alloc_pages+706
> [0xc011b6ca] pte_alloc_one+21
> [0xc01632ac] __pte_alloc+21
> [0xc01634bb] copy_pte_range+67
> [0xc0163827] copy_page_range+284
> [0xc0122a79] dup_mmap+427
> [0xc0122e22] dup_mm+129
> [0xc0122eda] copy_mm+104

OK, so you're leaking pgd's on a fork-intensive load.  It's a 4G i386
highmem system but I'm sure there are enough of those out there (still) for
this bug to have been promptly reported if it was generally occurring.

There's something special about either your setup or the test which you're
running.

Is it really the case that the bug only turns up when you run tests like

	while echo; do cat /sys/kernel/kexec_crash_loaded; done
and
	while echo; do cat /sys/kernel/uevent_seqnum ; done;

or will any fork-intensive workload also do it?  Say,

	while echo ; do true ; done

?

Another interesting factoid here is that after the oomkilling you slabinfo has

mm_struct             38     98    584    7    1 : tunables   32   16    8 : slabdata     14     14      0 : globalstat    2781    196    49   31 				   0    1    0    0    0 : cpustat 368800  11864 368920  11721

so we aren't leaking mm_structs.  In fact we aren't leaking anything from
slab.   But we are leaking pgds.

iirc the most recent change we've made in the pgd_t area is the quicklist
management which went into 2.6.22-rc1.  You say the bug was present in
2.6.22.  Can you test 2.6.21?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
