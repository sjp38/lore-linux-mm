Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4786B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 10:50:34 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h89so90859569lfi.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:50:34 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id 195si9776875ljf.255.2017.03.13.07.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 07:50:32 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id y193so12043372lfd.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:50:32 -0700 (PDT)
Subject: Re: [mm/kasan] BUG: KASAN: slab-out-of-bounds in inotify_read at addr
 ffff88001539780c
References: <20170311135436.hh2pvivpiadkgdkr@wfg-t540p.sh.intel.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <899f0c39-81b5-5d02-5ced-937884d22c89@gmail.com>
Date: Mon, 13 Mar 2017 17:51:46 +0300
MIME-Version: 1.0
In-Reply-To: <20170311135436.hh2pvivpiadkgdkr@wfg-t540p.sh.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, LKP <lkp@01.org>, Dmitry Vyukov <dvyukov@google.com>



On 03/11/2017 04:54 PM, Fengguang Wu wrote:
> Hi Alexander,
> 
> FYI, here is another bisect result.
> 

Also wrong for the same reason as before.

> [   22.974867] debug: unmapping init [mem 0xffff8800023f5000-0xffff8800023fffff]
> [   40.729584] x86/mm: Checked W+X mappings: passed, no W+X pages found.
> [   40.743879] random: init: uninitialized urandom read (12 bytes read)
> [   40.754136] hostname (177) used greatest stack depth: 29632 bytes left
> [   40.791170] ==================================================================
> [   40.792751] BUG: KASAN: slab-out-of-bounds in inotify_read+0x1ac/0x2c6 at addr ffff88001539780c
> [   40.794614] Read of size 5 by task init/1

This is false-positive. According to dmesg this kernel was built with "gcc version 4.6.4 (Debian 4.6.4-7)".
As we recently discovered here - http://lkml.kernel.org/r/<1eb0b1ba-3847-9bdc-8f4a-adcd34de3486@gmail.com>
some old gcc versions such as 4.7.4 and now apparently 4.6.4 as well cause false-positives reports.
I'm guessing that old gcc miss-compile something in check_memory_region().

Given that kasan is fully supported only since gcc 5, could you teach the bot use only supported gcc 
for the runtime testing with kasan?

> [   40.795491] CPU: 0 PID: 1 Comm: init Not tainted 4.7.0-05999-g80a9201 #1
> [   40.796933] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
> [   40.798606]  ffffed0002a72f02 ffff88000004fcb8 ffffffff813fbc56 ffff88000004fd48
> [   40.799906]  ffffffff81125e14 ffff880000000000 ffff880000041300 0000000000000246
> [   40.801214]  0000000000000282 ffff880011331b00 0000000000000010 0000000000000246
> [   40.802505] Call Trace:
> [   40.802934]  [<ffffffff813fbc56>] dump_stack+0x19/0x1b
> [   40.803791]  [<ffffffff81125e14>] kasan_report+0x316/0x552
> [   40.804670]  [<ffffffff81124ca6>] check_memory_region+0x10b/0x10d
> [   40.805674]  [<ffffffff81124d7b>] kasan_check_read+0x11/0x13
> [   40.806623]  [<ffffffff81171647>] inotify_read+0x1ac/0x2c6
> [   40.807535]  [<ffffffff8108cda1>] ? wait_woken+0x76/0x76
> [   40.808425]  [<ffffffff811382b0>] __vfs_read+0x23/0xe3
> [   40.809270]  [<ffffffff813a372f>] ? security_file_permission+0x93/0x9c
> [   40.810351]  [<ffffffff81138406>] vfs_read+0x96/0x102
> [   40.811181]  [<ffffffff811387cb>] SyS_read+0x4e/0x94
> [   40.812010]  [<ffffffff81d379bd>] entry_SYSCALL_64_fastpath+0x23/0xc1
> [   40.813058] Object at ffff8800153977e0, in cache kmalloc-64
> [   40.813979] Object allocated with size 54 bytes.
> [   40.814697] Allocation:
> [   40.815123] PID = 189
> [   40.815514]  [<ffffffff81010c9f>] save_stack_trace+0x27/0x45
> [   40.816473]  [<ffffffff8112530e>] kasan_kmalloc+0xe5/0x16c
> [   40.817399]  [<ffffffff81123d1d>] __kmalloc+0x16c/0x17e
> [   40.818289]  [<ffffffff8117106e>] inotify_handle_event+0x80/0x10e
> [   40.819323]  [<ffffffff8116f8b0>] fsnotify+0x3c5/0x4f4
> [   40.820200]  [<ffffffff81145c5b>] vfs_link+0x1d8/0x210
> [   40.821070]  [<ffffffff81145dfb>] SyS_linkat+0x168/0x22c
> [   40.821981]  [<ffffffff81145ed8>] SyS_link+0x19/0x1b
> [   40.822805]  [<ffffffff81d379bd>] entry_SYSCALL_64_fastpath+0x23/0xc1
> [   40.823902] Memory state around the buggy address:
> [   40.824664]  ffff880015397700: fc fc fc fc 00 00 00 00 00 00 00 fc fc fc fc fc
> 
>                                                           # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
