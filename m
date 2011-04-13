Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC1E1900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:50:31 -0400 (EDT)
Received: by qyk2 with SMTP id 2so3521990qyk.14
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:50:29 -0700 (PDT)
Date: Thu, 14 Apr 2011 06:50:22 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110413215022.GI3987@mtj.dyndns.org>
References: <alpine.DEB.2.00.1104130942500.16214@router.home>
 <alpine.DEB.2.00.1104131148070.20908@router.home>
 <20110413185618.GA3987@mtj.dyndns.org>
 <alpine.DEB.2.00.1104131521050.25812@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104131521050.25812@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, eric.dumazet@gmail.com, shaohua.li@intel.com

Hello,

On Wed, Apr 13, 2011 at 03:22:36PM -0500, Christoph Lameter wrote:
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

Is this correct?  If the percpu count changes in the middle, doesn't
the count get added twice?  Can you please use the cmpxchg() only in
the fast path?  ie.

	do {
		count = this_cpu_read();
		if (overflow) {
			disable preemption and do the slow thing.
			return;
		}
	} while (this_cpu_cmpxchg());

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
