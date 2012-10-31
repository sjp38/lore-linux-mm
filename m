Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id AF8686B0083
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 07:03:39 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id fl17so1683051vcb.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 04:03:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1351679605-4816-1-git-send-email-walken@google.com>
References: <1351679605-4816-1-git-send-email-walken@google.com>
Date: Wed, 31 Oct 2012 04:03:38 -0700
Message-ID: <CANN689GKp6beDOwSs_EYaYRgs4GzjuD+1engDYuRTOB+nHdTsA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/6] mm: use augmented rbtrees for finding unmapped areas
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org

On Wed, Oct 31, 2012 at 3:33 AM, Michel Lespinasse <walken@google.com> wrote:
> My own feel for this series is that I'm fairly confident in the
> robustness of my vm_unmapped_area() implementation; however I would
> like to confirm that people are happy with this new interface. Also
> the code that figures out what constraints to pass to
> vm_unmapped_area() is a bit odd; I have tried to make the constraints
> match the behavior of the current code but it's not clear to me if
> that behavior makes sense in the first place.

I wanted to expand a bit on that by listing some of these behaviors I
have made sure to preserve without really understanding why they are
as they are:

- arch_get_unmapped_area() doesn't make use of mm->mmap_base, this
value is used only when doing downwards allocations. However, many
architectures including x86_64 carefully initialize this (in
arch_pick_mmap_layout() ) to different values based on the up/down
allocation direction. It seems that the legacy (upwards allocation)
mmap_base value is irrelevant as I don't see any place using it ???

- For downwards allocations, it is not clear if the lowest valid
address should be 0 or PAGE_SIZE. Existing brute-force search code
will treat address 0 as valid on entering the loop, but invalid when
reaching the end of the loop.

- When user passes a suggested address without the MAP_FIXED flag, the
address range we validate the address against varies depending on the
upwards/downwards allocation direction. This doesn't make much sense
since there is no address space search taking place in this case.

- The stragegy of allocating upwards if the downwards allocation
failed is a bit strange. I'm not sure what we really want; maybe we
only need to extend the valid address range for the initial search ?
(IIRC Rik's initial patch series got rid of this redundant search, but
didn't explain why this was considered safe).

That's all I noticed, but this is really most of the remaining code
left in arch_get_unmapped_area[_topdown]... and I didn't even go into
architectures other than x86, where I could find some additional
questionable stuff (but I don't even want to go there before we at
least agree on the general principle of this patch series).

I hope with a proper understanding of the allocation strategies /
constraints it might be possible to unify the remaining
arch_get_unmapped_area[_topdown] code between architectures, but I'm
keeping this for a later step as I'm obviously not informed enough to
tackle that just yet...

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
