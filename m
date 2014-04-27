Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9706B6B0044
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 03:20:46 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id q108so5768791qgd.3
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 00:20:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id m2si6178685qae.204.2014.04.27.00.20.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 00:20:45 -0700 (PDT)
Date: Sun, 27 Apr 2014 09:20:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Dirty/Access bits vs. page content
Message-ID: <20140427072034.GC1429@laptop.programming.kicks-ass.net>
References: <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
 <1398389846.8437.6.camel@pasglop>
 <1398393700.8437.22.camel@pasglop>
 <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
 <5359CD7C.5020604@zytor.com>
 <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
 <alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
 <20140425135101.GE11096@twins.programming.kicks-ass.net>
 <alpine.LSU.2.11.1404251215280.5909@eggly.anvils>
 <20140426180711.GM26782@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140426180711.GM26782@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Sat, Apr 26, 2014 at 08:07:11PM +0200, Peter Zijlstra wrote:
> > > I think we could look at mapping_cap_account_dirty(page->mapping) while
> > > holding the ptelock, the mapping can't go away while we hold that lock.
> > > 
> > > And afaict that's the exact differentiator between these two cases.
> > 
> > Yes, that's easily done, but I wasn't sure whether it was correct to
> > skip on shmem or not - just because shmem doesn't participate in the
> > page_mkclean() protocol, doesn't imply it's free from similar bugs.
> > 
> > I haven't seen a precise description of the bug we're anxious to fix:
> > Dave's MADV_DONTNEED should be easily fixable, that's not a concern;
> > Linus's first patch wrote of writing racing with cleaning, but didn't
> > give a concrete example.
> 
> The way I understand it is that we observe the PTE dirty and set PAGE
> dirty before we make the PTE globally unavailable (through a TLB flush),
> and thereby we can mistakenly loose updates; by thinking a page is in
> fact clean even though we can still get updates.
> 
> But I suspect you got that far..

OK, so I've been thinking and figured I either mis-understand how the
hardware works or don't understand how Linus' patch will actually fully
fix the issue.

So what both try_to_unmap_one() and zap_pte_range() end up doing is
clearing the PTE entry and then flushing the TLBs.

However, that still leaves a window where there are remote TLB entries.
What if any of those remote entries cause a write (or have a dirty bit
cached) while we've already removed the PTE entry.

This means that the remote CPU cannot update the PTE anymore (its not
there after all).

Will the hardware fault when it does a translation and needs to update
the dirty/access bits while the PTE entry is !present?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
