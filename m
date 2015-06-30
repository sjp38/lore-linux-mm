Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id F2A276B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 12:42:19 -0400 (EDT)
Received: by wgck11 with SMTP id k11so14865002wgc.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 09:42:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8si20251934wiw.96.2015.06.30.09.42.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 09:42:17 -0700 (PDT)
Date: Tue, 30 Jun 2015 18:42:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 32/51] writeback: implement
 backing_dev_info->tot_write_bandwidth
Message-ID: <20150630164212.GT7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-33-git-send-email-tj@kernel.org>
 <20150630161458.GR7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150630161458.GR7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Tue 30-06-15 18:14:58, Jan Kara wrote:
> On Fri 22-05-15 17:13:46, Tejun Heo wrote:
> > cgroup writeback support needs to keep track of the sum of
> > avg_write_bandwidth of all wb's (bdi_writeback's) with dirty inodes to
> > distribute write workload.  This patch adds bdi->tot_write_bandwidth
> > and updates inode_wb_list_move_locked(), inode_wb_list_del_locked()
> > and wb_update_write_bandwidth() to adjust it as wb's gain and lose
> > dirty inodes and its avg_write_bandwidth gets updated.
> > 
> > As the update events are not synchronized with each other,
> > bdi->tot_write_bandwidth is an atomic_long_t.
> 
> So I was looking into what tot_write_bandwidth is used for and if I look
> right it is used for bdi_has_dirty_io() and for distribution of dirty pages
> when writeback is started against the whole bdi.
> 
> Now neither of these cases seem to be really performance critical (in all
> the cases we iterate the list of all wbs of the bdi anyway) so why don't we
> just compute the total write bandwidth when needed, instead of maintaining
> it all the time?

OK, now I realized that tot_write_bandwidth is also used in computation of
a dirty limit for a memcg and that one gets called pretty often so
maintaing total bandwidth probably pays off.

I was also thinking whether it wouldn't be better to maintain writeout
fractions for wb instead of bdi since summing average writeback bandwidths
seem somewhat hacky but what you do seems to be good enough for now. We can
always improve on that later when we see how things work in practice.

You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza
> 
> > Signed-off-by: Tejun Heo <tj@kernel.org>
> > Cc: Jens Axboe <axboe@kernel.dk>
> > Cc: Jan Kara <jack@suse.cz>
> > ---
> >  fs/fs-writeback.c                | 7 ++++++-
> >  include/linux/backing-dev-defs.h | 2 ++
> >  mm/page-writeback.c              | 3 +++
> >  3 files changed, 11 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index 0a90dc55..bbccf68 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -99,6 +99,8 @@ static bool wb_io_lists_populated(struct bdi_writeback *wb)
> >  		return false;
> >  	} else {
> >  		set_bit(WB_has_dirty_io, &wb->state);
> > +		atomic_long_add(wb->avg_write_bandwidth,
> > +				&wb->bdi->tot_write_bandwidth);
> >  		return true;
> >  	}
> >  }
> > @@ -106,8 +108,11 @@ static bool wb_io_lists_populated(struct bdi_writeback *wb)
> >  static void wb_io_lists_depopulated(struct bdi_writeback *wb)
> >  {
> >  	if (wb_has_dirty_io(wb) && list_empty(&wb->b_dirty) &&
> > -	    list_empty(&wb->b_io) && list_empty(&wb->b_more_io))
> > +	    list_empty(&wb->b_io) && list_empty(&wb->b_more_io)) {
> >  		clear_bit(WB_has_dirty_io, &wb->state);
> > +		atomic_long_sub(wb->avg_write_bandwidth,
> > +				&wb->bdi->tot_write_bandwidth);
> > +	}
> >  }
> >  
> >  /**
> > diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
> > index 7a94b78..d631a61 100644
> > --- a/include/linux/backing-dev-defs.h
> > +++ b/include/linux/backing-dev-defs.h
> > @@ -142,6 +142,8 @@ struct backing_dev_info {
> >  	unsigned int min_ratio;
> >  	unsigned int max_ratio, max_prop_frac;
> >  
> > +	atomic_long_t tot_write_bandwidth; /* sum of active avg_write_bw */
> > +
> >  	struct bdi_writeback wb;  /* the root writeback info for this bdi */
> >  	struct bdi_writeback_congested wb_congested; /* its congested state */
> >  #ifdef CONFIG_CGROUP_WRITEBACK
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index e31dea9..c95eb24 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -881,6 +881,9 @@ static void wb_update_write_bandwidth(struct bdi_writeback *wb,
> >  		avg += (old - avg) >> 3;
> >  
> >  out:
> > +	if (wb_has_dirty_io(wb))
> > +		atomic_long_add(avg - wb->avg_write_bandwidth,
> > +				&wb->bdi->tot_write_bandwidth);
> >  	wb->write_bandwidth = bw;
> >  	wb->avg_write_bandwidth = avg;
> >  }
> > -- 
> > 2.4.0
> > 
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
