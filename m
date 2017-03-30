Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE316B0390
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 02:43:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id t30so7984536wrc.15
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 23:43:45 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id 65si10661738wmu.102.2017.03.29.23.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 23:43:43 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id w43so9108657wrb.1
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 23:43:42 -0700 (PDT)
Date: Thu, 30 Mar 2017 08:43:39 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 4/8] asm-generic: add atomic-instrumented.h
Message-ID: <20170330064339.GA20935@gmail.com>
References: <cover.1490717337.git.dvyukov@google.com>
 <ffaaa56d5099d2926004f0290f73396d0bd842c8.1490717337.git.dvyukov@google.com>
 <20170329171526.GB26135@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170329171526.GB26135@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, peterz@infradead.org, mingo@redhat.com, akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org


* Mark Rutland <mark.rutland@arm.com> wrote:

> With some minimal CPP, it can be a lot more manageable:
> 
> ----
> #define INSTR_ATOMIC_XCHG(order)					\
> static __always_inline int atomic_xchg##order(atomic_t *v, int i)	\
> {									\
> 	kasan_check_write(v, sizeof(*v));				\
> 	arch_atomic_xchg##order(v, i);					\
> }
> 
> #define INSTR_ATOMIC_XCHG()
> 
> #ifdef arch_atomic_xchg_relaxed
> INSTR_ATOMIC_XCHG(_relaxed)
> #define atomic_xchg_relaxed atomic_xchg_relaxed
> #endif
> 
> #ifdef arch_atomic_xchg_acquire
> INSTR_ATOMIC_XCHG(_acquire)
> #define atomic_xchg_acquire atomic_xchg_acquire
> #endif
> 
> #ifdef arch_atomic_xchg_relaxed
> INSTR_ATOMIC_XCHG(_relaxed)
> #define atomic_xchg_relaxed atomic_xchg_relaxed
> #endif

Yeah, small detail: the third one wants to be _release, right?

> Is there any objection to some light CPP usage as above for adding the
> {relaxed,acquire,release} variants?

No objection from me to that way of writing it, this still looks very readable, 
and probably more readable than the verbose variants. It's similar in style to 
linux/atomic.h which has a good balance of C versus CPP.

What I objected to was the deep nested code generation approach in the original 
patch.

CPP is fine in many circumstances, but there's a level of (ab-)use where it 
becomes counterproductive.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
