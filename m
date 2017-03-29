Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF9356B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 13:15:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u202so13679913pgb.9
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:15:47 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l14si8005499plk.57.2017.03.29.10.15.46
        for <linux-mm@kvack.org>;
        Wed, 29 Mar 2017 10:15:46 -0700 (PDT)
Date: Wed, 29 Mar 2017 18:15:26 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 4/8] asm-generic: add atomic-instrumented.h
Message-ID: <20170329171526.GB26135@leverpostej>
References: <cover.1490717337.git.dvyukov@google.com>
 <ffaaa56d5099d2926004f0290f73396d0bd842c8.1490717337.git.dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ffaaa56d5099d2926004f0290f73396d0bd842c8.1490717337.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, peterz@infradead.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

Hi,

On Tue, Mar 28, 2017 at 06:15:41PM +0200, Dmitry Vyukov wrote:
> The new header allows to wrap per-arch atomic operations
> and add common functionality to all of them.

I had a quick look at what it would take to have arm64 use this, and I
have a couple of thoughts.

> +static __always_inline int atomic_xchg(atomic_t *v, int i)
> +{
> +	return arch_atomic_xchg(v, i);
> +}

I generally agree that avoiding several layers of CPP aids readability
here, and as-is I think this is fine.

However, avoiding CPP entirely will mean that the file becomes painfully
verbose when support for {relaxed,acquire,release}-order variants is
added.

Just considering atomic_xchg{,_relaxed,_acquire,_release}(), for
example:

----
static __always_inline int atomic_xchg(atomic_t *v, int i)
{
	kasan_check_write(v, sizeof(*v));
	return arch_atomic_xchg(v, i);
}

#ifdef arch_atomic_xchg_relaxed
static __always_inline int atomic_xchg(atomic_t *v, int i)
{
	kasan_check_write(v, sizeof(*v));
	return arch_atomic_xchg_relaxed(v, i);
}
#define atomic_xchg_relaxed atomic_xchg_relaxed
#endif

#ifdef arch_atomic_xchg_acquire
static __always_inline int atomic_xchg(atomic_t *v, int i)
{
	kasan_check_write(v, sizeof(*v));
	return arch_atomic_xchg_acquire(v, i);
}
#define atomic_xchg_acquire atomic_xchg_acquire
#endif

#ifdef arch_atomic_xchg_release
static __always_inline int atomic_xchg(atomic_t *v, int i)
{
	kasan_check_write(v, sizeof(*v));
	return arch_atomic_xchg_release(v, i);
}
#define atomic_xchg_release atomic_xchg_release
#endif
----


With some minimal CPP, it can be a lot more manageable:

----
#define INSTR_ATOMIC_XCHG(order)					\
static __always_inline int atomic_xchg##order(atomic_t *v, int i)	\
{									\
	kasan_check_write(v, sizeof(*v));				\
	arch_atomic_xchg##order(v, i);					\
}

#define INSTR_ATOMIC_XCHG()

#ifdef arch_atomic_xchg_relaxed
INSTR_ATOMIC_XCHG(_relaxed)
#define atomic_xchg_relaxed atomic_xchg_relaxed
#endif

#ifdef arch_atomic_xchg_acquire
INSTR_ATOMIC_XCHG(_acquire)
#define atomic_xchg_acquire atomic_xchg_acquire
#endif

#ifdef arch_atomic_xchg_relaxed
INSTR_ATOMIC_XCHG(_relaxed)
#define atomic_xchg_relaxed atomic_xchg_relaxed
#endif
----


Is there any objection to some light CPP usage as above for adding the
{relaxed,acquire,release} variants?

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
