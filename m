Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f47.google.com (mail-vk0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id E127F6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 11:03:07 -0500 (EST)
Received: by vkay187 with SMTP id y187so40190129vka.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 08:03:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 84si13192076vkc.42.2015.11.23.08.03.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 08:03:06 -0800 (PST)
Date: Mon, 23 Nov 2015 17:03:02 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp: introduce thp_mmu_gather to pin tail pages
 during MMU gather
Message-ID: <20151123160302.GX5078@redhat.com>
References: <1447938052-22165-1-git-send-email-aarcange@redhat.com>
 <1447938052-22165-2-git-send-email-aarcange@redhat.com>
 <20151119162255.b73e9db832501b40e1850c1a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151119162255.b73e9db832501b40e1850c1a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Nov 19, 2015 at 04:22:55PM -0800, Andrew Morton wrote:
> On Thu, 19 Nov 2015 14:00:51 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > This theoretical SMP race condition was found with source review. No
> > real life app could be affected as the result of freeing memory while
> > accessing it is either undefined or it's a workload the produces no
> > information.
> > 
> > For something to go wrong because the SMP race condition triggered,
> > it'd require a further tiny window within the SMP race condition
> > window. So nothing bad is happening in practice even if the SMP race
> > condition triggers. It's still better to apply the fix to have the
> > math guarantee.
> > 
> > The fix just adds a thp_mmu_gather atomic_t counter to the THP pages,
> > so split_huge_page can elevate the tail page count accordingly and
> > leave the tail page freeing task to whoever elevated thp_mmu_gather.
> > 
> 
> This is a pretty nasty patch :( We now have random page*'s with bit 0
> set floating around in mmu_gather.__pages[].  It assumes/requires that

Yes, and bit 0 is only relevant for the mmu_gather structure and its
users.

> nobody uses those pages until they hit release_pages().  And the tlb
> flushing code is pretty twisty, with various Kconfig and arch dependent
> handlers.

I already reviewed all callers and the mmu_gather freeing path for all
archs to be sure they all take the two paths that I updated in order
to free the pages. They call free_page_and_swap_cache or
free_pages_and_swap_cache.

The freeing is using common code VM functions, and it shouldn't
improvise calling put_page() manually, the freeing has to take care of
collecting the swapcache if needed etc... it has to deal with VM
details the arch is not aware about.

> Is there no nicer way?

We can grow the size of the mmu_gather to keep track that the page was
THP before the pmd_lock was dropped, in a separate bit from the struct
page pointer, but it'll take more memory.

This bit 0 looks a walk in the park if compared to the bit 0 in
page->compound_head that was just introduced. The compound_head bit 0
isn't only visible to the mmu_gather users (which should never try to
mess with the page pointer themself) and it collides with lru/next,
rcu_head.next users.

If you prefer me to enlarge the mmu_gather structure I can do that.

1 bit of extra information needs to be extracted before dropping the
pmd_lock in zap_huge_pmd() and it has to be available in
release_pages(), to know if the tail pages needs an explicit put_page
or not. It's basically a bit in the local stack, except it's not in
the local stack because it is an array of pages, so it needs many
bits and it's stored in the mmu_gather along the page.

Aside from the implementation of bit 0, I can't think of a simpler
design that provides for the same performance and low locking overhead
(this patch actually looks like an optimization when it's not helping
to prevent the race, because to fix the race I had to reduce the
number of times the lru_lock is taken in release_pages).

> > +/*
> > + * free_trans_huge_page_list() is used to free the pages returned by
> > + * trans_huge_page_release() (if still PageTransHuge()) in
> > + * release_pages().
> > + */
> 
> There is no function trans_huge_page_release().

Oops I updated the function name but not the comment... thanks!
Andrea

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index f7ae08f..2810322 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -225,9 +225,8 @@ static inline int trans_huge_mmu_gather_count(struct page *page)
 }
 
 /*
- * free_trans_huge_page_list() is used to free the pages returned by
- * trans_huge_page_release() (if still PageTransHuge()) in
- * release_pages().
+ * free_trans_huge_page_list() is used to free THP pages (if still
+ * PageTransHuge()) in release_pages().
  */
 extern void free_trans_huge_page_list(struct list_head *list);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
