Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECFB6B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 02:52:04 -0500 (EST)
Date: Tue, 22 Nov 2011 08:51:59 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111122075159.GA1675@x4.trippels.de>
References: <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121173556.GA1673@x4.trippels.de>
 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121185215.GA1673@x4.trippels.de>
 <20111121195113.GA1678@x4.trippels.de>
 <1321907275.13860.12.camel@pasglop>
 <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
 <alpine.DEB.2.00.1111212105330.19606@router.home>
 <1321948113.27077.24.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1321948113.27077.24.camel@edumazet-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On 2011.11.22 at 08:48 +0100, Eric Dumazet wrote:
> Le lundi 21 novembre 2011 a 21:18 -0600, Christoph Lameter a ecrit :
> 
> > Hmmm... That means that c->page points to page not frozen. Per cpu
> > partial pages are frozen until they are reused or until the partial list
> > is flushed.
> > 
> > Does this ever happen on x86 or only on other platforms? In put_cpu_partial() the
> > this_cpu_cmpxchg really needs really to be irq safe. this_cpu_cmpxchg is
> > only preempt safe.
> > 
> > Index: linux-2.6/mm/slub.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slub.c	2011-11-21 21:15:41.575673204 -0600
> > +++ linux-2.6/mm/slub.c	2011-11-21 21:16:33.442336849 -0600
> > @@ -1969,7 +1969,7 @@
> >  		page->pobjects = pobjects;
> >  		page->next = oldpage;
> > 
> > -	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
> > +	} while (irqsafe_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
> >  	stat(s, CPU_PARTIAL_FREE);
> >  	return pobjects;
> >  }
> > 
> 
> For x86, I wonder if our !X86_FEATURE_CX16 support is correct on SMP
> machines.
> 
> this_cpu_cmpxchg16b_emu() claims to be IRQ safe, but may be buggy...
> 
> Could we have somewhere a NMI handler calling kmalloc() ?
> 
> Please Markus send us :
> 
> cat /proc/cpuinfo
 processor       : 0
 vendor_id       : AuthenticAMD
 cpu family      : 16
 model           : 4
 model name      : AMD Phenom(tm) II X4 955 Processor
 stepping        : 2
 microcode       : 0x10000c6
 cpu MHz         : 800.000
 cache size      : 512 KB
 physical id     : 0
 siblings        : 4
 core id         : 0
 cpu cores       : 4
 apicid          : 0
 initial apicid  : 0
 fpu             : yes
 fpu_exception   : yes
 cpuid level     : 5
 wp              : yes
 flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
 mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext
 fxsr_opt pdpe1gb rdtscp lm 3dnowext 3dnow constant_tsc rep_good nopl
 nonstop_tsc extd_apicid pni monitor cx16 popcnt lahf_lm cmp_legacy svm
 extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit
 wdt npt lbrv svm_lock nrip_save
 bogomips        : 6420.59
 TLB size        : 1024 4K pages
 clflush size    : 64
 cache_alignment : 64
 address sizes   : 48 bits physical, 48 bits virtual
 power management: ts ttp tm stc 100mhzsteps hwpstate
(*4)

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
