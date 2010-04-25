Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 303796B01EE
	for <linux-mm@kvack.org>; Sun, 25 Apr 2010 15:29:47 -0400 (EDT)
Date: Sun, 25 Apr 2010 21:27:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100425192739.GG5789@random.random>
References: <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
 <20100410204756.GR5708@random.random>
 <4BC0E6ED.7040100@redhat.com>
 <20100411010540.GW5708@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20100411010540.GW5708@random.random>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ulrich Drepper <drepper@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 11, 2010 at 03:05:40AM +0200, Andrea Arcangeli wrote:
> With the above two params I get around 200M (around half) in
> hugepages with gcc building translate.o:
>=20
> $ rm translate.o ; time make translate.o
>   CC    translate.o
>=20
> real    0m22.900s
> user    0m22.601s
> sys     0m0.260s
> $ rm translate.o ; time make translate.o
>   CC    translate.o
>=20
> real    0m22.405s
> user    0m22.125s
> sys     0m0.240s
> # echo never > /sys/kernel/mm/transparent_hugepage/enabled
> # exit
> $ rm translate.o ; time make translate.o
>   CC    translate.o
>=20
> real    0m24.128s
> user    0m23.725s
> sys     0m0.376s
> $ rm translate.o ; time make translate.o
>   CC    translate.o
>=20
> real    0m24.126s
> user    0m23.725s
> sys     0m0.376s
> $ uptime
>  02:36:07 up 1 day, 19:45,  5 users,  load average: 0.01, 0.12, 0.08
>=20
> 1 sec in 24 means around 4% faster, hopefully when glibc will fully
> cooperate we'll get better results than the above with gcc...
>=20
> I tried to emulate it with khugepaged running in a loop and I get
> almost the whole gcc anon memory in hugepages this way (as expected):
>=20
> # echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_mill=
isecs
> # exit
> rm translate.o ; time make translate.o
>   CC    translate.o
>=20
> real    0m21.950s
> user    0m21.481s
> sys     0m0.292s
> $ rm translate.o ; time make translate.o
>   CC    translate.o
>=20
> real    0m21.992s
> user    0m21.529s
> sys     0m0.288s
> $=20
>=20
> So this takes more than 2 seconds away from 24 seconds reproducibly,
> and it means gcc now runs 8% faster. This requires running khugepaged
> at 100% of one of the four cores but with a slight chance to glibc
> we'll be able reach the exact same 8% speedup (or more because this
> also involves copying ~200M and sending IPIs to unmap pages and stop
> userland during the memory copy that won't be necessary anymore).
>=20
> BTW, the current default for khugepaged is to scan 8 pmd every 10
> seconds, that means collapsing at most 16M every 10 seconds. Checking
> 8 pmd pointers every 10 seconds and 6 wakeup per minute for a kernel
> thread is absolutely unmeasurable but despite the unmeasurable
> overhead, it provides for a very nice behavior for long lived
> allocations that may have been swapped in fragmented.
>=20
> This is on phenom X4, I'd be interested if somebody can try on other cpus.
>=20
> To get the environment of the test just:
>=20
> git clone git://git.kernel.org/pub/scm/virt/kvm/qemu-kvm.git
> cd qemu-kvm
> make
> cd x86_64-softmmu
>=20
> export MALLOC_MMAP_THRESHOLD_=3D$[1024*1024*1024]
> export MALLOC_TOP_PAD_=3D$[1024*1024*1024]
> rm translate.o; time make translate.o
>=20
> Then you need to flip the above sysfs controls as I did.

I patched gcc with the few liner change and without tweaking glibc and
with khugepaged killed at all times. The system already had heavy load
building glibc a couple of times and my usual kernel build load for
about 12 hours. Shutting down khugepaged isn't really necessary
considering how slow the scan is but I did it anyway.

