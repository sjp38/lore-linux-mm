Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC4C6B025E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 11:29:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x83so57890939wma.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:29:16 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id 64si34408014wmy.14.2016.07.14.08.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 08:29:15 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id f126so70690133wma.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:29:14 -0700 (PDT)
Date: Thu, 14 Jul 2016 17:29:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160714152913.GC12289@dhcp22.suse.cz>
References: <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp>
 <20160713133955.GK28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713145638.GM28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 13-07-16 16:53:28, David Rientjes wrote:
> On Wed, 13 Jul 2016, Mikulas Patocka wrote:
> 
> > What are the real problems that f9054c70d28bc214b2857cf8db8269f4f45a5e23 
> > tries to fix?
> > 
> 
> It prevents the whole system from livelocking due to an oom killed process 
> stalling forever waiting for mempool_alloc() to return.  No other threads 
> may be oom killed while waiting for it to exit.

But it is true that the patch has unintended side effect for any mempool
allocation from the reclaim path (aka PF_MEMALLOC context). So do you
think we should rework your additional patch to be explicit about
TIF_MEMDIE? Something like the following (not even compile tested for
illustration). Tetsuo has properly pointed out that this doesn't work
for multithreaded processes reliable but put that aside for now as that
needs a fix on a different layer. I believe we can fix that quite
easily after recent/planned changes.
---
diff --git a/mm/mempool.c b/mm/mempool.c
index 8f65464da5de..ea26d75c8adf 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -322,20 +322,20 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 
 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
 
+	gfp_mask |= __GFP_NOMEMALLOC;   /* don't allocate emergency reserves */
 	gfp_mask |= __GFP_NORETRY;	/* don't loop in __alloc_pages */
 	gfp_mask |= __GFP_NOWARN;	/* failures are OK */
 
 	gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
 
 repeat_alloc:
-	if (likely(pool->curr_nr)) {
-		/*
-		 * Don't allocate from emergency reserves if there are
-		 * elements available.  This check is racy, but it will
-		 * be rechecked each loop.
-		 */
-		gfp_temp |= __GFP_NOMEMALLOC;
-	}
+	/*
+	 * Make sure that the OOM victim will get access to memory reserves
+	 * properly if there are no objects in the pool to prevent from
+	 * livelocks.
+	 */
+	if (!likely(pool->curr_nr) && test_thread_flag(TIF_MEMDIE))
+		gfp_temp &= ~__GFP_NOMEMALLOC;
 
 	element = pool->alloc(gfp_temp, pool->pool_data);
 	if (likely(element != NULL))
@@ -359,7 +359,7 @@ void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 	 * We use gfp mask w/o direct reclaim or IO for the first round.  If
 	 * alloc failed with that and @pool was empty, retry immediately.
 	 */
-	if ((gfp_temp & ~__GFP_NOMEMALLOC) != gfp_mask) {
+	if ((gfp_temp & __GFP_DIRECT_RECLAIM) != (gfp_mask & __GFP_DIRECT_RECLAIM)) {
 		spin_unlock_irqrestore(&pool->lock, flags);
 		gfp_temp = gfp_mask;
 		goto repeat_alloc;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
