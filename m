Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4692D8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:08:55 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id m13so7369660pls.15
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:08:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j22sor1152364pll.8.2019.01.10.18.08.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 18:08:53 -0800 (PST)
Date: Thu, 10 Jan 2019 18:08:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is
 migrated
In-Reply-To: <fccdbef6-00cf-38ad-3aa0-9466c9b83176@suse.cz>
Message-ID: <alpine.LSU.2.11.1901101748550.3146@eggly.anvils>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils> <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com> <alpine.LSU.2.11.1811251900300.1278@eggly.anvils> <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
 <fccdbef6-00cf-38ad-3aa0-9466c9b83176@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Thu, 10 Jan 2019, Vlastimil Babka wrote:
> 
> For the record, anyone backporting this to older kernels should make
> sure to also include 605ca5ede764 ("mm/huge_memory.c: reorder operations
> in __split_huge_page_tail()") or they are in for a lot of fun, like me.

Thanks a lot for alerting us all to this, Vlastimil.  Yes, I consider
Konstantin's 605ca5ede764 a must-have, and so had it already in all
the trees on which I was testing put_and_wait_on_page_locked(),
without being aware of the critical role it was playing.

But you do enjoy fun, don't you? So I shouldn't apologize :)

> 
> Long story [1] short, Konstantin was correct in 605ca5ede764 changelog,
> although it wasn't the main known issue he was fixing:
> 
>   clear_compound_head() also must be called before unfreezing page
>   reference because after successful get_page_unless_zero() might follow
>   put_page() which needs correct compound_head().
> 
> Which is exactly what happens in __migration_entry_wait():
> 
>         if (!get_page_unless_zero(page))
>                 goto out;
>         pte_unmap_unlock(ptep, ptl);
>         put_and_wait_on_page_locked(page); -> does put_page(page)
> 
> while waiting on the THP split (which inserts those migration entries)
> to finish. Before put_and_wait_on_page_locked() it would wait first, and
> only then do put_page() on a page that's no longer tail page, so it
> would work out despite the dangerous get_page_unless_zero() on a tail
> page. Now it doesn't :)

It took me a while to follow there, but yes, agreed.

> 
> Now if only 605ca5ede764 had a CC:stable and a Fixes: tag... Machine
> Learning won this round though, because 605ca5ede764 was added to 4.14
> stable by Sasha...

I'm proud to have passed the Turing test in reverse, but actually
that was me, not ML.  My 173d9d9fd3dd ("mm/huge_memory: splitting set
mapping+index before unfreeze") in 4.20 built upon Konstantin's, so I
included his as a precursor when sending the stable guys pre-XArray
backports.  So Konstantin's is even in 4.9 stable now.

Hugh
