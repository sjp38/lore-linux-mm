Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id A38946B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 14:07:23 -0400 (EDT)
Received: by qcbjx9 with SMTP id jx9so23490016qcb.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 11:07:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n80si2610203qkh.72.2015.03.27.11.07.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 11:07:22 -0700 (PDT)
Date: Fri, 27 Mar 2015 14:06:26 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 28/48] writeback: implement and use mapping_congested()
Message-ID: <20150327180626.GA19117@redhat.com>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
 <1427086499-15657-29-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427086499-15657-29-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

On Mon, Mar 23, 2015 at 12:54:39AM -0400, Tejun Heo wrote:
> In several places, bdi_congested() and its wrappers are used to
> determine whether more IOs should be issued.  With cgroup writeback
> support, this question can't be answered solely based on the bdi
> (backing_dev_info).  It's dependent on whether the filesystem and bdi
> support cgroup writeback and the blkcg the asking task belongs to.
> 
> This patch implements mapping_congested() and its wrappers which take
> @mapping and @task and determines the congestion state considering
> cgroup writeback for the combination.  The new functions replace
> bdi_*congested() calls in places where the query is about specific
> mapping and task.
> 
> There are several filesystem users which also fit this criteria but
> they should be updated when each filesystem implements cgroup
> writeback support.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Vivek Goyal <vgoyal@redhat.com>
> ---
>  fs/fs-writeback.c           | 39 +++++++++++++++++++++++++++++++++++++++
>  include/linux/backing-dev.h | 27 +++++++++++++++++++++++++++
>  mm/fadvise.c                |  2 +-
>  mm/readahead.c              |  2 +-
>  mm/vmscan.c                 | 12 ++++++------
>  5 files changed, 74 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 48db5e6..015f359 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -130,6 +130,45 @@ static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>  	wb_queue_work(wb, work);
>  }
>  
> +#ifdef CONFIG_CGROUP_WRITEBACK
> +
> +/**
> + * mapping_congested - test whether a mapping is congested for a task
> + * @mapping: address space to test for congestion
> + * @task: task to test congestion for
> + * @cong_bits: mask of WB_[a]sync_congested bits to test
> + *
> + * Tests whether @mapping is congested for @task.  @cong_bits is the mask
> + * of congestion bits to test and the return value is the mask of set bits.
> + *
> + * If cgroup writeback is enabled for @mapping, its congestion state for
> + * @task is determined by whether the cgwb (cgroup bdi_writeback) for the
> + * blkcg of %current on @mapping->backing_dev_info is congested; otherwise,
> + * the root's congestion state is used.
> + */
> +int mapping_congested(struct address_space *mapping,
> +		      struct task_struct *task, int cong_bits)
> +{
> +	struct inode *inode = mapping->host;
> +	struct backing_dev_info *bdi = inode_to_bdi(inode);
> +	struct bdi_writeback *wb;
> +	int ret = 0;
> +
> +	if (!inode || !inode_cgwb_enabled(inode))
> +		return wb_congested(&bdi->wb, cong_bits);
> +
> +	rcu_read_lock();
> +	wb = wb_find_current(bdi);

Hi Tejun,

I am wondering that why do we lookup bdi_writeback using blkcg of
task and why not use the bdi_writeback associated with inode?

IIUC, whole idea is to attach an inode to bdi_writeback (and
change it later if need be) and that writeback is used for
controlling IO to that inode. And blkcg associated with the
writeback will be put in bio which in turn will be used
by block layer.

IOW, blkcg of a bio gets decided by the bdi_writeback
attached to inode and current writer does not seem to
matter. So I am not sure why mapping_congested() should
take task's blkcg into consideration instead of just
taking bdi_writeback from inode and see if it is congested
or not.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
