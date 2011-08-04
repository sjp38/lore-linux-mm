Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2D96B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 03:27:53 -0400 (EDT)
Date: Thu, 4 Aug 2011 09:27:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 4/5] mm: writeback: throttle __GFP_WRITE on per-zone
 dirty limits
Message-ID: <20110804072745.GA31039@tiehlicka.suse.cz>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <1311625159-13771-5-git-send-email-jweiner@redhat.com>
 <20110727142405.GG4024@tiehlicka.suse.cz>
 <20110803202500.GA8286@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110803202500.GA8286@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Wed 03-08-11 22:25:00, Johannes Weiner wrote:
> On Wed, Jul 27, 2011 at 04:24:05PM +0200, Michal Hocko wrote:
> > On Mon 25-07-11 22:19:18, Johannes Weiner wrote:
> > [...]
> > > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > > index 41dc871..ce673ec 100644
> > > --- a/mm/page-writeback.c
> > > +++ b/mm/page-writeback.c
> > > @@ -378,6 +390,24 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
> > >  }
> > >  EXPORT_SYMBOL(bdi_set_max_ratio);
> > >  
> > > +static void sanitize_dirty_limits(unsigned long *pbackground,
> > > +				  unsigned long *pdirty)
> > > +{
> > > +	unsigned long background = *pbackground;
> > > +	unsigned long dirty = *pdirty;
> > > +	struct task_struct *tsk;
> > > +
> > > +	if (background >= dirty)
> > > +		background = dirty / 2;
> > > +	tsk = current;
> > > +	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
> > > +		background += background / 4;
> > > +		dirty += dirty / 4;
> > > +	}
> > > +	*pbackground = background;
> > > +	*pdirty = dirty;
> > > +}
> > > +
> > >  /*
> > >   * global_dirty_limits - background-writeback and dirty-throttling thresholds
> > >   *
> > > @@ -389,33 +419,52 @@ EXPORT_SYMBOL(bdi_set_max_ratio);
> > >   */
> > >  void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
> > >  {
> > > -	unsigned long background;
> > > -	unsigned long dirty;
> > >  	unsigned long uninitialized_var(available_memory);
> > > -	struct task_struct *tsk;
> > >  
> > >  	if (!vm_dirty_bytes || !dirty_background_bytes)
> > >  		available_memory = determine_dirtyable_memory();
> > >  
> > >  	if (vm_dirty_bytes)
> > > -		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> > > +		*pdirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> > >  	else
> > > -		dirty = (vm_dirty_ratio * available_memory) / 100;
> > > +		*pdirty = vm_dirty_ratio * available_memory / 100;
> > >  
> > >  	if (dirty_background_bytes)
> > > -		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> > > +		*pbackground = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> > >  	else
> > > -		background = (dirty_background_ratio * available_memory) / 100;
> > > +		*pbackground = dirty_background_ratio * available_memory / 100;
> > >  
> > > -	if (background >= dirty)
> > > -		background = dirty / 2;
> > > -	tsk = current;
> > > -	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
> > > -		background += background / 4;
> > > -		dirty += dirty / 4;
> > > -	}
> > > -	*pbackground = background;
> > > -	*pdirty = dirty;
> > > +	sanitize_dirty_limits(pbackground, pdirty);
> > > +}
> > 
> > Hmm, wouldn't be the patch little bit easier to read if this was
> > outside in a separate (cleanup) one?
> 
> I didn't find it hard to read.  But I wrote it, so... :)
> 
> Will split it out in the next round.  Thanks, Michal.

Thanks

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
