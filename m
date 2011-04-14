Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8846D900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 22:14:30 -0400 (EDT)
Received: by wwi36 with SMTP id 36so1242669wwi.26
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 19:14:27 -0700 (PDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1104131521050.25812@router.home>
References: <alpine.DEB.2.00.1104130942500.16214@router.home>
	 <alpine.DEB.2.00.1104131148070.20908@router.home>
	 <20110413185618.GA3987@mtj.dyndns.org>
	 <alpine.DEB.2.00.1104131521050.25812@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 Apr 2011 04:14:23 +0200
Message-ID: <1302747263.3549.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

Le mercredi 13 avril 2011 A  15:22 -0500, Christoph Lameter a A(C)crit :
> On Thu, 14 Apr 2011, Tejun Heo wrote:
> 
> > On Wed, Apr 13, 2011 at 11:49:51AM -0500, Christoph Lameter wrote:
> > > Duh the retry setup if the number overflows is not correct.
> > >
> > > Signed-off-by: Christoph Lameter <cl@linux.com>
> >
> > Can you please repost folded patch with proper [PATCH] subject line
> > and cc shaohua.li@intel.com so that he can resolve conflicts?
> >
> > Thanks.
> 
> Ok here it is:
> 
> 
> 
> 
> From: Christoph Lameter <cl@linux.com>
> Subject: [PATCH] percpu: preemptless __per_cpu_counter_add
> 
> Use this_cpu_cmpxchg to avoid preempt_disable/enable in __percpu_add.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  lib/percpu_counter.c |   27 +++++++++++++++------------
>  1 file changed, 15 insertions(+), 12 deletions(-)
> 
> Index: linux-2.6/lib/percpu_counter.c
> ===================================================================
> --- linux-2.6.orig/lib/percpu_counter.c	2011-04-13 09:26:19.000000000 -0500
> +++ linux-2.6/lib/percpu_counter.c	2011-04-13 09:36:37.000000000 -0500
> @@ -71,19 +71,22 @@ EXPORT_SYMBOL(percpu_counter_set);
> 
>  void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
>  {
> -	s64 count;
> +	s64 count, new;
> 
> -	preempt_disable();
> -	count = __this_cpu_read(*fbc->counters) + amount;
> -	if (count >= batch || count <= -batch) {
> -		spin_lock(&fbc->lock);
> -		fbc->count += count;
> -		__this_cpu_write(*fbc->counters, 0);
> -		spin_unlock(&fbc->lock);
> -	} else {
> -		__this_cpu_write(*fbc->counters, count);
> -	}
> -	preempt_enable();
> +	do {
> +		count = this_cpu_read(*fbc->counters);
> +
> +		new = count + amount;
> +		/* In case of overflow fold it into the global counter instead */
> +		if (new >= batch || new <= -batch) {
> +			spin_lock(&fbc->lock);
> +			fbc->count += __this_cpu_read(*fbc->counters) + amount;
> +			spin_unlock(&fbc->lock);
> +			amount = 0;
> +			new = 0;
> +		}
> +
> +	} while (this_cpu_cmpxchg(*fbc->counters, count, new) != count);
>  }
>  EXPORT_SYMBOL(__percpu_counter_add);
> 

Not sure its a win for my servers, where CONFIG_PREEMPT_NONE=y

Maybe use here latest cmpxchg16b stuff instead and get rid of spinlock ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
