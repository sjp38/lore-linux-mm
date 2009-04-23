Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F02956B0093
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 18:49:44 -0400 (EDT)
Date: Thu, 23 Apr 2009 15:44:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
Message-Id: <20090423154409.92aaf809.akpm@linux-foundation.org>
In-Reply-To: <20090422171151.GF15367@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	<1240408407-21848-3-git-send-email-mel@csn.ul.ie>
	<1240416791.10627.78.camel@nimitz>
	<20090422171151.GF15367@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: dave@linux.vnet.ibm.com, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com, peterz@infradead.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009 18:11:51 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> > I depend on the allocator to tell me when I've fed it too high of an
> > order.  If we really need this, perhaps we should do an audit and then
> > add a WARN_ON() for a few releases to catch the stragglers.
> > 
> 
> I consider it buggy to ask for something so large that you always end up
> with the worst option - vmalloc().

Nevertheless, it's a pretty common pattern for initialisation code all
over the kernel to do

	while (allocate(huge_amount) == NULL)
		huge_amount /= 2;

and the proposed change will convert that from "works" to "either goes
BUG or mysteriously overindexes zone->free_area[] in
__rmqueue_smallest()".  The latter of which is really nasty.

> How about leaving it as a VM_BUG_ON
> to get as many reports as possible on who is depending on this odd
> behaviour?

That would be quite disruptive.  Even emitting a trace for each call
would be irritating.  How's about this:

--- a/mm/page_alloc.c~page-allocator-do-not-sanity-check-order-in-the-fast-path-fix
+++ a/mm/page_alloc.c
@@ -1405,7 +1405,8 @@ get_page_from_freelist(gfp_t gfp_mask, n
 
 	classzone_idx = zone_idx(preferred_zone);
 
-	VM_BUG_ON(order >= MAX_ORDER);
+	if (WARN_ON_ONCE(order >= MAX_ORDER))
+		return NULL;
 
 zonelist_scan:
 	/*
_


and then we revisit later?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
