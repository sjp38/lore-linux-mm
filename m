Date: Thu, 10 Jan 2008 11:28:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-Id: <20080110112849.d54721ac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080108210002.638347207@redhat.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 08 Jan 2008 15:59:44 -0500
Rik van Riel <riel@redhat.com> wrote:

> +	rotate_sum = zone->recent_rotated_file + zone->recent_rotated_anon;
> +
> +	/* Keep a floating average of RECENT references. */
> +	if (unlikely(rotate_sum > min(anon, file))) {
> +		spin_lock_irq(&zone->lru_lock);
> +		zone->recent_rotated_file /= 2;
> +		zone->recent_rotated_anon /= 2;
> +		spin_unlock_irq(&zone->lru_lock);
> +		rotate_sum /= 2;
> +	}
> +
> +	/*
> +	 * With swappiness at 100, anonymous and file have the same priority.
> +	 * This scanning priority is essentially the inverse of IO cost.
> +	 */
> +	anon_prio = sc->swappiness;
> +	file_prio = 200 - sc->swappiness;
> +
> +	/*
> +	 *                  anon       recent_rotated_anon
> +	 * %anon = 100 * ----------- / ------------------- * IO cost
> +	 *               anon + file       rotate_sum
> +	 */
> +	ap = (anon_prio * anon) / (anon + file + 1);
> +	ap *= rotate_sum / (zone->recent_rotated_anon + 1);
> +	if (ap == 0)
> +		ap = 1;
> +	else if (ap > 100)
> +		ap = 100;
> +	percent[0] = ap;
> +

Hmm, it seems..

When a program copies large amount of files, recent_rotated_file increases
rapidly and 

    rotate_sum
    ----------
recent_rotated_anon

will be very big.

And %ap will be big regardless of vm_swappiness  if it's not 0.

I think # of recent_successful_pageout(anon/file) should be took into account...

I'm sorry if I miss something.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
