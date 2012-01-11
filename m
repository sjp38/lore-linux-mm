Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id B638C6B005A
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 17:33:55 -0500 (EST)
Received: by ggnp4 with SMTP id p4so825917ggn.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:33:54 -0800 (PST)
Date: Wed, 11 Jan 2012 14:33:34 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: vmscan: deactivate isolated pages with lru lock
 released
In-Reply-To: <CAJd=RBAiAfyXBcn+9WO6AERthyx+C=cNP-romp9YJO3Hn7-U-g@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1201111351080.1846@eggly.anvils>
References: <CAJd=RBAiAfyXBcn+9WO6AERthyx+C=cNP-romp9YJO3Hn7-U-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 11 Jan 2012, Hillf Danton wrote:

> Spinners on other CPUs, if any, could take the lru lock and do their jobs while
> isolated pages are deactivated on the current CPU if the lock is released
> actively. And no risk of race raised as pages are already queued on locally
> private list.

You make a good point - except, I'm afraid as usual, I have difficulty
in understanding your comment, in separating how it is before your change
and how it is after your change.  Above you're describing how it is after
your change; and it would help if you point out that you're taking the
lock off clear_active_flags(), which goes all the way down the list of
pages we isolated (to a locally private list, yes, important point).

However... this patch is based on Linus's current, and will clash with a
patch of mine presently in akpm's tree - which I'm expecting will go on
to Linus soon, unless Andrew discards it in favour of yours (that might
involve a little unravelling, I didn't look).  Among other rearrangements,
I merged the code from clear_active_flags() into update_isolated_counts().

And something that worries me is that you're now dropping the spinlock
and reacquiring it shortly afterwards, just clear_active_flags in between.
That may bounce the lock around more than before, and actually prove worse.

I suspect that your patch can be improved, to take away that worry.
Why do we need to take the lock again?  Only to update reclaim_stat:
for the other stats, interrupts disabled is certainly good enough,
and more research might show that preemption disabled would be enough.

get_scan_count() is called at the (re)start of shrink_mem_cgroup_zone(),
before it goes down to do shrink_list()s: I think it would not be harmed
at all if we delayed updating reclaim_stat->recent_scanned until the
next time we take the lock, lower down.

Other things that strike me, looking here again: isn't it the case that
update_isolated_counts() is actually called either for file or for anon,
but never for both?  We might be able to make savings from that, perhaps
enlist help from isolate_lru_pages() to avoid having to go down the list
again to clear active flags.

I certainly do have more changes to make around here, in changing the
locking over to be per-memcg (and the locking on reclaim_stat is something
I have not got quite right yet): but if you've a good patch to reduce the
locking, I should rebase on top of yours.

Hugh

> 
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
> +++ b/mm/vmscan.c	Wed Jan 11 20:40:40 2012
> @@ -1464,6 +1464,7 @@ update_isolated_counts(struct mem_cgroup
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
> 
>  	nr_active = clear_active_flags(isolated_list, count);
> +	spin_lock_irq(&zone->lru_lock);
>  	__count_vm_events(PGDEACTIVATE, nr_active);
> 
>  	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
> @@ -1482,6 +1483,7 @@ update_isolated_counts(struct mem_cgroup
> 
>  	reclaim_stat->recent_scanned[0] += *nr_anon;
>  	reclaim_stat->recent_scanned[1] += *nr_file;
> +	spin_unlock_irq(&zone->lru_lock);
>  }
> 
>  /*
> @@ -1577,15 +1579,13 @@ shrink_inactive_list(unsigned long nr_to
>  			__count_zone_vm_events(PGSCAN_DIRECT, zone,
>  					       nr_scanned);
>  	}
> +	spin_unlock_irq(&zone->lru_lock);
> 
> -	if (nr_taken == 0) {
> -		spin_unlock_irq(&zone->lru_lock);
> +	if (nr_taken == 0)
>  		return 0;
> -	}
> 
>  	update_isolated_counts(mz, sc, &nr_anon, &nr_file, &page_list);
> 
> -	spin_unlock_irq(&zone->lru_lock);
> 
>  	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
>  						&nr_dirty, &nr_writeback);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
