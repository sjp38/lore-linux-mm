Subject: Re: [RFC][PATCH] mm: balance_dirty_pages() vs
	throttle_vm_writeout() deadlock
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070221160757.2183d23f.akpm@linux-foundation.org>
References: <1171986565.23046.5.camel@twins>
	 <20070221160757.2183d23f.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 26 Feb 2007 14:43:58 +0100
Message-Id: <1172497438.6374.53.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-02-21 at 16:07 -0800, Andrew Morton wrote:
> On Tue, 20 Feb 2007 16:49:24 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > 
> > If we have a lot of dirty memory and hit the throttle in balance_dirty_pages()
> > we (potentially) generate a lot of writeback and unstable pages, if however
> > during this writeback we need to reclaim a bit, we might hit
> > throttle_vm_writeout(), which might delay us until the combined total of
> > NR_UNSTABLE_NFS + NR_WRITEBACK falls below the dirty limit.
> > 
> > However unstable pages don't go away automagickally, they need a push. While
> > balance_dirty_pages() does this push, throttle_vm_writeout() doesn't. So we can
> > sit here ad infintum.
> > 
> > Hence I propose to remove the NR_UNSTABLE_NFS count from throttle_vm_writeout().
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> >  mm/page-writeback.c |    3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > Index: linux-2.6-git/mm/page-writeback.c
> > ===================================================================
> > --- linux-2.6-git.orig/mm/page-writeback.c	2007-02-20 15:07:43.000000000 +0100
> > +++ linux-2.6-git/mm/page-writeback.c	2007-02-20 16:42:45.000000000 +0100
> > @@ -310,8 +310,7 @@ void throttle_vm_writeout(void)
> >                   */
> >                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
> >  
> > -                if (global_page_state(NR_UNSTABLE_NFS) +
> > -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> > +                if (global_page_state(NR_WRITEBACK) <= dirty_thresh)
> >                          	break;
> >                  congestion_wait(WRITE, HZ/10);
> >          }
> 
> I think we need the below.  It is to address a deadlock which usb-storage
> triggered doing a GFP_NOIO allocation, but I suspect it'll fix NFS too?
> 

The deadlock seems to be elusive, I'll continue testing...

> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> throttle_vm_writeout() is designed to wait for the dirty levels to subside. 
> But if the caller holds IO or FS locks, we might be holding up that writeout.
> 
> So change it to take a single nap to give other devices a chance to clean some
> memory, then return.
> 
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>
> Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> Cc: Pete Zaitcev <zaitcev@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/writeback.h |    2 +-
>  mm/page-writeback.c       |   13 +++++++++++--
>  mm/vmscan.c               |    2 +-
>  3 files changed, 13 insertions(+), 4 deletions(-)
> 
> diff -puN mm/vmscan.c~throttle_vm_writeout-dont-loop-on-gfp_nofs-and-gfp_noio-allocations mm/vmscan.c
> --- a/mm/vmscan.c~throttle_vm_writeout-dont-loop-on-gfp_nofs-and-gfp_noio-allocations
> +++ a/mm/vmscan.c
> @@ -952,7 +952,7 @@ static unsigned long shrink_zone(int pri
>  		}
>  	}
>  
> -	throttle_vm_writeout();
> +	throttle_vm_writeout(sc->gfp_mask);
>  
>  	atomic_dec(&zone->reclaim_in_progress);
>  	return nr_reclaimed;
> diff -puN mm/page-writeback.c~throttle_vm_writeout-dont-loop-on-gfp_nofs-and-gfp_noio-allocations mm/page-writeback.c
> --- a/mm/page-writeback.c~throttle_vm_writeout-dont-loop-on-gfp_nofs-and-gfp_noio-allocations
> +++ a/mm/page-writeback.c
> @@ -296,11 +296,21 @@ void balance_dirty_pages_ratelimited_nr(
>  }
>  EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
>  
> -void throttle_vm_writeout(void)
> +void throttle_vm_writeout(gfp_t gfp_mask)
>  {
>  	long background_thresh;
>  	long dirty_thresh;
>  
> +	if ((gfp_mask & (__GFP_FS|__GFP_IO)) != ) {
> +		/*
> +		 * The caller might hold locks which can prevent IO completion
> +		 * or progress in the filesystem.  So we cannot just sit here
> +		 * waiting for IO to complete.
> +		 */
> +		congestion_wait(WRITE, HZ/10);
> +		return;
> +	}
> +
>          for ( ; ; ) {
>  		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
>  
> @@ -317,7 +327,6 @@ void throttle_vm_writeout(void)
>          }
>  }
>  
> -
>  /*
>   * writeback at least _min_pages, and keep writing until the amount of dirty
>   * memory is less than the background threshold, or until we're all clean.
> diff -puN include/linux/writeback.h~throttle_vm_writeout-dont-loop-on-gfp_nofs-and-gfp_noio-allocations include/linux/writeback.h
> --- a/include/linux/writeback.h~throttle_vm_writeout-dont-loop-on-gfp_nofs-and-gfp_noio-allocations
> +++ a/include/linux/writeback.h
> @@ -84,7 +84,7 @@ static inline void wait_on_inode(struct 
>  int wakeup_pdflush(long nr_pages);
>  void laptop_io_completion(void);
>  void laptop_sync_completion(void);
> -void throttle_vm_writeout(void);
> +void throttle_vm_writeout(gfp_t gfp_mask);
>  
>  /* These are exported to sysctl. */
>  extern int dirty_background_ratio;
> _


Hmm, fun :-)

It might, but I'm afraid that the NFS writeout path includes a
GFP_ATOMIC allocation, in which case this would not suffice. I'll trace
the paths again to make sure.

(To be more specific, in patch 28/29 in the swap over NFS series the
net/sunrpc/sched.c::rpc_malloc() bit)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
