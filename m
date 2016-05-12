Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD79828E2
	for <linux-mm@kvack.org>; Thu, 12 May 2016 12:08:34 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so57123136lfc.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 09:08:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a27si46418476wmi.10.2016.05.12.09.08.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 May 2016 09:08:31 -0700 (PDT)
Date: Thu, 12 May 2016 18:08:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] writeback: Avoid exhausting allocation reserves under
 memory pressure
Message-ID: <20160512160829.GA30647@quack2.suse.cz>
References: <1462436092-32665-1-git-send-email-jack@suse.cz>
 <20160505082433.GC4386@dhcp22.suse.cz>
 <20160505090750.GD1970@quack2.suse.cz>
 <20160505143751.06aa4223e266c1d92b3323a2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160505143751.06aa4223e266c1d92b3323a2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, tj@kernel.org

On Thu 05-05-16 14:37:51, Andrew Morton wrote:
> On Thu, 5 May 2016 11:07:50 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > On Thu 05-05-16 10:24:33, Michal Hocko wrote:
> > > > +/*
> > > > + * Check whether the request to writeback some pages can be merged with some
> > > > + * other request which is already pending. If yes, merge it and return true.
> > > > + * If no, return false.
> > > > + */
> > > > +static bool wb_merge_request(struct bdi_writeback *wb, long nr_pages,
> > > > +			     struct super_block *sb, bool range_cyclic,
> > > > +			     enum wb_reason reason)
> > > > +{
> > > > +	struct wb_writeback_work *work;
> > > > +	bool merged = false;
> > > > +
> > > > +	spin_lock_bh(&wb->work_lock);
> > > > +	list_for_each_entry(work, &wb->work_list, list) {
> > > 
> > > Is the lenght of the list bounded somehow? In other words is it possible
> > > that the spinlock would be held for too long to traverse the whole list?
> > 
> > I was thinking about this as well. With the merging enabled, the number of
> > entries queued from wb_start_writeback() is essentially limited by the
> > number of writeback reasons and there's only a couple of those. What is
> > more questionable is the number of entries queued from
> > __writeback_inodes_sb_nr(). Generally there should be a couple at maximum
> > either but it is hard to give any guarantee since e.g. filesystems use this
> > function to reduce amount of delay-allocated data when they are running out
> > of space. Hum, maybe we could limit the merging to scan only the last say
> > 16 entries. That should give good results in most cases... Thoughts?
> 
> If it's possible to cause a search complexity meltdown, someone will
> find a way :(

Agreed.

> Is there any reason why the requests coming out of
> writeback_inodes_sb_nr() cannot also be merged?

So my thought was that since these items are essentially synchronous -
writeback_inodes_sb_nr() returns only after the worker submits the IO - we
don't want to block waiters longer than necessary by bumping the number of
pages to write. Also it would be tricky to properly handle completions of
work->done when work items are merged. Finally, since the submitter waits
for work to be completed, this pretty much limits the capability of this
path to DoS the system.

> Your wb_merge_request() doesn't check ->tagged_writepages?
> 
> Why is ->for_sync handled differently?  Needs a comment.
> 
> Suggest turning this into a separate function.  Build a local
> wb_writeback_work in wb_start_writeback(), do:
> 
> 
> 	/* comment goes here */
> 	if (new->reason != old->reason)
> 		return false;
> 	/* comment goes here */
> 	if (new->range_cyclic != old->range_cyclic)
> 		retun false;
> 	return true;
> 
> then copy wb_start_writeback()'s local wb_writeback_work into the
> newly-allocated one if needed (kmemdup()).  Or just pass a billion args
> into that comparison function.
> 
> bdi_split_work_to_wbs() does GFP_ATOMIC as well.  Problem?  (Why the
> heck don't we document the *reasons* for these things, sigh).

Heh, there are much more GFP_ATOMIC allocations in fs/fs-writeback.c after
Tejun's memcg aware writeback... I believe they are GFP_ATOMIC mostly
because they can already be called from direct reclaim (e.g. when
requesting pages to be written through wakeup_flusher_threads()) and so we
don't want to recurse into direct reclaim code again.

> I suspect it would be best to be proactive here and use some smarter
> data structure.  It appears that all the wb_writeback_work fields
> except sb can be squeezed into a single word so perhaps a radix-tree. 
> Or hash them all together and use a chained array or something.  Maybe
> fiddle at it for an hour or so, see how it's looking?  It's a lot of
> fuss to avoid one problematic kmalloc(), sigh.
> 
> We really don't want there to be *any* pathological workload which
> results in merging failures - if that's the case then someone will hit
> it.  They'll experience the ooms (perhaps) and the search complexity
> issues (for sure).

So the question is what is the desired outcome. After Tetsuo's patch
"mm,writeback: Don't use memory reserves for wb_start_writeback" we will
use GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN instead of GFP_ATOMIC in
wb_start_writeback(). We can treat other places using GFP_ATOMIC in a
similar way. So my thought was that this is enough to avoid exhaustion of
reserves for writeback work items under memory pressure. And the merging of
writeback works I proposed was more like an optimization to avoid
unnecessary allocations. And in that case we can allow imperfection and
possibly large lists of queued works in pathological cases - I agree we
should not DoS the system by going through large linked lists in any case but
that is easily avoided if we are fine with the fact that merging won't happen
always when it could.

The question which is not clear to me is: Do we want to guard against
malicious attacker that may be consuming memory through writeback works
that are allocated via GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN? 
If yes, then my patch needs further thought. Any opinions?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
