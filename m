Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 003486B038A
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 11:32:00 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id n135so1596383itb.2
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 08:31:59 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id v7si205672iov.201.2017.03.14.08.31.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 08:31:59 -0700 (PDT)
Date: Tue, 14 Mar 2017 16:31:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170314153146.GQ5680@worktop>
References: <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej>
 <20170306203500.GR6500@twins.programming.kicks-ass.net>
 <CACT4Y+ZNb_eCLVBz6cUyr0jVPdSW_-nCedcBAh0anfds91B2vw@mail.gmail.com>
 <20170308152027.GA13133@leverpostej>
 <20170308174300.GL20400@arm.com>
 <CACT4Y+bjMLgXHv0Wwuo1fnEWitxfdJLdH2oCy+rSa2kTjNXmuw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bjMLgXHv0Wwuo1fnEWitxfdJLdH2oCy+rSa2kTjNXmuw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Mar 14, 2017 at 04:22:52PM +0100, Dmitry Vyukov wrote:
> Any other suggestions?

> -	return i + xadd(&v->counter, i);
> +	return i + arch_xadd(&v->counter, i);

> +#define xadd(ptr, v)					\
> +({							\
> +	__typeof__(ptr) ____ptr = (ptr);		\
> +	kasan_check_write(____ptr, sizeof(*____ptr));	\
> +	arch_xadd(____ptr, (v));			\
> +})

xadd() isn't a generic thing, it only exists inside x86 as a helper to
implement atomic bits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
