Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71ABC8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 22:12:01 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69so22283955pff.5
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 19:12:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o9si18587613pfe.63.2018.12.27.19.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 19:12:00 -0800 (PST)
Date: Thu, 27 Dec 2018 19:11:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mmotm] arm64: fix build for MAX_USER_VA_BITS
Message-Id: <20181227191158.db19ed656f902629d203b58f@linux-foundation.org>
In-Reply-To: <20181224210312.56539-1-cai@lca.pw>
References: <20181224210312.56539-1-cai@lca.pw>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 24 Dec 2018 16:03:12 -0500 Qian Cai <cai@lca.pw> wrote:

> Some code in 9b31cf493ff was lost during merging into the -mmotm tree
> for some reasons,
> 
> In file included from ./arch/arm64/include/asm/processor.h:46,
>                  from ./include/linux/rcupdate.h:43,
>                  from ./include/linux/rculist.h:11,
>                  from ./include/linux/pid.h:5,
>                  from ./include/linux/sched.h:14,
> 		 from arch/arm64/kernel/asm-offsets.c:22:
> ./arch/arm64/include/asm/pgtable-hwdef.h:83:30: error:
> 'MAX_USER_VA_BITS' undeclared here (not in a function); did you mean
> 'MAX_USER_PRIO'?
>  #define PTRS_PER_PGD  (1 << (MAX_USER_VA_BITS - PGDIR_SHIFT))
>                               ^~~~~~~~~~~~~~~~
> ./arch/arm64/include/asm/pgtable.h:442:26: note: in expansion of macro
> 'PTRS_PER_PGD'
>  extern pgd_t init_pg_dir[PTRS_PER_PGD];
>
> ...
>
> --- a/arch/arm64/include/asm/memory.h
> +++ b/arch/arm64/include/asm/memory.h
> @@ -67,6 +67,12 @@
>  #define KERNEL_START      _text
>  #define KERNEL_END        _end
>  
> +#ifdef CONFIG_ARM64_USER_VA_BITS_52
> +#define MAX_USER_VA_BITS	52
> +#else
> +#define MAX_USER_VA_BITS	VA_BITS
> +#endif
> +
>  /*
>   * Generic and tag-based KASAN require 1/8th and 1/16th of the kernel virtual
>   * address space for the shadow region respectively. They can bloat the stack

hm, that was presumably me getting lost in a maze of rejects.  It seems
OK now.
