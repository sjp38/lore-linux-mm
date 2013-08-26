Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 447C76B0034
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 03:38:32 -0400 (EDT)
Date: Mon, 26 Aug 2013 16:39:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 0/5] zram/zsmalloc promotion
Message-ID: <20130826073918.GB30132@bbox>
References: <1377065791-2959-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377065791-2959-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>, lliubbo@gmail.com

Seem to lose this from mail bomb.
Ping.

On Wed, Aug 21, 2013 at 03:16:26PM +0900, Minchan Kim wrote:
> It's 7th trial of zram/zsmalloc promotion.
> I rewrote cover-letter totally based on previous discussion.
> 
> The main reason to prevent zram promotion was no review of
> zsmalloc part while Jens, block maintainer, already acked
> zram part.
> 
> At that time, zsmalloc was used for zram, zcache and zswap so
> everybody wanted to make it general and at last, Mel reviewed it
> when zswap was submitted to merge mainline a few month ago.
> Most of review was related to zswap writeback mechanism which
> can pageout compressed page in memory into real swap storage
> in runtime and the conclusion was that zsmalloc isn't good for
> zswap writeback so zswap borrowed zbud allocator from zcache to
> replace zsmalloc. The zbud is bad for memory compression ratio(2)
> but it's very predictable behavior because we can expect a zpage
> includes just two pages as maximum. Other reviews were not major. 
> http://lkml.indiana.edu/hypermail/linux/kernel/1304.1/04334.html
> 
> Zcache doesn't use zsmalloc either so zsmalloc's user is only
> zram now so this patchset moves it into zsmalloc directory.
> Recently, Bob tried to move zsmalloc under mm directory to unify
> zram and zswap with adding pseudo block device in zswap(It's
> very weired to me) but he was simple ignoring zram's block device
> (a.k.a zram-blk) feature and considered only swap usecase of zram,
> in turn, it lose zram's good concept.
> 
> Mel raised an another issue in v6, "maintainance headache".
> He claimed zswap and zram has a similar goal that is to compresss
> swap pages so if we promote zram, maintainance headache happens
> sometime by diverging implementaion between zswap and zram
> so that he want to unify zram and zswap. For it, he want zswap
> to implement pseudo block device like Bob did to emulate zram so
> zswap can have an advantage of writeback as well as zram's benefit.
> But I wonder frontswap-based zswap's writeback is really good
> approach for writeback POV. I think that problem isn't only
> specific for zswap. If we want to configure multiple swap hierarchy
> with various speed device such as RAM, NVRAM, SSD, eMMC, NAS etc,
> it would be a general problem. So we should think of more general
> approach. At a glance, I can see two approach.
> 
> First, VM could be aware of heterogeneous swap configuration
> so it could aim for being able to configure cache hierarchy
> among swap devices. It may need indirction layer on swap, which
> was already talked about that way so VM can migrate a block from 
> A to B easily. It will support various configuration with VM's
> hints, maybe, in future.
> http://lkml.indiana.edu/hypermail/linux/kernel/1203.3/03812.html
> 
> Second, as more practical solution, we could use device mapper like
> dm-cache(https://lwn.net/Articles/540996/), which makes it very
> flexible. Now, it supports various configruation and cache policy
> (block size, writeback/writethrough, LRU, MFU although MQ is merged
> now) so it would be good fit for our purpose. Even, it can make zram
> support writeback. I tested it following as following scenario
> in KVM 4 CPU, 1G DRAM with background 800M memory hogger, which is
> allocates random data up to 800M.
> 
> 1) zram swap disk 1G, untar kernel.tgz to tmpfs, build -j 4
>    Fail to untar due to shortage of memory space by tmpfs default size limit
> 
> 2) zram swap disk 1G, untar kernel.tgz to ext2 on zram-blk, build -j 4
>    OOM happens while building the kernel but it untar successfully
>    on ext2 based on zram-blk. The reason OOM happend is zram can not find
>    free pages from main memory to store swap out pages although empty
>    swap space is still enough.
> 
> 3) dm-cache swap disk 1G, untar kernel.tgz to ext2 on zram-blk, build -j 4
>    dmcache consists of zram-meta 10M, zram-cache 1G and real swap storage 1G
>    No OOM happens and successfully building done.
> 
> Above tests proves zram can support writeback into real swap storage
> so that zram-cache can always have a free space. If necessary, we could
> add new plugin in dm-cache. I see It's really flexible and well-layered
> architecure so zram-blk's concept is good for us and it has lots of
> potential to be enhanced by MM/FS/Block developers. 
> 
> As other disadvantage of zswap writeback, frontswap's semantic is
> synchronous API so zswap should decompress in memory zpage
> right before writeback and even, it writes pages one by one,
> not a batch. If we extend frontswap API, we would enhance it but
> I belive we can do better in device mapper layer which is aware of
> block align, bandwidth, mapping table, asynchronous and lots of hints
> from the block layer. Nonetheless, if we should merge zram's
> functionality to zswap, I think zram should include zswap's
> functionaliy(But I hope it will never happen) because old age zram
> already has lots of real users rather than new young zswap so it's
> more handy to unify them with keeping changelog which is one of
> valuable things getting from staging stay for a long time.
> 
> The reason zram doesn't support writeback until now is just shortage
> of needs. The zram's main customers were embedded people so writeback
> into real swap storage is too bad for interactivity and wear-leveling
> on low falsh devices. But like above, zram has a potential to support
> writeback with other block drivers or more reasonable VM enhance
> so I'd like to claim zram's block concept is really good.
> 
> Another zram-blk's usecase is following as.
> The admin can format /dev/zramX with any FS and mount on it.
> It could help small memory system, too. For exmaple, many embedded
> system don't have swap so although tmpfs can support swapout,
> it's pointless. Then, let's assume temp file growing up until half
> of system memory once in a while. We don't want to write it on flash
> by wear-leveing issue and response problem so we want to keep in-memory.
> But if we use tmpfs, it should evict half of working set to cover them
> when the size reach peak. In the case, zram-blk would be good fit, too.
> 
> I'd like to enhance zram with more features like compaction to prevent
> fragmentation problem but zram developers cannot do it now because Greg,
> staging maintainer, doesn't want to add new feature until promotion is
> done because zram have been in staging for a very long time. Acutally,
> some patches about enhance are pending for a long time.
> 
> It's time to promote and let's make further enhancements.
> 
> Patch 1 adds new Kconfig for zram to use page table method instead
> of copy. Andrew suggested it.
> 
> Patch 2 adds lots of comment for zsmalloc.
> 
> Patch 3 moves zsmalloc under driver/staging/zram because zram is only
> user for zram now.
> 
> Patch 4 makes unmap_kernel_range exportable function because zsmalloc
> have used map_vm_area which is already exported function so zsmalloc
> need to use unmap_kernel_range for building as module.
> 
> Patch 5 moves zram from driver/staging to driver/blocks, finally.
> 
> It touches mm, staging, blocks so I am not sure who is right position
> maintainer so I will Cc Andrew, Jens and Greg.
> 
> Minchan Kim (4):
>   zsmalloc: add Kconfig for enabling page table method
>   zsmalloc: move it under zram
>   mm: export unmap_kernel_range
>   zram: promote zram from staging
> 
> Nitin Cupta (1):
>   zsmalloc: add more comment
> 
>  drivers/block/Kconfig                    |    2 +
>  drivers/block/Makefile                   |    1 +
>  drivers/block/zram/Kconfig               |   37 +
>  drivers/block/zram/Makefile              |    3 +
>  drivers/block/zram/zram.txt              |   71 ++
>  drivers/block/zram/zram_drv.c            |  987 +++++++++++++++++++++++++++
>  drivers/block/zram/zsmalloc.c            | 1084 ++++++++++++++++++++++++++++++
>  drivers/staging/Kconfig                  |    4 -
>  drivers/staging/Makefile                 |    2 -
>  drivers/staging/zram/Kconfig             |   25 -
>  drivers/staging/zram/Makefile            |    3 -
>  drivers/staging/zram/zram.txt            |   77 ---
>  drivers/staging/zram/zram_drv.c          |  984 ---------------------------
>  drivers/staging/zram/zram_drv.h          |  125 ----
>  drivers/staging/zsmalloc/Kconfig         |   10 -
>  drivers/staging/zsmalloc/Makefile        |    3 -
>  drivers/staging/zsmalloc/zsmalloc-main.c | 1063 -----------------------------
>  drivers/staging/zsmalloc/zsmalloc.h      |   43 --
>  include/linux/zram.h                     |  123 ++++
>  include/linux/zsmalloc.h                 |   52 ++
>  mm/vmalloc.c                             |    1 +
>  21 files changed, 2361 insertions(+), 2339 deletions(-)
>  create mode 100644 drivers/block/zram/Kconfig
>  create mode 100644 drivers/block/zram/Makefile
>  create mode 100644 drivers/block/zram/zram.txt
>  create mode 100644 drivers/block/zram/zram_drv.c
>  create mode 100644 drivers/block/zram/zsmalloc.c
>  delete mode 100644 drivers/staging/zram/Kconfig
>  delete mode 100644 drivers/staging/zram/Makefile
>  delete mode 100644 drivers/staging/zram/zram.txt
>  delete mode 100644 drivers/staging/zram/zram_drv.c
>  delete mode 100644 drivers/staging/zram/zram_drv.h
>  delete mode 100644 drivers/staging/zsmalloc/Kconfig
>  delete mode 100644 drivers/staging/zsmalloc/Makefile
>  delete mode 100644 drivers/staging/zsmalloc/zsmalloc-main.c
>  delete mode 100644 drivers/staging/zsmalloc/zsmalloc.h
>  create mode 100644 include/linux/zram.h
>  create mode 100644 include/linux/zsmalloc.h
> 
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