$ cat /sys/kernel/mm/transparent_hugepage/enabled=20
[always] madvise never
$ cat /sys/kernel/mm/transparent_hugepage/khugepaged/enabled=20
always madvise [never]
$ pgrep khugepaged
$ ~/bin/x86_64/perf stat -e cycles -e instructions -e dtlb-loads -e dtlb-lo=
ad-misses -e l1-dcache-loads -e l1-dcache-load-misses --repeat 3 gcc -I/cry=
pto/home/andrea/kernel/qemu-kvm/slirp -Werror -m64 -fstack-protector-all -W=
old-style-definition -Wold-style-declaration -I. -I/crypto/home/andrea/kern=
el/qemu-kvm -D_FORTIFY_SOURCE=3D2 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=3D64 -D=
_LARGEFILE_SOURCE -Wstrict-prototypes -Wredundant-decls -Wall -Wundef -Wend=
if-labels -Wwrite-strings -Wmissing-prototypes -fno-strict-aliasing  -DHAS_=
AUDIO -DHAS_AUDIO_CHOICE -I/crypto/home/andrea/kernel/qemu-kvm/fpu -I/crypt=
o/home/andrea/kernel/qemu-kvm/tcg -I/crypto/home/andrea/kernel/qemu-kvm/tcg=
/x86_64  -DTARGET_PHYS_ADDR_BITS=3D64 -I.. -I/crypto/home/andrea/kernel/qem=
u-kvm/target-i386 -DNEED_CPU_H   -MMD -MP -MT translate.o -O2 -g  -I/crypto=
/home/andrea/kernel/qemu-kvm/kvm/include -include /crypto/home/andrea/kerne=
l/qemu-kvm/kvm/include/linux/config.h -I/crypto/home/andrea/kernel/qemu-kvm=
/kvm/include/x86 -idirafter /crypto/home/andrea/kernel/qemu-kvm/compat -c -=
o translate.o /crypto/home/andrea/kernel/qemu-kvm/target-i386/translate.c

 Performance counter stats for 'gcc -I/crypto/home/andrea/kernel/qemu-kvm/s=
lirp -Werror -m64 -fstack-protector-all -Wold-style-definition -Wold-style-=
declaration -I. -I/crypto/home/andrea/kernel/qemu-kvm -D_FORTIFY_SOURCE=3D2=
 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=3D64 -D_LARGEFILE_SOURCE -Wstrict-protot=
ypes -Wredundant-decls -Wall -Wundef -Wendif-labels -Wwrite-strings -Wmissi=
ng-prototypes -fno-strict-aliasing -DHAS_AUDIO -DHAS_AUDIO_CHOICE -I/crypto=
/home/andrea/kernel/qemu-kvm/fpu -I/crypto/home/andrea/kernel/qemu-kvm/tcg =
-I/crypto/home/andrea/kernel/qemu-kvm/tcg/x86_64 -DTARGET_PHYS_ADDR_BITS=3D=
64 -I.. -I/crypto/home/andrea/kernel/qemu-kvm/target-i386 -DNEED_CPU_H -MMD=
 -MP -MT translate.o -O2 -g -I/crypto/home/andrea/kernel/qemu-kvm/kvm/inclu=
de -include /crypto/home/andrea/kernel/qemu-kvm/kvm/include/linux/config.h =
-I/crypto/home/andrea/kernel/qemu-kvm/kvm/include/x86 -idirafter /crypto/ho=
me/andrea/kernel/qemu-kvm/compat -c -o translate.o /crypto/home/andrea/kern=
el/qemu-kvm/target-i386/translate.c' (3 runs):

    55365925618  cycles                     ( +-   0.038% )  (scaled from 6=
6.67%)
    36558135065  instructions             #      0.660 IPC     ( +-   0.061=
% )  (scaled from 66.66%)
    16103841974  dTLB-loads                 ( +-   0.109% )  (scaled from 6=
6.68%)
            823  dTLB-load-misses           ( +-   0.081% )  (scaled from 6=
6.70%)
    16080393958  L1-dcache-loads            ( +-   0.030% )  (scaled from 6=
6.69%)
      357523292  L1-dcache-load-misses      ( +-   0.099% )  (scaled from 6=
6.68%)

   23.129143516  seconds time elapsed   ( +-   0.035% )

If I tweak glibc:

