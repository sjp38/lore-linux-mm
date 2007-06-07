Date: Thu, 7 Jun 2007 08:34:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22-rc4-mm1
Message-Id: <20070607083458.a3fc7737.akpm@linux-foundation.org>
In-Reply-To: <20070607214706.3efc5870.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070606020737.4663d686.akpm@linux-foundation.org>
	<20070607214706.3efc5870.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, clameter@sgi.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007 21:47:06 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Question.
> 
> While writing memory unplug, I noticed this code.
> ==
> static int
> fixup_anon_page(pte_t *pte, unsigned long start, unsigned long end, void *priv)
> {
>         struct vm_area_struct *vma = priv;
>         struct page *page = vm_normal_page(vma, start, *pte);
> 
>         if (page && PageAnon(page))
>                 page->index = linear_page_index(vma, start);
> 
>         return 0;
> }
> 
> static int fixup_anon_pages(struct vm_area_struct *vma)
> {
>         struct mm_walk walk = {
>                 .pte_entry = fixup_anon_page,
>         };
> 
>         return walk_page_range(vma->vm_mm,
>                         vma->vm_start, vma->vm_end, &walk, vma);
> }

I assume the above is your code - it's not in the tree?

> 
> I think that 'pte' passed to fixup_anon_page() by walk_page_range()
> is not guaranteed to be 'Present'.

yup - the pagewalker only checks for !pte_none().

> Then, vm_normal_page() will show print_bad_pte().

> If this never occur now, I'll add my own check code for memory migration by kernel here.

Yes, you'll need to perform additional filtering where appropriate.

> (Sorry, I can't find who should be CCed.)

Matt and David did most of the work here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
