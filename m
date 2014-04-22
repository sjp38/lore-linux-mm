Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 265666B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 17:36:41 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id ld13so87404vcb.19
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:36:40 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id iy9si7112931vec.87.2014.04.22.14.36.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 14:36:40 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id ib6so89988vcb.27
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:36:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140422075459.GD11182@twins.programming.kicks-ass.net>
References: <1398032742.19682.11.camel@pasglop>
	<CA+55aFz1sK+PF96LYYZY7OB7PBpxZu-uNLWLvPiRz-tJsBqX3w@mail.gmail.com>
	<1398054064.19682.32.camel@pasglop>
	<1398057630.19682.38.camel@pasglop>
	<CA+55aFwWHBtihC3w9E4+j4pz+6w7iTnYhTf4N3ie15BM9thxLQ@mail.gmail.com>
	<53558507.9050703@zytor.com>
	<CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
	<53559F48.8040808@intel.com>
	<CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
	<CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
	<20140422075459.GD11182@twins.programming.kicks-ass.net>
Date: Tue, 22 Apr 2014 14:36:40 -0700
Message-ID: <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
Subject: Re: Dirty/Access bits vs. page content
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Tue, Apr 22, 2014 at 12:54 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> So PAGE_FLAGS_CHECK_AT_FREE doesn't include PG_dirty, so while we now
> properly mark the page dirty, we could continue and simply free the
> thing?

Yes. But being free'd while dirty should be fairly normal for
anonymous pages, no? And while I did a "pte_mkclean()" the the
PageAnon() case (so that we won't waste time on "set_page_dirty()" on
pages we don't care about, a concurrent truncate() could have turned
what *used* to be a file-backed page into just a dirty page with no
mapping any more.

So I don't think we would necessarily want to check for PG_dirty at
page freeing time, because freeing dirty pages isn't necessarily
wrong. For example, tmpfs/shmfs pages are generally always dirty, and
would get freed when the inode is deleted.

That said, Dave Hansen did report a BUG_ON() in
mpage_prepare_extent_to_map(). His line number was odd, but I assume
it's this one:

        BUG_ON(PageWriteback(page));

which may be indicative of some oddity here wrt the dirty bit.

So I'm a bit worried.  I'm starting to think that we need to do
"set_page_dirty_lock()". It *used* to be the case that because we held
the page table lock and the page used to be mapped (even if we then
unmapped it), page_mapping() could not go away from under us because
truncate would see it in the rmap list and then get serialized on that
page table lock. But moving the set_page_dirty() later - and to
outside the page table lock - means that we probably need to use that
version that takes the page lock.

Which might kind of suck from a performance angle. But it might
explain DaveH's BUG_ON() when testing those patches?

I wonder if we could hold on to the page mapping some other way than
taking that page lock, because taking that page lock sounds
potentially damn expensive.

Who is the master of the lock_page() semantics? Hugh Dickins again?
I'm bringing him in for this issue too, since whenever there is some
vm locking issue, he is always on top of it.

Hugh - I'm assuming you are on linux-mm. If not, holler, and I'll send
you the two patches I wrote for the TLB dirty shootdown (short
explanation: dirty bit setting needs to be delayed until after tlb
flushing, since other CPU's may be busily writing to the page until
that time).

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
