In-reply-to: <20070221235532.2361f827.akpm@linux-foundation.org> (message from
	Andrew Morton on Wed, 21 Feb 2007 23:55:32 -0800)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
	<20070218145929.547c21c7.akpm@linux-foundation.org>
	<E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu>
	<20070218155916.0d3c73a9.akpm@linux-foundation.org>
	<E1HJC3P-0006tz-00@dorka.pomaz.szeredi.hu>
	<20070221133631.a5cbf49f.akpm@linux-foundation.org>
	<E1HK8aw-0005Lg-00@dorka.pomaz.szeredi.hu> <20070221235532.2361f827.akpm@linux-foundation.org>
Message-Id: <E1HK8uG-0005OT-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 22 Feb 2007 09:02:24 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > On Thu, 22 Feb 2007 08:42:26 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
> > > > 
> > > > Index: linux/mm/page-writeback.c
> > > > ===================================================================
> > > > --- linux.orig/mm/page-writeback.c	2007-02-19 17:32:41.000000000 +0100
> > > > +++ linux/mm/page-writeback.c	2007-02-19 18:05:28.000000000 +0100
> > > > @@ -198,6 +198,25 @@ static void balance_dirty_pages(struct a
> > > >  			dirty_thresh)
> > > >  				break;
> > > >  
> > > > +		/*
> > > > +		 * Acquit this producer if there's little or nothing
> > > > +		 * to write back to this particular queue
> > > > +		 *
> > > > +		 * Without this check a deadlock is possible in the
> > > > +		 * following case:
> > > > +		 *
> > > > +		 * - filesystem A writes data through filesystem B
> > > > +		 * - filesystem A has dirty pages over dirty_thresh
> > > > +		 * - writeback is started, this triggers a write in B
> > > > +		 * - balance_dirty_pages() is called synchronously
> > > > +		 * - the write to B blocks
> > > > +		 * - the writeback completes, but dirty is still over threshold
> > > > +		 * - the blocking write prevents futher writes from happening
> > > > +		 */
> > > > +		if (atomic_long_read(&bdi->nr_dirty) +
> > > > +		    atomic_long_read(&bdi->nr_writeback) < 16)
> > > > +			break;
> > > > +
> > > 
> > > The problem seems to that little "- the write to B blocks".
> > > 
> > > How come it blocks?  I mean, if we cannot retire writes to that filesystem
> > > then we're screwed anyway.
> > 
> > Sorry about the sloppy description.  I mean, it's not the lowlevel
> > write that will block, but rather the VFS one
> > (generic_file_aio_write).  It will block (or rather loop forever with
> > 0.1 second sleeps) in balance_dirty_pages().  That means, that for
> > this inode, i_mutex is held and no other writer can continue the work.
> 
> "this inode" I assume is the inode against filesystem A?

No, the one in B.

> Why does holding that inode's i_mutex prevent further writeback of
> pages in A?

It is generic_file_aio_write() that is holding the mutex.

Here's the stack for the filesystem daemon trying to write back a page:

08dcfb40:  [<08182fe6>] schedule+0x246/0x547
08dcfb98:  [<08183a03>] schedule_timeout+0x4e/0xb6
08dcfbcc:  [<08183991>] io_schedule_timeout+0x11/0x20
08dcfbd4:  [<080a0cf2>] congestion_wait+0x72/0x87
08dcfc04:  [<0809c693>] balance_dirty_pages+0xa8/0x153
08dcfc5c:  [<0809c7bf>] balance_dirty_pages_ratelimited_nr+0x43/0x45
08dcfc68:  [<080992b5>] generic_file_buffered_write+0x3e3/0x6f5
08dcfd20:  [<0809988e>] __generic_file_aio_write_nolock+0x2c7/0x5dd
08dcfda8:  [<08099cb6>] generic_file_aio_write+0x55/0xc7
08dcfddc:  [<080ea1e6>] ext3_file_write+0x39/0xaf
08dcfe04:  [<080b060b>] do_sync_write+0xd8/0x10e
08dcfebc:  [<080b06e3>] vfs_write+0xa2/0x1cb
08dcfeec:  [<080b09b8>] sys_pwrite64+0x65/0x69

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
