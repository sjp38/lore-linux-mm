Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 4853B6B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 12:49:55 -0500 (EST)
Date: Tue, 8 Jan 2013 18:49:51 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: oops in copy_page_rep()
Message-ID: <20130108174951.GG9163@redhat.com>
References: <20130105152208.GA3386@redhat.com>
 <CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com>
 <alpine.LNX.2.00.1301061037140.28950@eggly.anvils>
 <CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
 <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
 <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
 <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
 <20130108163141.GA27555@shutemov.name>
 <CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com>
 <20130108173058.GA27727@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130108173058.GA27727@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

Hi Kirill,

On Tue, Jan 08, 2013 at 07:30:58PM +0200, Kirill A. Shutemov wrote:
> Merged patch is obviously broken: huge_pmd_set_accessed() can be called
> only if the pmd is under splitting.

Of course I assume you meant "only if the pmd is not under splitting".

But no, setting a bitflag like the young bit or clearing or setting
the numa bit won't screw with split_huge_page and it's safe even if
the pmd is under splitting.

Those bits are only checked here at the last stage of
split_huge_page_map after taking the PT lock:

	spin_lock(&mm->page_table_lock);
	pmd = page_check_address_pmd(page, mm, address,
				     PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG);
	if (pmd) {
		pgtable = pgtable_trans_huge_withdraw(mm);
		pmd_populate(mm, &_pmd, pgtable);

		haddr = address;
		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
			pte_t *pte, entry;
			BUG_ON(PageCompound(page+i));
			entry = mk_pte(page + i, vma->vm_page_prot);
			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
			if (!pmd_write(*pmd))
				entry = pte_wrprotect(entry);
			else
				BUG_ON(page_mapcount(page) != 1);
			if (!pmd_young(*pmd))
				entry = pte_mkold(entry);
			if (pmd_numa(*pmd))
				entry = pte_mknuma(entry);
			pte = pte_offset_map(&_pmd, haddr);
			BUG_ON(!pte_none(*pte));
			set_pte_at(mm, haddr, pte, entry);
			pte_unmap(pte);
		}

If "young" or "numa" bitflags changed on the original *pmd for the
previous part of split_huge_page, nothing will go wrong by the time we
get to split_huge_page_map (the same is not true if the pfn changes!).

If you think this is too tricky, we could also decide to forbid
huge_pmd_set_accessed if the pmd is in splitting state, but I don't
think that flipping young/numa bits while in splitting state, can
cause any problem (if done correctly with PT lock + pmd_same).

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
