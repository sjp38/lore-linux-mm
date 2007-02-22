Date: Wed, 21 Feb 2007 23:55:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: dirty balancing deadlock
Message-Id: <20070221235532.2361f827.akpm@linux-foundation.org>
In-Reply-To: <E1HK8aw-0005Lg-00@dorka.pomaz.szeredi.hu>
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
	<20070218145929.547c21c7.akpm@linux-foundation.org>
	<E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu>
	<20070218155916.0d3c73a9.akpm@linux-foundation.org>
	<E1HJC3P-0006tz-00@dorka.pomaz.szeredi.hu>
	<20070221133631.a5cbf49f.akpm@linux-foundation.org>
	<E1HK8aw-0005Lg-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 22 Feb 2007 08:42:26 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
> > > 
> > > Index: linux/mm/page-writeback.c
> > > ===================================================================
> > > --- linux.orig/mm/page-writeback.c	2007-02-19 17:32:41.000000000 +0100
> > > +++ linux/mm/page-writeback.c	2007-02-19 18:05:28.000000000 +0100
> > > @@ -198,6 +198,25 @@ static void balance_dirty_pages(struct a
> > >  			dirty_thresh)
> > >  				break;
> > >  
> > > +		/*
> > > +		 * Acquit this producer if there's little or nothing
> > > +		 * to write back to this particular queue
> > > +		 *
> > > +		 * Without this check a deadlock is possible in the
> > > +		 * following case:
> > > +		 *
> > > +		 * - filesystem A writes data through filesystem B
> > > +		 * - filesystem A has dirty pages over dirty_thresh
> > > +		 * - writeback is started, this triggers a write in B
> > > +		 * - balance_dirty_pages() is called synchronously
> > > +		 * - the write to B blocks
> > > +		 * - the writeback completes, but dirty is still over threshold
> > > +		 * - the blocking write prevents futher writes from happening
> > > +		 */
> > > +		if (atomic_long_read(&bdi->nr_dirty) +
> > > +		    atomic_long_read(&bdi->nr_writeback) < 16)
> > > +			break;
> > > +
> > 
> > The problem seems to that little "- the write to B blocks".
> > 
> > How come it blocks?  I mean, if we cannot retire writes to that filesystem
> > then we're screwed anyway.
> 
> Sorry about the sloppy description.  I mean, it's not the lowlevel
> write that will block, but rather the VFS one
> (generic_file_aio_write).  It will block (or rather loop forever with
> 0.1 second sleeps) in balance_dirty_pages().  That means, that for
> this inode, i_mutex is held and no other writer can continue the work.

"this inode" I assume is the inode against filesystem A?

Why does holding that inode's i_mutex prevent further writeback of pages in A?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
