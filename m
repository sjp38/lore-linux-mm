Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1926B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 02:50:17 -0400 (EDT)
Received: by pasz6 with SMTP id z6so212950641pas.2
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 23:50:17 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id og1si59495691pbc.146.2015.10.26.23.50.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 23:50:16 -0700 (PDT)
Received: by pasz6 with SMTP id z6so212950255pas.2
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 23:50:16 -0700 (PDT)
Date: Tue, 27 Oct 2015 15:50:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/5] mm: clear PG_dirty to mark page freeable
Message-ID: <20151027065032.GA26803@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
 <1445236307-895-4-git-send-email-minchan@kernel.org>
 <alpine.LSU.2.11.1510261826190.10825@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510261826190.10825@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Oct 26, 2015 at 06:28:13PM -0700, Hugh Dickins wrote:
> On Mon, 19 Oct 2015, Minchan Kim wrote:
> 
> > Basically, MADV_FREE relies on dirty bit in page table entry
> > to decide whether VM allows to discard the page or not.
> > IOW, if page table entry includes marked dirty bit, VM shouldn't
> > discard the page.
> > 
> > However, as a example, if swap-in by read fault happens,
> > page table entry doesn't have dirty bit so MADV_FREE could discard
> > the page wrongly.
> > 
> > For avoiding the problem, MADV_FREE did more checks with PageDirty
> > and PageSwapCache. It worked out because swapped-in page lives on
> > swap cache and since it is evicted from the swap cache, the page has
> > PG_dirty flag. So both page flags check effectively prevent
> > wrong discarding by MADV_FREE.
> > 
> > However, a problem in above logic is that swapped-in page has
> > PG_dirty still after they are removed from swap cache so VM cannot
> > consider the page as freeable any more even if madvise_free is
> > called in future.
> > 
> > Look at below example for detail.
> > 
> >     ptr = malloc();
> >     memset(ptr);
> >     ..
> >     ..
> >     .. heavy memory pressure so all of pages are swapped out
> >     ..
> >     ..
> >     var = *ptr; -> a page swapped-in and could be removed from
> >                    swapcache. Then, page table doesn't mark
> >                    dirty bit and page descriptor includes PG_dirty
> >     ..
> >     ..
> >     madvise_free(ptr); -> It doesn't clear PG_dirty of the page.
> >     ..
> >     ..
> >     ..
> >     .. heavy memory pressure again.
> >     .. In this time, VM cannot discard the page because the page
> >     .. has *PG_dirty*
> > 
> > To solve the problem, this patch clears PG_dirty if only the page
> > is owned exclusively by current process when madvise is called
> > because PG_dirty represents ptes's dirtiness in several processes
> > so we could clear it only if we own it exclusively.
> > 
> > Cc: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Acked-by: Hugh Dickins <hughd@google.com>
> 
> (and patches 1/5 and 2/5 too if you like)
> 

Thanks for the review, Hugh!

I will rebase all series from the beginning as you suggested
and will add your Acked-by because I feel you just reviewed
all of MADV_FREE code line and you have no found any problem.

If something happens(ie, I abuse your Acked-by) wrong, please
shout me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
