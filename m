Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D72616B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 03:57:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z96so2545445wrb.21
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:57:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s27si49923edm.150.2017.11.02.00.57.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 00:57:46 -0700 (PDT)
Date: Thu, 2 Nov 2017 08:57:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: use in_atomic() in print_vma_addr()
Message-ID: <20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
References: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 02-11-17 05:38:33, Yang Shi wrote:
> commit 3e51f3c4004c9b01f66da03214a3e206f5ed627b
> ("sched/preempt: Remove PREEMPT_ACTIVE unmasking off in_atomic()") makes
> in_atomic() just check the preempt count, so it is not necessary to use
> preempt_count() in print_vma_addr() any more. Replace preempt_count() to
> in_atomic() which is a generic API for checking atomic context.

But why? Is there some general work to get rid of the direct preempt_count
usage outside of the generic API?

> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index a728bed..19b684e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4460,7 +4460,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
>  	 * Do not print if we are in atomic
>  	 * contexts (in exception stacks, etc.):
>  	 */
> -	if (preempt_count())
> +	if (in_atomic())
>  		return;
>  
>  	down_read(&mm->mmap_sem);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
