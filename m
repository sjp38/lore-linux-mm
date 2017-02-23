Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 782DD6B038B
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 10:41:32 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x4so1345811wme.3
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 07:41:32 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n19si6895311wmg.126.2017.02.23.07.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 07:41:31 -0800 (PST)
Date: Thu, 23 Feb 2017 10:35:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V4 1/6] mm: delete unnecessary TTU_* flags
Message-ID: <20170223153534.GA4031@cmpxchg.org>
References: <cover.1487788131.git.shli@fb.com>
 <6e99fbb58c019dac280dde73a96586c0eba880d0.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6e99fbb58c019dac280dde73a96586c0eba880d0.1487788131.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Feb 22, 2017 at 10:50:39AM -0800, Shaohua Li wrote:
> Johannes pointed out TTU_LZFREE is unnecessary. It's true because we
> always have the flag set if we want to do an unmap. For cases we don't
> do an unmap, the TTU_LZFREE part of code should never run.
> 
> Also the TTU_UNMAP is unnecessary. If no other flags set (for
> example, TTU_MIGRATION), an unmap is implied.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Thanks!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> @@ -83,10 +83,8 @@ struct anon_vma_chain {
>  };
>  
>  enum ttu_flags {
> -	TTU_UNMAP = 1,			/* unmap mode */
>  	TTU_MIGRATION = 2,		/* migration mode */
>  	TTU_MUNLOCK = 4,		/* munlock mode */
> -	TTU_LZFREE = 8,			/* lazy free mode */
>  	TTU_SPLIT_HUGE_PMD = 16,	/* split huge PMD if any */
>  
>  	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */

This on top?

---
Subject: [PATCH] mm: delete unnecessary TTU_* flags fix

Clean up the TTU flags a bit. Remove dead TTU_ACTION macro.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 70ef7536c088..640214bc4635 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -82,17 +82,17 @@ struct anon_vma_chain {
 };
 
 enum ttu_flags {
-	TTU_MIGRATION = 2,		/* migration mode */
-	TTU_MUNLOCK = 4,		/* munlock mode */
-	TTU_SPLIT_HUGE_PMD = 16,	/* split huge PMD if any */
-
-	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
-	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
-	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
-	TTU_BATCH_FLUSH = (1 << 11),	/* Batch TLB flushes where possible
+	TTU_MIGRATION		= 0x1,	/* migration mode */
+	TTU_MUNLOCK		= 0x2,	/* munlock mode */
+
+	TTU_SPLIT_HUGE_PMD	= 0x4,	/* split huge PMD if any */
+	TTU_IGNORE_MLOCK	= 0x8,	/* ignore mlock */
+	TTU_IGNORE_ACCESS	= 0x10,	/* don't age */
+	TTU_IGNORE_HWPOISON	= 0x20,	/* corrupted page is recoverable */
+	TTU_BATCH_FLUSH		= 0x40,	/* Batch TLB flushes where possible
 					 * and caller guarantees they will
 					 * do a final flush if necessary */
-	TTU_RMAP_LOCKED = (1 << 12)	/* do not grab rmap lock:
+	TTU_RMAP_LOCKED		= 0x80	/* do not grab rmap lock:
 					 * caller holds it */
 };
 
@@ -182,8 +182,6 @@ static inline void page_dup_rmap(struct page *page, bool compound)
 int page_referenced(struct page *, int is_locked,
 			struct mem_cgroup *memcg, unsigned long *vm_flags);
 
-#define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
-
 int try_to_unmap(struct page *, enum ttu_flags flags);
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
