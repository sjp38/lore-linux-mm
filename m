Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3EC56B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 03:59:33 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id c137so6830561pga.6
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 00:59:33 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l30si7251369pgc.404.2017.10.02.00.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 00:59:32 -0700 (PDT)
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
References: <20170905194739.GA31241@amd> <20171001093704.GA12626@amd>
 <20171001102647.GA23908@amd>
 <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
From: Adrian Hunter <adrian.hunter@intel.com>
Message-ID: <72c93a69-610f-027e-c028-379b97b6f388@intel.com>
Date: Mon, 2 Oct 2017 10:52:46 +0300
MIME-Version: 1.0
In-Reply-To: <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, pavel@ucw.cz
Cc: linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-mm@kvack.org, linus walleij <linus.walleij@linaro.org>

The memory allocation used to be optional but became mandatory with:

  commit 304419d8a7e9204c5d19b704467b814df8c8f5b1
  Author: Linus Walleij <linus.walleij@linaro.org>
  Date:   Thu May 18 11:29:32 2017 +0200

      mmc: core: Allocate per-request data using the block layer core

There is also a bug in mmc_init_request() where it doesn't free it's
allocations on the error path, so you might want to check if you are leaking
memory.

Bounce buffers are being removed from v4.15 although you may experience
performance regression with that:

	https://marc.info/?l=linux-mmc&m=150589778700551



On 01/10/17 13:57, Tetsuo Handa wrote:
> Pavel Machek wrote:
>> Hi!
>>
>>> I inserted u-SD card, only to realize that it is not detected as it
>>> should be. And dmesg indeed reveals:
>>
>> Tetsuo asked me to report this to linux-mm.
>>
>> But 2^4 is 16 pages, IIRC that can't be expected to work reliably, and
>> thus this sounds like MMC bug, not mm bug.
> 
> Yes, 16 pages is costly allocations which will fail without invoking the
> OOM killer. But I thought this is an interesting case, for mempool
> allocation should be able to handle memory allocation failure except
> initial allocations, and initial allocation is failing.
> 
> I think that using kvmalloc() (and converting corresponding kfree() to
> kvfree()) will make initial allocations succeed, but that might cause
> needlessly succeeding subsequent mempool allocations under memory pressure?
> 
>>
>>> [10994.299846] mmc0: new high speed SDHC card at address 0003
>>> [10994.302196] kworker/2:1: page allocation failure: order:4,
>>> mode:0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=(null)
>>> [10994.302212] CPU: 2 PID: 9500 Comm: kworker/2:1 Not tainted
>>> 4.14.0-rc2 #135
>>> [10994.302215] Hardware name: LENOVO 42872WU/42872WU, BIOS 8DET73WW
>>> (1.43 ) 10/12/2016
>>> [10994.302222] Workqueue: events_freezable mmc_rescan
>>> [10994.302227] Call Trace:
>>> [10994.302233]  dump_stack+0x4d/0x67
>>> [10994.302239]  warn_alloc+0xde/0x180
>>> [10994.302243]  __alloc_pages_nodemask+0xaa4/0xd30
>>> [10994.302249]  ? cache_alloc_refill+0xb73/0xc10
>>> [10994.302252]  cache_alloc_refill+0x101/0xc10
>>> [10994.302258]  ? mmc_init_request+0x2d/0xd0
>>> [10994.302262]  ? mmc_init_request+0x2d/0xd0
>>> [10994.302265]  __kmalloc+0xaf/0xe0
>>> [10994.302269]  mmc_init_request+0x2d/0xd0
>>> [10994.302273]  alloc_request_size+0x45/0x60
>>> [10994.302276]  ? free_request_size+0x30/0x30
>>> [10994.302280]  mempool_create_node+0xd7/0x130
>>> [10994.302283]  ? alloc_request_simple+0x20/0x20
>>> [10994.302287]  blk_init_rl+0xe8/0x110
>>> [10994.302290]  blk_init_allocated_queue+0x70/0x180
>>> [10994.302294]  mmc_init_queue+0xdd/0x370
>>> [10994.302297]  mmc_blk_alloc_req+0xf6/0x340
>>> [10994.302301]  mmc_blk_probe+0x18b/0x4e0
>>> [10994.302305]  mmc_bus_probe+0x12/0x20
>>> [10994.302309]  driver_probe_device+0x2f4/0x490
>>>
>>> Order 4 allocations are not supposed to be reliable...
>>>
>>> Any ideas?
>>>
>>> Thanks,
>>> 									Pavel
>>>
>>
>>
>>
>> -- 
>> (english) http://www.livejournal.com/~pavelmachek
>> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
