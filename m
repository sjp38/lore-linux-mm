In-reply-to: <1191577623.22357.69.camel@twins> (message from Peter Zijlstra on
	Fri, 05 Oct 2007 11:47:03 +0200)
Subject: Re: [PATCH] remove throttle_vm_writeout()
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	 <20071004145640.18ced770.akpm@linux-foundation.org>
	 <E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
	 <20071004160941.e0c0c7e5.akpm@linux-foundation.org>
	 <E1Ida56-0002Zz-00@dorka.pomaz.szeredi.hu>
	 <20071004164801.d8478727.akpm@linux-foundation.org>
	 <E1Idanu-0002c1-00@dorka.pomaz.szeredi.hu>
	 <20071004174851.b34a3220.akpm@linux-foundation.org>
	 <1191572520.22357.42.camel@twins>
	 <E1IdjOa-0002qg-00@dorka.pomaz.szeredi.hu> <1191577623.22357.69.camel@twins>
Message-Id: <E1IdkOf-0002tK-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 05 Oct 2007 12:27:05 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index 4ef4d22..eff2438 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -88,7 +88,7 @@ static inline void wait_on_inode(struct inode *inode)
>  int wakeup_pdflush(long nr_pages);
>  void laptop_io_completion(void);
>  void laptop_sync_completion(void);
> -void throttle_vm_writeout(gfp_t gfp_mask);
> +void throttle_vm_writeout(struct zone *zone, gfp_t gfp_mask);
>  
>  /* These are exported to sysctl. */
>  extern int dirty_background_ratio;
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index eec1481..f949997 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -326,11 +326,8 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
>  }
>  EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
>  
> -void throttle_vm_writeout(gfp_t gfp_mask)
> +void throttle_vm_writeout(struct zone *zone, gfp_t gfp_mask)
>  {
> -	long background_thresh;
> -	long dirty_thresh;
> -
>  	if ((gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO)) {
>  		/*
>  		 * The caller might hold locks which can prevent IO completion
> @@ -342,17 +339,16 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>  	}
>  
>          for ( ; ; ) {
> -		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
> +		unsigned long thresh = zone_page_state(zone, NR_ACTIVE) +
> +			zone_page_state(zone, NR_INACTIVE);
>  
> -                /*
> -                 * Boost the allowable dirty threshold a bit for page
> -                 * allocators so they don't get DoS'ed by heavy writers
> -                 */
> -                dirty_thresh += dirty_thresh / 10;      /* wheeee... */
> +		/*
> +		 * wait when 75% of the zone's pages are under writeback
> +		 */
> +		thresh -= thresh >> 2;
> +		if (zone_page_state(zone, NR_WRITEBACK) < thresh)
> +			break;
>  
> -                if (global_page_state(NR_UNSTABLE_NFS) +
> -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> -                        	break;
>                  congestion_wait(WRITE, HZ/10);
>          }
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1be5a63..7dd6bd9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -948,7 +948,7 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
>  		}
>  	}
>  
> -	throttle_vm_writeout(sc->gfp_mask);
> +	throttle_vm_writeout(zone, sc->gfp_mask);
>  
>  	atomic_dec(&zone->reclaim_in_progress);
>  	return nr_reclaimed;
> 
> 

I think that's an improvement in all respects.

However it still does not generally address the deadlock scenario: if
there's a small DMA zone, and fuse manages to put all of those pages
under writeout, then there's trouble.

But it's not really fuse specific.  If it was a normal filesystem that
did that, and it needed a GFP_DMA allocation for writeout, it is in
trouble also, as that allocation would fail (at least no deadlock).

Or is GFP_DMA never used by fs/io writeout paths?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
