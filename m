Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id F22126B00DA
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 09:27:23 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id xa7so3226250pbc.10
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 06:27:23 -0800 (PST)
Received: from psmtp.com ([74.125.245.140])
        by mx.google.com with SMTP id j10si17487779pac.257.2013.11.06.06.27.21
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 06:27:22 -0800 (PST)
Date: Wed, 6 Nov 2013 15:31:12 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: lockref: Use bloated_spinlocks to avoid explicit config dependencies
Message-ID: <20131106133112.GB22132@shutemov.name>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
 <20131105224217.GC20167@shutemov.name>
 <20131105155619.021f32eba1ca8f15a73ed4c9@linux-foundation.org>
 <20131105231310.GE20167@shutemov.name>
 <20131106093131.GU28601@twins.programming.kicks-ass.net>
 <20131106111845.GG26785@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131106111845.GG26785@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Nov 06, 2013 at 12:18:45PM +0100, Peter Zijlstra wrote:
> On Wed, Nov 06, 2013 at 10:31:31AM +0100, Peter Zijlstra wrote:
> > Subject: mm: Properly separate the bloated ptl from the regular case
> > 
> > Use kernel/bounds.c to convert build-time spinlock_t size into a
> > preprocessor symbol and apply that to properly separate the page::ptl
> > situation.
> > 
> > Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> > ---
> >  include/linux/mm.h       | 24 +++++++++++++-----------
> >  include/linux/mm_types.h |  9 +++++----
> >  kernel/bounds.c          |  2 ++
> >  mm/memory.c              | 11 +++++------
> >  4 files changed, 25 insertions(+), 21 deletions(-)
> > 
> > diff --git a/kernel/bounds.c b/kernel/bounds.c
> > index e8ca97b5c386..5982437eca2c 100644
> > --- a/kernel/bounds.c
> > +++ b/kernel/bounds.c
> > @@ -11,6 +11,7 @@
> >  #include <linux/kbuild.h>
> >  #include <linux/page_cgroup.h>
> >  #include <linux/log2.h>
> > +#include <linux/spinlock.h>
> >  
> >  void foo(void)
> >  {
> > @@ -21,5 +22,6 @@ void foo(void)
> >  #ifdef CONFIG_SMP
> >  	DEFINE(NR_CPUS_BITS, ilog2(CONFIG_NR_CPUS));
> >  #endif
> > +	DEFINE(BLOATED_SPINLOCKS, sizeof(spinlock_t) > sizeof(int));
> >  	/* End of constants */
> >  }
> 
> Using that we could also do.. not been near a compiler.
> 

[ Subject adjusted, CC: +Linus ]
> ---
> Subject: lockref: Use bloated_spinlocks to avoid explicit config dependencies
> 
> Avoid the fragile Kconfig construct guestimating spinlock_t sizes; use a
> friendly compile-time test to determine this.
> 
> Not-Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> ---
>  lib/Kconfig   | 3 ---
>  lib/lockref.c | 2 +-
>  2 files changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/lib/Kconfig b/lib/Kconfig
> index b3c8be0da17f..254af289d1d0 100644
> --- a/lib/Kconfig
> +++ b/lib/Kconfig
> @@ -54,9 +54,6 @@ config ARCH_USE_CMPXCHG_LOCKREF
>  config CMPXCHG_LOCKREF
>  	def_bool y if ARCH_USE_CMPXCHG_LOCKREF
>  	depends on SMP
> -	depends on !GENERIC_LOCKBREAK
> -	depends on !DEBUG_SPINLOCK
> -	depends on !DEBUG_LOCK_ALLOC
>  
>  config CRC_CCITT
>  	tristate "CRC-CCITT functions"
> diff --git a/lib/lockref.c b/lib/lockref.c
> index 6f9d434c1521..a158fd86aa1a 100644
> --- a/lib/lockref.c
> +++ b/lib/lockref.c
> @@ -1,7 +1,7 @@
>  #include <linux/export.h>
>  #include <linux/lockref.h>
>  
> -#ifdef CONFIG_CMPXCHG_LOCKREF
> +#if defined(CONFIG_CMPXCHG_LOCKREF) && !BLOATED_SPINLOCKS

Having CONFIG_CMPXCHG_LOCKREF=y, but not really using it could be
misleading.
Should we get rid of CONFIG_CMPXCHG_LOCKREF completely and have here:

#if defined(CONFIG_ARCH_USE_CMPXCHG_LOCKREF) && \
	defined(CONFIG_SMP) && !BLOATED_SPINLOCKS

?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
