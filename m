Message-ID: <4472C529.2030306@yahoo.com.au>
Date: Tue, 23 May 2006 18:17:45 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: tracking dirty pages patches
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com> <20060522132905.6e1a711c.akpm@osdl.org>
In-Reply-To: <20060522132905.6e1a711c.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, a.p.zijlstra@chello.nl, torvalds@osdl.org, dhowells@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>>and your mods may change the balance there.  Andrew will
>>remember better whether that set_page_dirty has stronger justification.)
> 
> 
> It was added by the below, which nobody was terribly happy with at the
> time.  (Took me 5-10 minutes to hunt this down.  Insert rote comment about
> comments).

Hmm, I couldn't find any discussion on lkml or linux-mm about it.

I wonder why it wasn't simply changed so as to return the page even if
the pte was not marked dirty.

> 
> 
> 
> Date: Mon, 19 Jan 2004 18:43:46 +0000
> From: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
> To: bk-commits-head@vger.kernel.org
> Subject: [PATCH] s390: endless loop in follow_page.
> 
> 
> ChangeSet 1.1490.3.215, 2004/01/19 10:43:46-08:00, akpm@osdl.org
> 
> 	[PATCH] s390: endless loop in follow_page.
> 	
> 	From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 	
> 	Fix endless loop in get_user_pages() on s390.  It happens only on s/390
> 	because pte_dirty always returns 0.  For all other architectures this is an
> 	optimization.
> 	
> 	In the case of "write && !pte_dirty(pte)" follow_page() returns NULL.  On all
> 	architectures except s390 handle_pte_fault() will then create a pte with
> 	pte_dirty(pte)==1 because write_access==1.  In the following, second call to
> 	follow_page() all is fine.  With the physical dirty bit patch pte_dirty() is
> 	always 0 for s/390 because the dirty bit doesn't live in the pte.
> 
> 
> # This patch includes the following deltas:
> #	           ChangeSet	1.1490.3.214 -> 1.1490.3.215
> #	         mm/memory.c	1.145   -> 1.146  
> #
> 
>  memory.c |   21 +++++++++++++--------
>  1 files changed, 13 insertions(+), 8 deletions(-)
> 
> 
> diff -Nru a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c	Mon Jan 19 15:47:24 2004
> +++ b/mm/memory.c	Mon Jan 19 15:47:24 2004
> @@ -651,14 +651,19 @@
>  	pte = *ptep;
>  	pte_unmap(ptep);
>  	if (pte_present(pte)) {
> -		if (!write || (pte_write(pte) && pte_dirty(pte))) {
> -			pfn = pte_pfn(pte);
> -			if (pfn_valid(pfn)) {
> -				struct page *page = pfn_to_page(pfn);
> -
> -				mark_page_accessed(page);
> -				return page;
> -			}
> +		if (write && !pte_write(pte))
> +			goto out;
> +		if (write && !pte_dirty(pte)) {
> +			struct page *page = pte_page(pte);
> +			if (!PageDirty(page))
> +				set_page_dirty(page);
> +		}
> +		pfn = pte_pfn(pte);
> +		if (pfn_valid(pfn)) {
> +			struct page *page = pfn_to_page(pfn);
> +			
> +			mark_page_accessed(page);
> +			return page;
>  		}
>  	}
>  

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
