Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 036276B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:03:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v190so4842045wme.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 06:03:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u16si2525615wrc.200.2017.03.15.06.03.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 06:03:06 -0700 (PDT)
Date: Wed, 15 Mar 2017 14:03:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: retry writepages() on ENOMEM when doing an data
 integrity writeback
Message-ID: <20170315130305.GJ32620@dhcp22.suse.cz>
References: <20170309090449.GD15874@quack2.suse.cz>
 <20170315050743.5539-1-tytso@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315050743.5539-1-tytso@mit.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Wed 15-03-17 01:07:43, Theodore Ts'o wrote:
> Currently, file system's writepages() function must not fail with an
> ENOMEM, since if they do, it's possible for buffered data to be lost.
> This is because on a data integrity writeback writepages() gets called
> but once, and if it returns ENOMEM and you're lucky the error will get
> reflected back to the userspace process calling fsync() --- at which
> point the application may or may not be properly checking error codes.
> If you aren't lucky, the user is unmounting the file system, and the
> dirty pages will simply be lost.
> 
> For this reason, file system code generally will use GFP_NOFS, and in
> some cases, will retry the allocation in a loop, on the theory that
> "kernel livelocks are temporary; data loss is forever".
> Unfortunately, this can indeed cause livelocks, since inside the
> writepages() call, the file system is holding various mutexes, and
> these mutexes may prevent the OOM killer from killing its targetted
> victim if it is also holding on to those mutexes.

The victim might be looping inside do_writepages now instead (especially
when the memory reserves are depleted), though. On the other hand the
recent OOM killer changes do not rely on the oom victim exiting anymore.
We try to reap as much memory from its address space as possible
which alone should help us to move on. Even if that is not sufficient we
will move on to another victim. So unless everything is in this path and
all the memory is sitting unreachable from the reapable address space we
should be safe.

> A better solution would be to allow writepages() to call the memory
> allocator with flags that give greater latitude to the allocator to
> fail, and then release its locks and return ENOMEM, and in the case of
> background writeback, the writes can be retried at a later time.  In
> the case of data-integrity writeback retry after waiting a brief
> amount of time.

yes that sounds reasonable to me. Btw. I was proposing
__GFP_RETRY_MAYFAIL recently [1] which sounds like a good fit here.

[1] http://lkml.kernel.org/r/20170307154843.32516-1-mhocko@kernel.org

> Signed-off-by: Theodore Ts'o <tytso@mit.edu>

The patch looks good to me be I am not familiar with all the callers to
be fully qualified to give my Acked-by

> ---
> 
> As we had discussed in an e-mail thread last week, I'm interested in
> allowing ext4_writepages() to return ENOMEM without causing dirty
> pages from buffered writes getting list.  It looks like doing so
> should be fairly straightforward.   What do folks think?
> 
>  mm/page-writeback.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 290e8b7d3181..8666d3f3c57a 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2352,10 +2352,16 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
>  
>  	if (wbc->nr_to_write <= 0)
>  		return 0;
> -	if (mapping->a_ops->writepages)
> -		ret = mapping->a_ops->writepages(mapping, wbc);
> -	else
> -		ret = generic_writepages(mapping, wbc);
> +	while (1) {
> +		if (mapping->a_ops->writepages)
> +			ret = mapping->a_ops->writepages(mapping, wbc);
> +		else
> +			ret = generic_writepages(mapping, wbc);
> +		if ((ret != ENOMEM) || (wbc->sync_mode != WB_SYNC_ALL))
> +			break;
> +		cond_resched();
> +		congestion_wait(BLK_RW_ASYNC, HZ/50);
> +	}
>  	return ret;
>  }
>  
> -- 
> 2.11.0.rc0.7.gbe5a750

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
