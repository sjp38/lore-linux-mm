Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 354AC6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 19:43:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so56769279pfb.0
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 16:43:30 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id kg11si14630898pab.171.2016.04.19.16.43.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 16:43:29 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id c20so11503659pfc.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 16:43:29 -0700 (PDT)
From: "Shi, Yang" <yang.shi@linaro.org>
Subject: [BUG linux-next] Kernel panic found with linux-next-20160414
Message-ID: <5716C29F.1090205@linaro.org>
Date: Tue, 19 Apr 2016 16:43:27 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, sfr@canb.auug.org.au, Hugh Dickins <hughd@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, yang.shi@linaro.org

Hi folks,

When I ran ltp on linux-next-20160414 on my ARM64 machine, I got the 
below kernel panic:

Unable to handle kernel paging request at virtual address ffffffc007846000
pgd = ffffffc01e21d000
[ffffffc007846000] *pgd=0000000000000000, *pud=0000000000000000
Internal error: Oops: 96000047 [#11] PREEMPT SMP
Modules linked in: loop
CPU: 7 PID: 274 Comm: systemd-journal Tainted: G      D 
4.6.0-rc3-next-20160414-WR8.0.0.0_standard+ #9
Hardware name: Freescale Layerscape 2085a RDB Board (DT)
task: ffffffc01e3fcf80 ti: ffffffc01ea8c000 task.ti: ffffffc01ea8c000
PC is at copy_page+0x38/0x120
LR is at migrate_page_copy+0x604/0x1660
pc : [<ffffff9008ff2318>] lr : [<ffffff900867cdac>] pstate: 20000145
sp : ffffffc01ea8ecd0
x29: ffffffc01ea8ecd0 x28: 0000000000000000
x27: 1ffffff7b80240f8 x26: ffffffc018196f20
x25: ffffffbdc01e1180 x24: ffffffbdc01e1180
x23: 0000000000000000 x22: ffffffc01e3fcf80
x21: ffffffc00481f000 x20: ffffff900a31d000
x19: ffffffbdc01207c0 x18: 0000000000000f00
x17: 0000000000000000 x16: 0000000000000000
x15: 0000000000000000 x14: 0000000000000000
x13: 0000000000000000 x12: 0000000000000000
x11: 0000000000000000 x10: 0000000000000000
x9 : 0000000000000000 x8 : 0000000000000000
x7 : 0000000000000000 x6 : 0000000000000000
x5 : 0000000000000000 x4 : 0000000000000000
x3 : 0000000000000000 x2 : 0000000000000000
x1 : ffffffc00481f080 x0 : ffffffc007846000

Call trace:
Exception stack(0xffffffc021fc2ed0 to 0xffffffc021fc2ff0)
2ec0:                                   ffffffbdc00887c0 ffffff900a31d000
2ee0: ffffffc021fc30f0 ffffff9008ff2318 0000000020000145 0000000000000025
2f00: ffffffbdc025a280 ffffffc020adc4c0 0000000041b58ab3 ffffff900a085fd0
2f20: ffffff9008200658 0000000000000000 0000000000000000 ffffffbdc00887c0
2f40: ffffff900b0f1320 ffffffc021fc3078 0000000041b58ab3 ffffff900a0864f8
2f60: ffffff9008210010 ffffffc021fb8960 ffffff900867bacc 1ffffff8043f712d
2f80: ffffffc021fc2fb0 ffffff9008210564 ffffffc021fc3070 ffffffc021fb8940
2fa0: 0000000008221f78 ffffff900862f9c8 ffffffc021fc2fe0 ffffff9008215dc8
2fc0: 1ffffff8043f8602 ffffffc021fc0000 ffffffc00968a000 ffffffc00221f080
2fe0: f9407e11d00001f0 d61f02209103e210
[<ffffff9008ff2318>] copy_page+0x38/0x120
[<ffffff900867de7c>] migrate_page+0x74/0x98
[<ffffff90089ba418>] nfs_migrate_page+0x58/0x80
[<ffffff900867dffc>] move_to_new_page+0x15c/0x4d8
[<ffffff900867eec8>] migrate_pages+0x7c8/0x11f0
[<ffffff90085f8724>] compact_zone+0xdfc/0x2570
[<ffffff90085f9f78>] compact_zone_order+0xe0/0x170
[<ffffff90085fb688>] try_to_compact_pages+0x2e8/0x8f8
[<ffffff90085913a0>] __alloc_pages_direct_compact+0x100/0x540
[<ffffff9008592420>] __alloc_pages_nodemask+0xc40/0x1c58
[<ffffff90086887e8>] khugepaged+0x468/0x19c8
[<ffffff9008301700>] kthread+0x248/0x2c0
[<ffffff9008206610>] ret_from_fork+0x10/0x40
Code: d281f012 91020021 f1020252 d503201f (a8000c02)


I did some initial investigation and found it is caused by 
DEBUG_PAGEALLOC and CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT. And, mainline 
4.6-rc3 works well.

It should be not arch specific although I got it caught on ARM64. I 
suspect this might be caused by Hugh's huge tmpfs patches.

Thanks,
Yang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
