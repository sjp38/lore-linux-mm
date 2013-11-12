Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 63AD16B0044
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 12:16:39 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id xa7so7203356pbc.38
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 09:16:39 -0800 (PST)
Received: from psmtp.com ([74.125.245.174])
        by mx.google.com with SMTP id p2si20278680pbe.8.2013.11.12.09.16.35
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 09:16:37 -0800 (PST)
Date: 12 Nov 2013 12:16:33 -0500
Message-ID: <20131112171633.7498.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH v5 4/4] MCS Lock: Barrier corrections
In-Reply-To: <20131112160827.GB25953@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tim.c.chen@linux.intel.com, will.deacon@arm.com
Cc: a.p.zijlstra@chello.nl, aarcange@redhat.com, akpm@linux-foundation.org, alex.shi@linaro.org, andi@firstfloor.org, arnd@arndb.de, aswin@hp.com, dave.hansen@intel.com, davidlohr.bueso@hp.com, figo1802@gmail.com, hpa@zytor.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@horizon.com, matthew.r.wilcox@intel.com, mingo@elte.hu, paulmck@linux.vnet.ibm.com, peter@hurleysoftware.com, raghavendra.kt@linux.vnet.ibm.com, riel@redhat.com, scott.norton@hp.com, tglx@linutronix.de, torvalds@linux-foundation.org, waiman.long@hp.com, walken@google.com

> On Mon, Nov 11, 2013 at 09:17:52PM +0000, Tim Chen wrote:
>> An alternate implementation is
>> 	while (!ACCESS_ONCE(node->locked))
>> 		arch_mutex_cpu_relax();
>> 	smp_load_acquire(&node->locked);
>> 
>> Leaving the smp_load_acquire at the end to provide appropriate barrier.
>> Will that be acceptable?

Will Deacon <will.deacon@arm.com> wrote:
> It still doesn't solve my problem though: I want a way to avoid that busy
> loop by some architecture-specific manner. The arch_mutex_cpu_relax() hook
> is a start, but there is no corresponding hook on the unlock side to issue a
> wakeup. Given a sensible relax implementation, I don't have an issue with
> putting a load-acquire in a loop, since it shouldn't be aggresively spinning
> anymore.

So you want something like this?

/*
 * This is a spin-wait with acquire semantics.  That is, accesses after
 * this are not allowed to be reordered before the load that meets
 * the specified condition.  This requires that it end with either a
 * load-acquire or a full smp_mb().  The optimal way to do this is likely
 * to be architecture-dependent.  E.g. x86 MONITOR/MWAIT instructions.
 */
#ifndef smp_load_acquire_until
#define smp_load_acquire_until(addr, cond) \
	while (!(smp_load_acquire(addr) cond)) { \
		do { \
			arch_mutex_cpu_relax(); \
		} while (!(ACCESS_ONCE(*(addr)) cond)); \
	}
#endif

	smp_load_acquire_until(&node->locked, != 0);

Alternative implementations:

#define smp_load_acquire_until(addr, cond) { \
	while (!(ACCESS_ONCE(*(addr)) cond)) \
		arch_mutex_cpu_relax(); \
	smp_mb(); }

#define smp_load_acquire_until(addr, cond) \
	if (!(smp_load_acquire(addr) cond)) { \
		do { \
			arch_mutex_cpu_relax(); \
		} while (!(ACCESS_ONCE(*(addr)) cond)); \
		smp_mb(); \
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
