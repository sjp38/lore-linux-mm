Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0817C8D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 12:37:58 -0400 (EDT)
Date: Mon, 21 Mar 2011 16:37:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110321163742.GA24244@csn.ul.ie>
References: <20110316150208.7407c375.akpm@linux-foundation.org>
 <4D827CC1.4090807@fiec.espol.edu.ec>
 <20110317144727.87a461f9.akpm@linux-foundation.org>
 <20110318111300.GF707@csn.ul.ie>
 <4D839EDB.9080703@fiec.espol.edu.ec>
 <20110319134628.GG707@csn.ul.ie>
 <4D84D3F2.4010200@fiec.espol.edu.ec>
 <20110319235144.GG10696@random.random>
 <20110321094149.GH707@csn.ul.ie>
 <20110321134832.GC5719@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110321134832.GC5719@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alex Villac??s Lasso <avillaci@fiec.espol.edu.ec>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Mon, Mar 21, 2011 at 02:48:32PM +0100, Andrea Arcangeli wrote:
> On Mon, Mar 21, 2011 at 09:41:49AM +0000, Mel Gorman wrote:
> > The check is at the wrong level I believe because it misses NFS pages which
> > will still get queued for IO which can block waiting on a request to complete.
> 
> But for example ->migratepage won't block at all for swapcache... it's
> just a pointer for migrate_page... so I didnt' want to skip what could
> be nonblocking, it just makes migrate less reliable for no good in
> some case. The fallback case is very likely blocking instead so I only
> returned -EBUSY there.
> 

Fair point.

> Best would be to pass a sync/nonblock param to migratepage(nonblock)
> so that nfs_migrate_page can pass "nonblock" instead of "false" to
> nfs_find_and_lock_request.
> 

I had considered this but thought passing in sync to things like
migrate_page() that ignored it looked a little ugly.

> > sync should be bool.
> 
> That's better thanks.
> 
> > It's overkill to return EBUSY just because we failed to get a lock which could
> > be released very quickly. If we left rc as -EAGAIN it would retry again.
> > The worst case scenario is that the current process is the holder of the
> > lock and the loop is pointless but this is a relatively rare situation
> > (other than Hugh's loopback test aside which seems to be particularly good
> > at triggering that situation).
> 
> This change was only meant to possibly avoid some cpu waste in the
> tight loop, not really "blocking" related so I'm sure ok to drop it
> for now. The page lock holder better to be quick because with sync=0
> the tight loop will retry real fast. If the holder blocks we're not so
> smart at retrying in a tight loop but for now it's ok.
> 

Ok.

> > >  			goto move_newpage;
> > >  
> > > @@ -686,7 +695,11 @@ static int unmap_and_move(new_page_t get
> > >  	BUG_ON(charge);
> > >  
> > >  	if (PageWriteback(page)) {
> > > -		if (!force || !sync)
> > > +		if (!sync) {
> > > +			rc = -EBUSY;
> > > +			goto uncharge;
> > > +		}
> > > +		if (!force)
> > >  			goto uncharge;
> > 
> > Where as this is ok because if the page is being written back, it's fairly
> > unlikely it'll get cleared quickly enough for the retry loop to make sense.
> 
> Agreed.
> 
> > Because of the NFS pages and being a bit aggressive about using -EBUSY,
> > how about the following instead? (build tested only unfortunately)
> 
> I tested my version below but I think one needs udf with lots of dirty
> pages plus the usb to trigger this which I don't have setup
> immediately.
> 
> > @@ -586,18 +586,23 @@ static int move_to_new_page(struct page *newpage, struct page *page,
> >  	mapping = page_mapping(page);
> >  	if (!mapping)
> >  		rc = migrate_page(mapping, newpage, page);
> > -	else if (mapping->a_ops->migratepage)
> > -		/*
> > -		 * Most pages have a mapping and most filesystems
> > -		 * should provide a migration function. Anonymous
> > -		 * pages are part of swap space which also has its
> > -		 * own migration function. This is the most common
> > -		 * path for page migration.
> > -		 */
> > -		rc = mapping->a_ops->migratepage(mapping,
> > -						newpage, page);
> > -	else
> > -		rc = fallback_migrate_page(mapping, newpage, page);
> > +	else {
> > +		/* Do not writeback pages if !sync */
> > +		if (PageDirty(page) && !sync)
> > +			rc = -EBUSY;
> 
> I think it's better to at least change it to:
> 
> if (PageDirty(page) && !sync && mapping->a_ops->migratepage != migrate_page))
> 
> I wasn't sure how to handle noblocking ->migratepage for swapcache and
> tmpfs but probably the above check is a good enough approximation.
> 

It's a good enough approximation. It's a little ugly but I don't think
it's much uglier than passing in unused parameters to migrate_page().

> Before sending my patch I thought of adding a "sync" parameter to
> ->migratepage(..., sync/nonblock) but then the patch become
> bigger... and I just wanted to know if this was the problem or not so
> I deferred it.
> 

I deferred it for similar reasons. It was becoming a much larger change
than should be necessary for the fix.

> If we're sure that all migratepage blocks except for things like
> swapcache/tmpfs or other not-filebacked things that defines it to
> migrate_page, we're pretty well covered by adding a check like above
> migratepage == migrate_page and maybe we don't need to add a
> "sync/nonblock" parameter to ->migratepage(). For example the
> buffer_migrate_page can block too in lock_buffer.
> 

Agreed.

> This is the patch I'm trying with the addition of the above check and
> some comment space/tab issue cleanup.
> 

Nothing bad jumped out at me. Lets see how it gets on with testing.

Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
