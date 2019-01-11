Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA418E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:58:37 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id u20so11245883pfa.1
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:58:37 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id l7si15083723pgk.169.2019.01.11.12.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 12:58:36 -0800 (PST)
Subject: Re: [PATCH 3/3] bitops.h: set_mask_bits() to return old value
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
 <1547166387-19785-4-git-send-email-vgupta@synopsys.com>
 <20190111092408.GM30894@hirez.programming.kicks-ass.net>
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Message-ID: <d36b8582-184a-37d2-699f-04837745b70a@synopsys.com>
Date: Fri, 11 Jan 2019 12:58:22 -0800
MIME-Version: 1.0
In-Reply-To: <20190111092408.GM30894@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Miklos Szeredi <mszeredi@redhat.com>, Jani Nikula <jani.nikula@intel.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>

On 1/11/19 1:24 AM, Peter Zijlstra wrote:
> diff --git a/include/linux/bitops.h b/include/linux/bitops.h
> index 705f7c442691..2060d26a35f5 100644
> --- a/include/linux/bitops.h
> +++ b/include/linux/bitops.h
> @@ -241,10 +241,10 @@ static __always_inline void __assign_bit(long nr, volatile unsigned long *addr,
>  	const typeof(*(ptr)) mask__ = (mask), bits__ = (bits);	\
>  	typeof(*(ptr)) old__, new__;				\
>  								\
> +	old__ = READ_ONCE(*(ptr));				\
>  	do {							\
> -		old__ = READ_ONCE(*(ptr));			\
>  		new__ = (old__ & ~mask__) | bits__;		\
> -	} while (cmpxchg(ptr, old__, new__) != old__);		\
> +	} while (!try_cmpxchg(ptr, &old__, new__));		\
>  								\
>  	new__;							\
>  })
> 
> 
> While there you probably want something like the above... 

As a separate change perhaps so that a revert (unlikely as it might be) could be
done with less pain.

> although,
> looking at it now, we seem to have 'forgotten' to add try_cmpxchg to the
> generic code :/

So it _has_ to be a separate change ;-)

But can we even provide a sane generic try_cmpxchg. The asm-generic cmpxchg relies
on local irq save etc so it is clearly only to prevent a new arch from failing to
compile. atomic*_cmpxchg() is different story since atomics have to be provided by
arch.

Anyhow what is more interesting is the try_cmpxchg API itself. So commit
a9ebf306f52c756 introduced/use of try_cmpxchg(), which indeed makes the looping
"nicer" to read and obvious code gen improvements.

So,
        for (;;) {
                new = val $op $imm;
                old = cmpxchg(ptr, val, new);
                if (old == val)
                        break;
                val = old;
        }

becomes

        do {
        } while (!try_cmpxchg(ptr, &val, val $op $imm));


But on pure LL/SC retry based arches, we still end up with generated code having 2
loops. We discussed something similar a while back: see [1]

First loop is inside inline asm to retry LL/SC and the outer one due to code
above. Explicit return of try_cmpxchg() means setting up a register with a boolean
status of cmpxchg (AFAIKR ARMv7 already does that but ARC e.g. uses a CPU flag
thus requires an additional insn or two). We could arguably remove the inline asm
loop and retry LL/SC from the outer loop, but it seems cleaner to keep the retry
where it belongs.

Also under the hood, try_cmpxchg() would end up re-reading it for the issue fixed
by commit 44fe84459faf1a.

Heck, it would all be simpler if we could express this w/o use of cmpxchg.

	try_some_op(ptr, &val, val $op $imm);

P.S. the horrible API name is for indicative purposes only

This would remove the outer loop completely, also avoid any re-reads due to the
semantics of cmpxchg etc.

[1] https://www.spinics.net/lists/kernel/msg2029217.html
