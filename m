Subject: Re: [PATCH] mm: exempt pcp alloc from watermarks
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <45100028.90109@yahoo.com.au>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	 <20060914220011.2be9100a.akpm@osdl.org>
	 <20060914234926.9b58fd77.pj@sgi.com>
	 <20060915002325.bffe27d1.akpm@osdl.org>
	 <20060915012810.81d9b0e3.akpm@osdl.org>
	 <20060915203816.fd260a0b.pj@sgi.com>
	 <20060915214822.1c15c2cb.akpm@osdl.org>
	 <20060916043036.72d47c90.pj@sgi.com>
	 <20060916081846.e77c0f89.akpm@osdl.org>
	 <20060917022834.9d56468a.pj@sgi.com>	<450D1A94.7020100@yahoo.com.au>
	 <20060917041525.4ddbd6fa.pj@sgi.com>	<450D434B.4080702@yahoo.com.au>
	 <20060917061922.45695dcb.pj@sgi.com>  <450D5310.50004@yahoo.com.au>
	 <1158583495.23551.53.camel@twins>  <45100028.90109@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 19 Sep 2006 16:51:23 +0200
Message-Id: <1158677483.23551.59.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Jackson <pj@sgi.com>, akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2006-09-20 at 00:35 +1000, Nick Piggin wrote:
> Peter Zijlstra wrote:
> > On Sun, 2006-09-17 at 23:52 +1000, Nick Piggin wrote:
> > 
> > 
> >>What we could do then, is allocate pages in batches (we already do),
> >>but only check watermarks if we have to go to the buddly allocator
> >>(we don't currently do this, but really should anyway, considering
> >>that the watermark checks are based on pages in the buddy allocator
> >>rather than pages in buddy + pcp).
> > 
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> Hi Peter,
> 
> Thanks for the patch! I have a slight preference for the following
> version, which speculatively tests pcp->count without disabling
> interrupts (the chance of being preempted or scheduled in this
> window is basically the same as the chance of being preempted after
> checking watermarks). What do you think?

The race here allows to wrongly bypass the watermark check. My version
raced the other way about, where you could find a non empty pcp where an
empty one was otherwise expected.

OTOH it is much shorter, I'll see if I can shorten mine and keep the
race safe (and perhaps do what Christoph suggests).

> plain text document attachment (mm-pcp-bypass-wmark.patch)
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c	2006-09-20 00:06:46.000000000 +1000
> +++ linux-2.6/mm/page_alloc.c	2006-09-20 00:20:28.000000000 +1000
> @@ -880,6 +880,16 @@ get_page_from_freelist(gfp_t gfp_mask, u
>  				!cpuset_zone_allowed(*z, gfp_mask))
>  			continue;
>  
> +		if (likely(order == 0)) {
> +			int cold = !!(gfp_mask & __GFP_COLD);
> +			int cpu  = raw_smp_processor_id();
> +			struct per_cpu_pages *pcp;
> +
> +			pcp = &zone_pcp(*z, cpu)->pcp[cold];
> +			if (likely(pcp->count))
> +				goto skip_watermarks;
> +		}
> +
>  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
>  			unsigned long mark;
>  			if (alloc_flags & ALLOC_WMARK_MIN)
> @@ -889,16 +899,17 @@ get_page_from_freelist(gfp_t gfp_mask, u
>  			else
>  				mark = (*z)->pages_high;
>  			if (!zone_watermark_ok(*z, order, mark,
> -				    classzone_idx, alloc_flags))
> +				    classzone_idx, alloc_flags)) {
>  				if (!zone_reclaim_mode ||
>  				    !zone_reclaim(*z, gfp_mask, order))
>  					continue;
> +			}
>  		}
>  
> +skip_watermarks:
>  		page = buffered_rmqueue(zonelist, *z, order, gfp_mask);
> -		if (page) {
> +		if (page)
>  			break;
> -		}
>  	} while (*(++z) != NULL);
>  	return page;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
