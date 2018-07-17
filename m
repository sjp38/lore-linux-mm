Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 03E0F6B0006
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 23:14:07 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id i18-v6so35627087iog.12
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:14:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n130-v6sor1553504iod.292.2018.07.16.20.14.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 20:14:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu-qQOr5rLzdb-gTUD-QSOXQ=L7njO2Aqk4-jg5FD1kTgQ@mail.gmail.com>
References: <CA+55aFyARQV302+mXNYznrOOjzW+yxbcv+=OkD43dG6G1ktoMQ@mail.gmail.com>
 <alpine.DEB.2.21.1807140031440.2644@nanos.tec.linutronix.de>
 <CA+55aFzBx1haeM2QSFvhaW2t_HVK78Y=bKvsiJmOZztwkZ-y7Q@mail.gmail.com>
 <CA+55aFzVGa57apuzDMBLgWQQRcm3BNBs1UEg-G_2o7YW1i=o2Q@mail.gmail.com>
 <CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com>
 <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
 <CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
 <CA+55aFwD0cXbD6wW_2gs0kXRk-VsF05oE+4M6J=OoVj-wOOGSg@mail.gmail.com> <CAKv+Gu-qQOr5rLzdb-gTUD-QSOXQ=L7njO2Aqk4-jg5FD1kTgQ@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 17 Jul 2018 11:14:04 +0800
Message-ID: <CAKv+Gu_fgtYBtSaeW=B7oB0WEadge4wfytidPgr+209u_KaRqQ@mail.gmail.com>
Subject: Re: Instability in current -git tree
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Miller <davem@davemloft.net>, Al Viro <viro@zeniv.linux.org.uk>, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Ted Ts'o <tytso@google.com>, Mike Snitzer <snitzer@redhat.com>, linux-mm <linux-mm@kvack.org>, Daniel Vacek <neelx@redhat.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Mel Gorman <mgorman@techsingularity.net>

On 17 July 2018 at 10:59, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> On 14 July 2018 at 08:20, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>> On Fri, Jul 13, 2018 at 4:51 PM Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>>>
>>> I'm building a "replace VM_BUG_ON() with proper printk's instead" right now.
>>
>> Ok, the machine now stays up, and I get messages like
>>
>>   Removed VM_BUG_ON()!
>>      pfn c2400 - c25ff
>>      zone DMA32 DMA
>>      zone pfn 1000 1
>>
>>   Removed VM_BUG_ON()!
>>      pfn c0a00 - c0bff
>>      zone DMA32 DMA
>>      zone pfn 1000 1
>>
>>   Removed VM_BUG_ON()!
>>      pfn c2200 - c23ff
>>      zone DMA DMA32
>>      zone pfn 1 1000
>>
>> instead.
>>
>> That's from
>>
>> +               printk("Removed VM_BUG_ON()!\n");
>> +               printk("   pfn %lx - %lx\n", page_to_pfn(start_page),
>> page_to_pfn(end_page));
>> +               printk("   zone %s %s\n", page_zone(start_page)->name,
>> page_zone(end_page)->name);
>> +               printk("   zone pfn %lx %lx\n",
>> page_zone(start_page)->zone_start_pfn,
>> page_zone(end_page)->zone_start_pfn);
>>
>> inside an if() statement that replaced that VM_BUG_ON().
>>
>> WTF? That's just odd.
>>
>> But everything seems to work fine, and now it doesn't crash.
>>
>> But there's something really odd going on wrt page_zone() and/or page_to_pfn().
>>
>> page_to_pfn() implies this is just regular memory in the 3GB area. It
>> is likely related to this:
>>
>>  BIOS-e820: [mem 0x00000000c0b33000-0x00000000c226cfff] reserved
>>  BIOS-e820: [mem 0x00000000c226d000-0x00000000c227efff] ACPI data
>>  BIOS-e820: [mem 0x00000000c227f000-0x00000000c2439fff] usable
>>  BIOS-e820: [mem 0x00000000c243a000-0x00000000c2a61fff] ACPI NVS
>>  BIOS-e820: [mem 0x00000000c2a62000-0x00000000c32fefff] reserved
>>  BIOS-e820: [mem 0x00000000c32ff000-0x00000000c32fffff] usable
>>  BIOS-e820: [mem 0x00000000c3300000-0x00000000c7ffffff] reserved
>>
>> I dunno. It's a bit odd. I'm not sure I understand that VM_BUG_ON().
>> Adding Ard (who worked on the memblock_next_valid_pfn() thing not that
>> long ago) and must have hit this same BUG_ON() because he modified it
>> not that long ago.
>>
>> Ard, I triggered the VM_BUG_ON() in mm/page_alloc.c:2016, with a call trace opf
>>
>>   RIP: move_pfreepages_block()
>>   Call Trace:
>>     steal_suitable_fallback
>>     get_page_from_freelist
>>     ...
>>
>> just for some context.
>>
>
> Pavel's fix for this issue in commit e181ae0c5db9 is causing boot
> problems on i686 for me.
>
> Is anyone else seeing the same?
>
> I get no output whatsoever when booting a i386_defconfig kernel under
> qemu/kvm (without EFI)

Never mind, I spotted the followup fix.
