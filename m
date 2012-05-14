Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id E7E0E6B0081
	for <linux-mm@kvack.org>; Mon, 14 May 2012 17:12:42 -0400 (EDT)
Date: Mon, 14 May 2012 23:12:26 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2 v2] Flexible proportions for BDIs
Message-ID: <20120514211226.GS5353@quack.suse.cz>
References: <1336084760-19534-1-git-send-email-jack@suse.cz>
 <20120507144344.GA13983@localhost>
 <20120509113720.GC5092@quack.suse.cz>
 <20120510073123.GA7523@localhost>
 <20120511145114.GA18227@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120511145114.GA18227@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, peterz@infradead.org

On Fri 11-05-12 22:51:14, Wu Fengguang wrote:
> > > > Look at the gray "bdi setpoint" lines. The
> > > > VM_COMPLETIONS_PERIOD_LEN=8s kernel is able to achieve roughly the
> > > > same stable bdi_setpoint as the vanilla kernel, while being able to
> > > > adapt to the balanced bdi_setpoint much more fast (actually now the
> > > > bdi_setpoint is immediately close to the balanced value when
> > > > balance_dirty_pages() starts throttling, while the vanilla kernel
> > > > takes about 20 seconds for bdi_setpoint to grow up).
> > >   Which graph is from which kernel? All four graphs have the same name so
> > > I'm not sure...
> > 
> > They are for test cases:
> > 
> > 0.5s period
> >         bay/JBOD-2HDD-thresh=1000M/xfs-1dd-1-3.4.0-rc2-prop+/balance_dirty_pages-pages+.png
> > 3s period
> >         bay/JBOD-2HDD-thresh=1000M/xfs-1dd-1-3.4.0-rc2-prop3+/balance_dirty_pages-pages+.png
> > 8s period
> >         bay/JBOD-2HDD-thresh=1000M/xfs-1dd-1-3.4.0-rc2-prop8+/balance_dirty_pages-pages+.png
> > vanilla
> >         bay/JBOD-2HDD-thresh=1000M/xfs-1dd-1-3.3.0/balance_dirty_pages-pages+.png
> > 
> > >   The faster (almost immediate) initial adaptation to bdi's writeout fraction
> > > is mostly an effect of better normalization with my patches. Although it is
> > > pleasant, it happens just at the moment when there is a small number of
> > > periods with non-zero number of events. So more important for practice is
> > > in my opininion to compare transition of computed fractions when workload
> > > changes (i.e. we start writing to one bdi while writing to another bdi or
> > > so).
> > 
> > OK. I'll test this scheme and report back.
> > 
> >         loop {
> >                 dd to disk 1 for 30s
> >                 dd to disk 2 for 30s
> >         }
> 
> Here are the new results. For simplicity I run the dd dirtiers
> continuously, and start another dd reader to knock down the write
> bandwidth from time to time:
> 
>          loop {
>                  dd from disk 1 for 30s
>                  dd from disk 2 for 30s
>          }
> 
> The first attached iostat graph shows the resulting read/write
> bandwidth for one of the two disks.
> 
> The followed graphs are for
>         - 3s period
>         - 8s period
>         - vanilla
> in order. The test case is (xfs-1dd, mem=2GB, 2 disks JBOD).
  Thanks for the test! So here 3s period adapts to changed throughput
fairly quickly, similarly as vanilla kernel, 8s period takes a bit more time.
Random variations in computed proportions for 3s period are about the same
as for vanilla kernel and in a reasonable range I'd say. For 8s period
variations are even smaller as expected.

So all in all I'd say 3s period did fine here, although it did not offer
much benefit over the previous algorithm. 8s period was a bit too slow to
adapt.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
