Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 47DE66B02F4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:03:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t3so3576422wme.9
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 00:03:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si13740638wrf.105.2017.06.27.00.03.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 00:03:08 -0700 (PDT)
Subject: Re: mmotm 2017-06-23-15-03 uploaded
From: Vlastimil Babka <vbabka@suse.cz>
References: <594d905d.geNp0UO7DULvNDPS%akpm@linux-foundation.org>
 <CAC=cRTNJe5Bo-1E+3oJEbWM8Yt5SyZOhnUiC9U5OK0GWrp1E0g@mail.gmail.com>
 <c3caa911-6e40-42a8-da4d-45243fb7f4ad@suse.cz>
Message-ID: <13ab3968-a7e4-add3-b050-438d462f7fc4@suse.cz>
Date: Tue, 27 Jun 2017 09:03:07 +0200
MIME-Version: 1.0
In-Reply-To: <c3caa911-6e40-42a8-da4d-45243fb7f4ad@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: huang ying <huang.ying.caritas@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.cz, Mark Brown <broonie@kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

[+CC Rasmus, sorry]

On 06/27/2017 09:01 AM, Vlastimil Babka wrote:
> On 06/27/2017 08:45 AM, huang ying wrote:
>> On Sat, Jun 24, 2017 at 6:04 AM,  <akpm@linux-foundation.org> wrote:
>>> * mm-page_allocc-eliminate-unsigned-confusion-in-__rmqueue_fallback.patch
>>
>> After git bisecting, find the above patch will cause the following bug
>> on i386 with memory eater + swap.
>>
>> [   10.657876] BUG: unable to handle kernel paging request at 001fe2b8
>> [   10.658412] IP: set_pfnblock_flags_mask+0x50/0x80
>> [   10.658779] *pde = 00000000
>> [   10.658779]
>> [   10.659126] Oops: 0000 [#1] SMP
>> [   10.659372] CPU: 0 PID: 1403 Comm: usemem Not tainted 4.12.0-rc6-mm1+ #12
>> [   10.659888] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
>> BIOS 1.10.2-1 04/01/2014
>> [   10.660522] task: f54a4c40 task.stack: f54ee000
>> [   10.660878] EIP: set_pfnblock_flags_mask+0x50/0x80
>> [   10.661246] EFLAGS: 00010006 CPU: 0
>> [   10.661517] EAX: 0007f8ae EBX: 00000000 ECX: 00000009 EDX: 00000200
>> [   10.661994] ESI: 001fe2b8 EDI: 00000e00 EBP: f54efd8c ESP: f54efd80
>> [   10.662473]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
>> [   10.662891] CR0: 80050033 CR2: 001fe2b8 CR3: 356a3000 CR4: 00000690
>> [   10.663378] Call Trace:
>> [   10.663577]  set_pageblock_migratetype+0x31/0x40
>> [   10.663933]  __rmqueue+0x367/0x560
>> [   10.664197]  get_page_from_freelist+0x5b7/0x8e0
>> [   10.664546]  __alloc_pages_nodemask+0x31a/0x1000
>> [   10.664913]  ? handle_mm_fault+0x1e8/0x840
>> [   10.665230]  handle_mm_fault+0x71d/0x840
>> [   10.665537]  __do_page_fault+0x175/0x400
>> [   10.665848]  ? vmalloc_sync_all+0x190/0x190
>> [   10.666173]  do_page_fault+0xb/0x10
>> [   10.666446]  common_exception+0x64/0x6a
>> [   10.666742] EIP: 0x8005e04c
>> [   10.666959] EFLAGS: 00010246 CPU: 0
>> [   10.667229] EAX: 07d47400 EBX: 80063000 ECX: bfc964d8 EDX: 67179000
>> [   10.667705] ESI: 07d47400 EDI: 07d47400 EBP: 00000000 ESP: bfc962cc
>> [   10.668180]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
>> [   10.668595]  ? vmalloc_sync_all+0x190/0x190
>> [   10.668922] Code: 8b 5b 28 25 00 fc ff ff 29 c1 89 c8 b9 1f 00 00
>> 00 2b 4d 08 c1 e8 0a c1 e0 02 89 c6 c1 e8 05 83 e6 1f 29 f1 8d 34 83
>> d3 e7 d3 e2 <8b> 1e f7 d7 eb 0c 8d 76 00 8d bc 27 00 00 00 00 89 c3 89
>> d9 89
>> [   10.670369] EIP: set_pfnblock_flags_mask+0x50/0x80 SS:ESP: 0068:f54efd80
>> [   10.670881] CR2: 00000000001fe2b8
>> [   10.671140] ---[ end trace f51518af57e6b531 ]---
>>
>> I think this comes from the signed and unsigned int comparison on
>> i386.  The gcc version is,
> 
> Yes, the unsigned vs signed comparison is wrong, and effectively the
> same problem as the previous wrong attempt, which removed the order >= 0
> condition. Thanks for the report.
> 
> However, the patch in mmotm seems to be missing this crucial hunk that
> Rasmus had in the patch he sent [1]:
> 
> -__rmqueue_fallback(struct zone *zone, unsigned int order, int
> start_migratetype)
> +__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> 
> which makes this a signed vs signed comparison.
> 
> What happened to it? Andrew?
> 
> [1] http://lkml.kernel.org/r/20170621185529.2265-1-linux@rasmusvillemoes.dk
> 
>> gcc (Debian 6.3.0-18) 6.3.0 20170516
>>
>> Best Regards,
>> Huang, Ying
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
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
