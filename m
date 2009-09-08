Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC5506B0085
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:41:32 -0400 (EDT)
Date: Tue, 8 Sep 2009 17:41:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Message-ID: <20090908154132.GC29902@wotan.suse.de>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org> <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> <20090424104137.GA7601@sgi.com> <E1LxMlO-0000sU-1J@pomaz-ex.szeredi.hu> <1240592448.4946.35.camel@heimdal.trondhjem.org> <20090425051028.GC10088@wotan.suse.de> <20090908153007.GB2513@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090908153007.GB2513@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Miklos Szeredi <miklos@szeredi.hu>, holt@sgi.com, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 08, 2009 at 11:30:07AM -0400, Chris Mason wrote:
> > > As I said, I think I can fix the NFS problem by simply unmapping the
> > > page inside ->writepage() whenever we know the write request was
> > > originally set up by a page fault.
> > 
> > The biggest outstanding problem we have remaining is get_user_pages.
> > Callers are only required to hold a ref on the page and then they
> > can call set_page_dirty at any point after that.
> > 
> > I have a half-done patch somewhere to add a put_user_pages, and then
> > we could probably go from there to pinning the fs metadata (whether
> > by using the page lock or something else, I don't quite know).
> 
> Hi everyone,
> 
> Sorry for digging up an old thread, but is there any reason we can't
> just use page_mkwrite here?  I'd love to get rid of the btrfs code to
> detect places that use set_page_dirty without a page_mkwrite.

It is because page_mkwrite must be called before the page is dirtied
(it may fail, it theoretically may do something crazy with the previous
clean page data). And in several places I think it gets called from a
nasty context.

It hasn't fallen completely off my radar. fsblock has the same issue
(although I've just been ignoring gup writes into fsblock fs for the
time being).

I have a basic idea of what to do... It would be nice to change calling
convention of get_user_pages and take the page lock. Database people might
scream, in which case we could only take the page lock for filesystems that
define ->page_mkwrite (so shared mem segments avoid the overhead). Lock
ordering might get a bit interesting, but if we can have callers ensure they
always submit and release partially fulfilled requirests, then we can always
trylock them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