$ export MALLOC_TOP_PAD_=3D100000000
$ export MALLOC_MMAP_THRESHOLD_=3D1000000000
$ ~/bin/x86_64/perf stat -e cycles -e instructions -e dtlb-loads -e dtlb-lo=
ad-misses -e l1-dcache-loads -e l1-dcache-load-misses --repeat 3 gcc -I/cry=
pto/home/andrea/kernel/qemu-kvm/slirp -Werror -m64 -fstack-protector-all -W=
old-style-definition -Wold-style-declaration -I. -I/crypto/home/andrea/kern=
el/qemu-kvm -D_FORTIFY_SOURCE=3D2 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=3D64 -D=
_LARGEFILE_SOURCE -Wstrict-prototypes -Wredundant-decls -Wall -Wundef -Wend=
if-labels -Wwrite-strings -Wmissing-prototypes -fno-strict-aliasing  -DHAS_=
AUDIO -DHAS_AUDIO_CHOICE -I/crypto/home/andrea/kernel/qemu-kvm/fpu -I/crypt=
o/home/andrea/kernel/qemu-kvm/tcg -I/crypto/home/andrea/kernel/qemu-kvm/tcg=
/x86_64  -DTARGET_PHYS_ADDR_BITS=3D64 -I.. -I/crypto/home/andrea/kernel/qem=
u-kvm/target-i386 -DNEED_CPU_H   -MMD -MP -MT translate.o -O2 -g  -I/crypto=
/home/andrea/kernel/qemu-kvm/kvm/include -include /crypto/home/andrea/kerne=
l/qemu-kvm/kvm/include/linux/config.h -I/crypto/home/andrea/kernel/qemu-kvm=
/kvm/include/x86 -idirafter /crypto/home/andrea/kernel/qemu-kvm/compat -c -=
o translate.o /crypto/home/andrea/kernel/qemu-kvm/target-i386/translate.c

 Performance counter stats for 'gcc -I/crypto/home/andrea/kernel/qemu-kvm/s=
lirp -Werror -m64 -fstack-protector-all -Wold-style-definition -Wold-style-=
declaration -I. -I/crypto/home/andrea/kernel/qemu-kvm -D_FORTIFY_SOURCE=3D2=
 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=3D64 -D_LARGEFILE_SOURCE -Wstrict-protot=
ypes -Wredundant-decls -Wall -Wundef -Wendif-labels -Wwrite-strings -Wmissi=
ng-prototypes -fno-strict-aliasing -DHAS_AUDIO -DHAS_AUDIO_CHOICE -I/crypto=
/home/andrea/kernel/qemu-kvm/fpu -I/crypto/home/andrea/kernel/qemu-kvm/tcg =
-I/crypto/home/andrea/kernel/qemu-kvm/tcg/x86_64 -DTARGET_PHYS_ADDR_BITS=3D=
64 -I.. -I/crypto/home/andrea/kernel/qemu-kvm/target-i386 -DNEED_CPU_H -MMD=
 -MP -MT translate.o -O2 -g -I/crypto/home/andrea/kernel/qemu-kvm/kvm/inclu=
de -include /crypto/home/andrea/kernel/qemu-kvm/kvm/include/linux/config.h =
-I/crypto/home/andrea/kernel/qemu-kvm/kvm/include/x86 -idirafter /crypto/ho=
me/andrea/kernel/qemu-kvm/compat -c -o translate.o /crypto/home/andrea/kern=
el/qemu-kvm/target-i386/translate.c' (3 runs):

    52684457919  cycles                     ( +-   0.059% )  (scaled from 6=
6.67%)
    36392861901  instructions             #      0.691 IPC     ( +-   0.130=
% )  (scaled from 66.68%)
    16014094544  dTLB-loads                 ( +-   0.152% )  (scaled from 6=
6.67%)
            784  dTLB-load-misses           ( +-   0.450% )  (scaled from 6=
6.69%)
    16030576638  L1-dcache-loads            ( +-   0.161% )  (scaled from 6=
6.70%)
      353904925  L1-dcache-load-misses      ( +-   0.510% )  (scaled from 6=
6.68%)

   22.048837226  seconds time elapsed   ( +-   0.224% )

Then I disabled transparent hugepage (I left the glibc tweak just in
case anyone wonders that with the environment var set, less brk
syscalls run, but it doesn't make any difference without transparent
hugepage regardless of those environment settings).

$ cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]
$ set|grep MALLOC
MALLOC_MMAP_THRESHOLD_=3D1000000000
MALLOC_TOP_PAD_=3D100000000
_=3DMALLOC_TOP_PAD_
$ ~/bin/x86_64/perf stat -e cycles -e instructions -e dtlb-loads -e dtlb-lo=
ad-misses -e l1-dcache-loads -e l1-dcache-load-misses --repeat 3 gcc -I/cry=
pto/home/andrea/kernel/qemu-kvm/slirp -Werror -m64 -fstack-protector-all -W=
old-style-definition -Wold-style-declaration -I. -I/crypto/home/andrea/kern=
el/qemu-kvm -D_FORTIFY_SOURCE=3D2 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=3D64 -D=
_LARGEFILE_SOURCE -Wstrict-prototypes -Wredundant-decls -Wall -Wundef -Wend=
if-labels -Wwrite-strings -Wmissing-prototypes -fno-strict-aliasing  -DHAS_=
AUDIO -DHAS_AUDIO_CHOICE -I/crypto/home/andrea/kernel/qemu-kvm/fpu -I/crypt=
o/home/andrea/kernel/qemu-kvm/tcg -I/crypto/home/andrea/kernel/qemu-kvm/tcg=
/x86_64  -DTARGET_PHYS_ADDR_BITS=3D64 -I.. -I/crypto/home/andrea/kernel/qem=
u-kvm/target-i386 -DNEED_CPU_H   -MMD -MP -MT translate.o -O2 -g  -I/crypto=
/home/andrea/kernel/qemu-kvm/kvm/include -include /crypto/home/andrea/kerne=
l/qemu-kvm/kvm/include/linux/config.h -I/crypto/home/andrea/kernel/qemu-kvm=
/kvm/include/x86 -idirafter /crypto/home/andrea/kernel/qemu-kvm/compat -c -=
o translate.o /crypto/home/andrea/kernel/qemu-kvm/target-i386/translate.c

 Performance counter stats for 'gcc -I/crypto/home/andrea/kernel/qemu-kvm/s=
lirp -Werror -m64 -fstack-protector-all -Wold-style-definition -Wold-style-=
declaration -I. -I/crypto/home/andrea/kernel/qemu-kvm -D_FORTIFY_SOURCE=3D2=
 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=3D64 -D_LARGEFILE_SOURCE -Wstrict-protot=
ypes -Wredundant-decls -Wall -Wundef -Wendif-labels -Wwrite-strings -Wmissi=
ng-prototypes -fno-strict-aliasing -DHAS_AUDIO -DHAS_AUDIO_CHOICE -I/crypto=
/home/andrea/kernel/qemu-kvm/fpu -I/crypto/home/andrea/kernel/qemu-kvm/tcg =
-I/crypto/home/andrea/kernel/qemu-kvm/tcg/x86_64 -DTARGET_PHYS_ADDR_BITS=3D=
64 -I.. -I/crypto/home/andrea/kernel/qemu-kvm/target-i386 -DNEED_CPU_H -MMD=
 -MP -MT translate.o -O2 -g -I/crypto/home/andrea/kernel/qemu-kvm/kvm/inclu=
de -include /crypto/home/andrea/kernel/qemu-kvm/kvm/include/linux/config.h =
-I/crypto/home/andrea/kernel/qemu-kvm/kvm/include/x86 -idirafter /crypto/ho=
me/andrea/kernel/qemu-kvm/compat -c -o translate.o /crypto/home/andrea/kern=
el/qemu-kvm/target-i386/translate.c' (3 runs):

    58193692408  cycles                     ( +-   0.129% )  (scaled from 6=
6.66%)
    36565168786  instructions             #      0.628 IPC     ( +-   0.052=
% )  (scaled from 66.68%)
    16098510972  dTLB-loads                 ( +-   0.223% )  (scaled from 6=
6.69%)
            867  dTLB-load-misses           ( +-   0.168% )  (scaled from 6=
6.69%)
    16186049665  L1-dcache-loads            ( +-   0.112% )  (scaled from 6=
6.69%)
      364792323  L1-dcache-load-misses      ( +-   0.145% )  (scaled from 6=
6.66%)

   24.313032086  seconds time elapsed   ( +-   0.154% )

(24.31-22.04)/22.04 =3D 10.2% boost (or 9.3% faster if you divide it by
24.31 ;).

Ulrich also sent me a snippnet to align the region in glibc, I tried
it but it doesn't get faster than with the environment vars above so
the above is simpler than having to rebuild glibc for benchmarking
(plus I was unsure if this snippnet really works as well as the two
env variables, so I used an unmodified stock glibc for this test).

diff --git a/malloc/malloc.c b/malloc/malloc.c
index 722b1d4..b067b65 100644
--- a/malloc/malloc.c
+++ b/malloc/malloc.c
@@ -3168,6 +3168,10 @@ static Void_t* sYSMALLOc(nb, av) INTERNAL_SIZE_T nb;=
 mstate av;
