Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8225D6B027C
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 04:36:56 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so46426808wjc.6
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 01:36:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si17777364wjd.181.2016.12.19.01.36.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Dec 2016 01:36:55 -0800 (PST)
Date: Fri, 16 Dec 2016 09:40:57 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 7/9] jbd2: make the whole kjournald2 kthread NOFS safe
Message-ID: <20161216084057.GE26608@quack2.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-8-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161215140715.12732-8-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu 15-12-16 15:07:13, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> kjournald2 is central to the transaction commit processing. As such any
> potential allocation from this kernel thread has to be GFP_NOFS. Make
> sure to mark the whole kernel thread GFP_NOFS by the memalloc_nofs_save.
> 
> Suggested-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/jbd2/journal.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
> index 8ed971eeab44..6dad8c5d6ddf 100644
> --- a/fs/jbd2/journal.c
> +++ b/fs/jbd2/journal.c
> @@ -206,6 +206,13 @@ static int kjournald2(void *arg)
>  	wake_up(&journal->j_wait_done_commit);
>  
>  	/*
> +	 * Make sure that no allocations from this kernel thread will ever recurse
> +	 * to the fs layer because we are responsible for the transaction commit
> +	 * and any fs involvement might get stuck waiting for the trasn. commit.
> +	 */
> +	memalloc_nofs_save();
> +
> +	/*
>  	 * And now, wait forever for commit wakeup events.
>  	 */
>  	write_lock(&journal->j_state_lock);
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
