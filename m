Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 94AC86B0261
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 19:31:42 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id d7so14325833wre.15
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 16:31:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k27sor960908wre.13.2018.01.17.16.31.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 16:31:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180109162633.GM1732@dhcp22.suse.cz>
References: <20180109153921.GA13070@techadventures.net> <20180109162633.GM1732@dhcp22.suse.cz>
From: Joonsoo Kim <js1304@gmail.com>
Date: Thu, 18 Jan 2018 09:31:39 +0900
Message-ID: <CAAmzW4M9JDLjP1mX-3_JAe3nymsxq=Dmc9fhgp9Chf9bkF5Jsg@mail.gmail.com>
Subject: Re: [PATCH] mm/page_owner: Remove drain_all_pages from init_early_allocated_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@techadventures.net>, Linux Memory Management List <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, ayush.m@samsung.com

2018-01-10 1:26 GMT+09:00 Michal Hocko <mhocko@suse.com>:
> [CC Joonsoo]
>
> On Tue 09-01-18 16:39:21, Oscar Salvador wrote:
>> When setting page_owner = on, the following warning can be seen in the boot log:
>>
>>  WARNING: CPU: 0 PID: 0 at mm/page_alloc.c:2537 drain_all_pages+0x171/0x1a0
>>  Modules linked in:
>>  CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.15.0-rc7-next-20180109-1-default+ #7
>>  Hardware name: Dell Inc. Latitude E7470/0T6HHJ, BIOS 1.11.3 11/09/2016
>>  RIP: 0010:drain_all_pages+0x171/0x1a0
>>  RSP: 0000:ffffffff82003ea8 EFLAGS: 00010246
>>  RAX: 000000000000000f RBX: ffffffffffffffff RCX: ffffffff8205b388
>>  RDX: 0000000000000001 RSI: 0000000000000096 RDI: 0000000000000202
>>  RBP: 0000000000000000 R08: 0000000000000000 R09: 00000000000000af
>>  R10: 0000000000000004 R11: 00000000000000ae R12: ffff88024dfdcec0
>>  R13: ffffffff82530740 R14: 0000000000000000 R15: 00000000a8831448
>>  FS:  0000000000000000(0000) GS:ffff88024dc00000(0000) knlGS:0000000000000000
>>  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>  CR2: ffff88024dfff000 CR3: 000000000200a001 CR4: 00000000000606b0
>>  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>  DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>>  Call Trace:
>>   init_page_owner+0x4e/0x260
>>   start_kernel+0x3e6/0x4a6
>>   ? set_init_arg+0x55/0x55
>>   secondary_startup_64+0xa5/0xb0
>>  Code: c5 ed ff 89 df 48 c7 c6 20 3b 71 82 e8 f9 4b 52 00 3b 05 d7 0b f8 00 89 c3 72 d5 5b 5d 41 5
>>  ---[ end trace 45da7f0cb4aef07b ]---
>>
>> This warning is showed because we are calling drain_all_pages() in
>> init_early_allocated_pages(), but mm_percpu_wq is not up yet,
>> it is being set up later on in kernel_init_freeable() -> init_mm_internals().
>
> I _think_ the patch is correct. The changelog should explain, _why_
> removing drain_all_pages is OK. Joonsoo what was the reason to put it
> here in the first place? I do not see any real reason. This is an init
> code and we shouldn't have any pages on those caches anyway. Moreover I
> fail to see why the fact they are on the pcp caches mattered at all.

I also _think_ the patch is correct. My intention is to move all the
free page from the pcp
to the buddy since init_early_allocated_pages() tries to distinguish
allocated page by
checking the buddy flag. However, this is an init code and batch
counter of the pcp would
be zero so there would be no free page on pcp.

Acked-by: iamjoonsoo.kim@lge.com

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
