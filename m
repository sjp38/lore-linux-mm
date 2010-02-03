Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C06226B0088
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 15:09:07 -0500 (EST)
Subject: Re: [RFC][PATCH] vmscan: balance local_irq_disable() and
 local_irq_enable()
From: Steven Rostedt <rostedt@goodmis.org>
Reply-To: rostedt@goodmis.org
In-Reply-To: <1265226801-6199-2-git-send-email-jkacur@redhat.com>
References: <1265226801-6199-1-git-send-email-jkacur@redhat.com>
	 <1265226801-6199-2-git-send-email-jkacur@redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Wed, 03 Feb 2010 15:09:06 -0500
Message-ID: <1265227746.24386.15.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: John Kacur <jkacur@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

t On Wed, 2010-02-03 at 20:53 +0100, John Kacur wrote:
> Balance local_irq_disable() and local_irq_enable() as well as
> spin_lock_irq() and spin_lock_unlock_irq
> 
> Signed-off-by: John Kacur <jkacur@redhat.com>
> ---
>  mm/vmscan.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c26986c..b895025 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1200,8 +1200,9 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
>  		if (current_is_kswapd())
>  			__count_vm_events(KSWAPD_STEAL, nr_freed);
>  		__count_zone_vm_events(PGSTEAL, zone, nr_freed);
> +		local_irq_enable();
>  
> -		spin_lock(&zone->lru_lock);
> +		spin_lock_irq(&zone->lru_lock);
>  		/*
>  		 * Put back any unfreeable pages.
>  		 */


The above looks wrong. I don't know the code, but just by looking at
where the locking and interrupts are, I can take a guess.

Lets add a little more of the code:

                local_irq_disable();
                if (current_is_kswapd())
                        __count_vm_events(KSWAPD_STEAL, nr_freed);
                __count_zone_vm_events(PGSTEAL, zone, nr_freed);

                spin_lock(&zone->lru_lock);
                /*

I'm guessing the __count_zone_vm_events and friends need interrupts
disabled here, probably due to per cpu stuff. But if you enable
interrupts before the spin_lock() you may let an interrupt come in and
invalidate what was done above it.

So no, I do not think enabling interrupts here is a good thing.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
