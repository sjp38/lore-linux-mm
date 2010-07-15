Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C01EE6B02A3
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 10:51:03 -0400 (EDT)
Date: Thu, 15 Jul 2010 22:50:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/6] writeback: take account of NR_WRITEBACK_TEMP in
 balance_dirty_pages()
Message-ID: <20100715145045.GA6511@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711021748.594522648@intel.com>
 <20100712145206.9808b411.akpm@linux-foundation.org>
 <E1OYbKB-0008UF-2J@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1OYbKB-0008UF-2J@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, "hch@infradead.org" <hch@infradead.org>, "richard@rsk.demon.co.uk" <richard@rsk.demon.co.uk>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 04:58:47PM +0800, Miklos Szeredi wrote:
> On Mon, 12 Jul 2010, Andrew Morton wrote:
> > On Sun, 11 Jul 2010 10:06:57 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > 
> > > Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > >  mm/page-writeback.c |    7 ++++---
> > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > > 
> > > --- linux-next.orig/mm/page-writeback.c	2010-07-11 08:41:37.000000000 +0800
> > > +++ linux-next/mm/page-writeback.c	2010-07-11 08:42:14.000000000 +0800
> > > @@ -503,11 +503,12 @@ static void balance_dirty_pages(struct a
> > >  		};
> > >  
> > >  		get_dirty_limits(&background_thresh, &dirty_thresh,
> > > -				&bdi_thresh, bdi);
> > > +				 &bdi_thresh, bdi);
> > >  
> > >  		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> > > -					global_page_state(NR_UNSTABLE_NFS);
> > > -		nr_writeback = global_page_state(NR_WRITEBACK);
> > > +				 global_page_state(NR_UNSTABLE_NFS);
> > > +		nr_writeback = global_page_state(NR_WRITEBACK) +
> > > +			       global_page_state(NR_WRITEBACK_TEMP);
> > >  
> > >  		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> > >  		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> > > 
> > 
> > hm, OK.
> 
> Hm, hm.  I'm not sure this is right.  The VM has absolutely no control
> over NR_WRITEBACK_TEMP pages, they may clear quickly or may not make
> any progress.  So it's usually wrong to make a decision based on
> NR_WRITEBACK_TEMP for an unrelated device.

Ah OK, let's remove this patch.

> Using it in throttle_vm_writeout() would actually be deadlocky, since
> the userspace filesystem will probably depend on memory allocations to
> complete the writeout.

Right.

> The only place where we should be taking NR_WRITEBACK_TEMP into
> account is calculating the remaining memory that can be devided
> between dirtyers, and that's (clip_bdi_dirty_limit) where it is
> already used.

clip_bdi_dirty_limit() is removed in the next patch, hopefully it's OK.

> > I wonder whether we could/should have unified NR_WRITEBACK_TEMP and
> > NR_UNSTABLE_NFS.  Their "meanings" aren't quite the same, but perhaps
> > some "treat page as dirty because the fs is futzing with it" thing.
> 
> AFAICS NR_UNSTABLE_NFS is something akin to NR_DIRTY, only on the
> server side.  So nfs can very much do something about making
> NR_UNSTABLE_NFS go away, while there's nothing that can be done about
> NR_WRITEBACK_TEMP.

Right. nfs_write_inode() normally tries to commit unstable pages.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
