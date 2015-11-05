Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD9B82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 20:48:51 -0500 (EST)
Received: by pasz6 with SMTP id z6so72572490pas.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 17:48:50 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id gt4si3803128pbb.89.2015.11.04.17.48.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 17:48:50 -0800 (PST)
Date: Thu, 5 Nov 2015 10:48:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Message-ID: <20151105014855.GJ7357@bbox>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
 <20151105001348.GC7357@bbox>
 <CALCETrV0yd26+G_kvmRbJwjCNguUh6iLwhyO1yKQ2bgiiWegEw@mail.gmail.com>
 <20151105005607.GE7357@bbox>
 <CALCETrWWgbPNwCr-=LF8p33H25C_aNS5vy4wd3NUap6SmrsmkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWWgbPNwCr-=LF8p33H25C_aNS5vy4wd3NUap6SmrsmkA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, Shaohua Li <shli@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin wang <yalin.wang2010@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Mel Gorman <mgorman@suse.de>

On Wed, Nov 04, 2015 at 05:29:57PM -0800, Andy Lutomirski wrote:
> On Wed, Nov 4, 2015 at 4:56 PM, Minchan Kim <minchan@kernel.org> wrote:
> > On Wed, Nov 04, 2015 at 04:42:37PM -0800, Andy Lutomirski wrote:
> >> On Wed, Nov 4, 2015 at 4:13 PM, Minchan Kim <minchan@kernel.org> wrote:
> >> > On Tue, Nov 03, 2015 at 07:41:35PM -0800, Andy Lutomirski wrote:
> >> >> On Nov 3, 2015 5:30 PM, "Minchan Kim" <minchan@kernel.org> wrote:
> >> >> >
> >> >> > Linux doesn't have an ability to free pages lazy while other OS already
> >> >> > have been supported that named by madvise(MADV_FREE).
> >> >> >
> >> >> > The gain is clear that kernel can discard freed pages rather than swapping
> >> >> > out or OOM if memory pressure happens.
> >> >> >
> >> >> > Without memory pressure, freed pages would be reused by userspace without
> >> >> > another additional overhead(ex, page fault + allocation + zeroing).
> >> >> >
> >> >>
> >> >> [...]
> >> >>
> >> >> >
> >> >> > How it works:
> >> >> >
> >> >> > When madvise syscall is called, VM clears dirty bit of ptes of the range.
> >> >> > If memory pressure happens, VM checks dirty bit of page table and if it
> >> >> > found still "clean", it means it's a "lazyfree pages" so VM could discard
> >> >> > the page instead of swapping out.  Once there was store operation for the
> >> >> > page before VM peek a page to reclaim, dirty bit is set so VM can swap out
> >> >> > the page instead of discarding.
> >> >>
> >> >> What happens if you MADV_FREE something that's MAP_SHARED or isn't
> >> >> ordinary anonymous memory?  There's a long history of MADV_DONTNEED on
> >> >> such mappings causing exploitable problems, and I think it would be
> >> >> nice if MADV_FREE were obviously safe.
> >> >
> >> > It filter out VM_LOCKED|VM_HUGETLB|VM_PFNMAP and file-backed vma and MAP_SHARED
> >> > with vma_is_anonymous.
> >> >
> >> >>
> >> >> Does this set the write protect bit?
> >> >
> >> > No.
> >> >
> >> >>
> >> >> What happens on architectures without hardware dirty tracking?  For
> >> >> that matter, even on architecture with hardware dirty tracking, what
> >> >> happens in multithreaded processes that have the dirty TLB state
> >> >> cached in a different CPU's TLB?
> >> >>
> >> >> Using the dirty bit for these semantics scares me.  This API creates a
> >> >> page that can have visible nonzero contents and then can
> >> >> asynchronously and magically zero itself thereafter.  That makes me
> >> >> nervous.  Could we use the accessed bit instead?  Then the observable
> >> >
> >> > Access bit is used by aging algorithm for reclaim. In addition,
> >> > we have supported clear_refs feacture.
> >> > IOW, it could be reset anytime so it's hard to use marker for
> >> > lazy freeing at the moment.
> >> >
> >>
> >> That's unfortunate.  I think that the ABI would be much nicer if it
> >> used the accessed bit.
> >>
> >> In any case, shouldn't the aging algorithm be irrelevant here?  A
> >> MADV_FREE page that isn't accessed can be discarded, whereas we could
> >> hopefully just say that a MADV_FREE page that is accessed gets moved
> >> to whatever list holds recently accessed pages and also stops being a
> >> candidate for discarding due to MADV_FREE?
> >
> > I meant if we use access bit as indicator for lazy-freeing page,
> > we could discard valid page which is never hinted by MADV_FREE but
> > just doesn't mark access bit in page table by aging algorithm.
> 
> Oh, is the rule that the anonymous pages that are clean are discarded
> instead of swapped out?  That is, does your patch set detect that an

The page swapped-in after swapped-out has clean pte and swap device
has valid data if the page isn't touch so VM discards the page rather
than swapout. Of course, pte should point out the swap slot.
If VM decide to remove the page from swap slot, it should be marked
PG_dirty.

> anonymous page can be discarded if it's clean and that the lack of a
> dirty bit is the only indication that the page has been hit with
> MADV_FREE?

No dirty bit, exactly speaking, PG_Dirty
because the page I mentioned above has clean pte but will have PG_dirty.

> 
> If so, that seems potentially error prone -- I had assumed that pages
> that were swapped in but not written since swap-in would also be
> clean, and I don't see how you distinguish them.

I hope above will answer.
> 
> --Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
