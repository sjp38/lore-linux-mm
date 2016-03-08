Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 34A286B0254
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 22:56:34 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id fz5so3249182obc.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 19:56:34 -0800 (PST)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id h17si608369oig.64.2016.03.07.19.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 19:56:33 -0800 (PST)
Received: by mail-oi0-x244.google.com with SMTP id m82so245136oif.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 19:56:33 -0800 (PST)
From: Li Zhang <zhlcindy@gmail.com>
Subject: [PATCH 0/2] mm: Enable page parallel initialisation for Power
Date: Tue,  8 Mar 2016 11:55:52 +0800
Message-Id: <1457409354-10867-1-git-send-email-zhlcindy@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

From: Li Zhang <zhlcindy@linux.vnet.ibm.com>

Uptream has supported page parallel initialisation for X86 and the
boot time is improved greately. Some tests have been done for Power.

Here is the result I have done with different memory size.

* 4GB memory:
    boot time is as the following: 
    with patch vs without patch: 10.4s vs 24.5s
    boot time is improved 57%
* 200GB memory: 
    boot time looks the same with and without patches.
    boot time is about 38s
* 32TB memory: 
    boot time looks the same with and without patches 
    boot time is about 160s.
    The boot time is much shorter than X86 with 24TB memory.
    From community discussion, it costs about 694s for X86 24T system.

>From code view, parallel initialisation improve the performance by
deferring memory initilisation to kswap with N kthreads, it should
improve the performance therotically. 

>From the test result, On X86, performance is improved greatly with huge
memory. But on Power platform, it is improved greatly with less than 
100GB memory. For huge memory, it is not improved greatly. But it saves 
the time with several threads at least, as the following information 
shows(32TB system log):

[   22.648169] node 9 initialised, 16607461 pages in 280ms
[   22.783772] node 3 initialised, 23937243 pages in 410ms
[   22.858877] node 6 initialised, 29179347 pages in 490ms
[   22.863252] node 2 initialised, 29179347 pages in 490ms
[   22.907545] node 0 initialised, 32049614 pages in 540ms
[   22.920891] node 15 initialised, 32212280 pages in 550ms
[   22.923236] node 4 initialised, 32306127 pages in 550ms
[   22.923384] node 12 initialised, 32314319 pages in 550ms
[   22.924754] node 8 initialised, 32314319 pages in 550ms
[   22.940780] node 13 initialised, 33353677 pages in 570ms
[   22.940796] node 11 initialised, 33353677 pages in 570ms
[   22.941700] node 5 initialised, 33353677 pages in 570ms
[   22.941721] node 10 initialised, 33353677 pages in 570ms
[   22.941876] node 7 initialised, 33353677 pages in 570ms
[   22.944946] node 14 initialised, 33353677 pages in 570ms
[   22.946063] node 1 initialised, 33345485 pages in 580ms

It saves the time about 550*16 ms at least, although it can be ignore to compare 
the boot time about 160 seconds. What's more, the boot time is much shorter 
on Power even without patches than x86 for huge memory machine. 

So this patchset is still necessary to be enabled for Power. 

Li Zhang (2):
  mm: meminit: initialise more memory for inode/dentry hash tables in
    early boot
  powerpc/mm: Enable page parallel initialisation

 arch/powerpc/Kconfig |  1 +
 mm/page_alloc.c      | 11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
