Subject: Re: [patch 12/21] No Reclaim LRU Infrastructure
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080304192441.1EA2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080228192908.126720629@redhat.com>
	 <20080228192929.031646681@redhat.com>
	 <20080304192441.1EA2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 04 Mar 2008 10:05:58 -0500
Message-Id: <1204643158.5338.5.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-03-04 at 19:46 +0900, KOSAKI Motohiro wrote:
> Hi
> 
> sorry for late review.
> 
> > 
> > Index: linux-2.6.25-rc2-mm1/mm/Kconfig
> > ===================================================================
> > --- linux-2.6.25-rc2-mm1.orig/mm/Kconfig	2008-02-19 16:23:09.000000000 -0500
> > +++ linux-2.6.25-rc2-mm1/mm/Kconfig	2008-02-28 11:05:04.000000000 -0500
> > @@ -193,3 +193,13 @@ config NR_QUICK
> >  config VIRT_TO_BUS
> >  	def_bool y
> >  	depends on !ARCH_NO_VIRT_TO_BUS
> > +
> > +config NORECLAIM
> > +	bool "Track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"
> > +	depends on EXPERIMENTAL && 64BIT
> 
> as far as I remembered, somebody said CONFIG_NORECLAIM is easy confusable.
> may be..
> 
> IMHO insert "lru" word is better.
> example,
> 
> config NORECLAIM_LRU
> 	bool "Zone LRU of track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"
> 	depends on EXPERIMENTAL && 64BIT

OK.  But, I'd suggest the 'bool' description be something like:

config NORECLAIM_LRU
	bool "Add LRU list to track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"

> 
> 
> > @@ -356,8 +380,10 @@ void release_pages(struct page **pages, 
> >  				zone = pagezone;
> >  				spin_lock_irqsave(&zone->lru_lock, flags);
> >  			}
> > -			VM_BUG_ON(!PageLRU(page));
> > -			__ClearPageLRU(page);
> > +			is_lru_page = PageLRU(page);
> > +			VM_BUG_ON(!(is_lru_page));
> > +			if (is_lru_page)
> > +				__ClearPageLRU(page);
> >  			del_page_from_lru(zone, page);
> >  		}
> 
> it seems unnecessary change??

Hmmm.  Not sure what I was thinking here.  Might be a relic of some
previous debug instrumentation.  Guess I don't have any problem with
removing this change.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
