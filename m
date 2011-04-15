Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8D1900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:27:42 -0400 (EDT)
Received: by pwi10 with SMTP id 10so1732603pwi.14
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:27:39 -0700 (PDT)
Date: Sat, 16 Apr 2011 03:27:34 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110415182734.GB15916@mtj.dyndns.org>
References: <alpine.DEB.2.00.1104130942500.16214@router.home>
 <alpine.DEB.2.00.1104131148070.20908@router.home>
 <20110413185618.GA3987@mtj.dyndns.org>
 <alpine.DEB.2.00.1104131521050.25812@router.home>
 <1302747263.3549.9.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104141608300.19533@router.home>
 <20110414211522.GE21397@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151235350.8055@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104151235350.8055@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

Hello, Christoph.

>  void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
>  {
> -	s64 count;
> +	s64 count, new, overflow;
> 
> -	preempt_disable();
> -	count = __this_cpu_read(*fbc->counters) + amount;
> -	if (count >= batch || count <= -batch) {
> +	do {
> +		overflow = 0;
> +		count = this_cpu_read(*fbc->counters);
> +
> +		new = count + amount;
> +		/* In case of overflow fold it into the global counter instead */
> +		if (new >= batch || new <= -batch) {
> +			overflow = new;
> +			new = 0;
> +		}
> +#ifdef CONFIG_PREEMPT
> +	} while (this_cpu_cmpxchg(*fbc->counters, count, new) != count);
> +#else
> +	} while (0);
> +	this_cpu_write(*fbc->counters, new);
> +#endif

Eeeek, no.  If you want to do the above, please put it in a separate
inline function with sufficient comment.

> +	if (unlikely(overflow)) {
>  		spin_lock(&fbc->lock);
> -		fbc->count += count;
> -		__this_cpu_write(*fbc->counters, 0);
> +		fbc->count += overflow;
>  		spin_unlock(&fbc->lock);

Why put this outside and use yet another branch?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
