Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0ECEF6B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 04:01:47 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id u128so5380774vkg.9
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 01:01:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z142sor6428737itb.146.2017.10.04.01.01.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 01:01:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACRpkdYPn3xxZQP+xXggPpoHercBL3L7dmMBnbXww5SEsFx5tg@mail.gmail.com>
References: <20170905194739.GA31241@amd> <20171001093704.GA12626@amd>
 <20171001102647.GA23908@amd> <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
 <CACRpkdYirC+rh_KALgVqKZMjq2DgbW4oi9MJkmrzwn+1O+94-g@mail.gmail.com>
 <7b423dc8-00aa-9cde-3557-8c72863001fd@intel.com> <CACRpkdYPn3xxZQP+xXggPpoHercBL3L7dmMBnbXww5SEsFx5tg@mail.gmail.com>
From: Ulf Hansson <ulf.hansson@linaro.org>
Date: Wed, 4 Oct 2017 10:01:45 +0200
Message-ID: <CAPDyKFo+KehnATz5RWJN0JngZAYdCEd-EEjXbv9y8oU_Q1Leaw@mail.gmail.com>
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>, Adrian Hunter <adrian.hunter@intel.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Pavel Machek <pavel@ucw.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-mm@kvack.org

On 4 October 2017 at 09:53, Linus Walleij <linus.walleij@linaro.org> wrote:
> On Tue, Oct 3, 2017 at 8:30 AM, Adrian Hunter <adrian.hunter@intel.com> wrote:
>> On 02/10/17 17:09, Linus Walleij wrote:
>>> On Sun, Oct 1, 2017 at 12:57 PM, Tetsuo Handa
>>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>>
>>>>>> I inserted u-SD card, only to realize that it is not detected as it
>>>>>> should be. And dmesg indeed reveals:
>>>>>
>>>>> Tetsuo asked me to report this to linux-mm.
>>>>>
>>>>> But 2^4 is 16 pages, IIRC that can't be expected to work reliably, and
>>>>> thus this sounds like MMC bug, not mm bug.
>>>
>>>
>>> I'm not sure I fully understand this error message:
>>> "worker/2:1: page allocation failure: order:4"
>>>
>>> What I guess from context is that the mmc_init_request()
>>> call is failing to allocate 16 pages, meaning for 4K pages
>>> 64KB which is the typical bounce buffer.
>>>
>>> This is what the code has always allocated as bounce buffer,
>>> but it used to happen upfront, when probing the MMC block layer,
>>> rather than when allocating the requests.
>>
>> That is not exactly right.  As I already wrote, the memory allocation used
>> to be optional but became mandatory with:
>>
>>   commit 304419d8a7e9204c5d19b704467b814df8c8f5b1
>>   Author: Linus Walleij <linus.walleij@linaro.org>
>>   Date:   Thu May 18 11:29:32 2017 +0200
>>
>>       mmc: core: Allocate per-request data using the block layer core
>
> Yes you are right, it used to look like this, with the bounce buffer
> hiding behind a Kconfig symbol:
>
> #ifdef CONFIG_MMC_BLOCK_BOUNCE
>     if (host->max_segs == 1) {
>         unsigned int bouncesz;
>
>         bouncesz = MMC_QUEUE_BOUNCESZ;
>
>         if (bouncesz > host->max_req_size)
>             bouncesz = host->max_req_size;
>         if (bouncesz > host->max_seg_size)
>             bouncesz = host->max_seg_size;
>         if (bouncesz > (host->max_blk_count * 512))
>             bouncesz = host->max_blk_count * 512;
>
>         if (bouncesz > 512 &&
>             mmc_queue_alloc_bounce_bufs(mq, bouncesz)) {
>             blk_queue_bounce_limit(mq->queue, BLK_BOUNCE_ANY);
>             blk_queue_max_hw_sectors(mq->queue, bouncesz / 512);
>             blk_queue_max_segments(mq->queue, bouncesz / 512);
>             blk_queue_max_segment_size(mq->queue, bouncesz);
>
>             ret = mmc_queue_alloc_bounce_sgs(mq, bouncesz);
>             if (ret)
>                 goto cleanup_queue;
>             bounce = true;
>         }
>     }
> #endif
>
> I recently concluded that I find no evidence whatsoever that anyone
> turned this symbol on. Actually. (Checked defconfigs and distro configs.)
> The option was just sitting there unused.
> This code was never exercised except by some people who turned it
> on on their custom kernels in the past. It's in practice dead code.
>
> My patch started to allocate and use bounce buffers for all hosts
> with max_segs == 1, unless specifically flagged NOT to use bounce
> buffers.
>
> That wasn't smart, I should have just deleted them. Mea culpa.
>
> So that is why I asked Ulf to simply put the patch deleting the bounce
> buffers that noone is using to fixes, and it should fix this problem.

Adrian, Linus,

Thanks for looking into the problem! I am queuing up the patch
deleting bounce buffers for fixes asap!

Kind regards
Uffe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
