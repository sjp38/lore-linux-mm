Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 586BF6B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 00:57:11 -0400 (EDT)
From: Neil Brown <neilb@suse.de>
Date: Fri, 2 Oct 2009 15:04:10 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <19141.35274.513790.845711@notabene.brown>
Subject: Re: [PATCH 03/31] mm: expose gfp_to_alloc_flags()
In-Reply-To: message from David Rientjes on Thursday October 1
References: <1254405903-15760-1-git-send-email-sjayaraman@suse.de>
	<alpine.DEB.1.00.0910011355230.32006@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thursday October 1, rientjes@google.com wrote:
> On Thu, 1 Oct 2009, Suresh Jayaraman wrote:
> 
> > From: Peter Zijlstra <a.p.zijlstra@chello.nl> 
> > 
> > Expose the gfp to alloc_flags mapping, so we can use it in other parts
> > of the vm.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> 
> Nack, these flags are internal to the page allocator and exporting them to 
> generic VM code is unnecessary.
> 
> The only bit you actually use in your patchset is ALLOC_NO_WATERMARKS to 
> determine whether a particular allocation can use memory reserves.  I'd 
> suggest adding a bool function that returns whether the current context is 
> given access to reserves including your new __GFP_MEMALLOC flag and 
> exporting that instead.

That sounds like a very appropriate suggestion, thanks.

So something like this?
Then change every occurrence of
+		if (!(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
to
+		if (!(gfp_has_no_watermarks(gfpflags)))

??

Thanks,
NeilBrown



diff --git a/mm/internal.h b/mm/internal.h
index 22ec8d2..7ff78d6 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -195,6 +195,8 @@ static inline struct page *mem_map_next(struct page *iter,
 #define __paginginit __init
 #endif
 
+int gfp_has_no_watermarks(gfp_t gfp_mask);
+
 /* Memory initialisation debug and verification */
 enum mminit_level {
 	MMINIT_WARNING,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bf72055..4b4292a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1782,6 +1782,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	return alloc_flags;
 }
 
+int gfp_has_no_watermarks(gfp_t gfp_mask)
+{
+	return (gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
