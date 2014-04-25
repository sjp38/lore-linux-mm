Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 277E96B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 21:47:51 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so2208066pdj.4
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 18:47:50 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id tv5si3733970pbc.29.2014.04.24.18.47.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 24 Apr 2014 18:47:50 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N4K00GYJCZNN650@mailout2.samsung.com> for linux-mm@kvack.org;
 Fri, 25 Apr 2014 10:47:47 +0900 (KST)
Message-id: <1398390340.4283.36.camel@kjgkr>
Subject: [BUG] kmemleak on __radix_tree_preload
From: Jaegeuk Kim <jaegeuk.kim@samsung.com>
Reply-to: jaegeuk.kim@samsung.com
Date: Fri, 25 Apr 2014 10:45:40 +0900
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi mm folks,

When I was testing recent linus tree, I got several kmemleaks as below.
Could any of you guys guide how to fix this?
Thanks,

0. Test
 - fsstress on f2fs

1. Kernel version
commit 4d0fa8a0f01272d4de33704f20303dcecdb55df1
Merge: 39bfe90 b5539fa
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue Apr 22 09:28:02 2014 -0700

    Merge tag 'gpio-v3.15-2' of
git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-gpio
    
    Pull gpio fixes from Linus Walleij:

2. Bug
 This is one of the results, but all the results indicate
__radix_tree_preload.

unreferenced object 0xffff88002ae2a238 (size 576):
comm "fsstress", pid 25019, jiffies 4295651360 (age 2276.104s)
hex dump (first 32 bytes):
01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
40 7d 37 81 ff ff ff ff 50 a2 e2 2a 00 88 ff ff  @}7.....P..*....
backtrace:
 [<ffffffff8170e546>] kmemleak_alloc+0x26/0x50
 [<ffffffff8119feac>] kmem_cache_alloc+0xdc/0x190
 [<ffffffff81378709>] __radix_tree_preload+0x49/0xc0
 [<ffffffff813787a1>] radix_tree_maybe_preload+0x21/0x30
 [<ffffffff8114bbbc>] add_to_page_cache_lru+0x3c/0xc0
 [<ffffffff8114c778>] grab_cache_page_write_begin+0x98/0xf0
 [<ffffffffa02d3151>] f2fs_write_begin+0xa1/0x370 [f2fs]
 [<ffffffff8114af47>] generic_perform_write+0xc7/0x1e0
 [<ffffffff8114d230>] __generic_file_aio_write+0x1d0/0x400
 [<ffffffff8114d4c0>] generic_file_aio_write+0x60/0xe0
 [<ffffffff811b281a>] do_sync_write+0x5a/0x90
 [<ffffffff811b3575>] vfs_write+0xc5/0x1f0
 [<ffffffff811b3a92>] SyS_write+0x52/0xb0
 [<ffffffff81730912>] system_call_fastpath+0x16/0x1b
 [<ffffffffffffffff>] 0xffffffffffffffff


-- 
Jaegeuk Kim
Samsung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
