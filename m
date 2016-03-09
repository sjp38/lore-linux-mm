Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3876B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 06:01:01 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id tt10so36778389pab.3
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 03:01:01 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id c67si11824851pfj.47.2016.03.09.03.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 03:01:00 -0800 (PST)
Subject: Re: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
References: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
 <alpine.DEB.2.20.1603080857360.4047@east.gentwo.org>
 <56DEF3D3.6080008@synopsys.com>
 <alpine.DEB.2.20.1603081438020.4268@east.gentwo.org>
 <56DFC604.6070407@synopsys.com>
 <20160309101349.GJ6344@twins.programming.kicks-ass.net>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <56E0024F.4070401@synopsys.com>
Date: Wed, 9 Mar 2016 16:30:31 +0530
MIME-Version: 1.0
In-Reply-To: <20160309101349.GJ6344@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-parisc@vger.kernel, Andrew Morton <akpm@linux-foundation.org>, Helge Deller <deller@gmx.de>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Noam Camus <noamc@ezchip.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-snps-arc@lists.infradead.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wednesday 09 March 2016 03:43 PM, Peter Zijlstra wrote:
>>> If you take the lock in __bit_spin_unlock
>>> then the race cannot happen.
>>
>> Of course it won't but that means we penalize all non atomic callers of the API
>> with a superfluous spinlock which is not require din first place given the
>> definition of API.
> 
> Quite. _However_, your arch is still broken, but not by your fault. Its
> the generic-asm code that is wrong.
> 
> The thing is that __bit_spin_unlock() uses __clear_bit_unlock(), which
> defaults to __clear_bit(). Which is wrong.
> 
> ---
> Subject: bitops: Do not default to __clear_bit() for __clear_bit_unlock()
> 
> __clear_bit_unlock() is a special little snowflake. While it carries the
> non-atomic '__' prefix, it is specifically documented to pair with
> test_and_set_bit() and therefore should be 'somewhat' atomic.
> 
> Therefore the generic implementation of __clear_bit_unlock() cannot use
> the fully non-atomic __clear_bit() as a default.
> 
> If an arch is able to do better; is must provide an implementation of
> __clear_bit_unlock() itself.
> 
> Reported-by: Vineet Gupta <Vineet.Gupta1@synopsys.com>

This needs to be CCed stable as it fixes a real bug for ARC.

> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Tested-by: Vineet Gupta <Vineet.Gupta1@synopsys.com>

FWIW, could we add some background to commit log, specifically what prompted this.
Something like below...

---->8------
This came up as a result of hackbench livelock'ing in slab_lock() on ARC with SMP
+ SLUB + !LLSC.

The issue was incorrect pairing of atomic ops.

slab_lock() -> bit_spin_lock() -> test_and_set_bit()
slab_unlock() -> __bit_spin_unlock() -> __clear_bit()

The non serializing __clear_bit() was getting "lost"

80543b8e:	ld_s       r2,[r13,0] <--- (A) Finds PG_locked is set
80543b90:	or         r3,r2,1    <--- (B) other core unlocks right here
80543b94:	st_s       r3,[r13,0] <--- (C) sets PG_locked (overwrites unlock)

Fixes ARC STAR 9000817404
---->8------

> ---
>  include/asm-generic/bitops/lock.h | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/include/asm-generic/bitops/lock.h b/include/asm-generic/bitops/lock.h
> index c30266e94806..8ef0ccbf8167 100644
> --- a/include/asm-generic/bitops/lock.h
> +++ b/include/asm-generic/bitops/lock.h
> @@ -29,16 +29,16 @@ do {					\
>   * @nr: the bit to set
>   * @addr: the address to start counting from
>   *
> - * This operation is like clear_bit_unlock, however it is not atomic.
> - * It does provide release barrier semantics so it can be used to unlock
> - * a bit lock, however it would only be used if no other CPU can modify
> - * any bits in the memory until the lock is released (a good example is
> - * if the bit lock itself protects access to the other bits in the word).
> + * A weaker form of clear_bit_unlock() as used by __bit_lock_unlock(). If all
> + * the bits in the word are protected by this lock some archs can use weaker
> + * ops to safely unlock.
> + *
> + * See for example x86's implementation.
>   */

To be able to override/use-generic don't we need #ifndef ....

>  #define __clear_bit_unlock(nr, addr)	\
>  do {					\
> -	smp_mb();			\
> -	__clear_bit(nr, addr);		\
> +	smp_mb__before_atomic();	\
> +	clear_bit(nr, addr);		\
>  } while (0)
>  
>  #endif /* _ASM_GENERIC_BITOPS_LOCK_H_ */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