=20
   size =3D nb + mp_.top_pad + MINSIZE;
=20
+#define TWOM (2*1024*1024)
+  char *cur =3D (char*)MORECORE(0);
+  size =3D (char*)((size_t)(cur + size + TWOM - 1)&~(TWOM-1))-cur;
+
   /*
     If contiguous, we can subtract out existing space that we hope to
     combine with new space. We add it back later only if


Now that my gcc in my workstation hugepage-friendly I can test a
kernel compile and see if I get any boost with that too, before it was
just impossible.

Also note: if you read ggc-page.c or glibc malloc.c you'll notice
things like GGC_QUIRE_SIZE, and all sort of other alignment and
multipage heuristics there. So it's absolutely guaranteed the moment
the kernel gets transparent hugepages they will add the few liner
change to get the guaranteed boost at least for the 2M size
allocations, like they already do to rate-limit the number of syscalls
and all other alignment tricks they do for the cache etc.. Talking
about gcc and glibc changes in this context is very real IMHO and I
think it's much superior solution than having mmap(4k) backed by 2M
pages with all complexity and additional branches it'd introduce in
all page faults (not just in a single large mmap which is a slow
path).

What we can add to the kernel, an idea that Ulrich proposed, is a mmap
MMAP_ALIGN parameter to mmap, so that the first argument of mmap
becomes the alignment. That creates more vmas but the below munmap
does too. It's simply mandatory that 2M size alignment allocations
starts 2M aligned from now on (the rest is handled by khugepaged
already including the very user stack). To avoid fragmenting the
virtual address space and in turn creating more vmas (and potentially
micro-slowing-down the page faults) probably these allocations
multiple of 2M in size and 2M aligned could go in their own address,
something a MAP_ALIGN param can achieve inside the kernel
transparently. Of course if userland munmap(4k) it'll fragment but
that's up to userland to munmap also in aligned chunks multiple of 2m,
if it wants to be optimal and avoid vma creation.

The kernel used is aa.git fb6122f722c9e07da384c1309a5036a5f1c80a77 on
single socket 4 cores phenom X4 4G of 800mhz ddr2 as before (and no virt).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

--- /var/tmp/portage/sys-devel/gcc-4.4.2/work/gcc-4.4.2/gcc/ggc-page.c	2008=
-07-28 16:33:56.000000000 +0200
+++ /tmp/gcc-4.4.2/gcc/ggc-page.c	2010-04-25 06:01:32.829753566 +0200
@@ -450,6 +450,11 @@
 #define BITMAP_SIZE(Num_objects) \
   (CEIL ((Num_objects), HOST_BITS_PER_LONG) * sizeof(long))
=20
+#ifdef __x86_64__
+#define HPAGE_SIZE (2*1024*1024)
+#define GGC_QUIRE_SIZE 512
+#endif
+
 /* Allocate pages in chunks of this size, to throttle calls to memory
    allocation routines.  The first page is used, the rest go onto the
    free list.  This cannot be larger than HOST_BITS_PER_INT for the
@@ -654,6 +659,23 @@
 #ifdef HAVE_MMAP_ANON
   char *page =3D (char *) mmap (pref, size, PROT_READ | PROT_WRITE,
 			      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+#ifdef HPAGE_SIZE
+  if (!(size & (HPAGE_SIZE-1)) &&
+      page !=3D (char *) MAP_FAILED && (size_t) page & (HPAGE_SIZE-1)) {
+	  char *old_page;
+	  munmap(page, size);
+	  page =3D (char *) mmap (pref, size + HPAGE_SIZE-1,
+				PROT_READ | PROT_WRITE,
+				MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	  old_page =3D page;
+	  page =3D (char *) (((size_t)page + HPAGE_SIZE-1)
+			   & ~(HPAGE_SIZE-1));
+	  if (old_page !=3D page)
+		  munmap(old_page, page-old_page);
+	  if (page !=3D old_page + HPAGE_SIZE-1)
+		  munmap(page+size, old_page+HPAGE_SIZE-1-page);
+  }
+#endif
 #endif
 #ifdef HAVE_MMAP_DEV_ZERO
   char *page =3D (char *) mmap (pref, size, PROT_READ | PROT_WRITE,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
