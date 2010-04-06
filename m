Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ED2C46B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 05:30:44 -0400 (EDT)
Date: Tue, 6 Apr 2010 10:30:21 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406093021.GC17882@csn.ul.ie>
References: <patchbomb.1270168887@v2.random> <20100405120906.0abe8e58.akpm@linux-foundation.org> <20100405193616.GA5125@elte.hu> <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com> <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org> <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100405232115.GM5825@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 01:21:15AM +0200, Andrea Arcangeli wrote:
> Hi Linus,
> 
> On Mon, Apr 05, 2010 at 01:58:57PM -0700, Linus Torvalds wrote:
> > What I'm asking for is this thing called "Does it actually work in 
> > REALITY". That's my point about "not just after a clean boot".
> > 
> > Just to really hit the issue home, here's my current machine:
> > 
> > 	[root@i5 ~]# free
> > 	             total       used       free     shared    buffers     cached
> > 	Mem:       8073864    1808488    6265376          0      75480    1018412
> > 	-/+ buffers/cache:     714596    7359268
> > 	Swap:     10207228      12848   10194380
> > 
> > Look, I have absolutely _sh*tloads_ of memory, and I'm not using it. 
> > Really. I've got 8GB in that machine, it's just not been doing much more 
> > than a few "git pull"s and "make allyesconfig" runs to check the current 
> > kernel and so it's got over 6GB free. 
> > 
> > So I'm bound to have _tons_ of 2M pages, no?
> > 
> > No. Lookie here:
> > 
> > 	[344492.280001] DMA: 1*4kB 1*8kB 1*16kB 2*32kB 2*64kB 0*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15836kB
> > 	[344492.280020] DMA32: 17516*4kB 19497*8kB 18318*16kB 15195*32kB 10332*64kB 5163*128kB 1371*256kB 123*512kB 2*1024kB 1*2048kB 0*4096kB = 2745528kB
> > 	[344492.280027] Normal: 57295*4kB 66959*8kB 39639*16kB 29486*32kB 10483*64kB 2366*128kB 398*256kB 100*512kB 27*1024kB 3*2048kB 0*4096kB = 3503268kB
> > 
> > just to help you parse that: this is a _lightly_ loaded machine. It's been 
> > up for about four days. And look at it.
> > 
> > In case you can't read it, the relevant part is this part:
> > 
> > 	DMA: .. 1*2048kB 3*4096kB
> > 	DMA32: .. 1*2048kB 0*4096kB
> > 	Normal: .. 3*2048kB 0*4096kB
> > 
> > there is just a _small handful_ of 2MB pages. Seriously. On a machine with 
> > 8 GB of RAM, and three quarters of it free, and there is just a couple of 
> > contiguous 2MB regions. Note, that's _MB_, not GB.
> 

