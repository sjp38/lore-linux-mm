Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5C86B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 11:02:21 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id v1so3834707yhn.12
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 08:02:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g6si13575286qaz.115.2015.01.26.08.02.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 08:02:20 -0800 (PST)
Date: Mon, 26 Jan 2015 16:19:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] mm: incorporate read-only pages into transparent huge
 pages
Message-ID: <20150126151906.GS11755@redhat.com>
References: <1422113880-4712-1-git-send-email-ebru.akagunduz@gmail.com>
 <54C5EE66.4060700@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54C5EE66.4060700@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, riel@redhat.com

Hi,

On Mon, Jan 26, 2015 at 08:36:06AM +0100, Vlastimil Babka wrote:
> >  - Add fast path optimistic check to
> >    __collapse_huge_page_isolate()
> 
> My interpretation is that the optimistic check is in khugepaged_scan_pmd() while
> in __collapse_huge_page_isolate() it's protected by lock, as Andrea suggested?

Correct, __collapse_huge_page_isolate is the "accurate" check that was
missing in v1. The optimistic check was the one in khugepaged_scan_pmd
and it was already present.

> > @@ -2168,9 +2168,6 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
> >  		VM_BUG_ON_PAGE(!PageAnon(page), page);
> >  		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
> >  
> > -		/* cannot use mapcount: can't collapse if there's a gup pin */
> > -		if (page_count(page) != 1)
> > -			goto out;
> >  		/*
> >  		 * We can do it before isolate_lru_page because the
> >  		 * page can't be freed from under us. NOTE: PG_lock
> > @@ -2179,6 +2176,31 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
> >  		 */
> >  		if (!trylock_page(page))
> >  			goto out;
> > +
> > +		/*
> > +		 * cannot use mapcount: can't collapse if there's a gup pin.
> > +		 * The page must only be referenced by the scanned process
> > +		 * and page swap cache.
> > +		 */
> > +		if (page_count(page) != 1 + !!PageSwapCache(page)) {
> > +			unlock_page(page);
> > +			goto out;
> > +		}
> > +		if (!pte_write(pteval)) {
> > +			if (++ro > khugepaged_max_ptes_none) {
> > +				unlock_page(page);
> > +				goto out;
> 
> So just for completeness, as I said later for v1 I think this can leave us with
> read-only VMA: consider ro == 256 and none == 256, referenced can still be >0
> (up to 256). I think that the check for referenced that follows this for loop
> should also check if (ro + none < HPAGE_PMD_NR).

The moment "ro" becomes 256 or "none" becomes 256, we immediately goto out.

	if (likely(referenced))
		return 1;
out:
	release_pte_pages(pte, _pte);
	return 0;

"out" is past the referenced check and we fail the collapse
immediately.

If ro is < 255 then "none" is also < 255 (if pte_write is true, then
pte_none cannot be true).

Overall I don't see how we could collapse in readonly vma and where
the bug is for this case, but I may be overlooking something obvious.

> > +			}
> > +			if (PageSwapCache(page) && !reuse_swap_page(page)) {
> > +				unlock_page(page);
> > +				goto out;
> > +			}
> > +			/*
> > +			 * Page is not in the swap cache, and page count is
> > +			 * one (see above). It can be collapsed into a THP.
> > +			 */
> 
> I would still put the VM_BUG_ON(page_count(page) != 1) here as I suggested
> previously. Even more so that I think it would have been able to catch the
> problem that Andrea pointed out in v1.

This is subtle, but we can't do VM_BUG_ON because it's ok if the VM
comes before us in another CPU, and takes a pin on the page to isolate
the page.

In short if you changed the current upstream code like below:

		/* cannot use mapcount: can't collapse if there's a gup pin */
		if (page_count(page) != 1)
			goto out;
		VM_BUG_ON(page_count(page) != 1);
		trylock...

the VM_BUG_ON could fire as a false positive. It's not even related to
the trylock_page, it's related to the LRU lock and isolate_lru_page
that the VM could run on a different CPU and it's not a bug.

The VM is free to pin the page. We only need to be sure there are no
GUP-pins after we blocked all variants of GUP and the check is enough
for that.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
