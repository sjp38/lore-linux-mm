Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1832F6B0005
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 09:21:31 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id t188so606043qkf.6
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 06:21:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m6sor189365qti.4.2018.02.04.06.21.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Feb 2018 06:21:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180203013455.GA739@jagdpanzerIV>
References: <20180130114841.aa2d3bd99526c03c6a5b5810@linux-foundation.org> <20180203013455.GA739@jagdpanzerIV>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Sun, 4 Feb 2018 22:21:29 +0800
Message-ID: <CAC=cRTPyh-JTY=uOQf2dgmyPDyY-4+ryxkedp-iZMcFQZtnaqw@mail.gmail.com>
Subject: Re: bisected bd4c82c22c367e is the first bad commit (was [Bug 198617]
 New: zswap causing random applications to crash)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi, Sergey,

Thanks for reporting!

On Sat, Feb 3, 2018 at 9:34 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hello,
>
> On (01/30/18 11:48), Andrew Morton wrote:
>> Subject: [Bug 198617] New: zswap causing random applications to crash
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=198617
>>
>>             Bug ID: 198617
>>            Summary: zswap causing random applications to crash
>>            Product: Memory Management
>>            Version: 2.5
>>     Kernel Version: 4.14.15
>>           Hardware: x86-64
>>                 OS: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Page Allocator
>>           Assignee: akpm@linux-foundation.org
>>           Reporter: kernel_org@dlk.pl
>>         Regression: No
>>
>> https://bugs.freedesktop.org/show_bug.cgi?id=104709
>> https://bugs.kde.org/show_bug.cgi?id=389542
>>
>> I did have zswap enabled for a long while, and a lot of wine games,
>> plasmashell, xorg, kwin_x11 (and other) did crash randomly when reached 100% of
>> physical ram and swap was like almost never used.
>>
>> I could esilly open a lot of browser tabs and the browser or xorg would fail
>> every time.
>>
>> After disabling zswap no crashes at all.
>>
>> /etc/systemd/swap.conf
>> zswap_enabled=1
>> zswap_compressor=lz4      # lzo lz4
>> zswap_max_pool_percent=25 # 1-99
>> zswap_zpool=zbud          # zbud z3fold
>
>
> So I did a number of tests and I confirm that under memory pressure
> with frontswap enabled I do see segfaults and memory corruptions in
> random user space applications.
>
> kernel: urxvt[338]: segfault at 20 ip 00007fc08889ae0d sp 00007ffc73a7fc40 error 6 in libc-2.26.so[7fc08881a000+1ae000]
>  #0  0x00007fc08889ae0d _int_malloc (libc.so.6)
>  #1  0x00007fc08889c2f3 malloc (libc.so.6)
>  #2  0x0000560e6004bff7 _Z14rxvt_wcstoutf8PKwi (urxvt)
>  #3  0x0000560e6005e75c n/a (urxvt)
>  #4  0x0000560e6007d9f1 _ZN16rxvt_perl_interp6invokeEP9rxvt_term9hook_typez (urxvt)
>  #5  0x0000560e6003d988 _ZN9rxvt_term9cmd_parseEv (urxvt)
>  #6  0x0000560e60042804 _ZN9rxvt_term6pty_cbERN2ev2ioEi (urxvt)
>  #7  0x0000560e6005c10f _Z17ev_invoke_pendingv (urxvt)
>  #8  0x0000560e6005cb55 ev_run (urxvt)
>  #9  0x0000560e6003b9b9 main (urxvt)
>  #10 0x00007fc08883af4a __libc_start_main (libc.so.6)
>  #11 0x0000560e6003f9da _start (urxvt)
>
> kernel: urxvt[343]: segfault at 10 ip 00007fa56bd7d52b sp 00007ffc09783a40 error 4 in libc-2.26.so[7fa56bcfd000+1ae000]
>  #0  0x00007fa56bd7d52b _int_malloc (libc.so.6)
>  #1  0x00007fa56bd7f2f3 malloc (libc.so.6)
>  #2  0x00007fa56b3d6097 n/a (libxcb.so.1)
>  #3  0x00007fa56b3d64d8 n/a (libxcb.so.1)
>  #4  0x00007fa56c921b79 n/a (libX11.so.6)
>  #5  0x00007fa56c921ceb n/a (libX11.so.6)
>  #6  0x00007fa56c921fdd _XEventsQueued (libX11.so.6)
>  #7  0x00007fa56c913c49 XEventsQueued (libX11.so.6)
>  #8  0x000055b35cfc3262 _ZN12rxvt_display8flush_cbERN2ev7prepareEi (urxvt)
>  #9  0x000055b35cfc910f _Z17ev_invoke_pendingv (urxvt)
>  #10 0x000055b35cfc9c02 ev_run (urxvt)
>  #11 0x000055b35cfa89b9 main (urxvt)
>  #12 0x00007fa56bd1df4a __libc_start_main (libc.so.6)
>  #13 0x000055b35cfac9da _start (urxvt)
>
>  Stack trace of thread 351:
>  #0  0x00007f5baaee7860 raise (libc.so.6)
>  #1  0x00007f5baaee8ec9 abort (libc.so.6)
>  #2  0x00007f5baaf30849 __malloc_assert (libc.so.6)
>  #3  0x00007f5baaf34011 _int_malloc (libc.so.6)
>  #4  0x00007f5baaf352f3 malloc (libc.so.6)
>  #5  0x00007f5baaf71cad __alloc_dir (libc.so.6)
>  #6  0x00007f5baaf71dbd opendir_tail (libc.so.6)
>  #7  0x00007f5bab5bbac4 Perl_pp_open_dir (libperl.so)
>  #8  0x00007f5bab55fec6 Perl_runops_standard (libperl.so)
>  #9  0x00007f5bab4d9390 Perl_call_sv (libperl.so)
>  #10 0x00005611f097e190 _ZN16rxvt_perl_interp6invokeEP9rxvt_term9hook_typez (urxvt)
>  #11 0x00005611f0947acb _ZN9rxvt_term14init_resourcesEiPKPKc (urxvt)
>  #12 0x00005611f0948da8 _ZN9rxvt_term5init2EiPKPKc (urxvt)
>  #13 0x00005611f097a0af n/a (urxvt)
>  #14 0x00007f5bab568259 Perl_pp_entersub (libperl.so)
>  #15 0x00007f5bab55fec6 Perl_runops_standard (libperl.so)
>  #16 0x00007f5bab4d9390 Perl_call_sv (libperl.so)
>  #17 0x00005611f097e190 _ZN16rxvt_perl_interp6invokeEP9rxvt_term9hook_typez (urxvt)
>  #18 0x00005611f0939a77 _ZN9rxvt_term9key_pressER9XKeyEvent (urxvt)
>  #19 0x00005611f093d77a _ZN9rxvt_term4x_cbER7_XEvent (urxvt)
>  #20 0x00005611f09572e8 _ZN12rxvt_display8flush_cbERN2ev7prepareEi (urxvt)
>  #21 0x00005611f095d10f _Z17ev_invoke_pendingv (urxvt)
>  #22 0x00005611f095dc02 ev_run (urxvt)
>  #23 0x00005611f093c9b9 main (urxvt)
>  #24 0x00007f5baaed3f4a __libc_start_main (libc.so.6)
>  #25 0x00005611f09409da _start (urxvt)
>
> and so on.
>
>
> However, the problem is not specific to 4.14.15 or 4.14.11.
>
> I manages to track it down to 4.14 merge window, so we are basically
> looking at 4.14-rc0+
>
> The bisect log looks as follows:
>
> git bisect start
> # bad: [2bd6bf03f4c1c59381d62c61d03f6cc3fe71f66e] Linux 4.14-rc1
> git bisect bad 2bd6bf03f4c1c59381d62c61d03f6cc3fe71f66e
> # good: [569dbb88e80deb68974ef6fdd6a13edb9d686261] Linux 4.13
> git bisect good 569dbb88e80deb68974ef6fdd6a13edb9d686261
> # good: [aae3dbb4776e7916b6cd442d00159bea27a695c1] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
> git bisect good aae3dbb4776e7916b6cd442d00159bea27a695c1
> # bad: [2f173d2688559a6f85643d38a2ad6f45eb420c42] KVM: x86: Fix immediate_exit handling for uninitialized AP
> git bisect bad 2f173d2688559a6f85643d38a2ad6f45eb420c42
> # bad: [d969443064abf2f51510559a5b01325eaabfcb1d] Merge tag 'sound-4.14-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
> git bisect bad d969443064abf2f51510559a5b01325eaabfcb1d
> # bad: [a0725ab0c7536076d5477264420ef420ebb64501] Merge branch 'for-4.14/block' of git://git.kernel.dk/linux-block
> git bisect bad a0725ab0c7536076d5477264420ef420ebb64501
> # bad: [f92e3da18b7d5941468040af962c201235148301] Merge branch 'efi-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> git bisect bad f92e3da18b7d5941468040af962c201235148301
> # good: [1c9fe4409ce3e9c78b1ed96ee8ed699d4f03bf33] x86/mm: Document how CR4.PCIDE restore works
> git bisect good 1c9fe4409ce3e9c78b1ed96ee8ed699d4f03bf33
> # bad: [da99ecf117fce6570bd3989263d68ee0007e1249] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
> git bisect bad da99ecf117fce6570bd3989263d68ee0007e1249
> # good: [f7b68046873724129798c405e1a4e326b409c08f] mm: use find_get_pages_range() in filemap_range_has_page()
> git bisect good f7b68046873724129798c405e1a4e326b409c08f
> # bad: [824f973904a1108806fa0fbe15dc93ee9ecd9e0a] userfaultfd: selftest: enable testing of UFFDIO_ZEROPAGE for shmem
> git bisect bad 824f973904a1108806fa0fbe15dc93ee9ecd9e0a
> # good: [98cc093cba1e925eb34963dedb5f1684f1bdb2f4] block, THP: make block_device_operations.rw_page support THP
> git bisect good 98cc093cba1e925eb34963dedb5f1684f1bdb2f4
> # bad: [fe490cc0fe9e6ee48cc48bb5dc463bc5f0f1428f] mm, THP, swap: add THP swapping out fallback counting
> git bisect bad fe490cc0fe9e6ee48cc48bb5dc463bc5f0f1428f
> # good: [3e14a57b2416b7c94189b95baffd673cf5e0d0a3] memcg, THP, swap: support move mem cgroup charge for THP swapped out
> git bisect good 3e14a57b2416b7c94189b95baffd673cf5e0d0a3
> # good: [d6810d730022016d9c0f389452b86b035dba1492] memcg, THP, swap: make mem_cgroup_swapout() support THP
> git bisect good d6810d730022016d9c0f389452b86b035dba1492
> # bad: [bd4c82c22c367e068acb1ec9ec02be2fac3e09e2] mm, THP, swap: delay splitting THP after swapped out
> git bisect bad bd4c82c22c367e068acb1ec9ec02be2fac3e09e2
> # first bad commit: [bd4c82c22c367e068acb1ec9ec02be2fac3e09e2] mm, THP, swap: delay splitting THP after swapped out
>
>
> The suspected first bad commit is:
>
> bd4c82c22c367e068acb1ec9ec02be2fac3e09e2 is the first bad commit
> commit bd4c82c22c367e068acb1ec9ec02be2fac3e09e2
> Author: Huang Ying
> Date:   Wed Sep 6 16:22:49 2017 -0700
>
>     mm, THP, swap: delay splitting THP after swapped out
>
>     In this patch, splitting transparent huge page (THP) during swapping out
>     is delayed from after adding the THP into the swap cache to after
>     swapping out finishes.  After the patch, more operations for the
>     anonymous THP reclaiming, such as writing the THP to the swap device,
>     removing the THP from the swap cache could be batched.  So that the
>     performance of anonymous THP swapping out could be improved.
>
>     This is the second step for the THP swap support.  The plan is to delay
>     splitting the THP step by step and avoid splitting the THP finally.
>
>     With the patchset, the swap out throughput improves 42% (from about
>     5.81GB/s to about 8.25GB/s) in the vm-scalability swap-w-seq test case
>     with 16 processes.  At the same time, the IPI (reflect TLB flushing)
>     reduced about 78.9%.  The test is done on a Xeon E5 v3 system.  The swap
>     device used is a RAM simulated PMEM (persistent memory) device.  To test
>     the sequential swapping out, the test case creates 8 processes, which
>     sequentially allocate and write to the anonymous pages until the RAM and
>     part of the swap device is used up.
>
>     Link: http://lkml.kernel.org/r/20170724051840.2309-12-ying.huang@intel.com

Can you give me some detailed steps to reproduce this?  Like the
kernel configuration file, swap configuration, etc.  Any kernel
WARNING during testing?  Can you reproduce this with a real swap
device instead of zswap?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
