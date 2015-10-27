Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id EDA226B0038
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 22:23:15 -0400 (EDT)
Received: by pasz6 with SMTP id z6so205897310pas.2
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 19:23:15 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id bk2si57790810pbc.78.2015.10.26.19.23.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 19:23:15 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so215268680pac.3
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 19:23:15 -0700 (PDT)
Date: Mon, 26 Oct 2015 19:23:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 5/5] mm: mark stable page dirty in KSM
In-Reply-To: <1445236307-895-6-git-send-email-minchan@kernel.org>
Message-ID: <alpine.LSU.2.11.1510261909250.10825@eggly.anvils>
References: <1445236307-895-1-git-send-email-minchan@kernel.org> <1445236307-895-6-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>

On Mon, 19 Oct 2015, Minchan Kim wrote:

> Stable page could be shared by several processes and last process
> could own the page among them after CoW or zapping for every process
> except last process happens. Then, page table entry of the page
> in last process can have no dirty bit and PG_dirty flag in page->flags.
> In this case, MADV_FREE could discard the page wrongly.
> For preventing it, we mark stable page dirty.

I agree with the change, but found that comment (repeated in the source)
rather hard to follow.  And it doesn't really do justice to the changes
you have made.

This is not now a MADV_FREE thing, it's more general than that, even
if MADV_FREE is the only thing that takes advantage of it.  I like
very much that you've made page reclaim sane, freeing non-dirty
anonymous pages instead of swapping them out, without having to
think of whether it's for MADV_FREE or not.

Would you mind if we replace your patch by a re-commented version?

[PATCH] mm: mark stable page dirty in KSM

The MADV_FREE patchset changes page reclaim to simply free a clean
anonymous page with no dirty ptes, instead of swapping it out; but
KSM uses clean write-protected ptes to reference the stable ksm page.
So be sure to mark that page dirty, so it's never mistakenly discarded.

Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/ksm.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN mm/ksm.c~mm-mark-stable-page-dirty-in-ksm mm/ksm.c
--- a/mm/ksm.c~mm-mark-stable-page-dirty-in-ksm
+++ a/mm/ksm.c
@@ -1050,6 +1050,12 @@ static int try_to_merge_one_page(struct
 			 */
 			set_page_stable_node(page, NULL);
 			mark_page_accessed(page);
+			/*
+			 * Page reclaim just frees a clean page with no dirty
+			 * ptes: make sure that the ksm page would be swapped.
+			 */
+			if (!PageDirty(page))
+				SetPageDirty(page);
 			err = 0;
 		} else if (pages_identical(page, kpage))
 			err = replace_page(vma, page, kpage, orig_pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
