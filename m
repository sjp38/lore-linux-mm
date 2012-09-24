Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 5A7426B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 10:36:16 -0400 (EDT)
Date: Mon, 24 Sep 2012 16:36:09 +0200
From: Borislav Petkov <bp@amd64.org>
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
Message-ID: <20120924143609.GH22303@aftab.osrc.amd.com>
References: <20120924102324.GA22303@aftab.osrc.amd.com>
 <20120924142305.GD12264@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120924142305.GD12264@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Conny Seidel <conny.seidel@amd.com>

On Mon, Sep 24, 2012 at 04:23:05PM +0200, Jan Kara wrote:
>   fprop_fraction_percpu() does:
>         do {
>                 seq = read_seqcount_begin(&p->sequence);
>                 fprop_reflect_period_percpu(p, pl);
>                 num = percpu_counter_read_positive(&pl->events);
>                 den = percpu_counter_read_positive(&p->events);
>         } while (read_seqcount_retry(&p->sequence, seq));
> 
>         /*
>          * Make fraction <= 1 and denominator > 0 even in presence of
>          * percpu
>          * counter errors
>          */
>         if (den <= num) {
>                 if (num)
>                         den = num;
>                 else
>                         den = 1;
>         }
>         *denominator = den;
>         *numerator = num;
> 
>   So after initial loop, num and den are >= 0 because
> percpu_counter_read_positive() asserts that. If den == 0, then the
> condition is true and thus we always set den to value >= 1. So at least in
> the theoretical model of computation what you observe cannot happen :).
> 
>   Because of use of percpu_counter_read_positive() it also doesn't seem like
> some catch with sign extension (we always deal with non-negative numbers)
> and because you are on a 64-bit machine, s64 fits into long without.
> However, do_div() assumes divisor is 32-bit and we can indeed observe that
> in the disassembly where we prepare the divisor as:
>          mov     -32(%rbp), %edi # denominator, denominator
> (32-bit move insn used). I'm not quite sure if I read the stack in the dump
> correctly but -32(%rbp) seems to be 0x2000000000000000 which would fit what
> we see.

Ok yes, I see exactly what you're saying. And the normalization code
in fprop_fraction_percpu above doesn't catch the large denominator
(0x2000000000000000) den > num case.

[ a?| ]

Conny, would you test pls?

> From dd0947226a0d5868ba0c2b8808162898396035b7 Mon Sep 17 00:00:00 2001
> From: Jan Kara <jack@suse.cz>
> Date: Mon, 24 Sep 2012 16:17:16 +0200
> Subject: [PATCH] lib: Debug flex proportions code
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  lib/flex_proportions.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
> index c785554..f88f793 100644
> --- a/lib/flex_proportions.c
> +++ b/lib/flex_proportions.c
> @@ -62,11 +62,13 @@ void fprop_global_destroy(struct fprop_global *p)
>   */
>  bool fprop_new_period(struct fprop_global *p, int periods)
>  {
> -	u64 events;
> +	s64 events;
>  	unsigned long flags;
>  
>  	local_irq_save(flags);
>  	events = percpu_counter_sum(&p->events);
> +	if (events < 0)
> +		printk("Got negative events: %lld\n", (long long)events);
>  	/*
>  	 * Don't do anything if there are no events.
>  	 */
> -- 
> 1.7.1
> 


-- 
Regards/Gruss,
Boris.

Advanced Micro Devices GmbH
Einsteinring 24, 85609 Dornach
GM: Alberto Bozzo
Reg: Dornach, Landkreis Muenchen
HRB Nr. 43632 WEEE Registernr: 129 19551

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
