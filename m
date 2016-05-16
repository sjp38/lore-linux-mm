Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B83D36B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 08:44:26 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so97653893lfd.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 05:44:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b193si19900933wmf.43.2016.05.16.05.44.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 05:44:25 -0700 (PDT)
Subject: Re: [BUG] Null pointer dereference when freeing pages on 4.6-rc6
References: <c1a35aab-1368-1164-f4e2-7e730acade15@linaro.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5739C0A7.6080906@suse.cz>
Date: Mon, 16 May 2016 14:44:23 +0200
MIME-Version: 1.0
In-Reply-To: <c1a35aab-1368-1164-f4e2-7e730acade15@linaro.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

[+CC Joonsoo based on git blame]

On 05/05/2016 11:13 PM, Shi, Yang wrote:
> Hi folks,
>
> When I enable the below kernel configs on 4.6-rc6, I came across null
> pointer deference issue in boot stage.
>
> CONFIG_SPARSEMEM
> CONFIG_DEFERRED_STRUCT_PAGE_INIT
> CONFIG_DEBUG_PAGEALLOC
> CONFIG_PAGE_EXTENSION
> CONFIG_DEBUG_VM
>
>
> The splat is:
>
> BUG: unable to handle kernel NULL pointer dereference at           (null)
> IP: [<ffffffff8118934b>] page_is_buddy+0x7b/0xe0
> PGD 0
> Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> Modules linked in:
> CPU: 3 PID: 106 Comm: pgdatinit1 Not tainted 4.6.0-rc6 #8
> Hardware name: Intel Corporation S5520HC/S5520HC, BIOS
> S5500.86B.01.10.0025.030220091519 03/02/2009
> task: ffff88017c1d0040 ti: ffff88017c1d4000 task.ti: ffff88017c1d4000
> RIP: 0010:[<ffffffff8118934b>]  [<ffffffff8118934b>] page_is_buddy+0x7b/0xe0
> RSP: 0000:ffff88017c1d7bf0  EFLAGS: 00010046
> RAX: 0000000000000000 RBX: ffffea0019810040 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffffea0019810040 RDI: 0000000000660401
> RBP: ffff88017c1d7c08 R08: 0000000000000001 R09: 0000000000000000
> R10: 00000000000001af R11: 0000000000000001 R12: ffffea0019810000
> R13: 0000000000000000 R14: 0000000000000009 R15: ffffea0019810000
> FS:  0000000000000000(0000) GS:ffff88066cc40000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000000 CR3: 0000000002406000 CR4: 00000000000006e0
> Stack:
>    0000000019810000 0000000000000000 ffff88066cfe6080 ffff88017c1d7c70
>    ffffffff8118bfea 0000000a00000000 0000160000000000 0000000000000001
>    0000000000000401 ffffea0019810040 0000000000000400 ffff88066cc5aca8
> Call Trace:
>    [<ffffffff8118bfea>] __free_one_page+0x23a/0x450
>    [<ffffffff8118c586>] free_pcppages_bulk+0x136/0x360
>    [<ffffffff8118cae8>] free_hot_cold_page+0x168/0x1b0
>    [<ffffffff8118cd8c>] __free_pages+0x5c/0x90
>    [<ffffffff8260fbf2>] __free_pages_boot_core.isra.70+0x11a/0x14d
>    [<ffffffff8260ff09>] deferred_free_range+0x50/0x62
>    [<ffffffff8261013b>] deferred_init_memmap+0x220/0x3c3
>    [<ffffffff8260ff1b>] ? deferred_free_range+0x62/0x62
>    [<ffffffff8108afc8>] kthread+0xf8/0x110
>    [<ffffffff81c026b2>] ret_from_fork+0x22/0x40
>    [<ffffffff8108aed0>] ? kthread_create_on_node+0x200/0x200
> Code: 75 7b 48 89 d8 8b 40 1c 85 c0 74 50 48 c7 c6 38 bd 0d 82 48 89 df
> e8 25 e2 02 00 0f 0b 48 89 f7 89 55 ec e8 18 cb 07 00 8b 55 ec <48> 8b
> 00 a8 02 74 9d 3b 53 30 75 98 49 8b 14 24 48 8b 03 48 c1
> RIP  [<ffffffff8118934b>] page_is_buddy+0x7b/0xe0
>    RSP <ffff88017c1d7bf0>
> CR2: 0000000000000000
> ---[ end trace e0c05a86b43d97f9 ]---
> note: pgdatinit1[106] exited with preempt_count 1
>
>
> I changed page_is_buddy and __free_one_page to non-inline to get more
> accurate stack trace.
>
>
> Then I did some investigation on it with printing the address of page
> and buddy, please see the below log:
>
> @@@@@@__free_one_page:715: page is at ffffea0005f05c00 buddy is at
> ffffea0005f05c80, order is 1
> @@@@@@__free_one_page:715: page is at ffffea0005f05c00 buddy is at
> ffffea0005f05d00, order is 2
> @@@@@@__free_one_page:715: page is at ffffea0005f05c00 buddy is at
> ffffea0005f05e00, order is 3
> @@@@@@__free_one_page:715: page is at ffffea0019810000 buddy is at
> ffffea0019810040, order is 0
>
> call trace splat
>
> @@@@@@__free_one_page:715: page is at ffffea0005f05bc0 buddy is at
> ffffea0005f05b80, order is 0
> @@@@@@__free_one_page:715: page is at ffffea0005f05b80 buddy is at
> ffffea0005f05bc0, order is 0
> @@@@@@__free_one_page:715: page is at ffffea0005f05b80 buddy is at
> ffffea0005f05b00, order is 1
> @@@@@@__free_one_page:715: page is at ffffea0005f05b40 buddy is at
> ffffea0005f05b00, order is 0
> @@@@@@__free_one_page:715: page is at ffffea0005f05b00 buddy is at
> ffffea0005f05b40, order is 0
>
> It shows just before the call trace splat, the page address jumped to
> ffffea0019810000 from ffffea0005f05xxx, not sure why this is happening.
> Any hint is appreciated.

I think the page address didn't jump, it was that the previous call of 
__free_one_page() finished at order=3 and now another one was invoked 
that started at order=0 page ffffea0019810000 and immediately hit the splat.

> And, reading the code leads me to the below call path:
>
> page_is_buddy()
> 	--> page_is_guard()
> 		--> lookup_page_ext()

 From a quick decodecode I guess that's indeed the path that's crashed. 
You could try verifying with e.g. addr2line on your vmlinux?

> Then lookup_page_ext() just returns null due to the below code:
>
> #if defined(CONFIG_DEBUG_VM) || defined(CONFIG_PAGE_POISONING)
>           /*
>            * The sanity checks the page allocator does upon freeing a
>            * page can reach here before the page_ext arrays are
>            * allocated when feeding a range of pages to the allocator
>            * for the first time during bootup or memory hotplug.
>            *
>            * This check is also necessary for ensuring page poisoning
>            * works as expected when enabled
>            */
>           if (!section->page_ext)
>                   return NULL;
> #endif
>
> So, according to the comment, it looks there should be a WARN or BUG if
> it returns NULL?

The comment reads like it's unlikely, but possible, so WARN/BUG doesn't 
sounds right.

> And, almost no codes check if the return pointer is
> null or not after lookup_page_ext() is called.

Yep, the callers related to DEBUG_VM (includes page_is_guard()) and page 
poisoning should probably check the return value. I hope Joonsoo knows 
something more here :)

> Thanks,
> Yang
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