The kernel you are using is presumably fairly recent so it has
anti-fragmentation app[lied.

The point of anti-frag is not to keep fragmentation low at all times but to
have the system in a state where fragmentation can be dealt with.  Hence,
buddyinfo is rarely useful for figuring out "how many huge pages can I
allocate?" In the past when I was measuring fragmentation at a given time,
I used both buddyinfo and /proc/kpageflags to check the state of the system.

There is a good chance you could allocate a decent percentage of
memory as huge pages but as you are unlikely to have run hugeadm
--set-recommended-min_free_kbytes early in boot, it is also likely to trash
heavily and the success rates will not be very impressive.

The min_free_kbytes is really important. In the past I've used the
mm_page_alloc_extfrag to measure its effect. With default settings, under
heavy loads, the event would trigger hundreds of thousands of times. With
set-recommended-min_free_kbytes, it would trigger tens or maybe hundreds of
times under the same situations and the bulk of those events were not severe.

> What I can provide is my current status so far on workstation:
> 
> $ free
>              total       used       free     shared    buffers
>              cached
> Mem:       1923648    1410912     512736          0     332236
>              391000
> -/+ buffers/cache:     687676    1235972
> Swap:      4200960      14204    4186756
> $ cat /proc/buddyinfo 
> Node 0, zone      DMA     46     34     30     12     16     11     10     5      0      1      0 
> Node 0, zone    DMA32     33    355    352    129     46   1307    751   225      9      1      0 
> $ uptime
>  00:06:54 up 10 days,  5:10,  3 users,  load average: 0.00, 0.00, 0.00
> $ grep Anon /proc/meminfo
> AnonPages:         78036 kB
> AnonHugePages:    100352 kB
> 
> And laptop:
> 
> $ free
>              total       used       free     shared    buffers
>              cached
> Mem:       3076948    1964136    1112812          0      91920
>              297212
> -/+ buffers/cache:    1575004    1501944
> Swap:      2939888      17668    2922220
> $ cat /proc/buddyinfo
> Node 0, zone      DMA     26      9      8      3      3      2      2     1      1      3      1
> Node 0, zone    DMA32    840   2142   6455   5848   5156   2554    291    52     30      0      0
> $ uptime
>  00:08:21 up 17 days, 20:17,  5 users,  load average: 0.06, 0.01, 0.00
> $ grep Anon /proc/meminfo 
> AnonPages:        856332 kB
> AnonHugePages:    272384 kB
> 
> this is with:
> 
> $ cat /sys/kernel/mm/transparent_hugepage/defrag
> always madvise [never]
> $ cat /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
> [yes] no
> 
> Currently the "defrag" sysfs control only toggles __GFP_WAIT from
> on/off in huge_memory.c (details in the patch with subject
> "transparent hugepage core" in the alloc_hugepage()
> function). Toggling __GFP_WAIT is a joke right now.
> 
> The real deal to address your worry is first to run "hugeadm
> --set-recommended-min_free_kbytes" and to apply Mel's patches called
> "memory compaction" which is a separate patchset.
> 

The former is critical, the latter is not strictly necessary but it will
reduce the cost of hugepage allocation significantly, increases the success
rates slightly when under load and will work on swapless systems. It's worth
applying both but transparent hugepage support also stands on its own.

> I'm the consumer, Mel's the producer ;).
> 
> With virtual machines the host kernel doesn't need to live forever (it
> has to be stable but we can easily reboot it without guest noticing),
> we can migrate virtual machines to fresh booted new hosts voiding the
> whole producer issue. Furthermore VM the first time are usually
> started at host boot time, and we want as much memory as possible
> backed by hugepages in the host.
> 
> This is not to say that the producer isn't important or can't work,
> Mel posted number that shows it works, and we definitely want it to
> work, but I'm just trying to make a point that a good consumer of
> plenty of hugepages available at boot is useful even assuming the
> producer won't ever work or won't ever get it (not the real life case
> we're dealing with!).
> 

Most recent figures on huge page allocation under load are at
http://lkml.org/lkml/2010/4/2/146. It includes data on the hugepage
allocation latency on vanilla kernels and without compaction.

> Initially we're going to take advantage of only the consumer in
> production exactly because it's already useful, even if we want to
> take advantage of a smart runtime "producer" too later on as time goes
> on. Migrating guests to produce hugepages isn't the ideal way for sure
> and I'm very confident that Mel's work already filling the gap very
> nicely.
> 
> The VM itself (regardless if the consumer is hugetlbfs or transparent
> hugepage support) is evolving towards being able to generated endless
> amount of hugepages (in 2M size, 1G still unthinkable because of the
> huge cost) as shown by the already mainline available "hugeadm
> --set-recommended-min_free_kbytes". BTW, I think having this 10 liner
> algorithm in userland hugeadm binary is wrong and it should be a
> separate sysctl like "echo 1
> >/sys/kernel/vm/set-recommended-min_free_kbytes", but that's offtopic
> and an implementation detail... This is just to show they are already
> addressing that stuff for hugetlbfs. So I just created a better
> consumer for the stuff they make an effort to produce anyway (i.e. 2M
> pages). The better consumer we have of it in the kernel, the more
> effort will be put into the producer.
> 
> > And don't tell me that these things are easy to fix. Don't tell me that 
> > the current VM is quite clean and can be harmlessly extended to deal with 
> > this all. Just don't. Not when we currently have a totally unexplained 
> > regression in the VM from the last scalability thing we did.
> 
> Well the risk of regression with the consumer is little if disabled
> with sysfs so it'd be trivial to localize if it caused any
> problem. About memory compaction I think we should limit the
> invocation of those new VM algorithms to hugetlbfs and transparent
> hugepage support (and I already created the sysfs controls to
> enable/disable those so you can run transparent hugepage support with
> or without defrag feature).

This effectively happens with the compaction patches as of V7. It only
triggers for orders > PAGE_ALLOC_COSTLY_ORDER which in practice is
mostly hugetlbfs with an occasional bit of madness from a very small
number of devices.

> So all of this can be turned off at
> runtime. You can run only the consumer, both consumer or producer, or
> none (and if none, risk of regression should be zero). There's no
> point to ever defrag if there is no consumer of 2M pages. khugepaged
> should be able to invoke memory compaction comfortably in the defrag
> job in the background if khugepaged/defrag is set to "yes".
> 
> I think worrying about the producer too much generates a chicken egg
> problem, without an heavy consumer in mainline, there's little point
> for people to work on the producer.

The other producer I have in mind for compaction in particular is huge
page allocation at runtime on swapless systems. hugeadm has the feature
of temporarily adding swap while it resizes the pool and while it works,
it's less than ideal because it still requires a local disk. KVM using
it for virtual guests would be a heavier user.

> Note that creating a good producer
> wasn't easy task, I did all I could to keep it self contained and I
> think I succeeded at that. My work as result created interest into
> improving the producer on Mel's side. I am sure if the consumer goes
> in, producing the stuff will also happen without much problems.
> 
> My preferred merging patch is to merge the consumer first. But then
> I'm not entirely against the other order too. Merging both at the same
> time to me looks unnecessary complexity merged in the kernel at the
> same time and it'd make things less bisectable. But it wouldn't be
> impossible either.
> 
> About the performance benefits I posted some numbers in linux-mm, but
> I'll collect it here (and this is after boot with plenty of
> hugepages). As a side note in this first part please note also the
> boost in the page fault rate (but this really only for curiosity, as
> this will only happen with hugepages are immediately available in the
> buddy).
> 
> ------------
> hugepages in the virtualization hypervisor (and also in the guest!) are
> much more important than in a regular host not using virtualization, becasue
> with NPT/EPT they decrease the tlb-miss cacheline accesses from 24 to 19 in
> case only the hypervisor uses transparent hugepages, and they decrease the
> tlb-miss cacheline accesses from 19 to 15 in case both the linux hypervisor and
> the linux guest both uses this patch (though the guest will limit the addition
> speedup to anonymous regions only for now...).  Even more important is that the
> tlb miss handler is much slower on a NPT/EPT guest than for a regular shadow
> paging or no-virtualization scenario. So maximizing the amount of virtual
> memory cached by the TLB pays off significantly more with NPT/EPT than without
> (even if there would be no significant speedup in the tlb-miss runtime).
> 
> [..]
> Some performance result:
> 
> vmx andrea # LD_PRELOAD=/usr/lib64/libhugetlbfs.so HUGETLB_MORECORE=yes HUGETLB_PATH=/mnt/huge/ ./largep
> ages3
> memset page fault 1566023
> memset tlb miss 453854
> memset second tlb miss 453321
> random access tlb miss 41635
> random access second tlb miss 41658
> vmx andrea # LD_PRELOAD=/usr/lib64/libhugetlbfs.so HUGETLB_MORECORE=yes HUGETLB_PATH=/mnt/huge/ ./largepages3
> memset page fault 1566471
> memset tlb miss 453375
> memset second tlb miss 453320
> random access tlb miss 41636
> random access second tlb miss 41637
> vmx andrea # ./largepages3
> memset page fault 1566642
> memset tlb miss 453417
> memset second tlb miss 453313
> random access tlb miss 41630
> random access second tlb miss 41647
> vmx andrea # ./largepages3
> memset page fault 1566872
> memset tlb miss 453418
> memset second tlb miss 453315
> random access tlb miss 41618
> random access second tlb miss 41659
> vmx andrea # echo 0 > /proc/sys/vm/transparent_hugepage
> vmx andrea # ./largepages3
> memset page fault 2182476
> memset tlb miss 460305
> memset second tlb miss 460179
> random access tlb miss 44483
> random access second tlb miss 44186
> vmx andrea # ./largepages3
> memset page fault 2182791
> memset tlb miss 460742
> memset second tlb miss 459962
> random access tlb miss 43981
> random access second tlb miss 43988
> 
> ============
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <sys/time.h>
> 
> #define SIZE (3UL*1024*1024*1024)
> 
> int main()
> {
> 	char *p = malloc(SIZE), *p2;
> 	struct timeval before, after;
> 
> 	gettimeofday(&before, NULL);
> 	memset(p, 0, SIZE);
> 	gettimeofday(&after, NULL);
> 	printf("memset page fault %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	gettimeofday(&before, NULL);
> 	memset(p, 0, SIZE);
> 	gettimeofday(&after, NULL);
> 	printf("memset tlb miss %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	gettimeofday(&before, NULL);
> 	memset(p, 0, SIZE);
> 	gettimeofday(&after, NULL);
> 	printf("memset second tlb miss %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	gettimeofday(&before, NULL);
> 	for (p2 = p; p2 < p+SIZE; p2 += 4096)
> 		*p2 = 0;
> 	gettimeofday(&after, NULL);
> 	printf("random access tlb miss %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	gettimeofday(&before, NULL);
> 	for (p2 = p; p2 < p+SIZE; p2 += 4096)
> 		*p2 = 0;
> 	gettimeofday(&after, NULL);
> 	printf("random access second tlb miss %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	return 0;
> }
> ============
> -------------
> 
> This is a more interesting benchmark of kernel compile and some random
> cpu bound dd command (not a microbenchmark like above):
> 
> -----------
> This is a kernel build in a 2.6.31 guest, on a 2.6.34-rc1 host. KVM
> run with "-drive cache=on,if=virtio,boot=on and -smp 4 -m 2g -vnc :0"
> (host has 4G of ram). CPU is Phenom (not II) with NPT (4 cores, 1
> die). All reads are provided from host cache and cpu overhead of the
> I/O is reduced thanks to virtio. Workload is just a "make clean
> >/dev/null; time make -j20 >/dev/null". Results copied by hand because
> I logged through vnc.
> 
> real 4m12.498s
> 14m28.106s
> 1m26.721s
> 
> real 4m12.000s
> 14m27.850s
> 1m25.729s
> 
> After the benchmark:
> 
> grep Anon /proc/meminfo 
> AnonPages:        121300 kB
> AnonHugePages:   1007616 kB
> cat /debugfs/kvm/largepages 
> 2296
> 
> 1.6G free in guest and 1.5free in host.
> 
> Then on host:
> 
> # echo never > /sys//kernel/mm/transparent_hugepage/enabled 
> # echo never > /sys/kernel/mm/transparent_hugepage/khugepaged/enabled 
> 
> then I restart the VM and re-run the same workload:
> 
> real 4m25.040s
> user 15m4.665s
> sys 1m50.519s
> 
> real 4m29.653s
> user 15m8.637s
> sys 1m49.631s
> 
> (guest kernel was not so recent and it had no transparent hugepage
> support because gcc normally won't take advantage of hugepages
> according to /proc/meminfo, so I made the comparison with a distro
> guest kernel with my usual .config I use in kvm guests)
> 
> So guest compile the kernel 6% faster with hugepages and the results
> are trivially reproducible and stable enough (especially with hugepage
> enabled, without it varies from 4m24 sto 4m30s as I tried a few times
> more without hugepages in NTP when userland wasn't patched yet...).
> 
> Below another test that takes advantage of hugepage in guest too, so
> running the same 2.6.34-rc1 with transparent hugepage support in both
> host and guest. (this really shows the power of KVM design, we boost
> the hypervisor and we get double boost for guest applications)
> 
> Workload: time dd if=/dev/zero of=/dev/null bs=128M count=100
> 
> Host hugepage no guest: 3.898
> Host hugepage guest hugepage: 3.966 (-1.17%)
> Host no hugepage no guest: 4.088 (-4.87%)
> Host hugepage guest no hugepage: 4.312 (-10.1%)
> Host no hugepage guest hugepage: 4.388 (-12.5%)
> Host no hugepage guest no hugepage: 4.425 (-13.5%)
> 
> Workload: time dd if=/dev/zero of=/dev/null bs=4M count=1000
> 
> Host hugepage no guest: 1.207
> Host hugepage guest hugepage: 1.245 (-3.14%)
> Host no hugepage no guest: 1.261 (-4.47%)
> Host no hugepage guest no hugepage: 1.323 (-9.61%)
> Host no hugepage guest hugepage: 1.371 (-13.5%)
> Host no hugepage guest no hugepage: 1.398 (-15.8%)
> 
> I've no local EPT system to test so I may run them over vpn later on
> some large EPT system (and surely there are better benchs than a silly
> dd... but this is a start and shows even basic stuff gets the boost).
> 
> The above is basically an "home-workstation/laptop" coverage. I
> (partly) intentionally run these on a system that has a ~$100 CPU and
> ~$50 motherboard, to show the absolute worst case, to be sure that
> 100% of home end users (running KVM) will take a measurable advantage
> from this effort.
> 
> On huge systems the percentage boost is expected much bigger than on
> the home-workstation above test of course.
> --------------
> 
> 
> Again gcc is a kind of worst case for it but it also shows a
> definitive significant and reproducible boost.
> 
> Also note for a non-virtualization usage (so outside of
> MADV_HUGEPAGE), invoking memory compaction synchronously is likely a
> risk of losing CPU speed. khugepaged takes care of long lived
> allocations of random tasks and the only thing to use memory
> compaction synchronously could be the page faults of regions marked
> MADV_HUGEPAGE. But we may only decide to invoke memory compaction
> asynchronously and never as result of direct reclaim in process
> context to avoid any latency to guest operations. All it matters after
> boot is that khugepaged can do its job, it's not urgent. When things
> are urgent migrating guests to a new cloud node is always possible.
> 
> I'd like to clarify this whole work has been done without ever making
> assumptions about virtual machines, I tried to make this as
> universally useful as possible (and not just because we want the exact
> same VM algorithms to trim one level of guest pagetables too to get a
> comulative boost so fully exploiting the KVM design ;). I'm thrilled
> Chris is going to test a host-only test for database and I'm sure
> willing to help with that.
> 
> Compacting everything that is "movable" is surely solvable from a
> theoretical standpoint and that includes all anonymous memory (huge or
> not) and all cache.

Page migration as it is handles these cases. It can't handle slab, page
table pages or some kernel allocations but anti-fragmentation does a
good job of grouping these allocations into the same 2M pages already -
particularly when min_free_kbytes is configured correctly.

> That alone accounts for an huge bulk of the total
> memory of a system, so being able to mix it all will result in the
> best behavior which isn't possible to achieve with hugetlbfs (so if
> the memory isn't allocated as anonymous memory can still be used as
> cache for I/O).> So in the very worst case, if everything else fails on
> the producer front (again: not the case as far as I can tell!) what
> should be reserved at boot is an amount of memory to limit the
> unmovable parts there.

This latter part is currently possible with the kernelcore=X boot parameter
so that the unmovable parts are limited to X amount of memory.  It shouldn't
be necessary to do this, but it is possible. If it is found that it is
required, I'd hope to receive a bug report on it.

> And to leave the movable parts free to be
> allocated dynamically without limitations depending on the workloads.
> 
> I'm quite sure Mel will be able to provide more details on his work
> that has been reviewed in detail already on linux-mm with lots of
> positive feedback which is why I expect zero problems on that side too
> in real life (besides my theoretical standpoint in previous chapter ;).
> 

The details of of what I have to say on compaction is covered in the compaction
leader http://lkml.org/lkml/2010/4/2/146 including allocation success rates
under severe compile-based load and data on allocation latencies.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
