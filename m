Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6F176B2932
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:57:18 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a26-v6so2569153pgw.7
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:57:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1-v6si3697394pld.424.2018.08.23.01.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 01:57:17 -0700 (PDT)
Date: Thu, 23 Aug 2018 10:57:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: respect arch_dup_mmap() return value
Message-ID: <20180823085714.GY29735@dhcp22.suse.cz>
References: <20180823051229.211856-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823051229.211856-1-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Wed 22-08-18 22:12:29, Nadav Amit wrote:
> Commit d70f2a14b72a4 ("include/linux/sched/mm.h: uninline
> mmdrop_async(), etc") ignored the return value of arch_dup_mmap(). As a
> result, on x86, a failure to duplicate the LDT (e.g., due to memory
> allocation error), would leave the duplicated memory mapping in an
> inconsistent state.
> 
> Fix by regarding the return value, as it was before the change.

Ohh, well spotted! I have a vague recollection I didn't really like the
patch. For other reasons. I didn't get to review it properly back then
because I didn't have much time and I didn't have a high motivation
because I simple disagreed with the patch.

> Fixes: d70f2a14b72a4 ("include/linux/sched/mm.h: uninline mmdrop_async(), etc")
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Nadav Amit <namit@vmware.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  kernel/fork.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 1b27babc4c78..4527d1d331de 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -549,8 +549,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>  			goto out;
>  	}
>  	/* a new mm has just been created */
> -	arch_dup_mmap(oldmm, mm);
> -	retval = 0;
> +	retval = arch_dup_mmap(oldmm, mm);
>  out:
>  	up_write(&mm->mmap_sem);
>  	flush_tlb_mm(oldmm);
> -- 
> 2.17.1
> 

-- 
Michal Hocko
SUSE Labs
