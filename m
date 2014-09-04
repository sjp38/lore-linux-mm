Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 324D86B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 10:27:28 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so7655125wiv.2
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 07:27:26 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id u12si2597768wiv.33.2014.09.04.07.27.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 07:27:25 -0700 (PDT)
Received: by mail-wg0-f50.google.com with SMTP id x12so10361067wgg.9
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 07:27:23 -0700 (PDT)
Date: Thu, 4 Sep 2014 16:27:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140904142721.GB14548@dhcp22.suse.cz>
References: <54061505.8020500@sr71.net>
 <5406262F.4050705@intel.com>
 <54062F32.5070504@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54062F32.5070504@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

[Sorry to reply so late]

On Tue 02-09-14 13:57:22, Dave Hansen wrote:
> I, of course, forgot to include the most important detail.  This appears
> to be pretty run-of-the-mill spinlock contention in the resource counter
> code.  Nearly 80% of the CPU is spent spinning in the charge or uncharge
> paths in the kernel.  It is apparently spinning on res_counter->lock in
> both the charge and uncharge paths.
> 
> It already does _some_ batching here on the free side, but that
> apparently breaks down after ~40 threads.
> 
> It's a no-brainer since the patch in question removed an optimization
> skipping the charging, and now we're seeing overhead from the charging.
> 
> Here's the first entry from perf top:
> 
>     80.18%    80.18%  [kernel]               [k] _raw_spin_lock
>                   |
>                   --- _raw_spin_lock
>                      |
>                      |--66.59%-- res_counter_uncharge_until
>                      |          res_counter_uncharge
>                      |          uncharge_batch
>                      |          uncharge_list
>                      |          mem_cgroup_uncharge_list
>                      |          release_pages
>                      |          free_pages_and_swap_cache

Ouch. free_pages_and_swap_cache completely kills the uncharge batching
because it reduces it to PAGEVEC_SIZE batches.

I think we really do not need PAGEVEC_SIZE batching anymore. We are
already batching on tlb_gather layer. That one is limited so I think
the below should be safe but I have to think about this some more. There
is a risk of prolonged lru_lock wait times but the number of pages is
limited to 10k and the heavy work is done outside of the lock. If this
is really a problem then we can tear LRU part and the actual
freeing/uncharging into a separate functions in this path.

Could you test with this half baked patch, please? I didn't get to test
it myself unfortunately.
---
diff --git a/mm/swap_state.c b/mm/swap_state.c
index ef1f39139b71..154444918685 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -265,18 +265,12 @@ void free_page_and_swap_cache(struct page *page)
 void free_pages_and_swap_cache(struct page **pages, int nr)
 {
 	struct page **pagep = pages;
+	int i;
 
 	lru_add_drain();
-	while (nr) {
-		int todo = min(nr, PAGEVEC_SIZE);
-		int i;
-
-		for (i = 0; i < todo; i++)
-			free_swap_cache(pagep[i]);
-		release_pages(pagep, todo, false);
-		pagep += todo;
-		nr -= todo;
-	}
+	for (i = 0; i < nr; i++)
+		free_swap_cache(pagep[i]);
+	release_pages(pagep, nr, false);
 }
 
 /*
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
