Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 42B616B0035
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:53:30 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so9221412pdj.31
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:53:29 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so9104531pbc.17
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:53:27 -0700 (PDT)
Date: Tue, 15 Oct 2013 10:53:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: fix BUG in __split_huge_page_pmd
In-Reply-To: <20131015144827.C45DDE0090@blue.fi.intel.com>
Message-ID: <alpine.LNX.2.00.1310151029040.12481@eggly.anvils>
References: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils> <20131015143407.GE3479@redhat.com> <20131015144827.C45DDE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 15 Oct 2013, Kirill A. Shutemov wrote:
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

Yes, that's correct, that's what I've been assuming the race is.
With CPU0 split_huge_page_pmd() being called from zap_pmd_range()
in the service of madvise(,,MADV_DONTNEED).

I don't have the stacktrace to hand: could perfectly well dig it out
in an hour or two, but honestly, it adds nothing more to the picture.
I have no trace of the CPU1 side of things, and have merely surmised
that it was doing a COW.

As to whether the MADV_DONTNEED down_read optimization is important:
I don't recall, might be able to discover justification in old mail,
0a27a14a6292 doesn't actually say; but in general we're much better
off using down_read than down_write where it's safe to do so.

But more importantly, MADV_DONTNEED down_read across zap_page_range
is building on the fact that file invalidation/truncation can already
call zap_page_range without touching mmap_sem at all: not a problem
for traditional anon-only THP, but something you'll have had to worry
about for THPageCache.

I'm afraid Andrea's mail about concurrent madvises gives me far more
to think about than I have time for: seems to get into problems he
knows a lot about but I'm unfamiliar with.  If this patch looks good
for now on its own, let's put it in; but no problem if you guys prefer
to wait for a fuller solution of more problems, we can ride with this
one internally for the moment.

And I should admit that the crash has occurred too rarely for us yet
to be able to judge whether this patch actually fixes it in practice.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
