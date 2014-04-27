Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 156636B0035
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 16:11:06 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so5040179pbc.21
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 13:11:05 -0700 (PDT)
Received: from mail-pb0-x231.google.com (mail-pb0-x231.google.com [2607:f8b0:400e:c01::231])
        by mx.google.com with ESMTPS id sf3si8990987pac.1.2014.04.27.13.11.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 27 Apr 2014 13:11:04 -0700 (PDT)
Received: by mail-pb0-f49.google.com with SMTP id rr13so4979669pbb.8
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 13:11:04 -0700 (PDT)
Date: Sun, 27 Apr 2014 13:09:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Dirty/Access bits vs. page content
In-Reply-To: <alpine.LSU.2.11.1404270459160.2688@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1404271220100.3724@eggly.anvils>
References: <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com> <1398389846.8437.6.camel@pasglop> <1398393700.8437.22.camel@pasglop> <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com> <5359CD7C.5020604@zytor.com>
 <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com> <alpine.LSU.2.11.1404250414590.5198@eggly.anvils> <20140425135101.GE11096@twins.programming.kicks-ass.net> <alpine.LSU.2.11.1404251215280.5909@eggly.anvils> <20140426180711.GM26782@laptop.programming.kicks-ass.net>
 <20140427072034.GC1429@laptop.programming.kicks-ass.net> <alpine.LSU.2.11.1404270459160.2688@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Sun, 27 Apr 2014, Hugh Dickins wrote:
> 
> But woke with a panic attack that we have overlooked the question
> of how page reclaim's page_mapped() checks are serialized.
> Perhaps this concern will evaporate with the morning dew,
> perhaps it will not...

It was a real concern, but we happen to be rescued by the innocuous-
looking is_page_cache_freeable() check at the beginning of pageout():
which will deserve its own comment, but that can follow later.

My concern was with page reclaim's shrink_page_list() racing against
munmap's or exit's (or madvise's) zap_pte_range() unmapping the page.

Once zap_pte_range() has cleared the pte from a vma, neither
try_to_unmap() nor page_mkclean() will see that vma as containing
the page, so neither will do its own flush TLB of the cpus involved,
before proceeding to writepage.

Linus's patch (serialializing with ptlock) or my patch (serializing
with i_mmap_mutex) both almost fix that, but it seemed not entirely:
because try_to_unmap() is only called when page_mapped(), and
page_mkclean() quits early without taking locks when !page_mapped().

So in the interval when zap_pte_range() has brought page_mapcount()
down to 0, but not yet flushed TLB on all mapping cpus, it looked as
if we still had a problem - neither try_to_unmap() nor page_mkclean()
would take the lock either of us rely upon for serialization.

But pageout()'s preliminary is_page_cache_freeable() check makes
it safe in the end: although page_mapcount() has gone down to 0,
page_count() remains raised until the free_pages_and_swap_cache()
after the TLB flush.

So I now believe we're safe after all with either patch, and happy
for Linus to go ahead with his.

Peter, returning at last to your question of whether we could exempt
shmem from the added overhead of either patch.  Until just now I
thought not, because of the possibility that the shmem_writepage()
could occur while one of the mm's cpus remote from zap_pte_range()
cpu was still modifying the page.  But now that I see the role
played by is_page_cache_freeable(), and of course the zapping end
has never dropped its reference on the page before the TLB flush,
however late that occurred, hmmm, maybe yes, shmem can be exempted.

But I'd prefer to dwell on that a bit longer: we can add that as
an optimization later if it holds up to scrutiny.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
