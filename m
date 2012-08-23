Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 664A46B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 01:12:07 -0400 (EDT)
Message-ID: <1345698660.13399.23.camel@pasglop>
Subject: Re: [PATCH 33/36] autonuma: powerpc port
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Aug 2012 15:11:00 +1000
In-Reply-To: <20120822223542.GG8107@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
	 <1345647560-30387-34-git-send-email-aarcange@redhat.com>
	 <1345672907.2617.44.camel@pasglop> <20120822223542.GG8107@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Tony Breeds <tbreeds@au1.ibm.com>, Kumar Gala <galak@kernel.crashing.org>

On Thu, 2012-08-23 at 00:35 +0200, Andrea Arcangeli wrote:

> I'm actually surprised you don't already check for PROTNONE
> there. Anyway yes this is necessary, the whole concept of NUMA hinting
> page faults is to make the pte not present, and to set another bit (be
> it a reserved bit or PROTNONE doesn't change anything in that
> respect). But another bit replacing _PAGE_PRESENT must exist.
> 
> This change is zero cost at runtime, and 0x1 or 0x3 won't change a
> thing for the CPU.

We don't have PROTNONE on ppc, see below.

 .../...

> > I'm concerned. We are already running short on RPN bits. We can't spare
> > more. If you absolutely need a PTE bit, we'll need to explore ways to
> > free some, but just reducing the RPN isn't an option.
> 
> No way to do it without a spare bit.
> 
> Note that this is now true for sched-numa rewrite as well because it
> also introduced the NUMA hinting page faults of AutoNUMA (except what
> it does during the fault is different there, but the mechanism of
> firing them and the need of a spare pte bit is identical).
> 
> But you must have a bit for protnone, don't you? You can implement it
> with prot none, I can add the vma as parameter to some function to
> achieve it if you need. It may be good idea to do anyway even if
> there's no need on x86 at this point.

So we don't do protnone, and now that you mention it, I think that means
that some of our embedded stuff is busted :-)

Basically PROT_NONE turns into _PAGE_PRESENT without _PAGE_USER for us.

On server, user accesses effectively use the user protection bits due to
the fact that the user segments are tagged as such. So the fact that
PROT_NONE -> !_PAGE_USER for us is essentially enough.

However, the embedded ppc situation is more interesting... and it looks
like it is indeed broken, meaning that a user can coerce the kernel into
accessing PROT_NONE on its behalf with copy_from_user & co (though read
only really).

Looks like the SW TLB handlers used on embedded should also check
whether the address is a user or kernel address, and enforce _PAGE_USER
in the former case. They might have done in the past, it's possible that
it's code we lost, but as it is, it's broken.

The case of HW loaded TLB embedded will need a different definition of
PAGE_NONE as well I suspect. Kumar, can you have a look ?

> > Think of what happens if PTE_4K_PFN is set...
> 
> It may very well broken with PTE_4K_PFN is set, I'm not familiar with
> that. If that's the case we'll just add an option to prevent
> AUTONUMA=y to be set if PTE_4K_PFN is set thanks for the info.
> 
> > Also you conveniently avoided all the other pte-*.h variants meaning you
> > broke the build for everything except ppc64 with 64k pages.
> 
> This can only be enabled on PPC64 in KConfig so no problem about
> ppc32.

I wasn't especially thinking of ppc32... there's also hash64-4k or
embedded 64... Also pgtable.h is common, so all those added uses of
_PAGE_NUMA_PTE to static inline functions are going to break the build
unless _PAGE_NUMA_PTE is #defined to 0 when not used (we do that for a
bunch of bits in pte-common.h already).

> > > diff --git a/mm/autonuma.c b/mm/autonuma.c
> > > index ada6c57..a4da3f3 100644
> > > --- a/mm/autonuma.c
> > > +++ b/mm/autonuma.c
> > > @@ -25,7 +25,7 @@ unsigned long autonuma_flags __read_mostly =
> > >  #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
> > >  	|(1<<AUTONUMA_ENABLED_FLAG)
> > >  #endif
> > > -	|(1<<AUTONUMA_SCAN_PMD_FLAG);
> > > +	|(0<<AUTONUMA_SCAN_PMD_FLAG);
> > 
> > That changes the default accross all architectures, is that ok vs.
> > Andrea ?
> 
> :) Indeed! But the next patch (34) undoes this hack. I just merged the
> patch with "git am" and then introduced a proper way for the arch to
> specify if the PMD scan is supported or not in an incremental
> patch. Adding ppc64 support, and making the PMD scan mode arch
> conditional are two separate things so I thought it was cleaner
> keeping those in two separate patches but I can fold them if you
> prefer.

Ok.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
