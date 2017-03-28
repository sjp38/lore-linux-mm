Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62E946B03A0
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 10:59:44 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k190so54458795qkc.19
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 07:59:44 -0700 (PDT)
Received: from cmta19.telus.net (cmta19.telus.net. [209.171.16.92])
        by mx.google.com with ESMTPS id r50si3628737qtr.40.2017.03.28.07.59.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 07:59:43 -0700 (PDT)
From: "Doug Smythies" <dsmythies@telus.net>
References: <003401d2a750$19f98190$4dec84b0$@net> seARcwoAN7u9zseBQc4ACH sjvgc2nPK4O2IskG6cfF9m
In-Reply-To: sjvgc2nPK4O2IskG6cfF9m
Subject: RE: ksmd lockup - kernel 4.11-rc series
Date: Tue, 28 Mar 2017 07:59:38 -0700
Message-ID: <000601d2a7d3$ed040f50$c70c2df0$@net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: en-ca
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, 'Hugh Dickins' <hughd@google.com>, 'Doug Smythies' <dsmythies@telus.net>

This e-mail is just corrections and adding the previously missing
requested data.

As originally stated, I have had 4 occurrences of the issue.
All four were using kernel 4.11-rc2.
While there was an event with kernel 4.10, that event did not lock
up the computer with an NMI watchdog CPU stuck loop.
 
On 2017.03.27 23:05 Doug Smythies wrote:
> On 2017.03.27 16:36 Kirill A. Shutemov wrote:
>> On Mon, Mar 27, 2017 at 04:16:00PM -0700, Doug Smythies wrote:
> ... [cut]...
>>> 
>>> Log segment for one occurrence:
>>> 
>>> Mar 27 15:17:07 s15 kernel: [92420.587173] BUG: unable to handle kernel paging request at ffff88e680000000
>>> Mar 27 15:17:07 s15 kernel: [92420.587203] IP: page_vma_mapped_walk+0xe6/0x5b0
>>> Mar 27 15:17:07 s15 kernel: [92420.587217] PGD ac80a067
>>> Mar 27 15:17:07 s15 kernel: [92420.587217] PUD 41f5ff067
>>> Mar 27 15:17:07 s15 kernel: [92420.587226] PMD 0
>>
>> +Hugh.
>>
>> Thanks for report.
>>
>> It's likely I've screwed something up with my page_vma_mapped_walk()
>> transition. I don't see anything yet. And it's 2:30 AM. I'll look more
>> into it tomorrow.
>>
>> Meanwhile, could you check where the page_vma_mapped_walk+0xe6 is in your
>> build:
>>
>> ./scripts/faddr2line <your vmlinux> page_vma_mapped_walk+0xe6
>
> I do not seem to be able to extract what you want:
>
With thanks to Tetsuo Handa (and this would be for 4.11-rc4):

$ ./scripts/faddr2line vmlinux page_vma_mapped_walk+0xe6
page_vma_mapped_walk+0xe6/0x5b0:
page_vma_mapped_walk at ??:?

> Also that is not always the second line of the log files. Here are the other 3:
>
> Mar 26 07:08:22 s15 kernel: [134972.690834] BUG: unable to handle kernel paging request at ffffdbbb798c5c20
> Mar 26 07:08:22 s15 kernel: [134972.690870] IP: remove_migration_pte+0x98/0x250
> Mar 26 07:08:22 s15 kernel: [134972.690884] PGD 41edc8067
> Mar 26 07:08:22 s15 kernel: [134972.690884] PUD 0
>
> Mar 16 10:08:45 s15 kernel: [235319.418876] BUG: unable to handle kernel paging request at fffffa0503952ca0
> Mar 16 10:08:45 s15 kernel: [235319.418909] IP: remove_migration_pte+0x98/0x250
> Mar 16 10:08:45 s15 kernel: [235319.418922] PGD 41edc7067
> Mar 16 10:08:45 s15 kernel: [235319.418923] PUD 41edc6067
> Mar 16 10:08:45 s15 kernel: [235319.418932] PMD 0
>
> I can not seem to find the log for the 4.11-rc1 failure. I think I might have made a mistake
> in my initial report, as the first one might have been with kernel 4.10:
>
The below event did not result in a NMI watchdog loop, stuck CPU.

