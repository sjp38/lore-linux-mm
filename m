Received: from sgi.com (sgi.SGI.COM [192.48.153.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA02446
	for <linux-mm@kvack.org>; Mon, 22 Feb 1999 15:37:27 -0500
Date: Mon, 22 Feb 1999 12:31:12 -0800
From: kanoj@kulten.engr.sgi.com (Kanoj Sarcar)
Message-Id: <9902221231.ZM2522@kulten.engr.sgi.com>
In-Reply-To: Neil Booth <NeilB@earthling.net>
        "PATCH - bug in vfree" (Feb 20,  8:46pm)
References: <36CEA095.D5EA37B5@earthling.net>
Subject: Re: PATCH - bug in vfree
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Neil Booth <NeilB@earthling.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Feb 20,  8:46pm, Neil Booth wrote:
> Subject: PATCH - bug in vfree
>

>
> Quick description:- vfree forgets to subtract the extra cushion page
> from the size of each virtual memory area stored in vmlist when it calls
> vmfree_area_pages. This means that only the  vmalloc-requested size is
> allocated by vmalloc_area_pages, but the requested size PLUS the cushion
> page is freed by vmfree_area_pages.
>
> More deeply:- Close inspection of get_vm_area reveals that
> (intentionally?) it does NOT insist there be a cushion page behind a VMA
> that is placed in front of a previously-allocated VMA, it ONLY
> guarantees that a cushion page lies in front of newly-allocated VMAs.
> Thus two VMAs could be immediately adjacent without a cushion page, and
> coupled with the vfree bug means that vfree-ing the first VMA also frees
> the first page of the second VMA, with dire consequences.
>
> I have described this as clearly as I can, I hope it makes sense. Alan,
> this same bug also exists in 2.0.36.
>
> Neil.
>
> [ text/plain ] :
>
> --- linux/mm/vmalloc.c~	Sun Jan 24 19:21:06 1999
> +++ linux/mm/vmalloc.c	Sat Feb 20 20:17:11 1999
> @@ -187,7 +187,7 @@
>  	for (p = &vmlist ; (tmp = *p) ; p = &tmp->next) {
>  		if (tmp->addr == addr) {
>  			*p = tmp->next;
> -			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr),
tmp->size);
> +			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size
- PAGE_SIZE);
>  			kfree(tmp);
>  			return;
>  		}
>-- End of excerpt from Neil Booth


On Feb 20,  9:14pm, Neil Booth wrote:
> Subject: Re: PATCH - bug in vfree
> Neil Booth wrote:
>
> > More deeply:- Close inspection of get_vm_area reveals that
> > (intentionally?) it does NOT insist there be a cushion page behind a VMA
> > that is placed in front of a previously-allocated VMA, it ONLY
> > guarantees that a cushion page lies in front of newly-allocated VMAs.
>
> Sorry, this is not correct (mistook < for <=). The bug report is
> correct, though.
>
> Neil.


Given that we agree that there is always one page between vm_structs,
the extra page freeing (in vfree) is probably inconsequential, given
that vmfree_area_pages/free_area_pmd/free_area_pte basically ignores
null ptes. But yes, I agree it would be nice to get the "bug" fixed
in vfree().

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
