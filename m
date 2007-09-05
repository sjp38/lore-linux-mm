Message-ID: <46DEFDF4.5000900@redhat.com>
Date: Wed, 05 Sep 2007 15:05:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC]: pte notifiers -- support for external page tables
References: <11890103283456-git-send-email-avi@qumranet.com>
In-Reply-To: <11890103283456-git-send-email-avi@qumranet.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: lkml@qumranet.com, linux-mm@kvack.org, shaohua.li@intel.com, kvm@qumranet.com, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:

> This sample patch adds a new mechanism, pte notifiers, that allows drivers
> to register an interest in a changes to ptes. Whenever Linux changes a
> pte, it will call a notifier to allow the driver to adjust the external
> page table and flush its tlb.
> 
> Note that only one notifier is implemented, ->clear(), but others should be
> similar.

This approach makes a lot of sense.

> diff --git a/mm/rmap.c b/mm/rmap.c
> index 41ac397..3f61d38 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -682,6 +682,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	}
>  
>  	/* Nuke the page table entry. */
> +	pte_notifier_call(vma, clear, address);
>  	flush_cache_page(vma, address, page_to_pfn(page));
>  	pteval = ptep_clear_flush(vma, address, pte);

If you want this to be useful to Infiniband, you should probably
also hook up do_wp_page() in mm/memory.c, where a page table can
be pointed to another page.

Probably the code in mm/mremap.c will need to be hooked up too.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
