Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 451A98D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:38:02 -0400 (EDT)
Date: Wed, 23 Mar 2011 01:37:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110323003718.GH5698@random.random>
References: <20110319235144.GG10696@random.random>
 <20110321094149.GH707@csn.ul.ie>
 <20110321134832.GC5719@random.random>
 <20110321163742.GA24244@csn.ul.ie>
 <4D878564.6080608@fiec.espol.edu.ec>
 <20110321201641.GA5698@random.random>
 <20110322112032.GD24244@csn.ul.ie>
 <20110322150314.GC5698@random.random>
 <4D8907C2.7010304@fiec.espol.edu.ec>
 <20110322214020.GD5698@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322214020.GD5698@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex =?iso-8859-1?B?VmlsbGFj7a1z?= Lasso <avillaci@fiec.espol.edu.ec>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

Hi Alex,

could you also try to reverse this below bit (not the whole previous
patch: only the bit below quoted below) with "patch -p1 -R < thismail"
on top of your current aa.git tree, and see if you notice any
regression compared to the previous aa.git build that worked well?

This is part of the fix, but I'd need to be sure this really makes a
difference before sticking to it for long. I'm not concerned by
keeping it, but it adds dirt, and the closer THP allocations are to
any other high order allocation the better. So the less
__GFP_NO_KSWAPD affects the better. The hint about not telling kswapd
to insist in the background for order 9 allocations with fallback
(like THP) is the maximum I consider clean because there's khugepaged
with its alloc_sleep_millisecs that replaces the kswapd task for THP
allocations. So that is clean enough, but when __GFP_NO_KSWAPD starts
to make compaction behave slightly different from a SLUB order 2
allocation I don't like it (especially because if you later enable
SLUB or some driver you may run into the same compaction issue again
if the below change is making a difference).

If things works fine even after you reverse the below, we can safely
undo this change and also feel safer for all other high order
allocations, so it'll make life easier. (plus we don't want
unnecessary special changes, we need to be sure this makes a
difference to keep it for long)

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
