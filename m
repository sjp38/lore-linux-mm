Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 234946B01F4
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 14:49:18 -0400 (EDT)
Date: Sat, 10 Apr 2010 20:47:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100410184750.GJ5708@random.random>
References: <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
 <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
 <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
 <20100405232115.GM5825@random.random>
 <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100406090813.GA14098@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

On Tue, Apr 06, 2010 at 11:08:13AM +0200, Ingo Molnar wrote:
> The goal of Andrea's and Mel's patch-set, to make this 'final performance 
> boost' more practical seems like a valid technical goal.

The integration in my current git tree (#19+):

git clone git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
later -> git fetch; git checkout -f origin/master

is working great and runs rock solid after the last integration bugfix
in migrate.c, enjoy! ;)

This is on my workstation, after building a ton of packages (including
javac binaries and all sort of other random stuff), lots of kernels,
mutt on large maildir folders, and running lots of ebuild that is
super heavy in vfs terms.

# free
             total       used       free     shared    buffers     cached
Mem:       3923408    2536380    1387028          0     482656    1194228
-/+ buffers/cache:     859496    3063912
Swap:      4200960        788    4200172
# uptime
 20:09:50 up 1 day, 13:19, 11 users,  load average: 0.00, 0.00, 0.00
# cat /proc/buddyinfo /proc/extfrag_index /proc/unusable_index
Node 0, zone      DMA      4      2      3      2      2      0      1      0      1      1      3
Node 0, zone    DMA32  10402  32864  10477   3729   2154   1156    471    136     22     50     41
Node 0, zone   Normal    196    155     40     21     16      7      4      1      0      2      0
Node 0, zone      DMA -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000
Node 0, zone    DMA32 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000
Node 0, zone   Normal -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 0.992
Node 0, zone      DMA 0.000 0.001 0.002 0.005 0.009 0.017 0.017 0.033 0.033 0.097 0.226
Node 0, zone    DMA32 0.000 0.030 0.223 0.347 0.434 0.536 0.644 0.733 0.784 0.801 0.876
Node 0, zone   Normal 0.000 0.072 0.185 0.244 0.306 0.400 0.482 0.576 0.623 0.623 1.000
# time echo 3 > /proc/sys/vm/drop_caches

real    0m0.989s
user    0m0.000s
sys     0m0.984s
# time echo > /proc/sys/vm/compact_memory

real    0m0.195s
user    0m0.000s
sys     0m0.124s
# cat /proc/buddyinfo /proc/extfrag_index /proc/unusable_index
Node 0, zone      DMA      4      2      3      2      2      0      1      0      1      1      3
Node 0, zone    DMA32   1632   1444   1336   1065    748    449    229    128     59     50    685
Node 0, zone   Normal   1046    783    552    367    261    176    116     82     50     43     15
Node 0, zone      DMA -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000
Node 0, zone    DMA32 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000
Node 0, zone   Normal -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000
Node 0, zone      DMA 0.000 0.001 0.002 0.005 0.009 0.017 0.017 0.033 0.033 0.097 0.226
Node 0, zone    DMA32 0.000 0.001 0.005 0.012 0.022 0.037 0.054 0.072 0.092 0.111 0.142
Node 0, zone   Normal 0.000 0.012 0.030 0.056 0.090 0.139 0.205 0.291 0.414 0.563 0.820
# free  
             total       used       free     shared    buffers     cached
Mem:       3923408     295240    3628168          0       4636      23192
-/+ buffers/cache:     267412    3655996
Swap:      4200960        788    4200172
# grep Anon /proc/meminfo 
AnonPages:        210472 kB
AnonHugePages:    102400 kB

(now AnonPages includes AnonHugePages, for backwards compatibility,
sorry about not having done it earlier, so ~50% of anon ram is in
hugepages)

MB of hugepages before drop_caches+compact_memory:

>>> (41)*4+(52)*2
268

MB of hugepages after drop_caches+compact_memory:

>>> (685+15)*4+(50+43)*2
2986

Total ram free: 3543 MB. 84% of the RAM not affected by unmovable
stuff after huge vfs slab load for about 2 days.

On laptop I got an huge swap storm that killed kdeinit4 with the oom
killer while I was away (found the login back in kdm4 when I got
back). that supposedly splitted all hugepages and now I after a while
I got all hugepages back:

