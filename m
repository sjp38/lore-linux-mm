Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id C16686B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 16:55:32 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id d137so57355927ywe.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 13:55:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o2si29758613qkc.210.2016.06.17.13.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 13:55:31 -0700 (PDT)
Date: Fri, 17 Jun 2016 15:55:26 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH v2 05/13] mm: Move memcg stack accounting to
 account_kernel_stack
Message-ID: <20160617205526.5cjfm56prpstvowc@treble>
References: <cover.1466192946.git.luto@kernel.org>
 <8a17889a9d47b7b4deb41f2fcccada8bf54d4b6f.1466192946.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <8a17889a9d47b7b4deb41f2fcccada8bf54d4b6f.1466192946.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Fri, Jun 17, 2016 at 01:00:41PM -0700, Andy Lutomirski wrote:
> We should account for stacks regardless of stack size.  Move it into
> account_kernel_stack.
> 
> Fixes: 12580e4b54ba8 ("mm: memcontrol: report kernel stack usage in cgroup2 memory.stat")
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  kernel/fork.c | 15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index be7f006af727..cd2abe6e4e41 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -165,20 +165,12 @@ static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
>  	struct page *page = alloc_kmem_pages_node(node, THREADINFO_GFP,
>  						  THREAD_SIZE_ORDER);
>  
> -	if (page)
> -		memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
> -					    1 << THREAD_SIZE_ORDER);
> -
>  	return page ? page_address(page) : NULL;
>  }
>  
>  static inline void free_thread_info(struct thread_info *ti)
>  {
> -	struct page *page = virt_to_page(ti);
> -
> -	memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
> -				    -(1 << THREAD_SIZE_ORDER));
> -	__free_kmem_pages(page, THREAD_SIZE_ORDER);
> +	free_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
>  }
>  # else
>  static struct kmem_cache *thread_info_cache;
> @@ -227,6 +219,11 @@ static void account_kernel_stack(struct thread_info *ti, int account)
>  
>  	mod_zone_page_state(zone, NR_KERNEL_STACK_KB,
>  			    THREAD_SIZE / 1024 * account);
> +
> +	/* All stack pages belong to the same memcg. */
> +	memcg_kmem_update_page_stat(
> +		virt_to_page(ti), MEMCG_KERNEL_STACK,
> +		account * (THREAD_SIZE / PAGE_SIZE));
>  }

Won't this be broken in the case where THREAD_SIZE < PAGE_SIZE?

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
