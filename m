Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5896B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:47:00 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j5so52649189pfb.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:47:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a1si4894376pgf.369.2017.03.01.07.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 07:46:58 -0800 (PST)
Date: Wed, 1 Mar 2017 16:46:59 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3] lockdep: Teach lockdep about memalloc_noio_save
Message-ID: <20170301154659.GL6515@twins.programming.kicks-ass.net>
References: <1488367797-27278-1-git-send-email-nborisov@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1488367797-27278-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: linux-kernel@vger.kernel.org, mhocko@kernel.org, vbabka.lkml@gmail.com, linux-mm@kvack.org, mingo@redhat.com

On Wed, Mar 01, 2017 at 01:29:57PM +0200, Nikolay Borisov wrote:
> Commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O
> during memory allocation") added the memalloc_noio_(save|restore) functions
> to enable people to modify the MM behavior by disbaling I/O during memory
> allocation. This was further extended in Fixes: 934f3072c17c ("mm: clear 
> __GFP_FS when PF_MEMALLOC_NOIO is set"). memalloc_noio_* functions prevent 
> allocation paths recursing back into the filesystem without explicitly 
> changing the flags for every allocation site. However, lockdep hasn't been 
> keeping up with the changes and it entirely misses handling the memalloc_noio
> adjustments. Instead, it is left to the callers of __lockdep_trace_alloc to 
> call the functino after they have shaven the respective GFP flags. 
> 
> Let's fix this by making lockdep explicitly do the shaving of respective
> GFP flags. 

I edited that to look like the below, then my compiler said:

../kernel/locking/lockdep.c: In function a??lockdep_set_current_reclaim_statea??:
../kernel/locking/lockdep.c:3866:33: error: implicit declaration of function a??memalloc_noio_flagsa?? [-Werror=implicit-function-declaration]
  current->lockdep_reclaim_gfp = memalloc_noio_flags(gfp_mask);
                                 ^~~~~~~~~~~~~~~~~~~
cc1: some warnings being treated as errors
../scripts/Makefile.build:294: recipe for target 'kernel/locking/lockdep.o' failed



---
Subject: lockdep: Teach lockdep about memalloc_noio_save
From: Nikolay Borisov <nborisov@suse.com>
Date: Wed, 1 Mar 2017 13:29:57 +0200

Commit 21caf2fc1931 ("mm: teach mm by current context info to not do
I/O during memory allocation") added the memalloc_noio_(save|restore)
functions to enable people to modify the MM behavior by disbaling I/O
during memory allocation.

This was further extended in commit: 934f3072c17c ("mm: clear __GFP_FS
when PF_MEMALLOC_NOIO is set"). memalloc_noio_* functions prevent
allocation paths recursing back into the filesystem without explicitly
changing the flags for every allocation site.

However, people forgot to update lockdep with the changes and it
entirely misses handling the memalloc_noio adjustments. Instead, it is
left to the callers of __lockdep_trace_alloc to call the function
after they have shaven the respective GFP flags.

Fixes: 934f3072c17c ("mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set")
Cc: vbabka.lkml@gmail.com
Cc: mingo@redhat.com
Acked-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Nikolay Borisov <nborisov@suse.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Link: http://lkml.kernel.org/r/1488367797-27278-1-git-send-email-nborisov@suse.com
---
 kernel/locking/lockdep.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Changes since v2: 
	* Incorporate Michal's suggestion of using memalloc_noio_flags explicitly. 
	* Tune the commit message to make the problem statement a bit more
	descriptive. 

--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2861,6 +2861,8 @@ static void __lockdep_trace_alloc(gfp_t
 	if (unlikely(!debug_locks))
 		return;
 
+	gfp_mask = memalloc_noio_flags(gfp_mask);
+
 	/* no reclaim without waiting on it */
 	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
 		return;
@@ -3852,7 +3854,7 @@ EXPORT_SYMBOL_GPL(lock_unpin_lock);
 
 void lockdep_set_current_reclaim_state(gfp_t gfp_mask)
 {
-	current->lockdep_reclaim_gfp = gfp_mask;
+	current->lockdep_reclaim_gfp = memalloc_noio_flags(gfp_mask);
 }
 
 void lockdep_clear_current_reclaim_state(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
