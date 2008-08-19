Date: Tue, 19 Aug 2008 19:20:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: unlockless reclaim
In-Reply-To: <20080819100529.GD10447@wotan.suse.de>
References: <20080819135424.60DA.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080819100529.GD10447@wotan.suse.de>
Message-Id: <20080819191820.12BF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Tue, Aug 19, 2008 at 02:09:07PM +0900, KOSAKI Motohiro wrote:
> > > -		unlock_page(page);
> > > +		/*
> > > +		 * At this point, we have no other references and there is
> > > +		 * no way to pick any more up (removed from LRU, removed
> > > +		 * from pagecache). Can use non-atomic bitops now (and
> > > +		 * we obviously don't have to worry about waking up a process
> > > +		 * waiting on the page lock, because there are no references.
> > > +		 */
> > > +		__clear_page_locked(page);
> > >  free_it:
> > >  		nr_reclaimed++;
> > >  		if (!pagevec_add(&freed_pvec, page)) {
> > > 
> > 
> > To insert VM_BUG_ON(page_count(page) != 1) is better?
> > Otherthing, looks good to me.
> 
> That is a very good idea, except that now with lockless pagecache, we're
> not so well placed to do this type of check. Actually at this point,
> the refcount will be 0 because of page_freeze_refs, and then if anybody
> else tries to do a get_page, they should hit the VM_BUG_ON in get_page.

Ah, you are right.
Sorry, I often forgot it ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
