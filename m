Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 557826B0062
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 23:45:13 -0400 (EDT)
Date: Wed, 8 Jul 2009 20:58:43 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/2] ZERO PAGE by pte_special
In-Reply-To: <20090709122801.21806c01.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LFD.2.01.0907082058340.3352@localhost.localdomain>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com> <20090709122801.21806c01.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>



On Thu, 9 Jul 2009, KAMEZAWA Hiroyuki wrote:
>
> +	/* we can ignore zero page */
> +	page = vm_normal_page(vma, addr, pte, 1);

> -			page = vm_normal_page(vma, addr, ptent);
> +			page = vm_normal_page(vma, addr, ptent, 1);

> -	page = vm_normal_page(vma, address, pte);
> +	page = vm_normal_page(vma, address, pte, (flags & FOLL_NOZERO));

> +	int ignore_zero = !!(flags & GUP_FLAGS_IGNORE_ZERO);
> ...
> +				page = vm_normal_page(gate_vma, start,
> +						      *pte, ignore_zero);

> +			if (ignore_zero)
> +				foll_flags |= FOLL_NOZERO;

> +	/* This returns NULL when we find ZERO page */
> +	old_page = vm_normal_page(vma, address, orig_pte, 1);

> +		/* we can ignore zero page */
> +		page = vm_normal_page(vma, addr, pte, 1);

> +		/* we avoid zero page here */
> +		page = vm_normal_page(vma, addr, *pte, 1);

> +		/*
> +		 * Because we comes from try_to_unmap_file(), we'll never see
> +		 * ZERO_PAGE or ANON.
> +		 */
> +		page = vm_normal_page(vma, address, *pte, 1);

>  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> -		pte_t pte);
> +		pte_t pte, int ignore_zero);

So I'm quoting these different uses, because they show the pattern that 
exists all over this patch: confusion about "no zero" vs "ignore zero" vs 
just plain no explanation at all.

Quite frankly, I hate the "ignore zero page" naming/comments. I can kind 
of see why you named them that way - we'll not consider it a normal page. 
But that's not "ignoring" it. That's very much noticing it, just saying we 
don't want to get the "struct page" for it.

I equally hate the anonymous "1" use, with or without comments. Does "1" 
mean that you want the zero page, does it means you _don't_ want it, what 
does it mean? Yes, I know that it means FOLL_NOZERO, and that when set, we 
don't want the zero page, but regardless, it's just not very readable.

So I would suggest:

 - never pass in "1".

 - never talk about "ignoring" it.

 - always pass in a _flag_, in this case FOLL_NOZERO.

If you follow those rules, you almost don't need commentary. Assuming 
somebody is knowledgeable about the Linux VM, and knows we have a zero 
page, you can just see a line like

	page = vm_normal_page(vma, address, *pte, FOLL_NOZERO);

and you can understand that you don't want to see ZERO_PAGE. There's never 
any question like "what does that '1' mean here?"

In fact, I'd pass in all of "flags", and then inside vm_normal_page() just 
do

	if (flags & FOLL_NOZERO) {
		...

rather than ever have any boolean arguments.

(Again, I think that we should unify all of FOLL_xyz and FAULT_FLAG_xyz 
and GUP_xyz into _one_ namespace - probably all under FAULT_FLAG_xyz - but 
that's still a separate issue from this particular patchset).

Anyway, that said, I think the patch looks pretty simple and fairly 
straightforward. Looks very much like 2.6.32 material, assuming people 
will test it heavily and clean it up as per above before the next merge 
window.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
