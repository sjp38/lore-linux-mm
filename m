Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2DF166B004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:28:11 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DB61882C66E
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:54:09 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9MovMBX5mj10 for <linux-mm@kvack.org>;
	Wed, 30 Sep 2009 19:54:09 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E58AB82C674
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 19:54:02 -0400 (EDT)
Date: Wed, 30 Sep 2009 19:45:22 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a
 kmem_cache_cpu
In-Reply-To: <20090930220541.GA31530@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0909301941570.11850@gentwo.org>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie> <1253624054-10882-3-git-send-email-mel@csn.ul.ie> <84144f020909220638l79329905sf9a35286130e88d0@mail.gmail.com> <20090922135453.GF25965@csn.ul.ie> <84144f020909221154x820b287r2996480225692fad@mail.gmail.com>
 <20090922185608.GH25965@csn.ul.ie> <20090930144117.GA17906@csn.ul.ie> <alpine.DEB.1.10.0909301053550.9450@gentwo.org> <20090930220541.GA31530@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Sep 2009, Mel Gorman wrote:

> > SLUB avoids that issue by having a "current" page for a processor. It
> > allocates from the current page until its exhausted. It can use fast path
> > logic both for allocations and frees regardless of the pages origin. The
> > node fallback is handled by the page allocator and that one is only
> > involved when a new slab page is needed.
> >
>
> This is essentially the "unqueued" nature of SLUB. It's objective "I have this
> page here which I'm going to use until I can't use it no more and will depend
> on the page allocator to sort my stuff out". I have to read up on SLUB up
> more to see if it's compatible with SLQB or not though. In particular, how
> does SLUB deal with frees from pages that are not the "current" page? SLQB
> does not care what page the object belongs to as long as it's node-local
> as the object is just shoved onto a LIFO for maximum hotness.

Frees are done directly to the target slab page if they are not to the
current active slab page. No centralized locks. Concurrent frees from
processors on the same node to multiple other nodes (or different pages
on the same node) can occur.

> > SLAB deals with it in fallback_alloc(). It scans the nodes in zonelist
> > order for free objects of the kmem_cache and then picks up from the
> > nearest node. Ugly but it works. SLQB would have to do something similar
> > since it also has the per node object bins that SLAB has.
> >
>
> In a real sense, this is what the patch ends up doing. When it fails to
> get something locally but sees that the local node is memoryless, it
> will check the remote node lists in zonelist order. I think that's
> reasonable behaviour but I'm biased because I just want the damn machine
> to boot again. What do you think? Pekka, Nick?

Look at fallback_alloc() in slab. You can likely copy much of it. It
considers memory policies and cpuset constraints.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
