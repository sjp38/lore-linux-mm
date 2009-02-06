Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D9C9B6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 19:47:24 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <Pine.LNX.4.64.0902051839540.1445@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de>
	 <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
	 <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>
	 <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>
	 <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>
	 <1233545923.2604.60.camel@ymzhang>
	 <1233565214.17835.13.camel@penberg-laptop>
	 <1233646145.2604.137.camel@ymzhang>
	 <Pine.LNX.4.64.0902031150110.5290@blonde.anvils>
	 <1233714090.2604.186.camel@ymzhang>
	 <Pine.LNX.4.64.0902051839540.1445@blonde.anvils>
Content-Type: text/plain; charset=UTF-8
Date: Fri, 06 Feb 2009 08:47:11 +0800
Message-Id: <1233881231.2604.310.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-05 at 19:04 +0000, Hugh Dickins wrote:
> On Wed, 4 Feb 2009, Zhang, Yanmin wrote:
> > On Tue, 2009-02-03 at 12:18 +0000, Hugh Dickins wrote:
> > > On Tue, 3 Feb 2009, Zhang, Yanmin wrote:
> > > > 
> > > > Would you like to test it on your machines?
> > > 
> > > Indeed I shall, starting in a few hours when I've finished with trying
> > > the script I promised yesterday to send you.  And I won't be at all
> > > surprised if your patch eliminates my worst cases, because I don't
> > > expect to have any significant amount of free memory during my testing,
> > > and my swap testing suffers from slub's thirst for higher orders.
> > > 
> > > But I don't believe the kind of check you're making is appropriate,
> > > and I do believe that when you try more extensive testing, you'll find
> > > regressions in other tests which were relying on the higher orders.
> > 
> > Yes, I agree. And we need find such tests which causes both memory used up
> > and lots of higher-order allocations.
> 
> Sceptical though I am about your free_pages test in slub's allocate_slab(),
> I can confirm that your patch does well on my swapping loads, performing
> slightly (not necessarily significantly) better than slab on those loads
As matter of fact, the patch has the same effect like slub_max_order=0 on
your workload, except the additional cost to check free pages.

> (though not quite as well on the "immune" machine where slub was already
> keeping up with slab; and I haven't even bothered to try it on the machine
> which behaves so very badly that no conclusions can yet be drawn).
> 
> I then tried a patch I thought obviously better than yours: just mask
> off __GFP_WAIT in that __GFP_NOWARN|__GFP_NORETRY preliminary call to
> alloc_slab_page(): so we're not trying to infer anything about high-
> order availability from the number of free order-0 pages, but actually
> going to look for it and taking it if it's free, forgetting it if not.
> 
> That didn't work well at all: almost as bad as the unmodified slub.c.
> I decided that was due to __alloc_pages_internal()'s
> wakeup_kswapd(zone, order): just expressing an interest in a high-
> order page was enough to send it off trying to reclaim them, though
> not directly.  Hacked in a condition to suppress that in this case:
> worked a lot better, but not nearly as well as yours.  I supposed
> that was somehow(?) due to the subsequent get_page_from_freelist()
> calls with different watermarking: hacked in another __GFP flag to
> break out to nopage just like the NUMA_BUILD GFP_THISNODE case does.
> Much better, getting close, but still not as good as yours.  
> 
> I think I'd better turn back to things I understand better!
Your investigation is really detail-focused. I also did some testing.
i>>?
I changed the script a little. i>>?As no the laptop devices which
create the worst result difference, I tested on my stoakley which has
2 qual-core processors, 8GB memory i>>?(started kernel with mem=1GB),
i>>?a scsi disk as swap partition (35GB). 

The testing runs in a loop. It starts 2 tasks to run kbuild of 2.6.28,
build1 and build2 separately. build1 runs on tmpfs directly. build2 runs
on a ext2 loop fs on tmpfs. Both build untar the source tarball firstly, then
use the defconfig to compile kernel. The script does a sync between build1 and
build2, so they could start at the same time every iteration.
i>>?
[root@lkp-st02-x8664 ~]# slabinfo -AD|head -n 15
Name                   Objects    Alloc     Free   %Fast
names_cache                 64 11734829 11734830  99  99 
filp                      1195  8484074  8482982  90   3 
vm_area_struct            3830  7688583  7684900  92  54 
buffer_head              33970  3832771  3798977  94   0 
bio-0                     5906  2383929  2378119  91  13 
journal_handle            1360  2182580  2182580  99  99 

