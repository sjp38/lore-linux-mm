Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B6FA6B01FC
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 22:35:54 -0400 (EDT)
Date: Thu, 19 Aug 2010 19:36:19 -0700 (PDT)
From: Sage Weil <sage@newdream.net>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
In-Reply-To: <20100820000258.GA30226@localhost>
Message-ID: <Pine.LNX.4.64.1008191935420.22373@cobra.newdream.net>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
 <20100819143710.GA4752@infradead.org> <20100819235553.GB22747@localhost>
 <20100820000258.GA30226@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, David Howells <dhowells@redhat.com>, Steve French <sfrench@samba.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010, Wu Fengguang wrote:

> [add CC to afs/cifs/ceph maintainers]
> 
> On Fri, Aug 20, 2010 at 07:55:53AM +0800, Wu Fengguang wrote:
> > On Thu, Aug 19, 2010 at 10:37:10AM -0400, Christoph Hellwig wrote:
> > > On Thu, Aug 19, 2010 at 10:15:25AM -0400, Jeff Layton wrote:
> > > > I'm looking at backporting some upstream changes to earlier kernels,
> > > > and ran across something I don't quite understand...
> > > > 
> > > > In nfs_commit_unstable_pages, we set the flags to FLUSH_SYNC. We then
> > > > zero out the flags if wbc->nonblocking or wbc->for_background is set.
> > > > 
> > > > Shouldn't we also clear it out if wbc->sync_mode == WB_SYNC_NONE ?
> > > > WB_SYNC_NONE means "don't wait on anything", so shouldn't that include
> > > > not waiting on the COMMIT to complete?
> > > 
> > > I've been trying to figure out what the nonblocking flag is supposed
> > > to mean for a while now.
> > > 
> > > It basically disappeared in commit 0d99519efef15fd0cf84a849492c7b1deee1e4b7
> > > 
> > > 	"writeback: remove unused nonblocking and congestion checks"
> > > 
> > > from Wu.  What's left these days is a couple of places in local copies
> > > of write_cache_pages (afs, cifs), and a couple of checks in random
> > > writepages instances (afs, block_write_full_page, ceph, nfs, reiserfs, xfs)
> > > and the use in nfs_write_inode.
> > 
> > In principle all nonblocking checks in ->writepages should be removed.
> > 
> > (My original patch does have chunks for afs/cifs that somehow get
> >  dropped in the process, and missed ceph because it's not upstream
> >  when I started patch..)

I'll queue up a fix for Ceph's ->writepages in my tree.

Thanks!
sage


> > 
> > > It's only actually set for memory
> > > migration and pageout, that is VM writeback.
> > > 
> > > To me it really doesn't make much sense, but maybe someone has a better
> > > idea what it is for.
> >  
> > Since migration and pageout still set nonblocking for ->writepage, we
> > may keep them in the near future, until VM does not start IO on itself.
> > 
> > > > +	if (wbc->nonblocking || wbc->for_background ||
> > > > +	    wbc->sync_mode == WB_SYNC_NONE)
> > > 
> > > You could remove the nonblocking and for_background checks as
> > > these impliy WB_SYNC_NONE.
> > 
> > Agreed.
> > 
> > Thanks,
> > Fengguang
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
