Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 969FF828E1
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 09:02:35 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so27261215lbb.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:02:35 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id r75si15783485wmg.59.2016.06.20.06.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 06:02:34 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id c82so10984743wme.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:02:33 -0700 (PDT)
Date: Mon, 20 Jun 2016 15:02:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 05/13] mm: Move memcg stack accounting to
 account_kernel_stack
Message-ID: <20160620130232.GC9892@dhcp22.suse.cz>
References: <cover.1466192946.git.luto@kernel.org>
 <8a17889a9d47b7b4deb41f2fcccada8bf54d4b6f.1466192946.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8a17889a9d47b7b4deb41f2fcccada8bf54d4b6f.1466192946.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Fri 17-06-16 13:00:41, Andy Lutomirski wrote:
> We should account for stacks regardless of stack size.  Move it into
> account_kernel_stack.
> 
> Fixes: 12580e4b54ba8 ("mm: memcontrol: report kernel stack usage in cgroup2 memory.stat")
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

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
>  
>  void free_task(struct task_struct *tsk)
> -- 
> 2.5.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
