Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58EC78E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 14:43:22 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 202so27595342pgb.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 11:43:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor19973845plo.55.2019.01.02.11.43.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 11:43:21 -0800 (PST)
Date: Wed, 2 Jan 2019 11:43:12 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
In-Reply-To: <CANaguZC_d2EBmNuXtcJRcEcw8uXK234tYSXx6Uc2o9JH_vfP4A@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1901021039490.13761@eggly.anvils>
References: <20181203170934.16512-1-vpillai@digitalocean.com> <20181203170934.16512-2-vpillai@digitalocean.com> <alpine.LSU.2.11.1812311635590.4106@eggly.anvils> <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com> <alpine.LSU.2.11.1901012010440.13241@eggly.anvils>
 <CANaguZC_d2EBmNuXtcJRcEcw8uXK234tYSXx6Uc2o9JH_vfP4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineeth Pillai <vpillai@digitalocean.com>
Cc: Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

On Wed, 2 Jan 2019, Vineeth Pillai wrote:
> 
> After reading the code again, I feel like we can make the retry logic
> simpler and avoid the use of oldi. If my understanding is correct,
> except for frontswap case, we reach try_to_unuse() only after we
> disable the swap device. So I think, we would not be seeing any more
> swap usage on the disabled swap device, after we loop through all the
> process and swapin the pages on that device. In that case, we would
> not need the retry logic right?

Wrong.  Without heavier locking that would add unwelcome overhead to
common paths, we shall "always" need the retry logic.  It does not
come into play very often, but here are two examples of why it's
needed (if I thought longer, I might find more).  And in practice,
yes, I sometimes saw 1 retry needed.

One, the issue already discussed, of a multiply-mapped page which is
swapped out, one pte swapped off, but swapped back in by concurrent
fault before the last pte has been swapped off and the page finally
deleted from swap cache.  That swapin still references the disabled
swapfile, and will need a retry to unuse (and that retry might need
another).  We may fix this later with an rmap walk while still holding
page locked for the first pte; but even if we do, I'd still want to
retain the retry logic, to avoid dependence on corner-case-free
reliable rmap walks.

Two, get_swap_page() allocated a swap entry for shmem file or vma
just before the swapoff started, but the swapper did not reach the
point of inserting that swap entry before try_to_unuse() scanned
the shmem file or vma in question.

> For frontswap case, the patch was missing a check for pages_to_unuse.
> We would still need the retry logic, but as you mentioned, I can
> easily remove the oldi logic and make it simpler. Or probably,
> refactor the frontswap code out as a special case if pages_to_unuse is
> still not zero after the initial loop.

I don't use frontswap myself, and haven't paid any attention to the
frontswap partial swapoff case (though notice now that shmem_unuse()
lacks the plumbing needed for it - that needs fixing); but doubt it
would be a good idea to refactor it out as a separate case.

Hugh
