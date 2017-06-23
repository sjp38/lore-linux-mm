Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDB46B02F4
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 02:21:06 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u62so8346438lfg.6
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 23:21:06 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id g68si204272ljg.228.2017.06.22.23.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 23:21:04 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id f28so5052518lfi.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 23:21:04 -0700 (PDT)
MIME-Version: 1.0
From: Andrei Vagin <avagin@gmail.com>
Date: Thu, 22 Jun 2017 23:21:03 -0700
Message-ID: <CANaxB-zPGB8Yy9480pTFmj9HECGs3quq9Ak18aBUbx9TsNSsaw@mail.gmail.com>
Subject: linux-next: BUG: Bad page state in process ip6tables-save pfn:1499f4
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>

Hello,

We run CRIU tests for linux-next and today they triggered a kernel
bug. I want to mention that this kernel is built with kasan. This bug
was triggered in travis-ci. I can't reproduce it on my host. Without
kasan, kernel crashed but it is impossible to get a kernel log for
this case.

[  699.207570] BUG: Bad page state in process ip6tables-save  pfn:1499f4
[  699.214542] page:ffffea0005267d00 count:-1 mapcount:0 mapping:
    (null) index:0x1
[  699.222758] flags: 0x17fff8000000000()
[  699.226632] raw: 017fff8000000000 0000000000000000 0000000000000001
ffffffffffffffff
[  699.234495] raw: dead000000000100 dead000000000200 0000000000000000
0000000000000000
[  699.242359] page dumped because: nonzero _count
[  699.247006] Modules linked in:
[  699.247022] CPU: 0 PID: 19609 Comm: ip6tables-save Not tainted
4.12.0-rc6-next-20170622 #1
[  699.247029] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[  699.247035] Call Trace:
[  699.247054]  dump_stack+0x85/0xc2
[  699.247070]  bad_page+0xea/0x160
[  699.247086]  check_new_page_bad+0xc2/0xe0
[  699.247103]  get_page_from_freelist+0xfec/0x1270
[  699.247161]  __alloc_pages_nodemask+0x1cf/0x4b0
[  699.247188]  ? __alloc_pages_slowpath+0x1610/0x1610
[  699.247214]  ? mark_lock+0x6d/0x860
[  699.247223]  ? alloc_set_pte+0x7db/0x8f0
[  699.247247]  alloc_pages_vma+0x85/0x250
[  699.247270]  wp_page_copy+0x13c/0xad0
[  699.247285]  ? do_wp_page+0x292/0x9a0
[  699.247309]  ? lock_downgrade+0x2c0/0x2c0
[  699.247320]  ? __do_fault+0x140/0x140
[  699.247341]  ? do_raw_spin_unlock+0x88/0x130
[  699.247361]  do_wp_page+0x29a/0x9a0
[  699.247386]  ? finish_mkwrite_fault+0x250/0x250
[  699.247403]  ? do_raw_spin_lock+0x93/0x120
[  699.247427]  __handle_mm_fault+0xb94/0x1790
[  699.247450]  ? __pmd_alloc+0x270/0x270
[  699.247466]  ? find_held_lock+0x119/0x150
[  699.247528]  handle_mm_fault+0x235/0x490
[  699.247553]  __do_page_fault+0x332/0x680
[  699.247586]  do_page_fault+0x22/0x30
[  699.247601]  page_fault+0x28/0x30
[  699.247609] RIP: 0033:0x2aaea0abef2b
[  699.247616] RSP: 002b:00007ffe1deecd20 EFLAGS: 00010206
[  699.247628] RAX: 00002aaea12f6e60 RBX: 000000037ffff1a0 RCX: 0000000000000028
[  699.247635] RDX: 00002aaea12f6f10 RSI: 00002aaea0af0040 RDI: 00002aaea10ec000
[  699.247642] RBP: 00007ffe1deece70 R08: 000000006fffffff R09: 0000000070000021
[  699.247649] R10: 0000000000000031 R11: 000000006ffffdff R12: 00002aaea0af0000
[  699.247655] R13: 00007ffe1deecf40 R14: 0000000000000003 R15: 000000006ffffeff
[  699.247697] Disabling lock debugging due to kernel taint

Here is a whole log: https://goo.gl/5xekS3

Thanks,
Andrei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
