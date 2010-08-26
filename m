Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2162E6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:41:22 -0400 (EDT)
Date: Thu, 26 Aug 2010 18:41:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] writeback: Record if the congestion was unnecessary
Message-ID: <20100826174105.GI20944@csn.ul.ie>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie> <1282835656-5638-3-git-send-email-mel@csn.ul.ie> <20100826173534.GC6873@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100826173534.GC6873@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 02:35:34AM +0900, Minchan Kim wrote:
> On Thu, Aug 26, 2010 at 04:14:15PM +0100, Mel Gorman wrote:
> > If congestion_wait() is called when there is no congestion, the caller
> > will wait for the full timeout. This can cause unreasonable and
> > unnecessary stalls. There are a number of potential modifications that
> > could be made to wake sleepers but this patch measures how serious the
> > problem is. It keeps count of how many congested BDIs there are. If
> > congestion_wait() is called with no BDIs congested, the tracepoint will
> > record that the wait was unnecessary.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  include/trace/events/writeback.h |   11 ++++++++---
> >  mm/backing-dev.c                 |   15 ++++++++++++---
> >  2 files changed, 20 insertions(+), 6 deletions(-)
> > 
> > diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
> > index e3bee61..03bb04b 100644
> > --- a/include/trace/events/writeback.h
> > +++ b/include/trace/events/writeback.h
> > @@ -155,19 +155,24 @@ DEFINE_WBC_EVENT(wbc_writepage);
> >  
> >  TRACE_EVENT(writeback_congest_waited,
> >  
> > -	TP_PROTO(unsigned int usec_delayed),
> > +	TP_PROTO(unsigned int usec_delayed, bool unnecessary),
> >  
> > -	TP_ARGS(usec_delayed),
> > +	TP_ARGS(usec_delayed, unnecessary),
> >  
> >  	TP_STRUCT__entry(
> >  		__field(	unsigned int,	usec_delayed	)
> > +		__field(	unsigned int,	unnecessary	)
> >  	),
> >  
> >  	TP_fast_assign(
> >  		__entry->usec_delayed	= usec_delayed;
> > +		__entry->unnecessary	= unnecessary;
> >  	),
> >  
> > -	TP_printk("usec_delayed=%u", __entry->usec_delayed)
> > +	TP_printk("usec_delayed=%u unnecessary=%d",
> > +		__entry->usec_delayed,
> > +		__entry->unnecessary
> > +	)
> >  );
> >  
> >  #endif /* _TRACE_WRITEBACK_H */
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index 7ae33e2..a49167f 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -724,6 +724,7 @@ static wait_queue_head_t congestion_wqh[2] = {
> >  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
> >  		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
> >  	};
> > +static atomic_t nr_bdi_congested[2];
> >  
> >  void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
> >  {
> > @@ -731,7 +732,8 @@ void clear_bdi_congested(struct backing_dev_info *bdi, int sync)
> >  	wait_queue_head_t *wqh = &congestion_wqh[sync];
> >  
> >  	bit = sync ? BDI_sync_congested : BDI_async_congested;
> > -	clear_bit(bit, &bdi->state);
> > +	if (test_and_clear_bit(bit, &bdi->state))
> > +		atomic_dec(&nr_bdi_congested[sync]);
> 
> Hmm.. Now congestion_wait's semantics "wait for _a_ backing_dev to become uncongested"
> But this seems to consider whole backing dev. Is your intention? or Am I missing now?
> 

Not whole backing devs, all backing devs. This is intentional.

If congestion_wait() is called with 0 BDIs congested, we sleep the full timeout
because a wakeup event will not occur - this is a bad scenario. To know if
0 BDIs were congested, one could either walk all the BDIs checking their
status or maintain a counter like nr_bdi_congested which is what I decided on.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
