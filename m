Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id E2A7E6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 11:58:24 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so8981241pbc.18
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 08:58:24 -0700 (PDT)
Date: Tue, 15 Oct 2013 17:58:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: fix BUG in __split_huge_page_pmd
Message-ID: <20131015155815.GG3479@redhat.com>
References: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
 <20131015143407.GE3479@redhat.com>
 <20131015144827.C45DDE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131015144827.C45DDE0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 15, 2013 at 05:48:27PM +0300, Kirill A. Shutemov wrote:
> Andrea Arcangeli wrote:
> > Hi Hugh,
> > 
> > On Tue, Oct 15, 2013 at 04:08:28AM -0700, Hugh Dickins wrote:
> > > Occasionally we hit the BUG_ON(pmd_trans_huge(*pmd)) at the end of
> > > __split_huge_page_pmd(): seen when doing madvise(,,MADV_DONTNEED).
> > > 
> > > It's invalid: we don't always have down_write of mmap_sem there:
> > > a racing do_huge_pmd_wp_page() might have copied-on-write to another
> > > huge page before our split_huge_page() got the anon_vma lock.
> > > 
> > 
> > I don't get exactly the scenario with do_huge_pmd_wp_page(), could you
> > elaborate?
> 
> I think the scenario is follow:
> 
> 	CPU0:					CPU1
> 
> __split_huge_page_pmd()
> 	page = pmd_page(*pmd);
> 					do_huge_pmd_wp_page() copy the
> 					page and changes pmd (the same as on CPU0)
> 					to point to newly copied page.
> 	split_huge_page(page)
> 	where page is original page,
> 	not allocated on COW.
> 	pmd still points on huge page.
> 
> 
> Hugh, have I got it correctly?

So MADV_DONTNEED runs with with a "end" not 2m aligned (requiring 4k
subpage zapping) on a wrprotected trans-huge page that is hitting a
COW. So this scenario would be deterministic (the thread may write
beyond the "end" of the MADV_DONTNEED) and it only requires two
specific events.

With my other scenario with two concurrent MADV_DONTNEED plus a page
fault, you could still lead to split_huge_page_pmd returning with
pmd_trans_huge(*pmd) == true, despite of the loop introduced.

But for the above case, the loop makes a meaningful difference. So I
see the good reason for looping now.

It wouldn't be ok to miss a partial MADV_DONTNEED zapping because of a
concurrent COW, while it would be ok in my other scenario (and the
loop in fact cannot do anything to prevent split_huge_page_pmd return
with the pmd still huge).

My other scenario with two concurrent MADV_DONTNEED and a page fault
is non deterministic so looping was meaningless.

In both scenario, the kernel wouldn't run into stability issues, even
if we only removed the BUG_ON. But the COW scenario, without the loop,
we'd silently miss a partial MADV_DONTNEED on the 4k subpages before
the "end" (or after the "start").

And we still need pmd_none_or_trans_huge_or_clear_bad in
zap_pmd_range, to deal with the non deterministic cases that the loop
won't help (the two MADV_DONTNEED + page fault), in addition to the
loop to deal with the deterministic COW scenario above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
