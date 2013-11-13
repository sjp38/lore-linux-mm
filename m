Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id AD1EE6B007D
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 12:39:50 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id mc17so721347pbc.7
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 09:39:50 -0800 (PST)
Received: from psmtp.com ([74.125.245.171])
        by mx.google.com with SMTP id tu7si24726068pab.17.2013.11.13.09.39.48
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 09:39:49 -0800 (PST)
Date: Wed, 13 Nov 2013 17:37:57 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v5 4/4] MCS Lock: Barrier corrections
Message-ID: <20131113173757.GG11928@mudshark.cambridge.arm.com>
References: <20131112160827.GB25953@mudshark.cambridge.arm.com>
 <20131112171633.7498.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131112171633.7498.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: "tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "aarcange@redhat.com" <aarcange@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "alex.shi@linaro.org" <alex.shi@linaro.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "arnd@arndb.de" <arnd@arndb.de>, "aswin@hp.com" <aswin@hp.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "davidlohr.bueso@hp.com" <davidlohr.bueso@hp.com>, "figo1802@gmail.com" <figo1802@gmail.com>, "hpa@zytor.com" <hpa@zytor.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "matthew.r.wilcox@intel.com" <matthew.r.wilcox@intel.com>, "mingo@elte.hu" <mingo@elte.hu>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "peter@hurleysoftware.com" <peter@hurleysoftware.com>, "raghavendra.kt@linux.vnet.ibm.com" <raghavendra.kt@linux.vnet.ibm.com>, "riel@redhat.com" <riel@redhat.com>, "scott.norton@hp.com" <scott.norton@hp.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "waiman.long@hp.com" <waiman.long@hp.com>, "walken@google.com" <walken@google.com>

On Tue, Nov 12, 2013 at 05:16:33PM +0000, George Spelvin wrote:
> > On Mon, Nov 11, 2013 at 09:17:52PM +0000, Tim Chen wrote:
> >> An alternate implementation is
> >> 	while (!ACCESS_ONCE(node->locked))
> >> 		arch_mutex_cpu_relax();
> >> 	smp_load_acquire(&node->locked);
> >> 
> >> Leaving the smp_load_acquire at the end to provide appropriate barrier.
> >> Will that be acceptable?
> 
> Will Deacon <will.deacon@arm.com> wrote:
> > It still doesn't solve my problem though: I want a way to avoid that busy
> > loop by some architecture-specific manner. The arch_mutex_cpu_relax() hook
> > is a start, but there is no corresponding hook on the unlock side to issue a
> > wakeup. Given a sensible relax implementation, I don't have an issue with
> > putting a load-acquire in a loop, since it shouldn't be aggresively spinning
> > anymore.
> 
> So you want something like this?
> 
> /*
>  * This is a spin-wait with acquire semantics.  That is, accesses after
>  * this are not allowed to be reordered before the load that meets
>  * the specified condition.  This requires that it end with either a
>  * load-acquire or a full smp_mb().  The optimal way to do this is likely
>  * to be architecture-dependent.  E.g. x86 MONITOR/MWAIT instructions.
>  */
> #ifndef smp_load_acquire_until
> #define smp_load_acquire_until(addr, cond) \
> 	while (!(smp_load_acquire(addr) cond)) { \
> 		do { \
> 			arch_mutex_cpu_relax(); \
> 		} while (!(ACCESS_ONCE(*(addr)) cond)); \
> 	}
> #endif
> 
> 	smp_load_acquire_until(&node->locked, != 0);
> 
> Alternative implementations:
> 
> #define smp_load_acquire_until(addr, cond) { \
> 	while (!(ACCESS_ONCE(*(addr)) cond)) \
> 		arch_mutex_cpu_relax(); \
> 	smp_mb(); }
> 
> #define smp_load_acquire_until(addr, cond) \
> 	if (!(smp_load_acquire(addr) cond)) { \
> 		do { \
> 			arch_mutex_cpu_relax(); \
> 		} while (!(ACCESS_ONCE(*(addr)) cond)); \
> 		smp_mb(); \
> 	}

Not really...

To be clear: having the load-acquire in a loop is fine, provided that
arch_mutex_cpu_relax is something which causes the load to back-off (you
mentioned the MONITOR/MWAIT instructions on x86).

On ARM, our equivalent of those instructions also has a counterpart
instruction that needs to be executed by the CPU doing the unlock. That
means we can do one of two things:

	1. Add an arch hook in the unlock path to pair with the relax()
	   call on the lock path (arch_mutex_cpu_wake() ?).

	2. Move most of the code into arch_mcs_[un]lock, like we do for
	   spinlocks.

Whilst (1) would suffice, (2) would allow further optimisation on arm64,
where we can play tricks to avoid the explicit wakeup if we can control the
way in which the lock value is written.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
