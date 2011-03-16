Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 970A28D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 16:35:34 -0400 (EDT)
Subject: Re: [PATCH 2/8] drivers/char/random: Split out __get_random_int
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20110316183549.8468.qmail@science.horizon.com>
References: <20110316183549.8468.qmail@science.horizon.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Mar 2011 15:35:07 -0500
Message-ID: <1300307707.3128.560.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi

On Wed, 2011-03-16 at 14:35 -0400, George Spelvin wrote:
> >From mpm@selenic.com Wed Mar 16 14:24:09 2011
> X-Virus-Scanned: Debian amavisd-new at waste.org
> Subject: Re: [PATCH 2/8] drivers/char/random: Split out __get_random_int
> From: Matt Mackall <mpm@selenic.com>
> To: George Spelvin <linux@horizon.com>
> Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org, 
>  linux-mm@kvack.org, penberg@cs.helsinki.fi
> In-Reply-To: <20110316042452.21452.qmail@science.horizon.com>
> References: <20110316042452.21452.qmail@science.horizon.com>
> Content-Type: text/plain; charset="UTF-8"
> Date: Wed, 16 Mar 2011 09:24:05 -0500
> Mime-Version: 1.0
> X-Mailer: Evolution 2.32.2 
> Content-Transfer-Encoding: 7bit
> 
> On Wed, 2011-03-16, Mat Mackall wrote:
> > On Wed, 2011-03-16 at 00:24 -0400, George Spelvin wrote:
> >> If you like, and don't mind a few more bytes of per-cpu data, I'll
> >> happily replace the whole dubious thing with a cryptographically secure
> >> high-speed PRNG.  I'm thinking ChaCha/12, as Salsa20 was selected by
> >> eSTREAM and ChaCha is generally agreed to be stronger.  (It's had more
> >> review as the basis of the BLAKE hash function, a SHA-3 finalist.)
> 
> > Yes, let's do this. ChaCha looks like a fine candidate.
> 
> Just to confirm, it'll have basically the same structure as the
> current code: a global secret key, re-seeded every 300 seconds,
> with per-CPU state for generation.

>   I'll generate 16 words at a time,
> and use them until they're exhausted or the global secret changes.
> 
> ChaCha uses a 256-bit (8-word) key.  It obviously shouldn't be shared
> with the weaker half-MD4 operation.  Should I generate both from the
> pool directly, or only take 8 words and use ChaCha to generate the
> half-MD4 key?

Ideally, I'd like to banish the syncookie code back to networking. I
actually had patches that did this, but they collided in flight with
Arjan's address-space randomization patches.

So decoupling the lightweight RNG from the half-MD4 crap should be the
goal. A future goal would be replacing half-MD4 (and its IPv6 sibling)
with a sensible alternative.

> > I'd rather not add an frandom until after we get rid of the
> > random/urandom dichotomy.
> 
> Can you explain?  I think Ted's idea of the split was a good idea.

