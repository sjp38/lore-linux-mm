Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8091F6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 11:31:10 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id dh6so314194984obb.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 08:31:10 -0700 (PDT)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id b8si11392692igb.22.2016.05.23.08.31.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 08:31:09 -0700 (PDT)
Received: by mail-io0-x244.google.com with SMTP id a79so17894206ioe.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 08:31:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160523144711.GV2278@dhcp22.suse.cz>
References: <CADUS3okXhU5mW5Y2BC88zq2GtaVyK1i+i2uT34zHbWPw3hFPTA@mail.gmail.com>
	<20160523144711.GV2278@dhcp22.suse.cz>
Date: Mon, 23 May 2016 23:31:09 +0800
Message-ID: <CADUS3onEpdMF6Pi9-cHkf+hA6bqOc4mkXAci7ikeUhtaELx4WQ@mail.gmail.com>
Subject: Re: page order 0 allocation fail but free pages are enough
From: yoma sophian <sophian.yoma@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

hi Michal

2016-05-23 22:47 GMT+08:00, Michal Hocko <mhocko@kernel.org>:
> On Mon 23-05-16 14:47:51, yoma sophian wrote:
>> hi all:
>> I got something wired that
>> 1. in softirq, there is a page order 0 allocation request
>> 2. Normal/High zone are free enough for order 0 page.
>> 3. but somehow kernel return order 0 allocation fail.
>>
>> My kernel version is 3.10 and below is kernel log:
>> from memory info,
>
> Can you reproduce it with the current vanlilla tree?
I think it would be quite hard, since this allocation failuer comes
when a lot of program, such as Youtube, opera, etc. running on ARM
processor at the same time.
Or is there any patch in vanlilla tree I can used for checking?

>
> [...]
>> [   94.586588] ksoftirqd/0: page allocation failure: order:0, mode:0x20
> [...]
>> [   94.865776] Normal free:63768kB min:2000kB low:2500kB high:3000kB
> [...]
>> [ 8606.701343] CompositorTileW: page allocation failure: order:0,
>> mode:0x20
> [...]
>> [ 8606.703590] Normal free:60684kB min:2000kB low:2500kB high:3000kB
>
> This is a lot of free memory to block GFP_ATOMIC. One possible
> explanation would be that this is a race with somebody releasing a lot
I will try to add memory free at buffered_rmqueue like below xxx place
buffered_rmqueue -->
               if (likely(order == 0)) {
                ..................
                if (list_empty(list)) {
                        pcp->count += rmqueue_bulk(zone, 0,
                                        pcp->batch, list,
                                        migratetype, cold);
                        if (unlikely(list_empty(list)))
                                goto failed;    xxxxx ==>  to show
memory free info
                }


> of memory. The free memory is surprisingly similar in both cases.
Would you please give me any clue that free memory silimar hint the
race condition happen?

Many Appreciate your kind suggestion,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
