Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 816376B0257
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 19:51:20 -0500 (EST)
Received: by wmww144 with SMTP id w144so85370642wmw.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 16:51:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l7si9208232wmf.85.2015.12.04.16.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 16:51:18 -0800 (PST)
Date: Fri, 4 Dec 2015 16:51:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: account pglazyfreed exactly
Message-Id: <20151204165116.e878bc3de8e461f7f020312a@linux-foundation.org>
In-Reply-To: <1449147064-1345-1-git-send-email-minchan@kernel.org>
References: <1449147064-1345-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com

On Thu,  3 Dec 2015 21:51:04 +0900 Minchan Kim <minchan@kernel.org> wrote:

> If anon pages are zapped by unmapping between page_mapped check
> and try_to_unmap in shrink_page_list, they could be !PG_dirty
> although thre are not MADV_FREEed pages so that VM accoutns it
> as pglazyfreed wrongly.
> 
> To fix, this patch counts the number of lazyfree ptes in
> try_to_unmap_one and try_to_unmap returns SWAP_LZFREE only if
> the count is not zero, page is !PG_dirty and SWAP_SUCCESS.

A few tiny things...

diff -puN mm/rmap.c~mm-support-madvisemadv_free-fix-2-fix mm/rmap.c
--- a/mm/rmap.c~mm-support-madvisemadv_free-fix-2-fix
+++ a/mm/rmap.c
@@ -1605,7 +1605,7 @@ int try_to_unmap(struct page *page, enum
 
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
-		.arg = (void *)&rp,
+		.arg = &rp,
 		.done = page_not_mapped,
 		.anon_lock = page_lock_anon_vma_read,
 	};
@@ -1651,7 +1651,6 @@ int try_to_unmap(struct page *page, enum
 int try_to_munlock(struct page *page)
 {
 	int ret;
-
 	struct rmap_private rp = {
 		.flags = TTU_MUNLOCK,
 		.lazyfreed = 0,
@@ -1659,7 +1658,7 @@ int try_to_munlock(struct page *page)
 
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
-		.arg = (void *)&rp,
+		.arg = &rp,
 		.done = page_not_mapped,
 		.anon_lock = page_lock_anon_vma_read,
 
diff -puN mm/vmscan.c~mm-support-madvisemadv_free-fix-2-fix mm/vmscan.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
