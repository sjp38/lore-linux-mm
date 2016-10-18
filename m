Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E1B216B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 07:11:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id q75so114794643itc.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:11:04 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id bb4si29405266pab.78.2016.10.18.04.11.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 04:11:04 -0700 (PDT)
Subject: Re: [PATCH] bdi flusher should not be throttled here when it fall
 into buddy slow path
References: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
 <20161018095912.GD22174@techsingularity.net>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <1f606d0e-791b-31ea-94b2-2c9713b7c176@huawei.com>
Date: Tue, 18 Oct 2016 19:08:05 +0800
MIME-Version: 1.0
In-Reply-To: <20161018095912.GD22174@techsingularity.net>
Content-Type: text/plain; charset="iso-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, mingo@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, vbabka@suse.cz, mhocko@suse.com, vdavydov.dev@gmail.com, minchan@kernel.org, riel@redhat.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

Call trace:
[<ffffffc0000863dc>] __switch_to+0x80/0x98
[<ffffffc001160c58>] __schedule+0x314/0x854
[<ffffffc0011611e0>] schedule+0x48/0xa4
[<ffffffc0011648c4>] schedule_timeout+0x158/0x2c8
[<ffffffc0011608b4>] io_schedule_timeout+0xbc/0x14c
[<ffffffc0001aec84>] wait_iff_congested+0x1d4/0x1ec
[<ffffffc0001a36b0>] shrink_inactive_list+0x530/0x760
[<ffffffc0001a3e14>] shrink_lruvec+0x534/0x76c
[<ffffffc0001a40d4>] shrink_zone+0x88/0x1b8
[<ffffffc0001a4444>] do_try_to_free_pages+0x240/0x478
[<ffffffc0001a4788>] try_to_free_pages+0x10c/0x284
[<ffffffc0001968a4>] __alloc_pages_nodemask+0x540/0x918
[<ffffffc0001dd0e8>] new_slab+0x334/0x4a0
[<ffffffc0001df37c>] __slab_alloc.isra.75.constprop.77+0x6bc/0x780
[<ffffffc0001df584>] kmem_cache_alloc+0x144/0x23c
[<ffffffc00018f040>] mempool_alloc_slab+0x2c/0x38
[<ffffffc00018f1f4>] mempool_alloc+0x7c/0x188
[<ffffffc0003f462c>] bio_alloc_bioset+0x1cc/0x254
[<ffffffc00022a430>] _submit_bh+0x74/0x1c8
[<ffffffc00022c9d0>] __block_write_full_page.constprop.33+0x1a0/0x40c
[<ffffffc00022cd1c>] block_write_full_page+0xe0/0x134
[<ffffffc00022da64>] blkdev_writepage+0x30/0x3c
[<ffffffc000197d08>] __writepage+0x34/0x74
[<ffffffc000198880>] write_cache_pages+0x1e8/0x450
[<ffffffc000198b3c>] generic_writepages+0x54/0x8c
[<ffffffc00019a990>] do_writepages+0x40/0x6c
[<ffffffc00021e604>] __writeback_single_inode+0x60/0x51c
[<ffffffc00021eeec>] writeback_sb_inodes+0x2d4/0x46c
[<ffffffc00021f128>] __writeback_inodes_wb+0xa4/0xe8
[<ffffffc00021f480>] wb_writeback+0x314/0x3fc
[<ffffffc000220224>] bdi_writeback_workfn+0x130/0x4e0
[<ffffffc0000be4d4>] process_one_work+0x18c/0x51c
[<ffffffc0000bedd8>] worker_thread+0x15c/0x51c
[<ffffffc0000c5718>] kthread+0x10c/0x120

the above calltrace occured when write sdcard under large and long pressure.
the patch is a performance issue. i hope flusher do not be throttled just here and
let it reclaim the successive clean file pages or anonymous pages on lru list
and then return to write left dirty pages of inode. it would speed up write-back
speed of dirty pages. so other direct reclaimers can reclaim more clean pages.
in low memory caused by big pagecache bdi writeback speed play a key role.


On 2016/10/18 17:59, Mel Gorman wrote:
> On Tue, Oct 18, 2016 at 03:12:45PM +0800, zhouxianrong@huawei.com wrote:
>> From: z00281421 <z00281421@notesmail.huawei.com>
>>
>> bdi flusher may enter page alloc slow path due to writepage and kmalloc.
>> in that case the flusher as a direct reclaimer should not be throttled here
>> because it can not to reclaim clean file pages or anaonymous pages
>> for next moment; furthermore writeback rate of dirty pages would be
>> slow down and other direct reclaimers and kswapd would be affected.
>> bdi flusher should be iosceduled by get_request rather than here.
>>
>> Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
>
> What does this patch do that PF_LESS_THROTTLE is not doing already if
> there is an underlying BDI?
>
> There have been a few patches like this recently that look like they might
> do something useful but are subtle. They really should be accompanied by
> a test case and data showing they either fix a functional issue (machine
> livelocking due to writeback not making progress) or a performance issue.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