> Feb 28 16:40:11 s15 kernel: [173260.528872] BUG: unable to handle kernel paging request at ffffeadad27224e0
> Feb 28 16:40:11 s15 kernel: [173260.529350] IP: remove_migration_pte+0x98/0x250
> Feb 28 16:40:11 s15 kernel: [173260.529798] PGD 41edc8067
> Feb 28 16:40:11 s15 kernel: [173260.529798] PUD 41edc7067
> Feb 28 16:40:11 s15 kernel: [173260.530245] PMD 0
> Feb 28 16:40:11 s15 kernel: [173260.530723]
> Feb 28 16:40:11 s15 kernel: [173260.531615] Oops: 0000 [#1] SMP
> Feb 28 16:40:11 s15 kernel: [173260.532062] Modules linked in: ... [deleted]...
> Feb 28 16:40:11 s15 kernel: [173260.536349] CPU: 2 PID: 5386 Comm: qemu-system-x86 Not tainted 4.10.0-stock #214

The actual fourth event that resulted in an NMI watchdog loop, stuck CPU:

Mar 24 06:52:12 s15 kernel: [78279.182896] general protection fault: 0000 [#1] SMP
Mar 24 06:52:12 s15 kernel: [78279.182919] Modules linked in: ... [deleted]...
Mar 24 06:52:12 s15 kernel: [78279.183237] CPU: 2 PID: 9321 Comm: qemu-system-x86 Not tainted 4.11.0-rc2-doug #220
Mar 24 06:52:12 s15 kernel: [78279.183258] Hardware name: System manufacturer System Product Name/P8Z68-M PRO, BIOS 4003 05/09/2013
Mar 24 06:52:12 s15 kernel: [78279.183284] task: ffff94385c53c380 task.stack: ffffb9aa8c0e8000
Mar 24 06:52:12 s15 kernel: [78279.183303] RIP: 0010:check_pte+0x112/0x190
Mar 24 06:52:12 s15 kernel: [78279.183316] RSP: 0018:ffffb9aa8c0eb290 EFLAGS: 00010203
Mar 24 06:52:12 s15 kernel: [78279.183332] RAX: 0000000000000001 RBX: ffffb9aa8c0eb2e0 RCX: ffffb9aa8c0eb2e0
Mar 24 06:52:12 s15 kernel: [78279.183352] RDX: 01ffffffffffffff RSI: 00003fffffe00000 RDI: 00ffe9f2fb33da80
Mar 24 06:52:12 s15 kernel: [78279.183373] RBP: ffffb9aa8c0eb290 R08: 0000000000000000 R09: 0000000000000000
Mar 24 06:52:12 s15 kernel: [78279.183401] R10: ffffb9aa8aaba000 R11: 0000000000000001 R12: ffffea5ec41e01c0
Mar 24 06:52:12 s15 kernel: [78279.183421] R13: ffffea5ec41e01c0 R14: 00007fa872c0d200 R15: ffff943bc7d47540
Mar 24 06:52:12 s15 kernel: [78279.183450] FS:  00007f20ea335700(0000) GS:ffff943bdf280000(0000) knlGS:0000000000000000
Mar 24 06:52:12 s15 kernel: [78279.183473] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Mar 24 06:52:12 s15 kernel: [78279.183489] CR2: 00007f4c2cf7d000 CR3: 0000000280fbd000 CR4: 00000000000426e0
Mar 24 06:52:12 s15 kernel: [78279.183510] Call Trace:
Mar 24 06:52:12 s15 kernel: [78279.183520]  page_vma_mapped_walk+0x34f/0x5b0
Mar 24 06:52:12 s15 kernel: [78279.183535]  remove_migration_pte+0x58/0x250
Mar 24 06:52:12 s15 kernel: [78279.183549]  rmap_walk_ksm+0x100/0x190
Mar 24 06:52:12 s15 kernel: [78279.183561]  rmap_walk+0x4f/0x60
Mar 24 06:52:12 s15 kernel: [78279.183572]  remove_migration_ptes+0x53/0x70
Mar 24 06:52:12 s15 kernel: [78279.183586]  ? trace_event_raw_event_mm_migrate_pages+0xd0/0xd0
Mar 24 06:52:12 s15 kernel: [78279.183604]  migrate_pages+0x980/0xa50
Mar 24 06:52:12 s15 kernel: [78279.183617]  ? __ClearPageMovable+0x10/0x10

Doug Smythies


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
