Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91F936B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 21:50:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q15-v6so9983678pff.17
        for <linux-mm@kvack.org>; Tue, 29 May 2018 18:50:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8-v6sor12233502pfa.103.2018.05.29.18.50.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 18:50:36 -0700 (PDT)
Date: Tue, 29 May 2018 18:50:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm/huge_memory.c: __split_huge_page() use atomic
 ClearPageDirty()
Message-ID: <alpine.LSU.2.11.1805291841070.3197@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Swapping load on huge=always tmpfs (with khugepaged tuned up to be very
eager, but I'm not sure that is relevant) soon hung uninterruptibly,
waiting for page lock in shmem_getpage_gfp()'s find_lock_entry(), most
often when "cp -a" was trying to write to a smallish file.  Debug showed
that the page in question was not locked, and page->mapping NULL by now,
but page->index consistent with having been in a huge page before.

Reproduced in minutes on a 4.15 kernel, even with 4.17's 605ca5ede764
("mm/huge_memory.c: reorder operations in __split_huge_page_tail()")
added in; but took hours to reproduce on a 4.17 kernel (no idea why).

The culprit proved to be the __ClearPageDirty() on tails beyond i_size
in __split_huge_page(): the non-atomic __bitoperation may have been safe
when 4.8's baa355fd3314 ("thp: file pages support for split_huge_page()")
introduced it, but liable to erase PageWaiters after 4.10's 62906027091f
("mm: add PageWaiters indicating tasks are waiting for a page bit").

Fixes: 62906027091f ("mm: add PageWaiters indicating tasks are waiting for a page bit")
Signed-off-by: Hugh Dickins <hughd@google.com>
---

It's not a 4.17-rc regression that this fixes, so no great need to slip
this into 4.17 at the last moment - though it makes a good companion to
Konstantin's 605ca5ede764. I think they both should go to stable, but
since Konstantin's already went into rc1 without that tag, we shall
have to recommend Konstantin's to GregKH out-of-band.

 mm/huge_memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 4.17-rc7/mm/huge_memory.c	2018-04-26 10:48:36.019288258 -0700
+++ linux/mm/huge_memory.c	2018-05-29 18:14:52.095512715 -0700
@@ -2431,7 +2431,7 @@ static void __split_huge_page(struct pag
 		__split_huge_page_tail(head, i, lruvec, list);
 		/* Some pages can be beyond i_size: drop them from page cache */
 		if (head[i].index >= end) {
-			__ClearPageDirty(head + i);
+			ClearPageDirty(head + i);
 			__delete_from_page_cache(head + i, NULL);
 			if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
 				shmem_uncharge(head->mapping->host, 1);
