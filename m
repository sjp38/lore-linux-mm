Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9646D6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:05:35 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id r45so53047822qte.6
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 23:05:35 -0700 (PDT)
Received: from cmta16.telus.net (cmta16.telus.net. [209.171.16.89])
        by mx.google.com with ESMTPS id h49si2630125qtc.167.2017.03.27.23.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 23:05:34 -0700 (PDT)
From: "Doug Smythies" <dsmythies@telus.net>
References: <003401d2a750$19f98190$4dec84b0$@net> seARcwoAN7u9zseBQc4ACH
In-Reply-To: seARcwoAN7u9zseBQc4ACH
Subject: RE: ksmd lockup - kernel 4.11-rc series
Date: Mon, 27 Mar 2017 23:05:29 -0700
Message-ID: <003501d2a789$4e83bbe0$eb8b33a0$@net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: en-ca
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, 'Hugh Dickins' <hughd@google.com>, Doug Smythies <dsmythies@telus.net>

On 2017.03.27 16:36 Kirill A. Shutemov wrote:
> On Mon, Mar 27, 2017 at 04:16:00PM -0700, Doug Smythies wrote:
... [cut]...
>> 
>> Log segment for one occurrence:
>> 
>> Mar 27 15:17:07 s15 kernel: [92420.587173] BUG: unable to handle kernel paging request at ffff88e680000000
>> Mar 27 15:17:07 s15 kernel: [92420.587203] IP: page_vma_mapped_walk+0xe6/0x5b0
>> Mar 27 15:17:07 s15 kernel: [92420.587217] PGD ac80a067
>> Mar 27 15:17:07 s15 kernel: [92420.587217] PUD 41f5ff067
>> Mar 27 15:17:07 s15 kernel: [92420.587226] PMD 0
>
> +Hugh.
>
> Thanks for report.
>
> It's likely I've screwed something up with my page_vma_mapped_walk()
> transition. I don't see anything yet. And it's 2:30 AM. I'll look more
> into it tomorrow.
>
> Meanwhile, could you check where the page_vma_mapped_walk+0xe6 is in your
> build:
>
> ./scripts/faddr2line <your vmlinux> page_vma_mapped_walk+0xe6

I do not seem to be able to extract what you want:

$ ./scripts/faddr2line /boot/vmlinuz-4.11.0-rc2-stock page_vma_mapped_walk+0xe6
readelf: Error: Not an ELF file - it has the wrong magic bytes at the start
nm: /boot/vmlinuz-4.11.0-rc2-stock: Warning: Ignoring section flag IMAGE_SCN_MEM_NOT_PAGED in section .bss
nm: /boot/vmlinuz-4.11.0-rc2-stock: no symbols
nm: /boot/vmlinuz-4.11.0-rc2-stock: Warning: Ignoring section flag IMAGE_SCN_MEM_NOT_PAGED in section .bss
nm: /boot/vmlinuz-4.11.0-rc2-stock: no symbols
no match for page_vma_mapped_walk+0xe6

Also that is not always the second line of the log files. Here are the other 3:

Mar 26 07:08:22 s15 kernel: [134972.690834] BUG: unable to handle kernel paging request at ffffdbbb798c5c20
Mar 26 07:08:22 s15 kernel: [134972.690870] IP: remove_migration_pte+0x98/0x250
Mar 26 07:08:22 s15 kernel: [134972.690884] PGD 41edc8067
Mar 26 07:08:22 s15 kernel: [134972.690884] PUD 0

Mar 16 10:08:45 s15 kernel: [235319.418876] BUG: unable to handle kernel paging request at fffffa0503952ca0
Mar 16 10:08:45 s15 kernel: [235319.418909] IP: remove_migration_pte+0x98/0x250
Mar 16 10:08:45 s15 kernel: [235319.418922] PGD 41edc7067
Mar 16 10:08:45 s15 kernel: [235319.418923] PUD 41edc6067
Mar 16 10:08:45 s15 kernel: [235319.418932] PMD 0

I can not seem to find the log for the 4.11-rc1 failure. I think I might have made a mistake
in my initial report, as the first one might have been with kernel 4.10:

Feb 28 16:40:11 s15 kernel: [173260.528872] BUG: unable to handle kernel paging request at ffffeadad27224e0
Feb 28 16:40:11 s15 kernel: [173260.529350] IP: remove_migration_pte+0x98/0x250
Feb 28 16:40:11 s15 kernel: [173260.529798] PGD 41edc8067
Feb 28 16:40:11 s15 kernel: [173260.529798] PUD 41edc7067
Feb 28 16:40:11 s15 kernel: [173260.530245] PMD 0
Feb 28 16:40:11 s15 kernel: [173260.530723]
Feb 28 16:40:11 s15 kernel: [173260.531615] Oops: 0000 [#1] SMP
Feb 28 16:40:11 s15 kernel: [173260.532062] Modules linked in: ... [deleted]...
Feb 28 16:40:11 s15 kernel: [173260.536349] CPU: 2 PID: 5386 Comm: qemu-system-x86 Not tainted 4.10.0-stock #214

Doug Smythies


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
