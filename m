Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1A73A6B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 04:53:05 -0400 (EDT)
Received: by lahg1 with SMTP id g1so26765148lah.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 01:53:04 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id du4si5199985lac.145.2015.09.18.01.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 01:53:03 -0700 (PDT)
Received: by lbbmp1 with SMTP id mp1so21838854lbb.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 01:53:03 -0700 (PDT)
Date: Fri, 18 Sep 2015 11:53:01 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150918085301.GC2035@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
 <1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
 <20150917193152.GJ2000@uranus>
 <20150918085835.597fb036@mschwide>
 <20150918071549.GA2035@uranus>
 <20150918102001.0e0389c7@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150918102001.0e0389c7@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, Sep 18, 2015 at 10:20:01AM +0200, Martin Schwidefsky wrote:
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index e2d46ad..b029d42 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -754,7 +754,7 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
>  
>  	if (pte_present(ptent)) {
>  		ptent = pte_wrprotect(ptent);
> -		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
> +		ptent = pte_clear_soft_dirty(ptent);
>  	} else if (is_swap_pte(ptent)) {
>  		ptent = pte_swp_clear_soft_dirty(ptent);
>  	}
> @@ -768,7 +768,7 @@ static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
>  	pmd_t pmd = *pmdp;
>  
>  	pmd = pmd_wrprotect(pmd);
> -	pmd = pmd_clear_flags(pmd, _PAGE_SOFT_DIRTY);
> +	pmd = pmd_clear_soft_dirty(pmd);
>  

You know, these are only two lines where we use _PAGE_SOFT_DIRTY
directly, so I don't see much point in adding 22 lines of code
for that. Maybe we can leave it as is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
