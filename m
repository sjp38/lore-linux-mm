Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C35F46B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:07:33 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id n5so39119034wmn.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:07:33 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id y41si12446308wmh.107.2016.01.27.10.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:07:32 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id n5so39118458wmn.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:07:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOxpaSVr2kAcBtN81DLK8Z9-MA-zOo9DG1mexkb=vVUxUVazrA@mail.gmail.com>
References: <CACT4Y+aBnm8VLe5f=AwO2nUoQZaH-UVqUynGB+naAC-zauOQsQ@mail.gmail.com>
 <CAOxpaSVr2kAcBtN81DLK8Z9-MA-zOo9DG1mexkb=vVUxUVazrA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 27 Jan 2016 19:07:12 +0100
Message-ID: <CACT4Y+Y1--HL4MyEk_0ZdBAac80LcdYc=rubWeeYtFUxe=D6ZQ@mail.gmail.com>
Subject: Re: mm: WARNING in __delete_from_page_cache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzkaller <syzkaller@googlegroups.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Junichi Nomura <j-nomura@ce.jp.nec.com>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Wed, Jan 27, 2016 at 7:02 PM, Ross Zwisler <zwisler@gmail.com> wrote:
> On Sun, Jan 24, 2016 at 3:48 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> Hello,
>>
>> The following program triggers WARNING in __delete_from_page_cache:
>>
>> ------------[ cut here ]------------
>> WARNING: CPU: 0 PID: 7676 at mm/filemap.c:217
>> __delete_from_page_cache+0x9f6/0xb60()
>> Modules linked in:
>> CPU: 0 PID: 7676 Comm: a.out Not tainted 4.4.0+ #276
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>  00000000ffffffff ffff88006d3f7738 ffffffff82999e2d 0000000000000000
>>  ffff8800620a0000 ffffffff86473d20 ffff88006d3f7778 ffffffff81352089
>>  ffffffff81658d36 ffffffff86473d20 00000000000000d9 ffffea0000009d60
>> Call Trace:
>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>  [<ffffffff82999e2d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
>>  [<ffffffff81352089>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:482
>>  [<ffffffff813522b9>] warn_slowpath_null+0x29/0x30 kernel/panic.c:515
>>  [<ffffffff81658d36>] __delete_from_page_cache+0x9f6/0xb60 mm/filemap.c:217
>>  [<ffffffff81658fb2>] delete_from_page_cache+0x112/0x200 mm/filemap.c:244
>>  [<ffffffff818af369>] __dax_fault+0x859/0x1800 fs/dax.c:487
>>  [<ffffffff8186f4f6>] blkdev_dax_fault+0x26/0x30 fs/block_dev.c:1730
>>  [<     inline     >] wp_pfn_shared mm/memory.c:2208
>>  [<ffffffff816e9145>] do_wp_page+0xc85/0x14f0 mm/memory.c:2307
>>  [<     inline     >] handle_pte_fault mm/memory.c:3323
>>  [<     inline     >] __handle_mm_fault mm/memory.c:3417
>
> Having inline functions represented in the stack trace and having file
> names with line numbers seems really useful - how did you get this
> output?  Is this a feature of some kernel patch applied for syzkaller?


I pipe normal kernel output through this script:
https://github.com/google/sanitizers/blob/master/address-sanitizer/tools/kasan_symbolize.py

If you are in linux source dir with vmlinux and modules, then you just do:
$ cat crash | kasan_symbolize.py

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
