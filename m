Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 344B26B006E
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 11:41:03 -0400 (EDT)
Received: by oicf142 with SMTP id f142so15595620oic.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:41:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i79si1882869oig.54.2015.03.25.08.41.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 08:41:02 -0700 (PDT)
Date: Wed, 25 Mar 2015 11:40:22 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCHSET 1/3 v2 block/for-4.1/core] writeback: cgroup writeback
 support
Message-ID: <20150325154022.GC29728@redhat.com>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

On Mon, Mar 23, 2015 at 12:54:11AM -0400, Tejun Heo wrote:
> 
> 
> How to test
> -----------
> 
> * Boot with kernel option "cgroup__DEVEL__legacy_files_on_dfl".
> 
> * umount /sys/fs/cgroup/memory
>   umount /sys/fs/cgroup/blkio
>   mkdir /sys/fs/cgroup/unified
>   mount -t cgroup -o __DEVEL__sane_behavior cgroup /sys/fs/cgroup/unified
>   echo +blkio > /sys/fs/cgroup/unified/cgroup.subtree_control
> 
> * Build the cgroup hierarchy (don't forget to enable blkio using
>   subtree_control) and put processes in cgroups and run tests on ext2
>   filesystems and blkio.throttle.* knobs.
> 

[..]
> This patchset is on top of
> 
>   block/for-4.1/core bfd343aa1718 ("blk-mq: don't wait in blk_mq_queue_enter() if __GFP_WAIT isn't set")
> + [1] [PATCH] writeback: fix possible underflow in write bandwidth calculation
> 
> and available in the following git branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-20150322
> 

Hi Tejun,

Great Work. I tried to do some basic testing and it seems to work.

I used "review-cgroup-writeback-switch-20150322" branch for my testing.

I have 32G of RAM on my system and I setup a write bandwidth of 1MB/s
on the disk and allowed a dd to run. That dd quickly consumed 5G of
page cache before it reached to a steady state. Sounds like too much
of cache consumption which will be drained at a speed of 1MB/s. Not
sure if this is expected or bdi back-pressure is not being applied soon
enough.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
