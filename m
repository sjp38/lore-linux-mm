Date: Tue, 6 Nov 2007 21:48:04 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 2/10] free swap space entries if vm_swap_full()
Message-ID: <20071106214804.3c6e4dee@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0711061818360.5249@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
	<20071103185447.358b9c4a@bree.surriel.com>
	<Pine.LNX.4.64.0711061818360.5249@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007 18:20:44 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Sat, 3 Nov 2007, Rik van Riel wrote:
> 
> > @@ -1142,14 +1145,13 @@ force_reclaim_mapped:
> >  		}
> >  	}
> >  	__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
> > +	spin_unlock_irq(&zone->lru_lock);
> >  	pgdeactivate += pgmoved;
> > -	if (buffer_heads_over_limit) {
> > -		spin_unlock_irq(&zone->lru_lock);
> > -		pagevec_strip(&pvec);
> > -		spin_lock_irq(&zone->lru_lock);
> > -	}
> >  
> > +	if (buffer_heads_over_limit)
> > +		pagevec_strip(&pvec);
> >  	pgmoved = 0;
> > +	spin_lock_irq(&zone->lru_lock);
> >  	while (!list_empty(&l_active)) {
> >  		page = lru_to_page(&l_active);
> >  		prefetchw_prev_lru_page(page, &l_active, flags);
> 
> Why are we dropping the lock here now? There would be less activity
> on the lru_lock if we would only drop it if necessary.

Fixed, thank you.

This will be in the next split VM series, later this week.

> > @@ -1163,6 +1165,8 @@ force_reclaim_mapped:
> >  			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
> >  			pgmoved = 0;
> >  			spin_unlock_irq(&zone->lru_lock);
> > +			if (vm_swap_full())
> > +				pagevec_swap_free(&pvec);
> >  			__pagevec_release(&pvec);
> >  			spin_lock_irq(&zone->lru_lock);
> >  		}
> 
> Same here. Maybe the spin_unlock and the spin_lock can go into
> pagevec_swap_free?

We need to unlock the zone->lru_lock across the
__pagevec_release(), which is why the unlock/lock
sequence was already there in the original code.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
