Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id EFE316B0037
	for <linux-mm@kvack.org>; Thu, 29 May 2014 21:53:28 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so378295pdi.25
        for <linux-mm@kvack.org>; Thu, 29 May 2014 18:53:28 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id lk6si3309432pab.166.2014.05.29.18.53.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 18:53:28 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so1144848pbc.40
        for <linux-mm@kvack.org>; Thu, 29 May 2014 18:53:27 -0700 (PDT)
Date: Thu, 29 May 2014 18:52:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] hugetlb: restrict hugepage_migration_support() to x86_64
 (Re: BUG at mm/memory.c:1489!)
In-Reply-To: <1401413716.29324.2.camel@concordia>
Message-ID: <alpine.LSU.2.11.1405291851001.27151@eggly.anvils>
References: <1401265922.3355.4.camel@concordia> <alpine.LSU.2.11.1405281712310.7156@eggly.anvils> <1401353983.4930.15.camel@concordia> <1401388474-mqnis5cp@n-horiguchi@ah.jp.nec.com> <1401413716.29324.2.camel@concordia>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, benh@kernel.crashing.org, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, trinity@vger.kernel.org

On Fri, 30 May 2014, Michael Ellerman wrote:
> 
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 3c1b968..f230a97 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -175,6 +175,12 @@ static inline int vma_migratable(struct vm_area_struct *vma)
>  {
>         if (vma->vm_flags & (VM_IO | VM_PFNMAP))
>                 return 0;
> +
> +#ifndef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
> +       if (vma->vm_flags & VM_HUGETLB)
> +               return 0;
> +#endif
> +
>         /*
>          * Migration allocates pages in the highest zone. If we cannot
>          * do so then migration (at least from node to node) is not

That's right, thanks.

> 
> 
> Which seems to be what Hugh was referring to in his mail - correct me if I'm
> wrong Hugh.
> 
> With your patch and the above hunk I can run trinity happily for a while,
> whereas without it crashes almost immediately.
> 
> So with the above hunk you can add my tested-by.
> 
> cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
