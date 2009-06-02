Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 21D656B00A5
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:10:55 -0400 (EDT)
Date: Tue, 2 Jun 2009 22:10:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v3
Message-ID: <20090602141031.GC21338@localhost>
References: <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601183225.GS1065@one.firstfloor.org> <20090602120042.GB1392@wotan.suse.de> <20090602124757.GG1065@one.firstfloor.org> <20090602125713.GG1392@wotan.suse.de> <20090602134659.GA21338@localhost> <20090602140830.GR1065@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602140830.GR1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 10:08:30PM +0800, Andi Kleen wrote:
> > > > We could probably call truncate_complete_page(), but then
> > > > we would also need to duplicate most of the checking outside
> > > > the function anyways and there wouldn't be any possibility
> > > > to share the clean/dirty variants. If you insist I can
> > > > do it, but I think it would be significantly worse code
> > > > than before and I'm reluctant to do that.
> > > 
> > > I can write you the patch for that too if you like.
> > 
> > I have already posted one on truncate_complete_page(). Not the way you want it?
> 
> Sorry I must have missed it (too much mail I guess). Can you repost please?

OK, here it is, a more simplified one.

---
 mm/memory-failure.c |   13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -324,23 +324,16 @@ static int me_free(struct page *p)
  */
 static int me_pagecache_clean(struct page *p)
 {
+	if (page_mapping(p))
+                truncate_complete_page(p->mapping, p);
+
 	if (!isolate_lru_page(p))
 		page_cache_release(p);
 
-	if (page_has_private(p))
-		do_invalidatepage(p, 0);
 	if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
 		Dprintk(KERN_ERR "MCE %#lx: failed to release buffers\n",
 			page_to_pfn(p));
 
-	/*
-	 * remove_from_page_cache assumes (mapping && !mapped)
-	 */
-	if (page_mapping(p) && !page_mapped(p)) {
-		remove_from_page_cache(p);
-		page_cache_release(p);
-	}
-
 	return RECOVERED;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
