Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DEF5E6B0069
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:34:17 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id d7so15998809wre.15
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 06:34:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13sor1034712eda.8.2018.01.18.06.34.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 06:34:15 -0800 (PST)
Date: Thu, 18 Jan 2018 17:34:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180118143410.sozfsbmb3liumn3x@node.shutemov.name>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <20180118131210.456oyh6fw4scwv53@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180118131210.456oyh6fw4scwv53@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, mhocko@kernel.org, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, dave.hansen@linux.intel.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Thu, Jan 18, 2018 at 04:12:10PM +0300, Kirill A. Shutemov wrote:
> On Thu, Jan 18, 2018 at 03:25:50PM +0300, Kirill A. Shutemov wrote:
> > On Thu, Jan 18, 2018 at 05:12:45PM +0900, Tetsuo Handa wrote:
> > > Tetsuo Handa wrote:
> > > > OK. I missed the mark. I overlooked that 4.11 already has this problem.
> > > > 
> > > > I needed to bisect between 4.10 and 4.11, and I got plausible culprit.
> > > > 
> > > > I haven't completed bisecting between b4fb8f66f1ae2e16 and c470abd4fde40ea6, but
> > > > b4fb8f66f1ae2e16 ("mm, page_alloc: Add missing check for memory holes") and
> > > > 13ad59df67f19788 ("mm, page_alloc: avoid page_to_pfn() when merging buddies")
> > > > are talking about memory holes, which matches the situation that I'm trivially
> > > > hitting the bug if CONFIG_SPARSEMEM=y .
> > > > 
> > > > Thus, I call for an attention by speculative execution. ;-)
> > > 
> > > Speculative execution failed. I was confused by jiffies precision bug.
> > > The final culprit is c7ab0d2fdc840266 ("mm: convert try_to_unmap_one() to use page_vma_mapped_walk()").
> > 
> > I think I've tracked it down. check_pte() in mm/page_vma_mapped.c doesn't
> > work as intended.
> > 
> > I've added instrumentation below to prove it.
> > 
> > The BUG() triggers with following output:
> > 
> > [   10.084024] diff: -858690919
> > [   10.084258] hpage_nr_pages: 1
> > [   10.084386] check1: 0
> > [   10.084478] check2: 0
> > 
> > Basically, pte_page(*pvmw->pte) is below pvmw->page, but
> > (pte_page(*pvmw->pte) < pvmw->page) doesn't catch it.
> > 
> > Well, I can see how C lawyer can argue that you can only compare pointers
> > of the same memory object which is not the case here. But this is kinda
> > insane.
> > 
> > Any suggestions how to rewrite it in a way that compiler would
> > understand?
> 
> The patch below makes the crash go away for me.
> 
> But this is situation is scary. So we cannot compare arbitrary pointers in
> kernel?
> 
> Don't we rely on this for lock ordering in some cases? Like in
> mutex_lock_double()?
> 
> diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> index d22b84310f6d..1f0f512fd127 100644
> --- a/mm/page_vma_mapped.c
> +++ b/mm/page_vma_mapped.c
> @@ -51,6 +51,8 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
>  		WARN_ON_ONCE(1);
>  #endif
>  	} else {
> +		unsigned long ptr1, ptr2;
> +
>  		if (is_swap_pte(*pvmw->pte)) {
>  			swp_entry_t entry;
>  
> @@ -63,12 +65,14 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
>  		if (!pte_present(*pvmw->pte))
>  			return false;
>  
> -		/* THP can be referenced by any subpage */
> -		if (pte_page(*pvmw->pte) - pvmw->page >=
> -				hpage_nr_pages(pvmw->page)) {
> +		ptr1 = (unsigned long)pte_page(*pvmw->pte);
> +		ptr2 = (unsigned long)pvmw->page;
> +
> +		if (ptr1 < ptr2)
>  			return false;
> -		}
> -		if (pte_page(*pvmw->pte) < pvmw->page)
> +
> +		/* THP can be referenced by any subpage */
> +		if (ptr1 - ptr2 >= hpage_nr_pages(pvmw->page))

Arghhh.. It has to be

		if (ptr1 - ptr2 >= hpage_nr_pages(pvmw->page) * sizeof(*pvmw->page))

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
