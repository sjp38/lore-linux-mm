Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 08A736B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 07:42:12 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n3so9786958lfn.5
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:42:11 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id h35si22323709ljh.54.2016.10.18.04.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 04:42:10 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id b75so31902489lfg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:42:10 -0700 (PDT)
Date: Tue, 18 Oct 2016 13:42:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] bdi flusher should not be throttled here when it fall
 into buddy slow path
Message-ID: <20161018114207.GD12092@dhcp22.suse.cz>
References: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
 <20161018095912.GD22174@techsingularity.net>
 <1f606d0e-791b-31ea-94b2-2c9713b7c176@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1f606d0e-791b-31ea-94b2-2c9713b7c176@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, mingo@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, vbabka@suse.cz, vdavydov.dev@gmail.com, minchan@kernel.org, riel@redhat.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

On Tue 18-10-16 19:08:05, zhouxianrong wrote:
> Call trace:
> [<ffffffc0000863dc>] __switch_to+0x80/0x98
> [<ffffffc001160c58>] __schedule+0x314/0x854
> [<ffffffc0011611e0>] schedule+0x48/0xa4
> [<ffffffc0011648c4>] schedule_timeout+0x158/0x2c8
> [<ffffffc0011608b4>] io_schedule_timeout+0xbc/0x14c
> [<ffffffc0001aec84>] wait_iff_congested+0x1d4/0x1ec
> [<ffffffc0001a36b0>] shrink_inactive_list+0x530/0x760
> [<ffffffc0001a3e14>] shrink_lruvec+0x534/0x76c
> [<ffffffc0001a40d4>] shrink_zone+0x88/0x1b8
> [<ffffffc0001a4444>] do_try_to_free_pages+0x240/0x478
> [<ffffffc0001a4788>] try_to_free_pages+0x10c/0x284
> [<ffffffc0001968a4>] __alloc_pages_nodemask+0x540/0x918
> [<ffffffc0001dd0e8>] new_slab+0x334/0x4a0
> [<ffffffc0001df37c>] __slab_alloc.isra.75.constprop.77+0x6bc/0x780
> [<ffffffc0001df584>] kmem_cache_alloc+0x144/0x23c
> [<ffffffc00018f040>] mempool_alloc_slab+0x2c/0x38
> [<ffffffc00018f1f4>] mempool_alloc+0x7c/0x188
> [<ffffffc0003f462c>] bio_alloc_bioset+0x1cc/0x254
> [<ffffffc00022a430>] _submit_bh+0x74/0x1c8
> [<ffffffc00022c9d0>] __block_write_full_page.constprop.33+0x1a0/0x40c
> [<ffffffc00022cd1c>] block_write_full_page+0xe0/0x134
> [<ffffffc00022da64>] blkdev_writepage+0x30/0x3c
> [<ffffffc000197d08>] __writepage+0x34/0x74
> [<ffffffc000198880>] write_cache_pages+0x1e8/0x450
> [<ffffffc000198b3c>] generic_writepages+0x54/0x8c
> [<ffffffc00019a990>] do_writepages+0x40/0x6c
> [<ffffffc00021e604>] __writeback_single_inode+0x60/0x51c
> [<ffffffc00021eeec>] writeback_sb_inodes+0x2d4/0x46c
> [<ffffffc00021f128>] __writeback_inodes_wb+0xa4/0xe8
> [<ffffffc00021f480>] wb_writeback+0x314/0x3fc
> [<ffffffc000220224>] bdi_writeback_workfn+0x130/0x4e0
> [<ffffffc0000be4d4>] process_one_work+0x18c/0x51c
> [<ffffffc0000bedd8>] worker_thread+0x15c/0x51c
> [<ffffffc0000c5718>] kthread+0x10c/0x120
> 
> the above calltrace occured when write sdcard under large and long pressure.
> the patch is a performance issue. i hope flusher do not be throttled just here and
> let it reclaim the successive clean file pages or anonymous pages on lru list
> and then return to write left dirty pages of inode. it would speed up write-back
> speed of dirty pages. so other direct reclaimers can reclaim more clean pages.
> in low memory caused by big pagecache bdi writeback speed play a key role.

If we got here then we are hitting into dirty/writeback pages on the
tail of the LRU list and the bdi is congested. So there are no clean
pages most probably and the storage doesn't catch up with that IO.

Why do you think that not throttling would help here? Do you really see
that the further reclaim really makes forward progress or it just wastes
more CPU without doing a useful work?

In other words much more information please!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
