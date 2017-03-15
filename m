Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE4B6B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 07:59:37 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y90so2601313wrb.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 04:59:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si2348147wrd.12.2017.03.15.04.59.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 04:59:35 -0700 (PDT)
Date: Wed, 15 Mar 2017 12:59:33 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH] mm: retry writepages() on ENOMEM when doing an data
 integrity writeback
Message-ID: <20170315115933.GF12989@quack2.suse.cz>
References: <20170309090449.GD15874@quack2.suse.cz>
 <20170315050743.5539-1-tytso@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315050743.5539-1-tytso@mit.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Wed 15-03-17 01:07:43, Ted Tso wrote:
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
> 
> A better solution would be to allow writepages() to call the memory
> allocator with flags that give greater latitude to the allocator to
> fail, and then release its locks and return ENOMEM, and in the case of
> background writeback, the writes can be retried at a later time.  In
> the case of data-integrity writeback retry after waiting a brief
> amount of time.
> 
> Signed-off-by: Theodore Ts'o <tytso@mit.edu>
> ---
> 
> As we had discussed in an e-mail thread last week, I'm interested in
> allowing ext4_writepages() to return ENOMEM without causing dirty
> pages from buffered writes getting list.  It looks like doing so
> should be fairly straightforward.   What do folks think?

Makes sense to me. One comment below:


> +	while (1) {
> +		if (mapping->a_ops->writepages)
> +			ret = mapping->a_ops->writepages(mapping, wbc);
> +		else
> +			ret = generic_writepages(mapping, wbc);
> +		if ((ret != ENOMEM) || (wbc->sync_mode != WB_SYNC_ALL))

-ENOMEM I guess...


> +			break;
> +		cond_resched();
> +		congestion_wait(BLK_RW_ASYNC, HZ/50);
> +	}
>  	return ret;
>  }

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
