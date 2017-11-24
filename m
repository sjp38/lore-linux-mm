Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0DE6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 03:05:10 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id f9so13446657wra.2
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 00:05:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z18si121775eda.277.2017.11.24.00.05.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 00:05:09 -0800 (PST)
Date: Fri, 24 Nov 2017 09:05:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,madvise: bugfix of madvise systemcall infinite loop
 under special circumstances.
Message-ID: <20171124080507.u76g634hucoxmpov@dhcp22.suse.cz>
References: <20171124022757.4991-1-guoxuenan@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171124022757.4991-1-guoxuenan@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guoxuenan <guoxuenan@huawei.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rppt@linux.vnet.ibm.com, hillf.zj@alibaba-inc.com, shli@fb.com, aarcange@redhat.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, rientjes@google.com, khandual@linux.vnet.ibm.com, riel@redhat.com

On Fri 24-11-17 10:27:57, guoxuenan wrote:
> From: chenjie <chenjie6@huawei.com>
> 
> The madvise() system call supported a set of "conventional" advice values,
> the MADV_WILLNEED parameter will trigger an infinite loop under direct
> access mode(DAX). In DAX mode, the function madvise_vma() will return
> directly without updating the pointer [prev].
> 
> For example:
> Special circumstances:
> 1a??init [ start < vam->vm_start < vam->vm_end < end ]
> 2a??madvise_vma() using MADV_WILLNEED parameter ;
> madvise_vma() -> madvise_willneed() -> return 0 && without updating [prev]
> 
> =======================================================================
> in Function SYSCALL_DEFINE3(madvise,...)
> 
> for (;;)
> {
> //[first loop: start = vam->vm_start < vam->vm_end  <end ];
>       update [start = vma->vm_start | end  ]
> 
> con0: if (start >= end)                 //false always;
> 	goto out;
>       tmp = vma->vm_end;
> 
> //do not update [prev] and always return 0;
>       error = madvise_willneed();
> 
> con1: if (error)                        //false always;
> 	goto out;
> 
> //[ vam->vm_start < start = vam->vm_end  <end ]
>       update [start = tmp ]
> 
> con2: if (start >= end)                 //false always ;
> 	goto out;
> 
> //because of pointer [prev] did not change,[vma] keep as it was;
>       update [ vma = prev->vm_next ]
> }
> 
> =======================================================================
> After the first cycle ;it will always keep
> [ vam->vm_start < start = vam->vm_end  < end ].
> since Circulation exit conditions (con{0,1,2}) will never meet ,the
> program stuck in infinite loop.

Are you sure? Have you tested this? I might be missing something because
madvise code is a bit of a mess but AFAICS prev pointer (updated or not)
will allow to move advance
		if (prev)
			vma = prev->vm_next;
		else	/* madvise_remove dropped mmap_sem */
			vma = find_vma(current->mm, start);
note that start is vma->vm_end and find_vma will find a vma which
vma_end > addr

So either I am missing something or this code has actaully never worked
for DAX, XIP which I find rather suspicious.
 
> Signed-off-by: chenjie <chenjie6@huawei.com>
> Signed-off-by: guoxuenan <guoxuenan@huawei.com>
> ---
>  mm/madvise.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 21261ff..c355fee 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -294,6 +294,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  #endif
>  
>  	if (IS_DAX(file_inode(file))) {
> +		*prev = vma;
>  		/* no bad return value, but ignore advice */
>  		return 0;
>  	}
> -- 
> 2.9.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
