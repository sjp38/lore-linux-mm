Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E95D6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 05:07:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so9669319wme.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 02:07:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si10240246wjf.206.2016.05.05.02.07.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 May 2016 02:07:52 -0700 (PDT)
Date: Thu, 5 May 2016 11:07:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] writeback: Avoid exhausting allocation reserves under
 memory pressure
Message-ID: <20160505090750.GD1970@quack2.suse.cz>
References: <1462436092-32665-1-git-send-email-jack@suse.cz>
 <20160505082433.GC4386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160505082433.GC4386@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, tj@kernel.org

On Thu 05-05-16 10:24:33, Michal Hocko wrote:
> > +/*
> > + * Check whether the request to writeback some pages can be merged with some
> > + * other request which is already pending. If yes, merge it and return true.
> > + * If no, return false.
> > + */
> > +static bool wb_merge_request(struct bdi_writeback *wb, long nr_pages,
> > +			     struct super_block *sb, bool range_cyclic,
> > +			     enum wb_reason reason)
> > +{
> > +	struct wb_writeback_work *work;
> > +	bool merged = false;
> > +
> > +	spin_lock_bh(&wb->work_lock);
> > +	list_for_each_entry(work, &wb->work_list, list) {
> 
> Is the lenght of the list bounded somehow? In other words is it possible
> that the spinlock would be held for too long to traverse the whole list?

I was thinking about this as well. With the merging enabled, the number of
entries queued from wb_start_writeback() is essentially limited by the
number of writeback reasons and there's only a couple of those. What is
more questionable is the number of entries queued from
__writeback_inodes_sb_nr(). Generally there should be a couple at maximum
either but it is hard to give any guarantee since e.g. filesystems use this
function to reduce amount of delay-allocated data when they are running out
of space. Hum, maybe we could limit the merging to scan only the last say
16 entries. That should give good results in most cases... Thoughts?

								Honza

> > +		if (work->reason == reason &&
> > +		    work->range_cyclic == range_cyclic &&
> > +		    work->auto_free == 1 && work->sb == sb &&
> > +		    work->for_sync == 0) {
> > +			work->nr_pages += nr_pages;
> > +			merged = true;
> > +			trace_writeback_merged(wb, work);
> > +			break;
> > +		}
> > +	}
> > +	spin_unlock_bh(&wb->work_lock);
> > +
> > +	return merged;
> > +}
> -- 
> Michal Hocko
> SUSE Labs
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
