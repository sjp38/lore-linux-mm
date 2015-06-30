Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0960F6B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 11:21:12 -0400 (EDT)
Received: by wguu7 with SMTP id u7so12761586wgu.3
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 08:21:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10si12121034wic.87.2015.06.30.08.21.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 08:21:10 -0700 (PDT)
Date: Tue, 30 Jun 2015 17:21:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 30/51] writeback: implement and use inode_congested()
Message-ID: <20150630152105.GP7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-31-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-31-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:44, Tejun Heo wrote:
> In several places, bdi_congested() and its wrappers are used to
> determine whether more IOs should be issued.  With cgroup writeback
> support, this question can't be answered solely based on the bdi
> (backing_dev_info).  It's dependent on whether the filesystem and bdi
> support cgroup writeback and the blkcg the inode is associated with.
> 
> This patch implements inode_congested() and its wrappers which take
> @inode and determines the congestion state considering cgroup
> writeback.  The new functions replace bdi_*congested() calls in places
> where the query is about specific inode and task.
> 
> There are several filesystem users which also fit this criteria but
> they should be updated when each filesystem implements cgroup
> writeback support.
> 
> v2: Now that a given inode is associated with only one wb, congestion
>     state can be determined independent from the asking task.  Drop
>     @task.  Spotted by Vivek.  Also, converted to take @inode instead
>     of @mapping and renamed to inode_congested().
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Vivek Goyal <vgoyal@redhat.com>
> ---
>  fs/fs-writeback.c           | 29 +++++++++++++++++++++++++++++
>  include/linux/backing-dev.h | 22 ++++++++++++++++++++++
>  mm/fadvise.c                |  2 +-
>  mm/readahead.c              |  2 +-
>  mm/vmscan.c                 | 11 +++++------
>  5 files changed, 58 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 99a2440..7ec491b 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -142,6 +142,35 @@ static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  	wb_queue_work(wb, work);
>  }
>  
> +#ifdef CONFIG_CGROUP_WRITEBACK
> +
> +/**
> + * inode_congested - test whether an inode is congested
> + * @inode: inode to test for congestion
> + * @cong_bits: mask of WB_[a]sync_congested bits to test
> + *
> + * Tests whether @inode is congested.  @cong_bits is the mask of congestion
> + * bits to test and the return value is the mask of set bits.
> + *
> + * If cgroup writeback is enabled for @inode, the congestion state is
> + * determined by whether the cgwb (cgroup bdi_writeback) for the blkcg
> + * associated with @inode is congested; otherwise, the root wb's congestion
> + * state is used.
> + */
> +int inode_congested(struct inode *inode, int cong_bits)
> +{
> +	if (inode) {

Hum, is there any point in supporting NULL inode with inode_congested()?
That would look more like a programming bug than anything... Otherwise the
patch looks good to me so you can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
