Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F0D2A6B0069
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 19:07:13 -0500 (EST)
Received: by ggnq1 with SMTP id q1so5838507ggn.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 16:07:11 -0800 (PST)
Date: Tue, 15 Nov 2011 16:07:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
In-Reply-To: <20111115234845.GK27150@suse.de>
Message-ID: <alpine.DEB.2.00.1111151554190.3781@chino.kir.corp.google.com>
References: <20111110100616.GD3083@suse.de> <20111110142202.GE3083@suse.de> <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com> <20111110161331.GG3083@suse.de> <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com> <20111111101414.GJ3083@suse.de> <20111114154408.10de1bc7.akpm@linux-foundation.org> <20111115132513.GF27150@suse.de> <alpine.DEB.2.00.1111151303230.23579@chino.kir.corp.google.com>
 <20111115234845.GK27150@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 15 Nov 2011, Mel Gorman wrote:

> Adding sync here could obviously be implemented although it may
> require both always-sync and madvise-sync. Alternatively, something
> like an options file could be created to create a bitmap similar to
> what ftrace does. Whatever the mechanism, it exposes the fact that
> "sync compaction" is used. If that turns out to be not enough, then
> you may want to add other steps like aggressively reclaiming memory
> which also potentially may need to be controlled via the sysfs file
> and this is the slippery slope.
> 

So what's being proposed here in this patch is the fifth time this line 
has been changed and its always been switched between true and !(gfp_mask 
& __GFP_NO_KSWAPD).  Instead of changing it every few months, I'd suggest 
that we tie the semantics of the tunable directly to sync_compaction since 
we're primarily targeting thp hugepages with this change anyway for the 
"always" case.  Comments?

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -116,6 +116,13 @@ echo always >/sys/kernel/mm/transparent_hugepage/defrag
 echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
 echo never >/sys/kernel/mm/transparent_hugepage/defrag
 
+If defrag is set to "always", then all hugepage allocations also attempt
+synchronous memory compaction which makes the allocation as aggressive
+as possible.  The overhead of attempting to allocate the hugepage is
+considered acceptable because of the longterm benefits of the hugepage
+itself at runtime.  If the VM should fallback to using regular pages
+instead, then you should use "madvise" or "never".
+
 khugepaged will be automatically started when
 transparent_hugepage/enabled is set to "always" or "madvise, and it'll
 be automatically shutdown if it's set to "never".

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2168,7 +2168,17 @@ rebalance:
 					sync_migration);
 	if (page)
 		goto got_pg;
-	sync_migration = true;
+
+	/*
+	 * Do not use synchronous migration for transparent hugepages unless
+	 * defragmentation is always attempted for such allocations since it
+	 * can stall in writeback, which is far worse than simply failing to
+	 * promote a page.  Otherwise, we really do want a hugepage and are as
+	 * aggressive as possible to allocate it.
+	 */
+	sync_migration = !(gfp_mask & __GFP_NO_KSWAPD) ||
+			(transparent_hugepage_flags &
+				(1 << TRANSPARENT_HUGEPAGE_DEFRAG_FLAG));
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
