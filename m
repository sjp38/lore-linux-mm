Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id E69FD280322
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 09:39:19 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so39615722wib.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 06:39:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 20si19629362wjq.25.2015.07.17.06.39.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 06:39:18 -0700 (PDT)
Date: Fri, 17 Jul 2015 14:39:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm, meminit: Allow early_pfn_to_nid to be used
 during runtime
Message-ID: <20150717133913.GF2561@suse.de>
References: <1437135724-20110-1-git-send-email-mgorman@suse.de>
 <1437135724-20110-4-git-send-email-mgorman@suse.de>
 <20150717131232.GK19282@twins.programming.kicks-ass.net>
 <20150717131729.GE2561@suse.de>
 <20150717132922.GN19282@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150717132922.GN19282@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nicolai Stange <nicstange@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Alex Ng <alexng@microsoft.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 17, 2015 at 03:29:22PM +0200, Peter Zijlstra wrote:
> On Fri, Jul 17, 2015 at 02:17:29PM +0100, Mel Gorman wrote:
> > On Fri, Jul 17, 2015 at 03:12:32PM +0200, Peter Zijlstra wrote:
> > > On Fri, Jul 17, 2015 at 01:22:04PM +0100, Mel Gorman wrote:
> > > >  int __meminit early_pfn_to_nid(unsigned long pfn)
> > > >  {
> > > > +	static DEFINE_SPINLOCK(early_pfn_lock);
> > > >  	int nid;
> > > >  
> > > > -	/* The system will behave unpredictably otherwise */
> > > > -	BUG_ON(system_state != SYSTEM_BOOTING);
> > > > +	/* Avoid locking overhead during boot but hotplug must lock */
> > > > +	if (system_state != SYSTEM_BOOTING)
> > > > +		spin_lock(&early_pfn_lock);
> > > >  
> > > >  	nid = __early_pfn_to_nid(pfn, &early_pfnnid_cache);
> > > > -	if (nid >= 0)
> > > > -		return nid;
> > > > -	/* just returns 0 */
> > > > -	return 0;
> > > > +	if (nid < 0)
> > > > +		nid = 0;
> > > > +
> > > > +	if (system_state != SYSTEM_BOOTING)
> > > > +		spin_unlock(&early_pfn_lock);
> > > > +
> > > > +	return nid;
> > > >  }
> > > 
> > > Why the conditional locking?
> > 
> > Unnecessary during boot when it's inherently serialised. The point of
> > the deferred initialisation was to boot as quickly as possible.
> 
> Sure, but does it make a measurable difference?

I'm don't know and no longer have access to the necessary machine to test
any more. You make a reasonable point and I would be surprised if it was
noticable. On the other hand, conditional locking is evil and the patch
reflected my thinking at the time "we don't need locks during boot". It's
the type of thinking that should be backed with figures if it was to be
used at all so lets go with;

---8<---
mm, meminit: Allow early_pfn_to_nid to be used during runtime v2

early_pfn_to_nid historically was inherently not SMP safe but only
used during boot which is inherently single threaded or during hotplug
which is protected by a giant mutex. With deferred memory initialisation
there was a thread-safe version introduced and the early_pfn_to_nid
would trigger a BUG_ON if used unsafely. Memory hotplug hit that check.
This patch makes early_pfn_to_nid introduces a lock to make it safe to
use during hotplug.

Reported-and-tested-by: Alex Ng <alexng@microsoft.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 94e2599830c2..93316f3bcecb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -982,21 +982,21 @@ static void __init __free_pages_boot_core(struct page *page,
 
 #if defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) || \
 	defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
-/* Only safe to use early in boot when initialisation is single-threaded */
+
 static struct mminit_pfnnid_cache early_pfnnid_cache __meminitdata;
 
 int __meminit early_pfn_to_nid(unsigned long pfn)
 {
+	static DEFINE_SPINLOCK(early_pfn_lock);
 	int nid;
 
-	/* The system will behave unpredictably otherwise */
-	BUG_ON(system_state != SYSTEM_BOOTING);
-
+	spin_lock(&early_pfn_lock);
 	nid = __early_pfn_to_nid(pfn, &early_pfnnid_cache);
-	if (nid >= 0)
-		return nid;
-	/* just returns 0 */
-	return 0;
+	if (nid < 0)
+		nid = 0;
+	spin_unlock(&early_pfn_lock);
+
+	return nid;
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
