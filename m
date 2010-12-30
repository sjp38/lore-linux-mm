Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 663176B00A8
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 22:15:58 -0500 (EST)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id oBU3Fnb9008627
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 19:15:49 -0800
Received: from gwb11 (gwb11.prod.google.com [10.200.2.11])
	by hpaq7.eem.corp.google.com with ESMTP id oBU3FYrv009143
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 19:15:47 -0800
Received: by gwb11 with SMTP id 11so5590125gwb.25
        for <linux-mm@kvack.org>; Wed, 29 Dec 2010 19:15:47 -0800 (PST)
Date: Wed, 29 Dec 2010 19:15:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] writeback: skip balance_dirty_pages() for in-memory fs
In-Reply-To: <20101221093925.GA23110@localhost>
Message-ID: <alpine.LSU.2.00.1012291856110.14917@sister.anvils>
References: <20101213144646.341970461@intel.com> <20101213150329.002158963@intel.com> <20101217021934.GA9525@localhost> <alpine.LSU.2.00.1012162239270.23229@sister.anvils> <20101217112111.GA8323@localhost> <alpine.LSU.2.00.1012202127310.16112@tigran.mtv.corp.google.com>
 <20101221093925.GA23110@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 2010, Wu Fengguang wrote:
> 
> This avoids unnecessary checks and dirty throttling on tmpfs/ramfs.
> 
> It also prevents
> 
> [  388.126563] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050
> 
> in the balance_dirty_pages tracepoint, which will call
> 
> 	dev_name(mapping->backing_dev_info->dev)
> 
> but shmem_backing_dev_info.dev is NULL.
> 
> Summary notes about the tmpfs/ramfs behavior changes:
> 
> As for 2.6.36 and older kernels, the tmpfs writes will sleep inside
> balance_dirty_pages() as long as we are over the (dirty+background)/2
> global throttle threshold.  This is because both the dirty pages and
> threshold will be 0 for tmpfs/ramfs. Hence this test will always
> evaluate to TRUE:
> 
>                 dirty_exceeded =
>                         (bdi_nr_reclaimable + bdi_nr_writeback >= bdi_thresh)
>                         || (nr_reclaimable + nr_writeback >= dirty_thresh);
> 
> For 2.6.37, someone complained that the current logic does not allow the
> users to set vm.dirty_ratio=0.  So commit 4cbec4c8b9 changed the test to
> 
>                 dirty_exceeded =
>                         (bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
>                         || (nr_reclaimable + nr_writeback > dirty_thresh);
> 
> So 2.6.37 will behave differently for tmpfs/ramfs: it will never get
> throttled unless the global dirty threshold is exceeded (which is very
> unlikely to happen; once happen, will block many tasks).
> 
> I'd say that the 2.6.36 behavior is very bad for tmpfs/ramfs. It means
> for a busy writing server, tmpfs write()s may get livelocked! The
> "inadvertent" throttling can hardly bring help to any workload because
> of its "either no throttling, or get throttled to death" property.
> 
> So based on 2.6.37, this patch won't bring more noticeable changes.
> 
> CC: Hugh Dickins <hughd@google.com>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks a lot for investigating further and writing it all up here.

Acked-by: Hugh Dickins <hughd@google.com>

I notice bdi_cap_writeback_dirty go from bdi_writeout_fraction(), and
bdi_cap_account_dirty appear in balance_dirty_pages_ratelimited_nr():
maybe one day a patch to use just one flag throughout?  Unless you can
dream up a use for the divergence.  (I hate wasting brainpower trying to
decide which of two always-the-sames to use, like page_cache_release()
and put_page(), until there's actual code to distinguish them.)

Hugh

> ---
>  mm/page-writeback.c |   10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> --- linux-next.orig/mm/page-writeback.c	2010-12-18 09:14:53.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2010-12-21 17:35:44.000000000 +0800
> @@ -230,13 +230,8 @@ void task_dirty_inc(struct task_struct *
>  static void bdi_writeout_fraction(struct backing_dev_info *bdi,
>  		long *numerator, long *denominator)
>  {
> -	if (bdi_cap_writeback_dirty(bdi)) {
> -		prop_fraction_percpu(&vm_completions, &bdi->completions,
> +	prop_fraction_percpu(&vm_completions, &bdi->completions,
>  				numerator, denominator);
> -	} else {
> -		*numerator = 0;
> -		*denominator = 1;
> -	}
>  }
>  
>  static inline void task_dirties_fraction(struct task_struct *tsk,
> @@ -878,6 +873,9 @@ void balance_dirty_pages_ratelimited_nr(
>  {
>  	struct backing_dev_info *bdi = mapping->backing_dev_info;
>  
> +	if (!bdi_cap_account_dirty(bdi))
> +		return;
> +
>  	current->nr_dirtied += nr_pages_dirtied;
>  
>  	if (unlikely(!current->nr_dirtied_pause))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
