Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 636076B00A3
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 02:33:01 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so608111pab.6
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 23:33:01 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id tu2si60587pbc.99.2014.02.25.23.32.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 23:33:00 -0800 (PST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 26 Feb 2014 17:32:56 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 6658E2CE8051
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 18:32:52 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1Q7Wco69961802
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 18:32:38 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1Q7Wpm5003828
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 18:32:51 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: numa: bugfix for LAST_CPUPID_NOT_IN_PAGE_FLAGS
In-Reply-To: <1391563546-26052-1-git-send-email-pingfank@linux.vnet.ibm.com>
References: <1391563546-26052-1-git-send-email-pingfank@linux.vnet.ibm.com>
Date: Wed, 26 Feb 2014 13:02:46 +0530
Message-ID: <87ob1ufhwh.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Ping Fan <qemulist@gmail.com>, linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Liu Ping Fan <qemulist@gmail.com> writes:

> When doing some numa tests on powerpc, I triggered an oops bug. I find
> it is caused by using page->_last_cpupid.  It should be initialized as
> "-1 & LAST_CPUPID_MASK", but not "-1". Otherwise, in task_numa_fault(),
> we will miss the checking (last_cpupid == (-1 & LAST_CPUPID_MASK)).
> And finally cause an oops bug in task_numa_group(), since the online cpu is
> less than possible cpu.
>
> Call trace:
> [   55.978091] SMP NR_CPUS=64 NUMA PowerNV
> [   55.978118] Modules linked in:
> [   55.978145] CPU: 24 PID: 804 Comm: systemd-udevd Not tainted
> 3.13.0-rc1+ #32
> [   55.978183] task: c000001e2746aa80 ti: c000001e32c50000 task.ti:
> c000001e32c50000
> [   55.978219] NIP: c0000000000f5ad0 LR: c0000000000f5ac8 CTR:
> c000000000913cf0
> [   55.978256] REGS: c000001e32c53510 TRAP: 0300   Not tainted
> (3.13.0-rc1+)
> [   55.978286] MSR: 9000000000009032 <SF,HV,EE,ME,IR,DR,RI>  CR:
> 28024424  XER: 20000000
> [   55.978380] CFAR: c000000000009324 DAR: 7265717569726857 DSISR:
> 40000000 SOFTE: 1
> GPR00: c0000000000f5ac8 c000001e32c53790 c000000001f34338
> 0000000000000021
> GPR04: 0000000000000000 0000000000000031 c000000001f74338
> 0000ffffffffffff
> GPR08: 0000000000000001 7265717569726573 0000000000000000
> 0000000000000000
> GPR12: 0000000028024422 c00000000ffdd800 00000000296b2e64
> 0000000000000020
> GPR16: 0000000000000002 0000000000000003 c000001e2f8e4658
> c000001e25c1c1d8
> GPR20: c000001e2f8e4000 c000000001f7a858 0000000000000658
> 0000000040000392
> GPR24: 00000000000000a8 c000001e33c1a400 00000000000001d8
> c000001e25c1c000
> GPR28: c000001e33c37ff0 0007837840000392 000000000000003f
> c000001e32c53790
> [   55.978903] NIP [c0000000000f5ad0] .task_numa_fault+0x1470/0x2370
> [   55.978934] LR [c0000000000f5ac8] .task_numa_fault+0x1468/0x2370
> [   55.978964] Call Trace:
> [   55.978978] [c000001e32c53790] [c0000000000f5ac8]
> .task_numa_fault+0x1468/0x2370 (unreliable)
> [   55.979036] [c000001e32c539e0] [c00000000020a820]
> .do_numa_page+0x480/0x4a0
> [   55.979072] [c000001e32c53b10] [c00000000020bfec]
> .handle_mm_fault+0x4ec/0xc90
> [   55.979123] [c000001e32c53c00] [c000000000e88c98]
> .do_page_fault+0x3a8/0x890
> [   55.979161] [c000001e32c53e30] [c000000000009568]
> handle_page_fault+0x10/0x30
> [   55.979197] Instruction dump:
> [   55.979216] 3c82fefb 3884b138 48d9cff1 60000000 48000574 3c62fefb
> 3863af78 3c82fefb
> [   55.979277] 3884b138 48d9cfd5 60000000 e93f0100 <812902e4> 7d2907b4
> 5529063e 7d2a07b4
> [   55.979354] ---[ end trace 15f2510da5ae07cf ]---
>
>
> Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
> ---
> I do the test on benh's git tree
>   git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc.git next commit 37e4a67be7beff74df2cdddfcb08153282c0f8a1
>   (With patch "sched: Avoid NULL dereference on sd_busy" by PerterZ)
> ---
>  include/linux/mm.h                |  2 +-
>  include/linux/page-flags-layout.h | 12 ++++--------
>  2 files changed, 5 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a7b4e31..ddc66df4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -727,7 +727,7 @@ static inline int page_cpupid_last(struct page *page)
>  }
>  static inline void page_cpupid_reset_last(struct page *page)
>  {
> -	page->_last_cpupid = -1;
> +	page->_last_cpupid = -1 & LAST_CPUPID_MASK;
>  }
>  #else


May be i am missing something in the below.  But does it change anything
? We do set CPUID_WIDTH = 0 if we have

#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT > BITS_PER_LONG - NR_PAGEFLAGS

and if we have CPUID_WIDTH == 0 we have

#if defined(CONFIG_NUMA_BALANCING) && LAST_CPUPID_WIDTH == 0
#define LAST_CPUPID_NOT_IN_PAGE_FLAGS
#endif

So what is that i am missing ?


>  static inline int page_cpupid_last(struct page *page)
> diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
> index da52366..3cbaa20 100644
> --- a/include/linux/page-flags-layout.h
> +++ b/include/linux/page-flags-layout.h
> @@ -69,15 +69,15 @@
>  #define LAST__CPU_MASK  ((1 << LAST__CPU_SHIFT)-1)
>
>  #define LAST_CPUPID_SHIFT (LAST__PID_SHIFT+LAST__CPU_SHIFT)
> +
> +#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT > BITS_PER_LONG - NR_PAGEFLAGS
> +#define LAST_CPUPID_NOT_IN_PAGE_FLAGS
> +#endif
>  #else
>  #define LAST_CPUPID_SHIFT 0
>  #endif
>
> -#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
>  #define LAST_CPUPID_WIDTH LAST_CPUPID_SHIFT
> -#else
> -#define LAST_CPUPID_WIDTH 0
> -#endif
>
>  /*
>   * We are going to use the flags for the page to node mapping if its in
> @@ -87,8 +87,4 @@
>  #define NODE_NOT_IN_PAGE_FLAGS
>  #endif
>
> -#if defined(CONFIG_NUMA_BALANCING) && LAST_CPUPID_WIDTH == 0
> -#define LAST_CPUPID_NOT_IN_PAGE_FLAGS
> -#endif
> -
>  #endif /* _LINUX_PAGE_FLAGS_LAYOUT */

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
