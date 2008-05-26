Date: Mon, 26 May 2008 03:40:49 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] lockless get_user_pages
Message-ID: <20080526014049.GC30840@wotan.suse.de>
References: <20080525144847.GB25747@wotan.suse.de> <20080525145227.GC25747@wotan.suse.de> <87fxs6xpyp.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fxs6xpyp.fsf@saeurebad.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, jens.axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Sun, May 25, 2008 at 07:18:06PM +0200, Johannes Weiner wrote:
> Hi Nick,
> 
> Nick Piggin <npiggin@suse.de> writes:
> 
> > +static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
> > +		unsigned long end, int write, struct page **pages, int *nr)
> > +{
> > +	unsigned long mask;
> > +	pte_t *ptep;
> > +
> > +	mask = _PAGE_PRESENT|_PAGE_USER;
> > +	if (write)
> > +		mask |= _PAGE_RW;
> > +
> > +	ptep = pte_offset_map(&pmd, addr);
> > +	do {
> > +		pte_t pte = gup_get_pte(ptep);
> > +		struct page *page;
> > +
> > +		if ((pte_val(pte) & (mask | _PAGE_SPECIAL)) != mask)
> > +			return 0;
> 
> Don't you leak the possbile high mapping here?

Hi Johannes,

Right you are. Good spotting.

--
Index: linux-2.6/arch/x86/mm/gup.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/gup.c
+++ linux-2.6/arch/x86/mm/gup.c
@@ -80,8 +80,10 @@ static noinline int gup_pte_range(pmd_t 
 		pte_t pte = gup_get_pte(ptep);
 		struct page *page;
 
-		if ((pte_val(pte) & (mask | _PAGE_SPECIAL)) != mask)
+		if ((pte_val(pte) & (mask | _PAGE_SPECIAL)) != mask) {
+			pte_unmap(ptep);
 			return 0;
+		}
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
 		get_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
