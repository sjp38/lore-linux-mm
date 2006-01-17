Subject: Re: Race in new page migration code?
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <Pine.LNX.4.62.0601170926440.24552@schroedinger.engr.sgi.com>
References: <20060114155517.GA30543@wotan.suse.de>
	 <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com>
	 <20060114181949.GA27382@wotan.suse.de>
	 <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.61.0601151053420.4500@goblin.wat.veritas.com>
	 <Pine.LNX.4.62.0601152251080.17034@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.61.0601161143190.7123@goblin.wat.veritas.com>
	 <Pine.LNX.4.62.0601170926440.24552@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 17 Jan 2006 13:46:11 -0500
Message-Id: <1137523571.5245.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-01-17 at 09:29 -0800, Christoph Lameter wrote:
> On Mon, 16 Jan 2006, Hugh Dickins wrote:
> 
> > Hmm, that battery of unusual tests at the start of migrate_page_add
> > is odd: the tests don't quite match the comment, and it isn't clear
> > what reasoning lies behind the comment anyway.
> 
> Here is patch to clarify the test. I'd be glad if someone could make
> the tests more accurate. This ultimately comes down to a concept of
> ownership of page by a process / mm_struct that we have to approximate.
> 
> ===
> 
> Explain the complicated check in migrate_page_add by putting the logic
> into a separate function migration_check. This way any enhancements can
> be easily added.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.15/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.15.orig/mm/mempolicy.c	2006-01-14 10:56:28.000000000 -0800
> +++ linux-2.6.15/mm/mempolicy.c	2006-01-17 09:24:20.000000000 -0800
> @@ -551,6 +551,37 @@ out:
>  	return rc;
>  }
>  
> +static inline int migration_check(struct mm_struct *mm, struct page *page)
> +{
> +	/*
> +	 * If the page has no mapping then we do not track reverse mappings.
> +	 * Thus the page is not mapped by other mms, so its safe to move.
> +	 */
> +	if (page->mapping)
should this be "if (!page->mapping)" ???
> +		return 1;
> +

<snip>
> -	if ((flags & MPOL_MF_MOVE_ALL) || !page->mapping || PageAnon(page) ||
like here ......................................^^^^^^^^^^^^^^
> -	    mapping_writably_mapped(page->mapping) ||
> -	    single_mm_mapping(vma->vm_mm, page->mapping))
> +	if ((flags & MPOL_MF_MOVE_ALL) || migration_check(vma->vm_mm, page))
>  		if (isolate_lru_page(page) == 1)
>  			list_add(&page->lru, pagelist);
>  }

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
