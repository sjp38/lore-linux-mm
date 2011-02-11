Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 06B6B8D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 09:56:41 -0500 (EST)
Date: Fri, 11 Feb 2011 15:56:34 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
Message-ID: <20110211145634.GJ5187@quack.suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
 <1296783534-11585-4-git-send-email-jack@suse.cz>
 <1296824956.26581.650.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296824956.26581.650.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>

On Fri 04-02-11 14:09:16, Peter Zijlstra wrote:
> On Fri, 2011-02-04 at 02:38 +0100, Jan Kara wrote:
> > +static int check_dirty_limits(struct backing_dev_info *bdi,
> > +                             struct dirty_limit_state *pst)
> > +{
> > +       struct dirty_limit_state st;
> > +       unsigned long bdi_thresh;
> > +       unsigned long min_bdi_thresh;
> > +       int ret = DIRTY_OK;
> >  
> > +       get_global_dirty_limit_state(&st);
> > +       /*
> > +        * Throttle it only when the background writeback cannot catch-up. This
> > +        * avoids (excessively) small writeouts when the bdi limits are ramping
> > +        * up.
> > +        */
> > +       if (st.nr_reclaimable + st.nr_writeback <=
> > +                       (st.background_thresh + st.dirty_thresh) / 2)
> > +               goto out;
> >  
> > +       get_bdi_dirty_limit_state(bdi, &st);
> > +       min_bdi_thresh = task_min_dirty_limit(st.bdi_thresh);
> > +       bdi_thresh = task_dirty_limit(current, st.bdi_thresh);
> > +
> > +       /*
> > +        * The bdi thresh is somehow "soft" limit derived from the global
> > +        * "hard" limit. The former helps to prevent heavy IO bdi or process
> > +        * from holding back light ones; The latter is the last resort
> > +        * safeguard.
> > +        */
> > +       if ((st.bdi_nr_reclaimable + st.bdi_nr_writeback > bdi_thresh)
> > +           || (st.nr_reclaimable + st.nr_writeback > st.dirty_thresh)) {
> > +               ret = DIRTY_EXCEED_LIMIT;
> > +               goto out;
> > +       }
> > +       if (st.bdi_nr_reclaimable + st.bdi_nr_writeback > min_bdi_thresh) {
> > +               ret = DIRTY_MAY_EXCEED_LIMIT;
> > +               goto out;
> > +       }
> > +       if (st.nr_reclaimable > st.background_thresh)
> > +               ret = DIRTY_EXCEED_BACKGROUND;
> > +out:
> > +       if (pst)
> > +               *pst = st;
> 
> By mandating pst is always provided you can reduce the total stack
> footprint, avoid the memcopy and clean up the control flow ;-)
  OK, will do.

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
