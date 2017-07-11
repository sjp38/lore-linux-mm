Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CFFEF6810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 17:45:51 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u110so1117713wrb.14
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:45:51 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 62si361960edc.60.2017.07.11.14.45.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 11 Jul 2017 14:45:50 -0700 (PDT)
Date: Tue, 11 Jul 2017 17:45:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmemmap, memory_hotplug: fallback to base pages for vmmap
Message-ID: <20170711214541.GA11141@cmpxchg.org>
References: <20170711134204.20545-1-mhocko@kernel.org>
 <20170711142558.GE11936@dhcp22.suse.cz>
 <20170711172623.GB961@cmpxchg.org>
 <20170711212544.GA25122@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711212544.GA25122@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cristopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 11, 2017 at 11:25:45PM +0200, Michal Hocko wrote:
> On Tue 11-07-17 13:26:23, Johannes Weiner wrote:
> > Hi Michael,
> > 
> > On Tue, Jul 11, 2017 at 04:25:58PM +0200, Michal Hocko wrote:
> > > Ohh, scratch that. The patch is bogus. I have completely missed that
> > > vmemmap_populate_hugepages already falls back to
> > > vmemmap_populate_basepages. I have to revisit the bug report I have
> > > received to see what happened apart from the allocation warning. Maybe
> > > we just want to silent that warning.
> > 
> > Yep, this should be fixed in 8e2cdbcb86b0 ("x86-64: fall back to
> > regular page vmemmap on allocation failure").
> > 
> > I figure it's good to keep some sort of warning there, though, as it
> > could have performance implications when we fall back to base pages.
> 
> Yeah, but I am not really sure the allocation warning is the right thing
> here because it is just too verbose. If you consider that we will get
> this warning for each memory section (128MB or 2GB)... I guess the
> existing
> pr_warn_once("vmemmap: falling back to regular page backing\n");
> 
> or maybe make it pr_warn should be enough. What do you think?

It could be useful to dump the memory context at least once, to 1) let
the user know we're falling back but also 2) to get the default report
we split out anytime we fail in a low-memory situation - in case there
is a problem with the MM subsystem.

Maybe something along the lines of this? (totally untested)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 95651dc58e09..d03c8f244e5b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1302,7 +1302,6 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 			vmemmap_verify((pte_t *)pmd, node, addr, next);
 			continue;
 		}
-		pr_warn_once("vmemmap: falling back to regular page backing\n");
 		if (vmemmap_populate_basepages(addr, next, node))
 			return -ENOMEM;
 	}
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index a56c3989f773..efd3f48c667c 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -52,18 +52,24 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 {
 	/* If the main allocator is up use that, fallback to bootmem. */
 	if (slab_is_available()) {
+		unsigned int order;
+		static int warned;
 		struct page *page;
+		gfp_t gfp_mask;
 
+		order = get_order(size);
+		gfp_mask = GFP_KERNEL|__GFP_ZERO|__GFP_REPEAT|__GFP_NOWARN;
 		if (node_state(node, N_HIGH_MEMORY))
-			page = alloc_pages_node(
-				node, GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
-				get_order(size));
+			page = alloc_pages_node(node, gfp_mask, size);
 		else
-			page = alloc_pages(
-				GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
-				get_order(size));
+			page = alloc_pages(gfp_mask, size);
 		if (page)
 			return page_address(page);
+		if (!warned) {
+			warn_alloc(gfp_mask, NULL,
+				   "vmemmap alloc failure: order:%u", order);
+			warned = 1;
+		}
 		return NULL;
 	} else
 		return __earlyonly_bootmem_alloc(node, size, size,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