As a matter of fact, I got similiar cache statstics with kbuild on different machines.
i>>?names_cache's object size is 4096. filp and i>>?vm_area_struct's are 192/168.
i>>?i>>?names_cache's default order is 3. Other active kmem_cache's order is 0.
names_cache is used by getname=>__getname from sys_open/execve/faccessstat, etc.
Although kernel allocates a page every time for i>>?i>>?names_cache object, mostly, kernel
only uses a dozen of bytes per i>>?names_cache object.

With kernel 2.6.29-rc2-slqb0121 (get slqb patch from Pekka's git tree):
Thu Feb  5 15:50:24 CST 2009 2.6.29-rc2slqb0121stat x86_64
[ymzhang@lkp-st02-x8664 Hugh]$ build1   144.15  91.70   32.99
build2  159.81  91.83   34.27
Thu Feb  5 15:53:09 CST 2009: 165 secs for 1 iters, 165 secs per iter
build1  123.02  90.29   33.08
build2  204.52  90.28   34.17
Thu Feb  5 15:56:39 CST 2009: 375 secs for 2 iters, 187 secs per iter
build1  132.74  90.60   33.45
build2  210.11  90.80   33.98
Thu Feb  5 16:00:15 CST 2009: 591 secs for 3 iters, 197 secs per iter
build1  135.34  90.71   32.95
build2  220.43  91.55   33.99
Thu Feb  5 16:04:00 CST 2009: 816 secs for 4 iters, 204 secs per iter
build1  121.68  91.09   33.26
build2  202.45  91.01   34.37
Thu Feb  5 16:07:30 CST 2009: 1026 secs for 5 iters, 205 secs per iter
build1  120.51  90.19   33.42
build2  217.56  90.38   34.18
Thu Feb  5 16:11:13 CST 2009: 1249 secs for 6 iters, 208 secs per iter
build1  137.14  90.33   34.54
build2  243.14  90.93   34.33
Thu Feb  5 16:15:22 CST 2009: 1498 secs for 7 iters, 214 secs per iter
build1  141.47  91.14   33.42
build2  249.78  91.57   34.10
Thu Feb  5 16:19:37 CST 2009: 1753 secs for 8 iters, 219 secs per iter
build1  147.72  90.42   34.04
build2  252.57  90.91   33.73
Thu Feb  5 16:23:58 CST 2009: 2014 secs for 9 iters, 223 secs per iter
build1  137.40  89.80   33.99
build2  248.67  91.18   34.03
Thu Feb  5 16:28:13 CST 2009: 2269 secs for 10 iters, 226 secs per iter


With kernel 2.6.29-rc2-slubstat (default slub_max_slub):
[ymzhang@lkp-st02-x8664 Hugh]$ sh tmpfs_swap.sh
Thu Feb  5 13:21:37 CST 2009 2.6.29-rc2slubstat x86_64
[ymzhang@lkp-st02-x8664 Hugh]$ build1   155.54  91.90   33.56
build2  163.86  91.69   34.52
Thu Feb  5 13:24:30 CST 2009: 173 secs for 1 iters, 173 secs per iter
build1  135.63  90.42   33.88
build2  308.88  91.63   34.71
Thu Feb  5 13:29:57 CST 2009: 500 secs for 2 iters, 250 secs per iter
build1  127.49  90.79   33.24
ymzhang  28382  4079  0 13:29 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2
build2  414.77  91.58   34.01
Thu Feb  5 13:37:05 CST 2009: 928 secs for 3 iters, 309 secs per iter
build1  146.99  91.07   33.59
ymzhang  24569  4079  0 13:37 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2
build2  505.73  93.01   34.12
Thu Feb  5 13:45:46 CST 2009: 1449 secs for 4 iters, 362 secs per iter
build1  163.20  91.35   34.39
ymzhang  20830  4079  0 13:45 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2

The 'tar xfj' line is a sign that if build2's untar finishs when build1 finishs compiling.
Above result shows since iters 3, build2's untar isn't finished although build1
finishs compiling already. So build1 result seems quite stable while build2 result is growing.

Comparing with slqb, the result is bad.

i>>?
With kernel 2.6.29-rc2-slubstat (slub_max_slub=1, so i>>?names_cache's order is 1):
[ymzhang@lkp-st02-x8664 Hugh]$ sh tmpfs_swap.sh
Thu Feb  5 14:42:35 CST 2009 2.6.29-rc2slubstat x86_64
[ymzhang@lkp-st02-x8664 Hugh]$ build1   161.61  92.09   34.14
build2  167.92  91.78   34.38
Thu Feb  5 14:45:30 CST 2009: 175 secs for 1 iters, 174 secs per iter
build1  128.22  91.02   33.39
build2  236.95  90.59   34.45
Thu Feb  5 14:49:37 CST 2009: 422 secs for 2 iters, 211 secs per iter
build1  134.34  90.56   33.94
ymzhang  28297  4069  0 14:49 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2
build2  338.49  91.10   34.33
Thu Feb  5 14:55:27 CST 2009: 772 secs for 3 iters, 257 secs per iter
build1  144.50  90.63   34.00
ymzhang  24398  4069  0 14:55 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2
build2  415.44  91.32   34.29
Thu Feb  5 15:02:33 CST 2009: 1198 secs for 4 iters, 299 secs per iter
build1  137.31  91.03   33.80
ymzhang  20580  4069  0 15:02 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2
build2  399.31  91.88   34.31
Thu Feb  5 15:09:24 CST 2009: 1609 secs for 5 iters, 321 secs per iter
build1  147.69  91.39   33.98
ymzhang  16743  4069  0 15:09 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2
build2  397.33  91.72   34.52
Thu Feb  5 15:16:12 CST 2009: 2017 secs for 6 iters, 336 secs per iter
build1  149.65  91.28   33.65
ymzhang  12864  4069  0 15:16 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2
build2  469.35  91.78   34.15
Thu Feb  5 15:24:12 CST 2009: 2497 secs for 7 iters, 356 secs per iter
build1  138.36  90.66   34.03
ymzhang   9077  4069  0 15:24 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2
build2  498.02  91.39   34.60
Thu Feb  5 15:32:38 CST 2009: 3003 secs for 8 iters, 375 secs per iter

We see some improvement, but the improvement isn't big. The result is still worse than slqb's.

i>>?
With kernel 2.6.29-rc2-slubstat (slub_max_slub=0, i>>?names_cache order is 0):
[ymzhang@lkp-st02-x8664 Hugh]$ sh tmpfs_swap.sh
Thu Feb  5 13:59:02 CST 2009 2.6.29-rc2slubstat x86_64
[ymzhang@lkp-st02-x8664 Hugh]$ build1   170.00  92.26   33.63
build2  176.22  91.18   35.16
Thu Feb  5 14:02:04 CST 2009: 182 secs for 1 iters, 182 secs per iter
build1  136.31  90.58   33.98
build2  201.79  91.32   34.92
Thu Feb  5 14:05:31 CST 2009: 389 secs for 2 iters, 194 secs per iter
build1  114.12  91.03   33.86
build2  205.86  90.70   34.27
Thu Feb  5 14:09:02 CST 2009: 600 secs for 3 iters, 200 secs per iter
build1  131.26  90.63   35.46
build2  227.58  91.36   34.97
Thu Feb  5 14:12:56 CST 2009: 834 secs for 4 iters, 208 secs per iter
build1  151.93  90.47   35.87
build2  259.79  91.01   35.35
Thu Feb  5 14:17:21 CST 2009: 1099 secs for 5 iters, 219 secs per iter
build1  106.57  92.21   35.75
ymzhang  16139  4052  0 14:17 pts/0    00:00:00 tar xfj /home/ymzhang/tmpfs/linux-2.6.28.tar.bz2
build2  233.17  90.77   35.05
Thu Feb  5 14:21:19 CST 2009: 1337 secs for 6 iters, 222 secs per iter
build1  139.56  90.82   33.61
build2  214.44  91.87   34.43
Thu Feb  5 14:25:02 CST 2009: 1560 secs for 7 iters, 222 secs per iter
build1  124.91  90.98   34.30
build2  214.43  91.79   34.35
Thu Feb  5 14:28:44 CST 2009: 1782 secs for 8 iters, 222 secs per iter
build1  134.76  90.80   33.59
build2  239.88  91.81   34.45
Thu Feb  5 14:32:48 CST 2009: 2026 secs for 9 iters, 225 secs per iter
build1  141.23  90.98   33.74
build2  250.96  91.72   34.20
Thu Feb  5 14:37:06 CST 2009: 2284 secs for 10 iters, 228 secs per iter


I repeat the testing and the results have fluctuation. I would like to
consider the result of slub (slub_max_order=0) is equal to slqb's.

Another testing is to start 2 parallel build1 testing. slub (default order) seems
having 17% regression against slqb. With slub_max_order=1, slub is ok.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
