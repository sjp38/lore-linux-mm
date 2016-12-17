Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED0836B0253
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 02:38:16 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id b14so13036044lfg.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 23:38:16 -0800 (PST)
Received: from asavdk3.altibox.net (asavdk3.altibox.net. [109.247.116.14])
        by mx.google.com with ESMTPS id b84si5788544lfd.398.2016.12.16.23.38.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 23:38:15 -0800 (PST)
Date: Sat, 17 Dec 2016 08:38:13 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC PATCH 02/14] sparc64: add new fields to mmu context for
 shared context support
Message-ID: <20161217073813.GB23567@ravnborg.org>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-3-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481913337-9331-3-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Mike

> diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
> index b84be67..d031799 100644
> --- a/arch/sparc/include/asm/mmu_context_64.h
> +++ b/arch/sparc/include/asm/mmu_context_64.h
> @@ -35,15 +35,15 @@ void __tsb_context_switch(unsigned long pgd_pa,
>  static inline void tsb_context_switch(struct mm_struct *mm)
>  {
>  	__tsb_context_switch(__pa(mm->pgd),
> -			     &mm->context.tsb_block[0],
> +			     &mm->context.tsb_block[MM_TSB_BASE],
>  #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
> -			     (mm->context.tsb_block[1].tsb ?
> -			      &mm->context.tsb_block[1] :
> +			     (mm->context.tsb_block[MM_TSB_HUGE].tsb ?
> +			      &mm->context.tsb_block[MM_TSB_HUGE] :
>  			      NULL)
>  #else
>  			     NULL
>  #endif
> -			     , __pa(&mm->context.tsb_descr[0]));
> +			     , __pa(&mm->context.tsb_descr[MM_TSB_BASE]));
>  }
>  
This is a nice cleanup that has nothing to do with your series.
Could you submit this as a separate patch so we can get it applied.

This is the only place left where the array index for tsb_block
and tsb_descr uses hardcoded values. And it would be good to get
rid of these.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
