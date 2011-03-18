Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2F2A28D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 08:29:28 -0400 (EDT)
Date: Fri, 18 Mar 2011 13:26:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110318122640.GD10696@random.random>
References: <bug-31142-10286@https.bugzilla.kernel.org/>
 <20110315135334.36e29414.akpm@linux-foundation.org>
 <4D7FEDDC.3020607@fiec.espol.edu.ec>
 <20110315161926.595bdb65.akpm@linux-foundation.org>
 <4D80D65C.5040504@fiec.espol.edu.ec>
 <20110316150208.7407c375.akpm@linux-foundation.org>
 <4D827CC1.4090807@fiec.espol.edu.ec>
 <20110317144727.87a461f9.akpm@linux-foundation.org>
 <20110318111300.GF707@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110318111300.GF707@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Villac??s Lasso <avillaci@fiec.espol.edu.ec>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Fri, Mar 18, 2011 at 11:13:00AM +0000, Mel Gorman wrote:
> To confirm if this is the case, I'd be very interested in hearing if this
> problem persists in the following cases
> 
> 1. 2.6.38-rc8 with defrag disabled by
>    echo never >/sys/kernel/mm/transparent_hugepage/defrag
>    (this will stop THP allocations calling into compaction)
> 2. 2.6.38-rc8 with THP disabled by
>    echo never > /sys/kernel/mm/transparent_hugepage/enabled
>    (if the problem still persists, then page reclaim is still a problem
>     but we should still stop THP doing sync writes)
> 3. 2.6.37 vanilla
>    (in case this is a new regression introduced since then)
> 
> Migration can do sync writes on dirty pages which is why it looks so similar
> to page reclaim but this can be controlled by the value of sync_migration
> passed into try_to_compact_pages(). If we find that option 1 above makes
> the regression go away or at least helps a lot, then a reasonable fix may
> be to never set sync_migration if __GFP_NO_KSWAPD which is always set for
> THP allocations. I've added Andrea to the cc to see what he thinks.

I agree. Forcing sync=0 when __GFP_NO_KSWAPD is set, sounds good to
me, if it is proven to resolve these I/O waits.

Also note that 2.6.38 upstream still misses a couple of important
compaction fixes that are in aa.git (everything relevant is already
queued in -mm but it was a bit late for 2.6.38), so I'd also be
interested to know if you can reproduce in current aa.git
origin/master branch.

If it's a __GFP_NO_KSWAPD allocation (do_huge_pmd_anonymous_page())
that is present in the hanging stack traces, I strongly doubt any of
the changes in aa.git is going to help at all, but it worth a try to
be sure.

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=48ad57f498835621d8bad83b972ee6e6c395523a
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=8f6854f7cbf71bc61758bcd92497378e1f677552
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=8ff6d16eb15d2b328bbe715fcaf453b6fedb2cf9
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=e31adb46cd8c4f331cfb02c938e88586d5846bf8

This is the implementation of Mel's idea that you can apply to
upstream or aa.git to see what happens...

===
Subject: compaction: use async migrate for __GFP_NO_KSWAPD

From: Andrea Arcangeli <aarcange@redhat.com>

__GFP_NO_KSWAPD allocations are usually very expensive and not mandatory to
succeed (they have graceful fallback). Waiting for I/O in those, tends to be
overkill in terms of latencies, so we can reduce their latency by disabling
sync migrate.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bd76256..36d1c79 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2085,7 +2085,7 @@ rebalance:
 					sync_migration);
 	if (page)
 		goto got_pg;
-	sync_migration = true;
+	sync_migration = !(gfp_mask & __GFP_NO_KSWAPD);
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
