Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8E39D6B0036
	for <linux-mm@kvack.org>; Sat, 26 Apr 2014 14:07:35 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id l6so4554744qcy.10
        for <linux-mm@kvack.org>; Sat, 26 Apr 2014 11:07:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id m6si5605959qcg.34.2014.04.26.11.07.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Apr 2014 11:07:34 -0700 (PDT)
Date: Sat, 26 Apr 2014 20:07:11 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Dirty/Access bits vs. page content
Message-ID: <20140426180711.GM26782@laptop.programming.kicks-ass.net>
References: <alpine.LSU.2.11.1404241252520.3455@eggly.anvils>
 <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
 <1398389846.8437.6.camel@pasglop>
 <1398393700.8437.22.camel@pasglop>
 <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
 <5359CD7C.5020604@zytor.com>
 <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
 <alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
 <20140425135101.GE11096@twins.programming.kicks-ass.net>
 <alpine.LSU.2.11.1404251215280.5909@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404251215280.5909@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

> > I think we could look at mapping_cap_account_dirty(page->mapping) while
> > holding the ptelock, the mapping can't go away while we hold that lock.
> > 
> > And afaict that's the exact differentiator between these two cases.
> 
> Yes, that's easily done, but I wasn't sure whether it was correct to
> skip on shmem or not - just because shmem doesn't participate in the
> page_mkclean() protocol, doesn't imply it's free from similar bugs.
> 
> I haven't seen a precise description of the bug we're anxious to fix:
> Dave's MADV_DONTNEED should be easily fixable, that's not a concern;
> Linus's first patch wrote of writing racing with cleaning, but didn't
> give a concrete example.

The way I understand it is that we observe the PTE dirty and set PAGE
dirty before we make the PTE globally unavailable (through a TLB flush),
and thereby we can mistakenly loose updates; by thinking a page is in
fact clean even though we can still get updates.

But I suspect you got that far..

> How about this: a process with one thread repeatedly (but not very often)
> writing timestamp into a shared file mapping, but another thread munmaps
> it at some point; and another process repeatedly (but not very often)
> reads the timestamp file (or peeks at it through mmap); with memory
> pressure forcing page reclaim.
> 
> In the page_mkclean() shared file case, the second process might see
> the timestamp move backwards: because a write from the timestamping
> thread went into the pagecache after it had been written, but the
> page not re-marked dirty; so when reclaimed and later read back
> from disk, the older timestamp is seen.
> 
> But I think you can remove "page_mkclean() " from that paragraph:
> the same can happen with shmem written out to swap.

I'm not entirely seeing how this could happen for shmem; the swap path
goes through try_to_unmap_one(), which removes the PTE and does a full
TLB flush. Anything after that will get a fault (which will hit either
the swapcache or actual swap).

The rmap walk of try_to_unmap() is the same as the one for
page_mkclean().

So if we're good on the one, we're good on the other.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
