Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF736B025F
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 10:02:37 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s185so6400775oif.3
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 07:02:37 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p83si591483oih.187.2017.10.06.07.02.33
        for <linux-mm@kvack.org>;
        Fri, 06 Oct 2017 07:02:33 -0700 (PDT)
Date: Fri, 6 Oct 2017 15:02:29 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: clear stale pointers from task stacks
Message-ID: <20171006140229.p5be6n6peafqasgl@armageddon.cambridge.arm.com>
References: <150728990124.744199.8403409836394318684.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150728990124.744199.8403409836394318684.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>

On Fri, Oct 06, 2017 at 02:38:21PM +0300, Konstantin Khlebnikov wrote:
> Kmemleak considers any pointers as task stacks as references.
                                  ^^
				  on

> This patch clears newly allocated and reused vmap stacks.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  include/linux/thread_info.h |    2 +-
>  kernel/fork.c               |    4 ++++
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
> index 905d769d8ddc..5f7eeab990fe 100644
> --- a/include/linux/thread_info.h
> +++ b/include/linux/thread_info.h
> @@ -42,7 +42,7 @@ enum {
>  #define THREAD_ALIGN	THREAD_SIZE
>  #endif
>  
> -#ifdef CONFIG_DEBUG_STACK_USAGE
> +#if IS_ENABLED(CONFIG_DEBUG_STACK_USAGE) || IS_ENABLED(CONFIG_DEBUG_KMEMLEAK)
>  # define THREADINFO_GFP		(GFP_KERNEL_ACCOUNT | __GFP_NOTRACK | \
>  				 __GFP_ZERO)
>  #else
> diff --git a/kernel/fork.c b/kernel/fork.c
> index c4ff0303b7c5..53e3b6f8a3bf 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -213,6 +213,10 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>  		if (!s)
>  			continue;
>  
> +#ifdef CONFIG_DEBUG_KMEMLEAK
> +		/* Clear stale pointers from reused stack. */
> +		memset(s->addr, 0, THREAD_SIZE);
> +#endif
>  		tsk->stack_vm_area = s;
>  		return s->addr;
>  	}

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