# grep Anon /proc/meminfo 
AnonPages:        767680 kB
AnonHugePages:    395264 kB
# uptime
 20:33:33 up 1 day, 13:45,  9 users,  load average: 0.00, 0.00, 0.00
# dmesg|grep kill
Out of memory: kill process 8869 (kdeinit4) score 320362 or a child
# 


(50% of ram in hugepages and 400M more of hugepages immediately
available after invoking drop_caches/compact_memory manually with
the two sysctl)

And if this isn't enough kernelcore= can also provide an even stronger
guarantee to prevent unmovable stuff to spill over and start shrinking
freeable slab before it's too late.

The drop caches would be run by try_to_free_pages internally which is
interlevated with the try_to_compact_pages calls of course, so this is
to show the full potential of set_recommended_min_free_kbytes
(in-kernel automatically run at late_initcall unless you boot with
transparent_hugepage=0) and memory compaction, on top of the already
compound-aware try_to_free_pages (in addition of the order fallback
with movable/unmovable of set_recommended_min_free_kbytes). And
without using kernelcore= but allowing ebuild and other heavy slab
unmovable users to grow as much as they want and with only 3G of ram.

The sluggishness of invoking alloc_pages with __GFP_WAIT from hugepage
page faults (synchronously in direct reclaim) also completely gone
away after I tracked it down to lumpy reclaim that I simply nuked.

This is already fully usable and works great, and as Avi showed it
boosts even a sort on host by 6%, think about HPC applications, and
soon I hope to boost gcc on host by 6% (and of >15% in guest with
NPT/EPT) by extending vm_end in 2M chunks in glibc, at least for those
huge gcc builds taking >200M like translate.o of qemu-kvm... (so I
hope soon gcc running on KVM guest, thanks to EPT/NPT, will run faster
than on mainline kernel without transparent hugepages on bare metal).

Now I'll add numa awareness by adding alloc_pages_vma and make a #20
release which is one last relevant bit... Then we may want to address
smaps to show hugepages per process instead of only global in /proc/meminfo.

The only tuning I might recommend to people benchmarking on top of
current aa.git, is to compare the workloads with:

echo always >/sys/kernel/mm/transparent_hugepage/defrag # default setting at boot
echo never >/sys/kernel/mm/transparent_hugepage/defrag

And also to speedup khugepaged by decreasing
/sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
(that will workaround the vm_end not being extended in 2M chunk).

There's also one sysctl called /proc/sys/vm/extfrag_threshold that
allows to tune memory compaction aggressiveness but I wouldn't twiddle
with it, supposedly it'll go away and be replaced by a future
exponential backoff based logic to interleave the
try_to_compact_pages/try_to_free_pages optimally and more dynamically
than the sysctl (discussion on linux-mm). But it's not an huge
priority at the moment, it already works great like this and it
absolutely never becomes sluggish and it's always responsive since I
nuked lumpy-reclaim. The half jiffy average wait time definitely not
necessary and it would be lost in the noise compared to addressing the
major problem we had in calling try_to_free_pages with order = 9 and
__GFP_WAIT.

> In fact the whole maintenance thought process seems somewhat similar to the 
> TSO situation: the networking folks first rejected TSO based on complexity 
> arguments, but then was embraced after some time.

Full agreement! I think everyone wants transparent hugepage, the only
compliant I ever heard so far is from Christoph that has some slight
preference on not introducing split_huge_page and going full hugepage
everywhere, with native in gup immediately where GUP only returns head
pages and every caller has to check PageTransHuge on them to see if
it's huge or not. Changing several hundred of drivers in one go and
with native swapping with hugepage backed swapcache immediately, which
means also pagecache has to deal with hugepages immediately, is
possible too, but I think this more gradual approach is easier to keep
under control, Rome wasn't built in a day. Surely in a second time I
want tmpfs backed by hugepages too at least. And maybe pagecache, but
it doesn't need to happen immediately. Also we've to keep in mind for
huge systems the PAGE_SIZE should eventually become 2M and those will
be able to take advantage of transparent hugepages for the 1G
pud_trans_huge, that will make HPC even faster. Anyway nothing
prevents to take Christoph's long term direction also by starting self
contained.

To me what is relevant is that everyone in the VM camp seems to want
transparent hugepages in some shape or form, because of the about
linear speedup they provide to everything running on them on bare
metal (and an more than linear cumulative speedup in case of nested
pagetables for obvious reasons), no matter what design that it is.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
