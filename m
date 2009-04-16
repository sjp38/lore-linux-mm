Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D40C05F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 22:03:35 -0400 (EDT)
Date: Thu, 16 Apr 2009 04:03:34 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
Message-ID: <20090416020334.GA22216@wotan.suse.de>
References: <20090414071152.GC23528@wotan.suse.de> <20090415082507.GA23674@wotan.suse.de> <20090415183847.d4fa1efb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090415183847.d4fa1efb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sage Weil <sage@newdream.net>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 15, 2009 at 06:38:47PM -0700, Andrew Morton wrote:
> On Wed, 15 Apr 2009 10:25:07 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > so filesystems can avoid LOR conditions with page lock.
> 
> All right, I give up.  What's LOR?

Lock order reversal.

 
> > - Sage needs this race closed for ceph filesystem.
> > - Trond for NFS (http://bugzilla.kernel.org/show_bug.cgi?id=12913).
> 
> I wonder which kernel version(s) we should put this in.
> 
> Going BUG isn't nice, but that report is against 2.6.27.  Is the BUG
> super-rare, or did we avoid it via other means, or what?

Trond?


> > @@ -2105,16 +2116,31 @@ unlock:
> >  		 *
> >  		 * do_no_page is protected similarly.
> >  		 */
> > -		wait_on_page_locked(dirty_page);
> > -		set_page_dirty_balance(dirty_page, page_mkwrite);
> > +		if (!page_mkwrite) {
> > +			wait_on_page_locked(dirty_page);
> > +			set_page_dirty_balance(dirty_page, page_mkwrite);
> > +		}
> >  		put_page(dirty_page);
> > +		if (page_mkwrite) {
> > +			struct address_space *mapping = dirty_page->mapping;
> > +
> > +			set_page_dirty(dirty_page);
> > +			unlock_page(dirty_page);
> > +			page_cache_release(dirty_page);
> > +			balance_dirty_pages_ratelimited(mapping);
> 
> hm.  I wonder what prevents (prevented) *mapping from vanishing under
> our feet here.

down_read on mmap_sem should be keeping it pinned.

 
> > +	if (dirty_page) {
> > +		struct address_space *mapping = page->mapping;
> > +
> >  		if (vma->vm_file)
> >  			file_update_time(vma->vm_file);
> >  
> > -		set_page_dirty_balance(dirty_page, page_mkwrite);
> > +		if (set_page_dirty(dirty_page))
> > +			page_mkwrite = 1;
> > +		unlock_page(dirty_page);
> >  		put_page(dirty_page);
> > +		if (page_mkwrite)
> > +			balance_dirty_pages_ratelimited(mapping);
> > +	} else {
> > +		unlock_page(vmf.page);
> > +		if (anon)
> > +			page_cache_release(vmf.page);
> >  	}
> >  
> >  	return ret;
> > +
> > +unwritable_page:
> > +	page_cache_release(page);
> > +	return ret;
> >  }
> 
> Whoa.  Running file_update_time() under lock_page() opens a whole can
> of worms, doesn't it?  That thing can do journal commits and all sorts
> of stuff.  And I don't think this ordering is necessary here?
 
Oh good catch. Yes I think we can just move that out to after the
put_page no problem.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
