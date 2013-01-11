Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 556416B006C
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 09:02:39 -0500 (EST)
Date: Fri, 11 Jan 2013 15:01:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: oops in copy_page_rep()
Message-ID: <20130111140136.GA11705@redhat.com>
References: <alpine.LNX.2.00.1301061037140.28950@eggly.anvils>
 <CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
 <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
 <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
 <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
 <20130108163141.GA27555@shutemov.name>
 <CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com>
 <20130108173058.GA27727@shutemov.name>
 <20130108174951.GG9163@redhat.com>
 <1357890644.1466.1.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357890644.1466.1.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On Fri, Jan 11, 2013 at 01:50:44AM -0600, Simon Jeons wrote:
> On Tue, 2013-01-08 at 18:49 +0100, Andrea Arcangeli wrote:
> > Hi Kirill,
> > 
> > On Tue, Jan 08, 2013 at 07:30:58PM +0200, Kirill A. Shutemov wrote:
> > > Merged patch is obviously broken: huge_pmd_set_accessed() can be called
> > > only if the pmd is under splitting.
> > 
> > Of course I assume you meant "only if the pmd is not under splitting".
> > 
> > But no, setting a bitflag like the young bit or clearing or setting
> > the numa bit won't screw with split_huge_page and it's safe even if
> > the pmd is under splitting.
> > 
> > Those bits are only checked here at the last stage of
> > split_huge_page_map after taking the PT lock:
> > 
> > 	spin_lock(&mm->page_table_lock);
> > 	pmd = page_check_address_pmd(page, mm, address,
> > 				     PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG);
> > 	if (pmd) {
> > 		pgtable = pgtable_trans_huge_withdraw(mm);
> > 		pmd_populate(mm, &_pmd, pgtable);
> > 
> > 		haddr = address;
> > 		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> > 			pte_t *pte, entry;
> > 			BUG_ON(PageCompound(page+i));
> > 			entry = mk_pte(page + i, vma->vm_page_prot);
> > 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> > 			if (!pmd_write(*pmd))
> > 				entry = pte_wrprotect(entry);
> > 			else
> > 				BUG_ON(page_mapcount(page) != 1);
> > 			if (!pmd_young(*pmd))
> > 				entry = pte_mkold(entry);
> > 			if (pmd_numa(*pmd))
> > 				entry = pte_mknuma(entry);
> > 			pte = pte_offset_map(&_pmd, haddr);
> > 			BUG_ON(!pte_none(*pte));
> > 			set_pte_at(mm, haddr, pte, entry);
> > 			pte_unmap(pte);
> > 		}
> > 
> > If "young" or "numa" bitflags changed on the original *pmd for the
> > previous part of split_huge_page, nothing will go wrong by the time we
> > get to split_huge_page_map (the same is not true if the pfn changes!).
> > 
> 
> But this time BUG_ON(mapcount != mapcount2) in function
> __split_huge_page will be trigged.

"young" or "numa" bitflags in the pmd don't alter
rmap/mapcount/pagecount/pfn or anything that could affect such BUG_ON,
so I'm not sure why you think so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
