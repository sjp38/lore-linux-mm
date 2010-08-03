Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0BC616B02B8
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 11:53:29 -0400 (EDT)
Date: Tue, 3 Aug 2010 18:01:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Kernel build bench with Transparent Hugepage Support #29
Message-ID: <20100803160131.GI6071@random.random>
References: <20100803135615.GG6071@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100803135615.GG6071@random.random>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Transparent Hugepage Support worst case macro benchmark: kernel build.

host: 24-way SMP (12cores, 2 sockets) 16G RAM
guest: 24-way SMP (24 vcpus) 15G RAM

- Same kernel in guest and host: aa.git tag THP-29 (2.6.35 based)
  http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=summary
  (see linux-mm for more info)
- Same gcc (and userland) patched with the patch at the end.
- Same kernel source, same .config, on tmpfs (tmpfs only eliminates the
  measurement error across different runs but ext4 leads to the same average
  results).
- khugepaged default settings (khugepaged taking 0% CPU)
- no glibc align tweak (that would improve performance a little further with
  THP always)

The measurement also includes the "make clean", and the full "make -j32" that
includes lots of other time consuming operations not getting any benefit from
transparent hugepages. If this was pure "gcc" the percentage speedup would be
much higher than this. This is a very real life workload that we run on a daily
basis, not a microbenchmark at all.

Kernel build on bare metal (note the dTLB-load-misses):

====== build ======
#!/bin/bash
make clean >/dev/null; make -j32 >/dev/null
===================
perf stat -e cycles -e instructions -e dtlb-loads -e dtlb-load-misses --repeat 3 ./build
===================

THP always host (fastest base result)

 Performance counter stats for './build' (3 runs):

      4420734012848  cycles                     ( +-   0.007% )
      2692414418384  instructions             #      0.609 IPC     ( +-   0.000% )
       696638665612  dTLB-loads                 ( +-   0.001% )
         2982343758  dTLB-load-misses           ( +-   0.051% )

       83.855147696  seconds time elapsed   ( +-   0.058% )

THP never host (slowdown 4.06%)

 Performance counter stats for './build' (3 runs):

      4599325985460  cycles                     ( +-   0.013% )
      2747874065083  instructions             #      0.597 IPC     ( +-   0.000% )
       710631792376  dTLB-loads                 ( +-   0.000% )
         4425816093  dTLB-load-misses           ( +-   0.039% )

       87.260443531  seconds time elapsed   ( +-   0.075% )
 
Kernel build on KVM powered guest:

=======
time (make clean; make -j32) >/dev/null
=======

THP always guest, EPT on + THP always host (slowdown 5.67%)

NOTE: the total KVM virtualization slowdown for the kernel build with
THP always in guest and host compared with bare metal with THP never
(like current upstream) is only 1.54%.

real 1m28.612s -> 88.612 seconds
user 26m13.862s
sys  2m11.376s

THP never guest, EPT on + THP always host (slowdown 12.71%)

real 1m34.516s -> 94.516 seconds
user 26m52.929s
sys  3m35.509s

THP never guest, EPT on + THP never host (slowdown 24.81%)

real 1m44.663s -> 104.663 seconds
user 28m13.382s
sys  5m39.373s

THP always guest, EPT off + THP always host (slowdown 198.33%)

real 4m10.166s -> 250.166 seconds
user 41m5.674s
sys  47m37.671s

THP never guest, EPT off + THP always host (slowdown 254.43%)

real 4m57.211s -> 297.211 seconds
user 53m44.302s
sys  53m21.600s

THP never guest, EPT off + THP never host (slowdown 260.15%)

real 5m2.006s -> 302.006 seconds
user 53m25.876s
sys  53m32.649s

This is trivial to reproduce, you can try yourself with aa.git and the
below gcc patch. The results are similar to what I got with NPT some
time ago with a less complete benchmark (no gcc patched in guest) and
only 4 cores.

After this worst case macro benchmark, I'll go ahead with more optimal
benchmarks (with bigger memory footprint and longer-living tasks not
quitting so fast and not including make -j32/make clean etc...) and I
expect more pronounced speedups, like the qemu-kvm translate.o gcc
build (the file with the automatic generated .c source for JIT
emulation), Java etc... And I'll include these results and all other
results I'll be getting, in my KVM Forum 2010 talk on Transparent
Hugepage Support next week in Boston.

Thanks!
Andrea

--- /var/tmp/portage/sys-devel/gcc-4.4.2/work/gcc-4.4.2/gcc/ggc-page.c	2008-07-28 16:33:56.000000000 +0200
+++ /tmp/gcc-4.4.2/gcc/ggc-page.c	2010-04-25 06:01:32.829753566 +0200
@@ -450,6 +450,11 @@
 #define BITMAP_SIZE(Num_objects) \
   (CEIL ((Num_objects), HOST_BITS_PER_LONG) * sizeof(long))
 
+#ifdef __x86_64__
+#define HPAGE_SIZE (2*1024*1024)
+#define GGC_QUIRE_SIZE 512
+#endif
+
 /* Allocate pages in chunks of this size, to throttle calls to memory
    allocation routines.  The first page is used, the rest go onto the
    free list.  This cannot be larger than HOST_BITS_PER_INT for the
@@ -457,7 +462,7 @@
    can override this by defining GGC_QUIRE_SIZE explicitly.  */
 #ifndef GGC_QUIRE_SIZE
 # ifdef USING_MMAP
-#  define GGC_QUIRE_SIZE 256
+#  define GGC_QUIRE_SIZE 512
 # else
 #  define GGC_QUIRE_SIZE 16
 # endif
@@ -654,6 +659,23 @@
 #ifdef HAVE_MMAP_ANON
   char *page = (char *) mmap (pref, size, PROT_READ | PROT_WRITE,
 			      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+#ifdef HPAGE_SIZE
+  if (!(size & (HPAGE_SIZE-1)) &&
+      page != (char *) MAP_FAILED && (size_t) page & (HPAGE_SIZE-1)) {
+	  char *old_page;
+	  munmap(page, size);
+	  page = (char *) mmap (pref, size + HPAGE_SIZE-1,
+				PROT_READ | PROT_WRITE,
+				MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	  old_page = page;
+	  page = (char *) (((size_t)page + HPAGE_SIZE-1)
+			   & ~(HPAGE_SIZE-1));
+	  if (old_page != page)
+		  munmap(old_page, page-old_page);
+	  if (page != old_page + HPAGE_SIZE-1)
+		  munmap(page+size, old_page+HPAGE_SIZE-1-page);
+  }
+#endif
 #endif
 #ifdef HAVE_MMAP_DEV_ZERO
   char *page = (char *) mmap (pref, size, PROT_READ | PROT_WRITE,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
