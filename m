Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id AC8736B0044
	for <linux-mm@kvack.org>; Fri,  4 May 2012 08:05:06 -0400 (EDT)
Received: by qabg27 with SMTP id g27so1136130qab.14
        for <linux-mm@kvack.org>; Fri, 04 May 2012 05:05:05 -0700 (PDT)
Date: Fri, 4 May 2012 14:04:58 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v1 1/6] timer: make __next_timer_interrupt explicit about
 no future event
Message-ID: <20120504120455.GB4413@somewhere.redhat.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
 <1336056962-10465-2-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336056962-10465-2-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, linux-mm@kvack.org

On Thu, May 03, 2012 at 05:55:57PM +0300, Gilad Ben-Yossef wrote:
> Current timer code fails to correctly return a value meaning
> that there is no future timer event, with the result that
> the timer keeps getting re-armed in HZ one shot mode even
> when we could turn it off, generating unneeded interrupts.
> This patch attempts to fix this problem.
> 
> What is happening is that when __next_timer_interrupt() wishes
> to return a value that signifies "there is no future timer
> event", it returns (base->timer_jiffies + NEXT_TIMER_MAX_DELTA).
> 
> However, the code in tick_nohz_stop_sched_tick(), which called
> __next_timer_interrupt() via get_next_timer_interrupt(),
> compares the return value to (last_jiffies + NEXT_TIMER_MAX_DELTA)
> to see if the timer needs to be re-armed.
> 
> base->timer_jiffies != last_jiffies and so
> tick_nohz_stop_sched_tick() interperts the return value as
> indication that there is a distant future event 12 days
> from now and programs the timer to fire next after KIME_MAX
> nsecs instead of avoiding to arm it. This ends up causesing
> a needless interrupt once every KTIME_MAX nsecs.

Good catch! So if I understand correctly, base->timer_jiffies can
be backward compared to last_jiffies. If we return
base->timer_jiffies + NEXT_TIMER_MAX_DELTA, the next_jiffies - last_jiffies
diff gives a delta that is a bit before NEXT_TIMER_MAX_DELTA.

And this can indeed happen if we haven't got any timer list executed since
we updated jiffies last, timer_jiffies can be a backward compared to last_jiffies.

This is harmless but causes needless timers.

I just have small comment below:

> 
> I've noticed a similar but slightly different fix to the
> same problem in the Tilera kernel tree from Chris M. (I've
> wrote this before seeing that one), so some variation of this
> fix is in use on real hardware for some time now.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> CC: Thomas Gleixner <tglx@linutronix.de>
> CC: Tejun Heo <tj@kernel.org>
> CC: John Stultz <johnstul@us.ibm.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Mel Gorman <mel@csn.ul.ie>
> CC: Mike Frysinger <vapier@gentoo.org>
> CC: David Rientjes <rientjes@google.com>
> CC: Hugh Dickins <hughd@google.com>
> CC: Minchan Kim <minchan.kim@gmail.com>
> CC: Konstantin Khlebnikov <khlebnikov@openvz.org>
> CC: Christoph Lameter <cl@linux.com>
> CC: Chris Metcalf <cmetcalf@tilera.com>
> CC: Hakan Akkan <hakanakkan@gmail.com>
> CC: Max Krasnyansky <maxk@qualcomm.com>
> CC: Frederic Weisbecker <fweisbec@gmail.com>
> CC: linux-kernel@vger.kernel.org
> CC: linux-mm@kvack.org
> ---
>  kernel/timer.c |   31 +++++++++++++++++++++----------
>  1 files changed, 21 insertions(+), 10 deletions(-)
> 
> diff --git a/kernel/timer.c b/kernel/timer.c
> index a297ffc..32ba64a 100644
> --- a/kernel/timer.c
> +++ b/kernel/timer.c
> @@ -1187,11 +1187,13 @@ static inline void __run_timers(struct tvec_base *base)
>   * is used on S/390 to stop all activity when a CPU is idle.
>   * This function needs to be called with interrupts disabled.
>   */
> -static unsigned long __next_timer_interrupt(struct tvec_base *base)
> +static bool __next_timer_interrupt(struct tvec_base *base,
> +					unsigned long *next_timer)
>  {
>  	unsigned long timer_jiffies = base->timer_jiffies;
>  	unsigned long expires = timer_jiffies + NEXT_TIMER_MAX_DELTA;
> -	int index, slot, array, found = 0;
> +	int index, slot, array;
> +	bool found = false;
>  	struct timer_list *nte;
>  	struct tvec *varray[4];
>  
> @@ -1202,12 +1204,12 @@ static unsigned long __next_timer_interrupt(struct tvec_base *base)
>  			if (tbase_get_deferrable(nte->base))
>  				continue;
>  
> -			found = 1;
> +			found = true;
>  			expires = nte->expires;
>  			/* Look at the cascade bucket(s)? */
>  			if (!index || slot < index)
>  				goto cascade;
> -			return expires;
> +			goto out;
>  		}
>  		slot = (slot + 1) & TVR_MASK;
>  	} while (slot != index);
> @@ -1233,7 +1235,7 @@ cascade:
>  				if (tbase_get_deferrable(nte->base))
>  					continue;
>  
> -				found = 1;
> +				found = true;
>  				if (time_before(nte->expires, expires))
>  					expires = nte->expires;
>  			}
> @@ -1245,7 +1247,7 @@ cascade:
>  				/* Look at the cascade bucket(s)? */
>  				if (!index || slot < index)
>  					break;
> -				return expires;
> +				goto out;
>  			}
>  			slot = (slot + 1) & TVN_MASK;
>  		} while (slot != index);
> @@ -1254,7 +1256,10 @@ cascade:
>  			timer_jiffies += TVN_SIZE - index;
>  		timer_jiffies >>= TVN_BITS;
>  	}
> -	return expires;
> +out:
> +	if (found)
> +		*next_timer = expires;
> +	return found;
>  }
>  
>  /*
> @@ -1317,9 +1322,15 @@ unsigned long get_next_timer_interrupt(unsigned long now)
>  	if (cpu_is_offline(smp_processor_id()))
>  		return now + NEXT_TIMER_MAX_DELTA;
>  	spin_lock(&base->lock);
> -	if (time_before_eq(base->next_timer, base->timer_jiffies))
> -		base->next_timer = __next_timer_interrupt(base);
> -	expires = base->next_timer;
> +	if (time_before_eq(base->next_timer, base->timer_jiffies)) {
> +
> +		if (__next_timer_interrupt(base, &expires))
> +			base->next_timer = expires;
> +		else
> +			expires = now + NEXT_TIMER_MAX_DELTA;

I believe you can update base->next_timer to now + NEXT_TIMER_MAX_DELTA,
so on any further idle interrupt exit that call tick_nohz_stop_sched_tick(),
we won't get again the overhead of __next_timer_interrupt().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
