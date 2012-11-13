Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 433206B006C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 07:09:14 -0500 (EST)
Date: Tue, 13 Nov 2012 12:09:09 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 15/19] mm: numa: Add fault driven placement and migration
Message-ID: <20121113120909.GB8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-16-git-send-email-mgorman@suse.de>
 <20121113104530.GF21522@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121113104530.GF21522@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 13, 2012 at 11:45:30AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > NOTE: This patch is based on "sched, numa, mm: Add fault driven
> >	placement and migration policy" but as it throws away 
> >	all the policy to just leave a basic foundation I had to 
> >	drop the signed-offs-by.
> 
> So, much of that has been updated meanwhile - but the split 
> makes fundamental sense - we considered it before.
> 

Yes, I saw the new series after I had written the changelog for V2. I
decided to release a V2 anyway and plan to examine the revised patches and
see what's in there. I hope to do that today, but it's more likely it will
be tomorrow as some other issues have piled up on the TODO list.

> One detail you did in this patch was the following rename:
> 
>      s/EMBEDDED_NUMA/NUMA_VARIABLE_LOCALITY
> 

Yes.

> > --- a/arch/sh/mm/Kconfig
> > +++ b/arch/sh/mm/Kconfig
> > @@ -111,6 +111,7 @@ config VSYSCALL
> >  config NUMA
> >  	bool "Non Uniform Memory Access (NUMA) Support"
> >  	depends on MMU && SYS_SUPPORTS_NUMA && EXPERIMENTAL
> > +	select NUMA_VARIABLE_LOCALITY
> >  	default n
> >  	help
> >  	  Some SH systems have many various memories scattered around
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> >
> ..aaba45d 100644
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -696,6 +696,20 @@ config LOG_BUF_SHIFT
> >  config HAVE_UNSTABLE_SCHED_CLOCK
> >  	bool
> >  
> > +#
> > +# For architectures that (ab)use NUMA to represent different memory regions
> > +# all cpu-local but of different latencies, such as SuperH.
> > +#
> > +config NUMA_VARIABLE_LOCALITY
> > +	bool
> 
> The NUMA_VARIABLE_LOCALITY name slightly misses the real point 
> though that NUMA_EMBEDDED tried to stress: it's important to 
> realize that these are systems that (ab-)use our NUMA memory 
> zoning code to implement support for variable speed RAM modules 
> - so they can use the existing node binding ABIs.
> 
> The cost of that is the losing of the regular NUMA node 
> structure. So by all means it's a convenient hack - but the name 
> must signal that. I'm not attached to the NUMA_EMBEDDED naming 
> overly strongly, but NUMA_VARIABLE_LOCALITY sounds more harmless 
> than it should.
> 
> Perhaps ARCH_WANT_NUMA_VARIABLE_LOCALITY_OVERRIDE? A tad long 
> but we don't want it to be overused in any case.
> 

I had two reasons for not using the NUMA_EMBEDDED name.

1. Embedded is too generic a term and could mean anything. There are x86
   machines that are considered embedded who this option is meaningless
   for. It's be irritating to get mails about how they cannot enable the
   NUMA_EMBEDDED option for their embedded machine.

2. I encounter people periodically that plan to abuse NUMA for building
   things like ram-like regions backed by something else that are not
   arch-specific. In some cases, these are far from being for an embedded
   use-case. While I have heavily discouraged such NUMA abuse in the past
   I still kept it in mind for the naming.

I'll go with the long name you suggest even though it's arch specific
because I never want point 2 above to happen anyway. Maybe the name will
poke the next person who plans to abuse NUMA in the eye hard enough to
discourage them.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
