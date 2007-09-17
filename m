Subject: Re: [PATCH/RFC 3/14] Reclaim Scalability:  move isolate_lru_page()
	to vmscan.c
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46EE46C6.1050607@linux.vnet.ibm.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205418.6536.5921.sendpatchset@localhost>
	 <46EE46C6.1050607@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 15:19:35 -0400
Message-Id: <1190056776.5460.120.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-17 at 14:50 +0530, Balbir Singh wrote:
> Lee Schermerhorn wrote:
> > +int isolate_lru_page(struct page *page)
> > +{
> > +	int ret = -EBUSY;
> > +
> > +	if (PageLRU(page)) {
> > +		struct zone *zone = page_zone(page);
> > +
> > +		spin_lock_irq(&zone->lru_lock);
> > +		if (PageLRU(page)) {
> > +			ret = 0;
> > +			ClearPageLRU(page);
> > +			if (PageActive(page))
> > +				del_page_from_active_list(zone, page);
> > +			else
> > +				del_page_from_inactive_list(zone, page);
> > +		}
> 
> Wouldn't using a pagelist as an argument and moving to that be easier?
> Are there any cases where we just remove from the list and not move it
> elsewhere?

Actually, isolate_lru_page() used to do that, and Nick removed that
aspect for use with the mlock patches--so as not to have to use a dummy
list for single pages in the mlock code.  Nick's way is probably OK
performance-wise for the current usage in migration and mlock code.
Might need to rethink this if this function gets wider usage, now that
it's globally visible.

> 
> > +		spin_unlock_irq(&zone->lru_lock);
> > +	}
> > +	return ret;
> > +}
> > +
> 
> Any chance we could merge __isolate_lru_page() and isolate_lru_page()?

I wondered about this in one of the patch descriptions.  Peter Z
proposed a wrapper around __isolate_lru_pages() to do this.  The other
changes that I made to __isolate_lru_pages complicate this a bit, but I
think it could be managable.  Note that isolate_lru_page() is called
with the zone lru_lock unlocked and it updates the list stats.
__isolate_lru_page is called from a batch *isolate_lru_pages*() function
and does not update the stats.  The wrapper can handle these extra
tasks, I think--efficiently, I hope.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
