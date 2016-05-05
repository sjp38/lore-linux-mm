Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 428CE6B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 04:24:37 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so8286692lfd.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 01:24:37 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id gq6si10045583wjb.181.2016.05.05.01.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 01:24:35 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r12so2125219wme.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 01:24:35 -0700 (PDT)
Date: Thu, 5 May 2016 10:24:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] writeback: Avoid exhausting allocation reserves under
 memory pressure
Message-ID: <20160505082433.GC4386@dhcp22.suse.cz>
References: <1462436092-32665-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462436092-32665-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, tj@kernel.org

On Thu 05-05-16 10:14:52, Jan Kara wrote:
> When system is under memory pressure memory management frequently calls
> wakeup_flusher_threads() to writeback pages to that they can be freed.
> This was observed to exhaust reserves for atomic allocations since
> wakeup_flusher_threads() allocates one writeback work for each device
> with dirty data with GFP_ATOMIC.
> 
> However it is pointless to allocate new work items when requested work
> is identical. Instead, we can merge the new work with the pending work
> items and thus save memory allocation.

Makes sense. See one question below:

> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/fs-writeback.c                | 37 +++++++++++++++++++++++++++++++++++++
>  include/trace/events/writeback.h |  1 +
>  2 files changed, 38 insertions(+)
> 
> This is a patch which should (and in my basic testing does) address the issues
> with many atomic allocations Tetsuo reported. What do people think?
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index fee81e8768c9..bb6725f5b1ba 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -189,6 +189,35 @@ out_unlock:
>  	spin_unlock_bh(&wb->work_lock);
>  }
>  
> +/*
> + * Check whether the request to writeback some pages can be merged with some
> + * other request which is already pending. If yes, merge it and return true.
> + * If no, return false.
> + */
> +static bool wb_merge_request(struct bdi_writeback *wb, long nr_pages,
> +			     struct super_block *sb, bool range_cyclic,
> +			     enum wb_reason reason)
> +{
> +	struct wb_writeback_work *work;
> +	bool merged = false;
> +
> +	spin_lock_bh(&wb->work_lock);
> +	list_for_each_entry(work, &wb->work_list, list) {

Is the lenght of the list bounded somehow? In other words is it possible
that the spinlock would be held for too long to traverse the whole list?

> +		if (work->reason == reason &&
> +		    work->range_cyclic == range_cyclic &&
> +		    work->auto_free == 1 && work->sb == sb &&
> +		    work->for_sync == 0) {
> +			work->nr_pages += nr_pages;
> +			merged = true;
> +			trace_writeback_merged(wb, work);
> +			break;
> +		}
> +	}
> +	spin_unlock_bh(&wb->work_lock);
> +
> +	return merged;
> +}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
