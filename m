Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts13-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071030191728.PYAW13659.tomts13-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 30 Oct 2007 15:17:28 -0400
Date: Tue, 30 Oct 2007 15:12:26 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 08/10] SLUB: Optional fast path using cmpxchg_local
Message-ID: <20071030191226.GA10977@Krystal>
References: <20071028033156.022983073@sgi.com> <20071028033300.240703208@sgi.com> <20071030114933.904a4cf8.akpm@linux-foundation.org> <Pine.LNX.4.64.0710301155240.12746@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710301155240.12746@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter (clameter@sgi.com) wrote:
> On Tue, 30 Oct 2007, Andrew Morton wrote:
> 
> > Let's cc linux-arch: presumably other architectures can implement cpu-local
> > cmpxchg and would see some benefit from doing so.
> 
> Matheiu had a whole series of cmpxchg_local patches. Ccing him too. I 
> think he has some numbers for other architectures.
>  

Well, I tested it on x86 and AMD64 only. For slub:

Using cmpxchg_local shows a performance improvements of the fast path
goes from a 66% speedup on a Pentium 4 to a 14% speedup on AMD64.

It really depends on how fast cmpxchg_local is vs disabling interrupts.


> > The semantics are "atomic wrt interrutps on this cpu, not atomic wrt other
> > cpus", yes?
> 
> Right.
> 
> > Do you have a feel for how useful it would be for arch maintainers to implement
> > this?  IOW, is it worth their time?
> 
> That depends on the efficiency of a cmpxchg_local vs. the interrupt 
> enable/ disable sequence on a particular arch. On x86 this yields about 
> 50% so it doubles the speed of the fastpath. On other architectures the 
> cmpxchg is so slow that it is not worth it (ia64 f.e.)

As Christoph pointed out, we even saw a small slowdown on ia64 because
there is no concept of atomicity wrt only one CPU. Emulating this with
irq disable has been tried, but just the supplementary memory barriers
hurts performance a bit. We tried to come up with clever macros that
switch between irq disable and cmpxchg_local depending on the
architecture, but all the results were awkward.

I guess it's time for me to repost my patchset. I use interrupt disable
to emulate the cmpxchg_local on architectures that lacks atomic ops.

# cmpxchg_local and cmpxchg64_local standardization
add-cmpxchg-local-to-generic-for-up.patch
i386-cmpxchg64-80386-80486-fallback.patch
add-cmpxchg64-to-alpha.patch
add-cmpxchg64-to-mips.patch
add-cmpxchg64-to-powerpc.patch
add-cmpxchg64-to-x86_64.patch
#
add-cmpxchg-local-to-arm.patch
add-cmpxchg-local-to-avr32.patch
add-cmpxchg-local-to-blackfin.patch
add-cmpxchg-local-to-cris.patch
add-cmpxchg-local-to-frv.patch
add-cmpxchg-local-to-h8300.patch
add-cmpxchg-local-to-ia64.patch
add-cmpxchg-local-to-m32r.patch
fix-m32r-__xchg.patch
fix-m32r-include-sched-h-in-smpboot.patch
local_t_m32r_optimized.patch
add-cmpxchg-local-to-m68k.patch
add-cmpxchg-local-to-m68knommu.patch
add-cmpxchg-local-to-parisc.patch
add-cmpxchg-local-to-ppc.patch
add-cmpxchg-local-to-s390.patch
add-cmpxchg-local-to-sh.patch
add-cmpxchg-local-to-sh64.patch
add-cmpxchg-local-to-sparc.patch
add-cmpxchg-local-to-sparc64.patch
add-cmpxchg-local-to-v850.patch
add-cmpxchg-local-to-xtensa.patch
#
slub-use-cmpxchg-local.patch

Mathieu

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
