Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 288A66B01A0
	for <linux-mm@kvack.org>; Mon, 25 May 2015 22:52:44 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so49062993igb.1
        for <linux-mm@kvack.org>; Mon, 25 May 2015 19:52:43 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id n4si7308148ige.19.2015.05.25.19.52.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 19:52:43 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so48910013igb.0
        for <linux-mm@kvack.org>; Mon, 25 May 2015 19:52:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com>
Date: Tue, 26 May 2015 10:52:43 +0800
Message-ID: <CAFP4FLr3gwnwg--tqJVFemPyKX=cmdakYJBeJ5BqvZeoBd2zbQ@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
From: yalin wang <yalin.wang2010@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, barami97@gmail.com, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

2015-05-25 0:02 GMT+08:00 Jungseok Lee <jungseoklee85@gmail.com>:
> Fork-routine sometimes fails to get a physically contiguous region for
> thread_info on 4KB page system although free memory is enough. That is,
> a physically contiguous region, which is currently 16KB, is not available
> since system memory is fragmented.
>
> This patch tries to solve the problem as allocating thread_info memory
> from vmalloc space, not 1:1 mapping one. The downside is one additional
> page allocation in case of vmalloc. However, vmalloc space is large enough,
> around 240GB, under a combination of 39-bit VA and 4KB page. Thus, it is
> not a big tradeoff for fork-routine service.
>
> Suggested-by: Sungjinn Chung <barami97@gmail.com>
> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  arch/arm64/Kconfig                   | 12 ++++++++++++
>  arch/arm64/include/asm/thread_info.h |  9 +++++++++
>  arch/arm64/kernel/process.c          |  7 +++++++
>  3 files changed, 28 insertions(+)
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 99930cf..93c236a 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -536,6 +536,18 @@ config ARCH_SELECT_MEMORY_MODEL
>  config HAVE_ARCH_PFN_VALID
>         def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
>
> +config ARCH_THREAD_INFO_ALLOCATOR
> +       bool "Enable vmalloc based thread_info allocator (EXPERIMENTAL)"
> +       depends on ARM64_4K_PAGES
> +       default n
> +       help
> +         This feature enables vmalloc based thread_info allocator. It
> +         prevents fork-routine from begin failed to obtain physically
> +         contiguour region due to memory fragmentation on low system
> +         memory platforms.
> +
> +         If unsure, say N
> +
>  config HW_PERF_EVENTS
>         bool "Enable hardware performance counter support for perf events"
>         depends on PERF_EVENTS
> diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
> index dcd06d1..e753e59 100644
> --- a/arch/arm64/include/asm/thread_info.h
> +++ b/arch/arm64/include/asm/thread_info.h
> @@ -61,6 +61,15 @@ struct thread_info {
>  #define init_thread_info       (init_thread_union.thread_info)
>  #define init_stack             (init_thread_union.stack)
>
> +#ifdef CONFIG_ARCH_THREAD_INFO_ALLOCATOR
> +#define alloc_thread_info_node(tsk, node)                              \
> +({                                                                     \
> +       __vmalloc_node_range(THREAD_SIZE, THREAD_SIZE, VMALLOC_START,   \
> +                       VMALLOC_END, GFP_KERNEL, PAGE_KERNEL, 0,        \
> +                       NUMA_NO_NODE, __builtin_return_address(0));     \
> +})
why not add __GFP_HIGHMEM, if you decided to use vmalloc() alloc stack pages?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
