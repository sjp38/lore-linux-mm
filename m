Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 802006B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 00:05:13 -0400 (EDT)
Received: from il06vts01.mot.com (il06vts01.mot.com [129.188.137.141])
	by mdgate1.mot.com (8.14.3/8.14.3) with SMTP id o3145SrA003507
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 22:05:28 -0600 (MDT)
Received: from mail-iw0-f172.google.com (mail-iw0-f172.google.com [209.85.223.172])
	by mdgate1.mot.com (8.14.3/8.14.3) with ESMTP id o3142AHk002727
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 22:05:28 -0600 (MDT)
Received: by mail-iw0-f172.google.com with SMTP id 2so592363iwn.22
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 21:05:11 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 1 Apr 2010 12:05:10 +0800
Message-ID: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
Subject: [Question] race condition in mm/page_alloc.c regarding page->lru?
From: TAO HU <tghk48@motorola.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>
List-ID: <linux-mm.kvack.org>

Hi, all

We got a panic on our ARM (OMAP) based HW.
Our code is based on 2.6.29 kernel (last commit for mm/page_alloc.c is
cc2559bccc72767cb446f79b071d96c30c26439b)

It appears to crash while going through pcp->list in
buffered_rmqueue() of mm/page_alloc.c after checking vmlinux.
"00100100" implies LIST_POISON1 that suggests a race condition between
list_add() and list_del() in my personal view.
However we not yet figure out locking problem regarding page.lru.

Any known issues about race condition in mm/page_alloc.c?
And other hints are highly appreciated.

 /* Find a page of the appropriate migrate type */
                if (cold) {
                   ... ...
                } else {
                        list_for_each_entry(page, &pcp->list, lru)
                                if (page_private(page) == migratetype)
                                        break;
                }

<1>[120898.805267] Unable to handle kernel paging request at virtual
address 00100100
<1>[120898.805633] pgd = c1560000
<1>[120898.805786] [00100100] *pgd=897b3031, *pte=00000000, *ppte=00000000
<4>[120898.806457] Internal error: Oops: 17 [#1] PREEMPT
... ...
<4>[120898.807861] CPU: 0    Not tainted  (2.6.29-omap1 #1)
<4>[120898.808044] PC is at get_page_from_freelist+0x1d0/0x4b0
<4>[120898.808227] LR is at get_page_from_freelist+0xc8/0x4b0
<4>[120898.808563] pc : [<c00a600c>]    lr : [<c00a5f04>]    psr: 800000d3
<4>[120898.808563] sp : c49fbd18  ip : 00000000  fp : c49fbd74
<4>[120898.809020] r10: 00000000  r9 : 001000e8  r8 : 00000002
<4>[120898.809204] r7 : 001200d2  r6 : 60000053  r5 : c0507c4c  r4 : c49fa000
<4>[120898.809509] r3 : 001000e8  r2 : 00100100  r1 : c0507c6c  r0 : 00000001
<4>[120898.809844] Flags: Nzcv  IRQs off  FIQs off  Mode SVC_32  ISA
ARM  Segment kernel
<4>[120898.810028] Control: 10c5387d  Table: 82160019  DAC: 00000017
<4>[120898.948425] Backtrace:
<4>[120898.948760] [<c00a5e3c>] (get_page_from_freelist+0x0/0x4b0)
from [<c00a6398>] (__alloc_pages_internal+0xac/0x3e8)
<4>[120898.949554] [<c00a62ec>] (__alloc_pages_internal+0x0/0x3e8)
from [<c00b461c>] (handle_mm_fault+0x16c/0xbac)
<4>[120898.950347] [<c00b44b0>] (handle_mm_fault+0x0/0xbac) from
[<c00b51d0>] (__get_user_pages+0x174/0x2b4)
<4>[120898.951019] [<c00b505c>] (__get_user_pages+0x0/0x2b4) from
[<c00b534c>] (get_user_pages+0x3c/0x44)
<4>[120898.951812] [<c00b5310>] (get_user_pages+0x0/0x44) from
[<c00caf9c>] (get_arg_page+0x50/0xa4)
<4>[120898.952636] [<c00caf4c>] (get_arg_page+0x0/0xa4) from
[<c00cb1ec>] (copy_strings+0x108/0x210)
<4>[120898.953430]  r7:beffffe4 r6:00000ffc r5:00000000 r4:00000018
<4>[120898.954223] [<c00cb0e4>] (copy_strings+0x0/0x210) from
[<c00cb330>] (copy_strings_kernel+0x3c/0x74)
<4>[120898.955047] [<c00cb2f4>] (copy_strings_kernel+0x0/0x74) from
[<c00cc778>] (do_execve+0x18c/0x2b0)
<4>[120898.955841]  r5:0001e240 r4:0001e224
<4>[120898.956329] [<c00cc5ec>] (do_execve+0x0/0x2b0) from
[<c00400e4>] (sys_execve+0x3c/0x5c)
<4>[120898.957153] [<c00400a8>] (sys_execve+0x0/0x5c) from
[<c003ce80>] (ret_fast_syscall+0x0/0x2c)
<4>[120898.957946]  r7:0000000b r6:0001e270 r5:00000000 r4:0001d580
<4>[120898.958740] Code: e1530008 0a000006 e2429018 e1a03009 (e5b32018)



-- 
Best Regards
Hu Tao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
