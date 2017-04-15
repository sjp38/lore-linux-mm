Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B407D6B03A0
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 20:40:18 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u195so57917058pgb.1
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 17:40:18 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id f66si3863436pgc.177.2017.04.14.17.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 17:40:17 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id 72so40536842pge.2
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 17:40:17 -0700 (PDT)
Date: Fri, 14 Apr 2017 17:40:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Make truncate_inode_pages_range() killable
In-Reply-To: <20170414215507.27682-1-bart.vanassche@sandisk.com>
Message-ID: <alpine.LSU.2.11.1704141726260.9676@eggly.anvils>
References: <20170414215507.27682-1-bart.vanassche@sandisk.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Mike Snitzer <snitzer@redhat.com>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, 14 Apr 2017, Bart Van Assche wrote:

> The default behavior of multipathd is to run kpartx against newly
> discovered paths. Avoid that these kpartx processes become unkillable
> if there are no paths left and when using queue_if_no_path. This patch
> avoids that kpartx sporadically hangs as follows:
> 
> Call Trace:
>  __schedule+0x3df/0xc10
>  schedule+0x3d/0x90
>  io_schedule+0x16/0x40
>  __lock_page+0x111/0x140
>  truncate_inode_pages_range+0x462/0x790
>  truncate_inode_pages+0x15/0x20
>  kill_bdev+0x35/0x40
>  __blkdev_put+0x76/0x220
>  blkdev_put+0x4e/0x170
>  blkdev_close+0x25/0x30
>  __fput+0xed/0x1f0
>  ____fput+0xe/0x10
>  task_work_run+0x85/0xc0
>  do_exit+0x311/0xc70
>  do_group_exit+0x50/0xd0
>  get_signal+0x2c7/0x930
>  do_signal+0x28/0x6b0
>  exit_to_usermode_loop+0x62/0xa0
>  do_syscall_64+0xda/0x140
>  entry_SYSCALL64_slow_path+0x25/0x25
> 
> Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Mike Snitzer <snitzer@redhat.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Hannes Reinecke <hare@suse.com>
> Cc: linux-mm@kvack.org

Changing a fundamental function, silently not to do its essential job,
when something in the kernel has forgotten (or is slow to) unlock_page():
that seems very wrong to me in many ways.  But linux-fsdevel, Cc'ed, will
be a better forum to advise on how to solve the problem you're seeing.

Hugh

> ---
>  mm/truncate.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 6263affdef88..91abd16d74f8 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -20,6 +20,7 @@
>  #include <linux/task_io_accounting_ops.h>
>  #include <linux/buffer_head.h>	/* grr. try_to_release_page,
>  				   do_invalidatepage */
> +#include <linux/sched/signal.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/cleancache.h>
>  #include <linux/rmap.h>
> @@ -366,7 +367,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  		return;
>  
>  	index = start;
> -	for ( ; ; ) {
> +	for ( ; !signal_pending_state(TASK_WAKEKILL, current); ) {
>  		cond_resched();
>  		if (!pagevec_lookup_entries(&pvec, mapping, index,
>  			min(end - index, (pgoff_t)PAGEVEC_SIZE), indices)) {
> @@ -400,7 +401,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  				continue;
>  			}
>  
> -			lock_page(page);
> +			if (lock_page_killable(page))
> +				break;
>  			WARN_ON(page_to_index(page) != index);
>  			wait_on_page_writeback(page);
>  			truncate_inode_page(mapping, page);
> -- 
> 2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
