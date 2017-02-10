Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29D3D6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:20:48 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id kq3so7444240wjc.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:20:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si1573760wrb.104.2017.02.10.02.20.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 02:20:47 -0800 (PST)
Date: Fri, 10 Feb 2017 11:20:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm,hugetlb: compute page_size_log properly
Message-ID: <20170210102044.GA10054@dhcp22.suse.cz>
References: <1486673582-6979-1-git-send-email-dave@stgolabs.net>
 <1486673582-6979-5-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486673582-6979-5-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, manfred@colorfullife.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

On Thu 09-02-17 12:53:02, Davidlohr Bueso wrote:
> The SHM_HUGE_* stuff  was introduced in:
> 
>    42d7395feb5 (mm: support more pagesizes for MAP_HUGETLB/SHM_HUGETLB)
> 
> It unnecessarily adds another layer, specific to sysv shm, without
> anything special about it: the macros are identical to the MAP_HUGE_*
> stuff, which in turn does correctly describe the hugepage subsystem.
> 
> One example of the problems with extra layers what this patch fixes:
> mmap_pgoff() should never be using SHM_HUGE_* logic. It is obviously
> harmless but it would still be grand to get rid of it -- although
> now in the manpages I don't see that happening.

Can we just drop SHM_HUGE_MASK altogether? It is not exported in uapi
headers AFAICS.

> 
> Cc: linux-mm@kvack.org
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 499b988b1639..40b29aca18c1 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1479,7 +1479,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  		struct user_struct *user = NULL;
>  		struct hstate *hs;
>  
> -		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & SHM_HUGE_MASK);
> +		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
>  		if (!hs)
>  			return -EINVAL;
>  
> -- 
> 2.6.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
