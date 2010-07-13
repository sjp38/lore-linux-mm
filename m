Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C79F06B02A8
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 04:59:26 -0400 (EDT)
In-reply-to: <20100712145206.9808b411.akpm@linux-foundation.org> (message from
	Andrew Morton on Mon, 12 Jul 2010 14:52:06 -0700)
Subject: Re: [PATCH 1/6] writeback: take account of NR_WRITEBACK_TEMP in
 balance_dirty_pages()
References: <20100711020656.340075560@intel.com>
	<20100711021748.594522648@intel.com> <20100712145206.9808b411.akpm@linux-foundation.org>
Message-Id: <E1OYbKB-0008UF-2J@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 13 Jul 2010 10:58:47 +0200
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: fengguang.wu@intel.com, hch@infradead.org, richard@rsk.demon.co.uk, david@fromorbit.com, jack@suse.cz, a.p.zijlstra@chello.nl, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

On Mon, 12 Jul 2010, Andrew Morton wrote:
> On Sun, 11 Jul 2010 10:06:57 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > 
> > Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  mm/page-writeback.c |    7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> > 
> > --- linux-next.orig/mm/page-writeback.c	2010-07-11 08:41:37.000000000 +0800
> > +++ linux-next/mm/page-writeback.c	2010-07-11 08:42:14.000000000 +0800
> > @@ -503,11 +503,12 @@ static void balance_dirty_pages(struct a
> >  		};
> >  
> >  		get_dirty_limits(&background_thresh, &dirty_thresh,
> > -				&bdi_thresh, bdi);
> > +				 &bdi_thresh, bdi);
> >  
> >  		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> > -					global_page_state(NR_UNSTABLE_NFS);
> > -		nr_writeback = global_page_state(NR_WRITEBACK);
> > +				 global_page_state(NR_UNSTABLE_NFS);
> > +		nr_writeback = global_page_state(NR_WRITEBACK) +
> > +			       global_page_state(NR_WRITEBACK_TEMP);
> >  
> >  		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> >  		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> > 
> 
> hm, OK.

Hm, hm.  I'm not sure this is right.  The VM has absolutely no control
over NR_WRITEBACK_TEMP pages, they may clear quickly or may not make
any progress.  So it's usually wrong to make a decision based on
NR_WRITEBACK_TEMP for an unrelated device.

Using it in throttle_vm_writeout() would actually be deadlocky, since
the userspace filesystem will probably depend on memory allocations to
complete the writeout.

The only place where we should be taking NR_WRITEBACK_TEMP into
account is calculating the remaining memory that can be devided
between dirtyers, and that's (clip_bdi_dirty_limit) where it is
already used.

> I wonder whether we could/should have unified NR_WRITEBACK_TEMP and
> NR_UNSTABLE_NFS.  Their "meanings" aren't quite the same, but perhaps
> some "treat page as dirty because the fs is futzing with it" thing.

AFAICS NR_UNSTABLE_NFS is something akin to NR_DIRTY, only on the
server side.  So nfs can very much do something about making
NR_UNSTABLE_NFS go away, while there's nothing that can be done about
NR_WRITEBACK_TEMP.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
