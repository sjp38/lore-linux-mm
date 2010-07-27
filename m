Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2C816600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 05:12:49 -0400 (EDT)
Date: Tue, 27 Jul 2010 11:12:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/6] writeback: reduce calls to global_page_state in
 balance_dirty_pages()
Message-ID: <20100727091220.GD3358@quack.suse.cz>
References: <20100711020656.340075560@intel.com>
 <20100711021748.735126772@intel.com>
 <20100726151946.GH3280@quack.suse.cz>
 <20100727035941.GA15007@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100727035941.GA15007@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, Dave Chinner <david@fromorbit.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue 27-07-10 11:59:41, Wu Fengguang wrote:
> > > This patch slightly changes behavior by replacing clip_bdi_dirty_limit()
> > > with the explicit check (nr_reclaimable + nr_writeback >= dirty_thresh)
> > > to avoid exceeding the dirty limit. Since the bdi dirty limit is mostly
> > > accurate we don't need to do routinely clip. A simple dirty limit check
> > > would be enough.
> > > 
> > > The check is necessary because, in principle we should throttle
> > > everything calling balance_dirty_pages() when we're over the total
> > > limit, as said by Peter.
> > > 
> > > We now set and clear dirty_exceeded not only based on bdi dirty limits,
> > > but also on the global dirty limits. This is a bit counterintuitive, but
> > > the global limits are the ultimate goal and shall be always imposed.
> >   Thinking about this again - what you did is rather big change for systems
> > with more active BDIs. For example if I have two disks sda and sdb and
> > write for some time to sda, then dirty limit for sdb gets scaled down.
> > So when we start writing to sbd we'll heavily throttle the threads until
> > the dirty limit for sdb ramps up regardless of how far are we to reach the
> > global limit...
> 
> The global threshold check is added in place of clip_bdi_dirty_limit()
> for safety and not intended as a behavior change. If ever leading to
> big behavior change and regression, that it would be indicating some
> too permissive per-bdi threshold calculation.
> 
> Did you see the global dirty threshold get exceeded when writing to 2+
> devices? Occasional small exceeding should be OK though. I tried the
> following debug patch and see no warnings when doing two concurrent cp
> over local disk and NFS.
  Oops, sorry. I've misread the code. You're right. There shouldn't be a big
change in the behavior.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
