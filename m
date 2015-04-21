Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 06106900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 04:59:49 -0400 (EDT)
Received: by wgsk9 with SMTP id k9so205593331wgs.3
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 01:59:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fh9si971043wib.20.2015.04.21.01.59.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 01:59:47 -0700 (PDT)
Date: Tue, 21 Apr 2015 10:59:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 15/49] writeback: move backing_dev_info->wb_lock and
 ->worklist into bdi_writeback
Message-ID: <20150421085942.GB24278@quack.suse.cz>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-16-git-send-email-tj@kernel.org>
 <20150420153224.GD17020@quack.suse.cz>
 <20150420181707.GD4206@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150420181707.GD4206@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

On Mon 20-04-15 14:17:07, Tejun Heo wrote:
> Hello, Jan.
> 
> On Mon, Apr 20, 2015 at 05:32:24PM +0200, Jan Kara wrote:
> > > @@ -454,9 +451,9 @@ EXPORT_SYMBOL(bdi_init);
> > >  
> > >  void bdi_destroy(struct backing_dev_info *bdi)
> > >  {
> > > -	bdi_wb_shutdown(bdi);
> > > -
> > > -	WARN_ON(!list_empty(&bdi->work_list));
> > > +	/* make sure nobody finds us on the bdi_list anymore */
> > > +	bdi_remove_from_list(bdi);
> > > +	wb_shutdown(&bdi->wb);
> > >  
> > >  	if (bdi->dev) {
> > >  		bdi_debug_unregister(bdi);
> >   But if someone ends up calling bdi_destroy() on unregistered bdi,
> > bdi_remove_from_list() will be corrupting memory, won't it? And if I
> 
> bdi_init() does INIT_LIST_HEAD() on it, so it should be fine, no?
  Yeah, checking the code again, we are fine.

> > remember right there were some corner cases where this really happened.
> > Previously we were careful and checked WB_registered. I guess we could
> > check for !list_empty(&bdi->bdi_list) and also reinit bdi_list in
> > bdi_remove_from_list() after synchronize_rcu_expedited().
> 
> But we can't call bdi_destroy() more than once no matter what.  We'd
> be doing double frees.
  Sorry, I was thinking about calling bdi_unregister() more than once but
as the call is moved into bdi_destroy() that is really called only once.

You can add:
Reviewed-by: Jan Kara <jack@suse.cz>
								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
