Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 77A266B00F5
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:51:25 -0400 (EDT)
Date: Tue, 2 Jun 2009 15:24:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602132441.GC6262@wotan.suse.de>
References: <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601183225.GS1065@one.firstfloor.org> <20090602120042.GB1392@wotan.suse.de> <20090602124757.GG1065@one.firstfloor.org> <20090602125713.GG1392@wotan.suse.de> <20090602132538.GK1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602132538.GK1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 03:25:38PM +0200, Andi Kleen wrote:
> On Tue, Jun 02, 2009 at 02:57:13PM +0200, Nick Piggin wrote:
> > > > not a big deal and just avoids duplicating code. I attached an
> > > > (untested) patch.
> > > 
> > > Thanks. But the function in the patch is not doing the same what
> > > the me_pagecache_clean/dirty are doing. For once there is no error
> > > checking, as in the second try_to_release_page()
> > > 
> > > Then it doesn't do all the IO error and missing mapping handling.
> > 
> > Obviously I don't mean just use that single call for the entire
> > handler. You can set the EIO bit or whatever you like. The
> > "error handling" you have there also seems strange. You could
> > retain it, but the page is assured to be removed from pagecache.
> 
> The reason this code double checks is that someone could have 
> a reference (remember we can come in any time) we cannot kill immediately.

Can't kill what? The page is gone from pagecache. It may remain
other kernel references, but I don't see why this code will
consider this as a failure (and not, for example, a raised error
count).

 
> > > The page_mapped() check is useless because the pages are not 
> > > mapped here etc.
> > 
> > That's OK, it is a core part of the protocol to prevent
> > truncated pages from being mapped, so I like it to be in
> > that function.
> > 
> > (you are also doing extraneous page_mapped tests in your handler,
> > so surely your concern isn't from the perspective of this
> > error handler code)
> 
> We do page_mapping() checks, not page_mapped checks.
> 
> I know details, but ...

+static int me_pagecache_clean(struct page *p)
+{
+       if (!isolate_lru_page(p))
+               page_cache_release(p);
+
+       if (page_has_private(p))
+               do_invalidatepage(p, 0);
+       if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
+               Dprintk(KERN_ERR "MCE %#lx: failed to release buffers\n",
+                       page_to_pfn(p));
+
+       /*
+        * remove_from_page_cache assumes (mapping && !mapped)
+        */
+       if (page_mapping(p) && !page_mapped(p)) {
                               ^^^^^^^^^^^^^^^

+               remove_from_page_cache(p);
+               page_cache_release(p);
+       }
+
+       return RECOVERED;


> > > we would also need to duplicate most of the checking outside
> > > the function anyways and there wouldn't be any possibility
> > > to share the clean/dirty variants. If you insist I can
> > > do it, but I think it would be significantly worse code
> > > than before and I'm reluctant to do that.
> > 
> > I can write you the patch for that too if you like.
> 
> Ok I will write it, but I will add a comment saying that Nick forced
> me to make the code worse @)
> 
> It'll be fairly redundant at least.

If it's that bad, then I'll be happy to rewrite it for you.

 
> > > > if you already have other large ones.
> > > 
> > > That's unclear too.
> > 
> > You can't do much about most kernel pages, and dirty metadata pages
> > are both going to cause big problems. User pagetable pages. Lots of
> > stuff.
> 
> User page tables was on the todo list, these are actually relatively
> easy. The biggest issue is to detect them.
> 
> Metadata would likely need file system callbacks, which I would like to 
> avoid at this point.

So I just don't know why you argue the point that you have lots
of large holes left.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
