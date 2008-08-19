Date: Tue, 19 Aug 2008 12:05:30 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: unlockless reclaim
Message-ID: <20080819100529.GD10447@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de> <20080818122554.GB9062@wotan.suse.de> <20080819135424.60DA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080819135424.60DA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 02:09:07PM +0900, KOSAKI Motohiro wrote:
> > -		unlock_page(page);
> > +		/*
> > +		 * At this point, we have no other references and there is
> > +		 * no way to pick any more up (removed from LRU, removed
> > +		 * from pagecache). Can use non-atomic bitops now (and
> > +		 * we obviously don't have to worry about waking up a process
> > +		 * waiting on the page lock, because there are no references.
> > +		 */
> > +		__clear_page_locked(page);
> >  free_it:
> >  		nr_reclaimed++;
> >  		if (!pagevec_add(&freed_pvec, page)) {
> > 
> 
> To insert VM_BUG_ON(page_count(page) != 1) is better?
> Otherthing, looks good to me.

That is a very good idea, except that now with lockless pagecache, we're
not so well placed to do this type of check. Actually at this point,
the refcount will be 0 because of page_freeze_refs, and then if anybody
else tries to do a get_page, they should hit the VM_BUG_ON in get_page.

 
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks for looking at it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
