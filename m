From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] Distributed mmap API
Date: Wed, 25 Feb 2004 17:46:46 -0500
References: <20040216190927.GA2969@us.ibm.com> <200402251707.05932.phillips@arcor.de> <20040225141646.28aa0750.akpm@osdl.org>
In-Reply-To: <20040225141646.28aa0750.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200402251746.46598.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: paulmck@us.ibm.com, sct@redhat.com, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 25 February 2004 17:16, Andrew Morton wrote:
> > but how can we legitimately get !pfn_valid there?
>
> A mapping of some I/O region?

With MAP_PRIVATE, on a distributed filesystem?  OK...

Can we recognize those I/O vmas and handle them with their own separate loop, 
saving a few cycles for the common case?  Or just:

	if (pte_present(pte)) {
		unsigned long pfn = pte_pfn(pte);
		struct page *page;
		if (unlikely(!pfn_valid(pfn))) {
			ptep_get_and_clear(ptep);
			tlb_remove_tlb_entry(tlb, ptep, address+offset);
			continue;
		}
		page = pfn_to_page(pfn);
		if (unlikely(!all) && is_anon(page))
			continue;
		pte = ptep_get_and_clear(ptep); /* get dirty bit atomically */
		tlb_remove_tlb_entry(tlb, ptep, address+offset);
		if (PageReserved(page))
			continue;
		if (pte_dirty(pte))
			set_page_dirty(page);
		if (page->mapping && pte_young(pte) && !PageSwapCache(page))
			mark_page_accessed(page);
		tlb->freed++;
		page_remove_rmap(page, ptep);
		tlb_remove_page(tlb, page);
	} else {

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
