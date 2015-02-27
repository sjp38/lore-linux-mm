Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 391126B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 22:09:56 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so24909533ieb.7
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 19:09:56 -0800 (PST)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com. [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id a19si3158843icl.55.2015.02.26.19.09.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 19:09:55 -0800 (PST)
Received: by iecrd18 with SMTP id rd18so24897237iec.8
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 19:09:55 -0800 (PST)
Date: Thu, 26 Feb 2015 19:09:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
In-Reply-To: <54EED9A7.5010505@suse.cz>
Message-ID: <alpine.DEB.2.10.1502261902580.24302@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <54EED9A7.5010505@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org

On Thu, 26 Feb 2015, Vlastimil Babka wrote:

> > NOTE: this is not about __GFP_THISNODE, this is only about GFP_THISNODE.
> > 
> > GFP_THISNODE is a secret combination of gfp bits that have different
> > behavior than expected.  It is a combination of __GFP_THISNODE,
> > __GFP_NORETRY, and __GFP_NOWARN and is special-cased in the page allocator
> > slowpath to fail without trying reclaim even though it may be used in
> > combination with __GFP_WAIT.
> > 
> > An example of the problem this creates: commit e97ca8e5b864 ("mm: fix 
> > GFP_THISNODE callers and clarify") fixed up many users of GFP_THISNODE
> > that really just wanted __GFP_THISNODE.  The problem doesn't end there,
> > however, because even it was a no-op for alloc_misplaced_dst_page(),
> > which also sets __GFP_NORETRY and __GFP_NOWARN, and
> > migrate_misplaced_transhuge_page(), where __GFP_NORETRY and __GFP_NOWAIT
> > is set in GFP_TRANSHUGE.  Converting GFP_THISNODE to __GFP_THISNODE is
> > a no-op in these cases since the page allocator special-cases
> > __GFP_THISNODE && __GFP_NORETRY && __GFP_NOWARN.
> > 
> > It's time to just remove GFP_TRANSHUGE entirely.  We leave __GFP_THISNODE
> 
>                               ^THISNODE :) Although yes, it would be nice if we
> could replace the GFP_TRANSHUGE magic checks as well.
> 

Haha, I referenced GFP_TRANSHUGE twice here when I meant GFP_THISNODE, I 
must want to fix that up as well.

> > to restrict an allocation to a local node, but remove GFP_TRANSHUGE and
> > it's obscurity.  Instead, we require that a caller clear __GFP_WAIT if it
> > wants to avoid reclaim.
> > 
> > This allows the aforementioned functions to actually reclaim as they
> > should.  It also enables any future callers that want to do
> > __GFP_THISNODE but also __GFP_NORETRY && __GFP_NOWARN to reclaim.  The
> > rule is simple: if you don't want to reclaim, then don't set __GFP_WAIT.
> 
> So, I agree with the intention, but this has some subtle implications that
> should be mentioned/decided. The check for GFP_THISNODE in
> __alloc_pages_slowpath() comes earlier than the check for __GFP_WAIT. So the
> differences will be:
> 
> 1) We will now call wake_all_kswapds(), unless __GFP_NO_KSWAPD is passed, which
> is only done for hugepages and some type of i915 allocation. Do we want the
> opportunistic attempts from slab to wake up kswapds or do we pass the flag?
> 
> 2) There will be another attempt on get_page_from_freelist() with different
> alloc_flags than in the fast path attempt. Without __GFP_WAIT (and also, again,
> __GFP_KSWAPD, since your commit b104a35d32, which is another subtle check for
> hugepage allocations btw), it will consider the allocation atomic and add
> ALLOC_HARDER flag, unless __GFP_NOMEMALLOC is in __gfp_flags - it seems it's
> generally not. It will also clear ALLOC_CPUSET, which was the concern of
> b104a35d32. However, if I look at __cpuset_node_allowed(), I see that it's
> always true for __GFP_THISNODE, which makes me question commit b104a35d32 in
> light of your patch 2/2 and generally the sanity of all these flags and my
> career choice.
> 

Do we do either of these?  gfp_exact_node() sets __GFP_THISNODE and clears 
__GFP_WAIT which will make the new conditional trigger immediately for 
NUMA configs.

Existing callers of GFP_KERNEL | __GFP_THISNODE aren't impacted and 
net/openvswitch/flow.c is mentioned in the changelog as actually wanting 
GFP_NOWAIT | __GFP_THISNODE so that this early check still fails.

> Ugh :)
> 

Ugh indeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
