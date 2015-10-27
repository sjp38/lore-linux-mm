Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C36446B0253
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 02:58:28 -0400 (EDT)
Received: by pasz6 with SMTP id z6so213173225pas.2
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 23:58:28 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id c17si59517340pbu.132.2015.10.26.23.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 23:58:28 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so222854698pac.3
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 23:58:28 -0700 (PDT)
Date: Tue, 27 Oct 2015 15:58:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/5] mm: mark stable page dirty in KSM
Message-ID: <20151027065845.GC26803@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
 <1445236307-895-6-git-send-email-minchan@kernel.org>
 <alpine.LSU.2.11.1510261909250.10825@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510261909250.10825@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Oct 26, 2015 at 07:23:12PM -0700, Hugh Dickins wrote:
> On Mon, 19 Oct 2015, Minchan Kim wrote:
> 
> > Stable page could be shared by several processes and last process
> > could own the page among them after CoW or zapping for every process
> > except last process happens. Then, page table entry of the page
> > in last process can have no dirty bit and PG_dirty flag in page->flags.
> > In this case, MADV_FREE could discard the page wrongly.
> > For preventing it, we mark stable page dirty.
> 
> I agree with the change, but found that comment (repeated in the source)
> rather hard to follow.  And it doesn't really do justice to the changes
> you have made.
> 
> This is not now a MADV_FREE thing, it's more general than that, even
> if MADV_FREE is the only thing that takes advantage of it.  I like
> very much that you've made page reclaim sane, freeing non-dirty
> anonymous pages instead of swapping them out, without having to
> think of whether it's for MADV_FREE or not.
> 
> Would you mind if we replace your patch by a re-commented version?
> 
> [PATCH] mm: mark stable page dirty in KSM
> 
> The MADV_FREE patchset changes page reclaim to simply free a clean
> anonymous page with no dirty ptes, instead of swapping it out; but
> KSM uses clean write-protected ptes to reference the stable ksm page.
> So be sure to mark that page dirty, so it's never mistakenly discarded.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Looks better than mine.
I will include this in my patchset when I respin.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
