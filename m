Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5897A6B0095
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 12:21:37 -0500 (EST)
Date: Wed, 18 Feb 2009 18:23:37 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Patch] mm: fix null pointer dereference in vm_normal_page()
Message-ID: <20090218172337.GA1767@cmpxchg.org>
References: <20090218125649.GU7272@hack.private>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20090218125649.GU7272@hack.private>
Sender: owner-linux-mm@kvack.org
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 18, 2009 at 08:56:49PM +0800, Americo Wang wrote:
> 
> One usage of vm_normal_page() is:
> 
>     struct page *page = vm_normal_page(gate_vma, start, *pte);
> 
> where gate_vma is returned by get_gate_vma() which can be NULL.
> So let vm_normal_page return NULL when vma is NULL.

I assume you refer to __get_user_pages()...?

This function checks whether the address is in the gate area and only
iff so requests the VMA representing it.

If you really did see an oops that is worked-around by your patch,
then the in_gate_area()/get_gate_vma() in question are broken.

> Signed-off-by: WANG Cong <wangcong@zeuux.org>
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>

  Nacked-by: Johannes Weiner <hannes@cmpxchg.org>

> ---
> diff --git a/mm/memory.c b/mm/memory.c
> index baa999e..e428aa6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -493,6 +493,9 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  {
>  	unsigned long pfn = pte_pfn(pte);
>  
> +	if (!vma)
> +		return NULL;
> +
>  	if (HAVE_PTE_SPECIAL) {
>  		if (likely(!pte_special(pte)))
>  			goto check_pfn;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
