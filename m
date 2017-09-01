Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E60C6B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 05:05:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 187so3060165wmn.2
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 02:05:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si1510604wrc.165.2017.09.01.02.05.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 02:05:45 -0700 (PDT)
Subject: Re: [PATCH] mm/mempolicy: Move VMA address bound checks inside
 mpol_misplaced()
References: <20170901070228.19954-1-khandual@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <268bbc32-7c1a-cdb8-039a-f1ea5d75b009@suse.cz>
Date: Fri, 1 Sep 2017 11:05:44 +0200
MIME-Version: 1.0
In-Reply-To: <20170901070228.19954-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org

On 09/01/2017 09:02 AM, Anshuman Khandual wrote:
> The VMA address bound checks are applicable to all memory policy modes,
> not just MPOL_INTERLEAVE.

But only MPOL_INTERLEAVE actually uses addr and vma->vm_start.

> Hence move it to the front and make it common.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

I would just remove them instead. Together with the BUG_ON(!vma). Looks
like just leftover from development.

> ---
>  mm/mempolicy.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 618ab12..7ec6694 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2173,6 +2173,8 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
>  	int ret = -1;
>  
>  	BUG_ON(!vma);
> +	BUG_ON(addr >= vma->vm_end);
> +	BUG_ON(addr < vma->vm_start);
>  
>  	pol = get_vma_policy(vma, addr);
>  	if (!(pol->flags & MPOL_F_MOF))
> @@ -2180,9 +2182,6 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
>  
>  	switch (pol->mode) {
>  	case MPOL_INTERLEAVE:
> -		BUG_ON(addr >= vma->vm_end);
> -		BUG_ON(addr < vma->vm_start);
> -
>  		pgoff = vma->vm_pgoff;
>  		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
>  		polnid = offset_il_node(pol, vma, pgoff);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