I had a long talk with Ted about two years ago (and separately with
Bruce Schneier) and we all agreed that the entropy accounting was a neat
idea in theory, but broken in practice. For entropy accounting to
actually work (and thus make random stronger than urandom), we MUST
strictly underestimate input entropy. But in general, we have no model
of entropy sources that actually lets us meet this claim (and in fact we
know that most of the sources don't!). 

And it hurts us because (a) it keeps us from sampling sources that may
have significant entropy in practice but not in theory and (b) confuses
the hell out of everyone.

We'd be better off with significantly more lighter-weight sampling from
less ideal sources and ditching entropy counting. In other words, we can
trade some ideal but unrealizable level of security for more actual
depth.

There's a bit of a chicken and egg problem here though: it's hard to
introduce a lot of new sampling (eg per-interrupt!) due to locking
overhead associated with entropy counting. A really lightweight approach
needs to be nearly exclusively cpu-local, but we need a design that can
still do cross-cpu catastrophic reseeding. And I've been pretty busy
with another little project, so this is all a bit stalled.

> >From c7a878c143c7e63d2540785b76db54b2e8cf6d38 Mon Sep 17 00:00:00 2001
> From: George Spelvin <linux@horizon.com>
> Date: Wed, 16 Mar 2011 11:42:52 -0400
> Subject: [PATCH 1/9] drivers/char/random: Eliminate randomize_range().
> 
> This is only called in three places, each of which is trivially
> replaced by a call to get_random_int() followed by a bit mask.
> (It's to randomize the start of the brk() range by 0..32M bytes,
> 0..8K pages, which is 13 bits of entropy.)
> 
> There is a slight behaviour change, as randomize_range() used PAGE_ALIGN()
> which rounds up, but it appears that rounding down was the intention.

Can't say I really like this. Your rolled-in bugfix is a perfect
demonstration of why we don't want to inline this: it's too easy to do
wrong. Ideally we'd have a nice ASR-friendly helper function using a
mask somewhere in mm/ that gets all the tricky arch pointer size and
alignment issues right, rather than a generic-looking one using modulus
(in a sketchy way) in random.h

> ---
>  arch/arm/kernel/process.c    |    3 +--
>  arch/x86/kernel/process.c    |    3 +--
>  arch/x86/kernel/sys_x86_64.c |    7 ++-----
>  drivers/char/random.c        |   19 -------------------
>  include/linux/random.h       |    1 -
>  5 files changed, 4 insertions(+), 29 deletions(-)
> 
> diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
> index 94bbedb..ffb7c87 100644
> --- a/arch/arm/kernel/process.c
> +++ b/arch/arm/kernel/process.c
> @@ -479,8 +479,7 @@ unsigned long get_wchan(struct task_struct *p)
>  
>  unsigned long arch_randomize_brk(struct mm_struct *mm)
>  {
> -	unsigned long range_end = mm->brk + 0x02000000;
> -	return randomize_range(mm->brk, range_end, 0) ? : mm->brk;
> +	return mm->brk + (get_random_int() & 0x01ffffff & PAGE_MASK);
>  }
>  
>  #ifdef CONFIG_MMU
> diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
> index ff45541..dcec1a1 100644
> --- a/arch/x86/kernel/process.c
> +++ b/arch/x86/kernel/process.c
> @@ -677,7 +677,6 @@ unsigned long arch_align_stack(unsigned long sp)
>  
>  unsigned long arch_randomize_brk(struct mm_struct *mm)
>  {
> -	unsigned long range_end = mm->brk + 0x02000000;
> -	return randomize_range(mm->brk, range_end, 0) ? : mm->brk;
> +	return mm->brk + (get_random_int() & 0x01ffffff & PAGE_MASK);
>  }
>  
> diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
> index ff14a50..0f874f7 100644
> --- a/arch/x86/kernel/sys_x86_64.c
> +++ b/arch/x86/kernel/sys_x86_64.c
> @@ -46,11 +46,8 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
>  		   of playground for now. -AK */
>  		*begin = 0x40000000;
>  		*end = 0x80000000;
> -		if (current->flags & PF_RANDOMIZE) {
> -			new_begin = randomize_range(*begin, *begin + 0x02000000, 0);
> -			if (new_begin)
> -				*begin = new_begin;
> -		}
> +		if (current->flags & PF_RANDOMIZE)
> +			*begin += (get_random_int() & 0x01ffffff & PAGE_MASK);
>  	} else {
>  		*begin = TASK_UNMAPPED_BASE;
>  		*end = TASK_SIZE;
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index 72a4fcb..cea9ddc 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -1639,22 +1639,3 @@ unsigned int get_random_int(void)
>  
>  	return ret;
>  }
> -
> -/*
> - * randomize_range() returns a start address such that
> - *
> - *    [...... <range> .....]
> - *  start                  end
> - *
> - * a <range> with size "len" starting at the return value is inside in the
> - * area defined by [start, end], but is otherwise randomized.
> - */
> -unsigned long
> -randomize_range(unsigned long start, unsigned long end, unsigned long len)
> -{
> -	unsigned long range = end - len - start;
> -
> -	if (end <= start + len)
> -		return 0;
> -	return PAGE_ALIGN(get_random_int() % range + start);
> -}
> diff --git a/include/linux/random.h b/include/linux/random.h
> index fb7ab9d..0e17434 100644
> --- a/include/linux/random.h
> +++ b/include/linux/random.h
> @@ -73,7 +73,6 @@ extern const struct file_operations random_fops, urandom_fops;
>  #endif
>  
>  unsigned int get_random_int(void);
> -unsigned long randomize_range(unsigned long start, unsigned long end, unsigned long len);
>  
>  u32 random32(void);
>  void srandom32(u32 seed);


-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
