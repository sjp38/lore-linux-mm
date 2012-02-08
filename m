Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 1EFDD6B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 14:49:09 -0500 (EST)
Date: Wed, 8 Feb 2012 13:49:05 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
In-Reply-To: <20120208163421.GL5938@suse.de>
Message-ID: <alpine.DEB.2.00.1202081338210.32060@router.home>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de> <1328568978-17553-3-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1202071025050.30652@router.home> <20120208144506.GI5938@suse.de> <alpine.DEB.2.00.1202080907320.30248@router.home>
 <20120208163421.GL5938@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 8 Feb 2012, Mel Gorman wrote:

> Ok, I looked into what is necessary to replace these with checking a page
> flag and the cost shifts quite a bit and ends up being more expensive.

That is only true if you go the slab route. Slab suffers from not having
the page struct pointer readily available. The changes are likely already
impacting slab performance without the virt_to_page patch.

> In slub, it's sufficient to check kmem_cache_cpu to know whether the
> objects in the list are pfmemalloc or not.

We try to minimize the size of kmem_cache_cpu. The page pointer is readily
available. We just removed the node field from kmem_cache_cpu because it
was less expensive to get the node number from the struct page field.

The same is certainly true for a PFMEMALLOC flag.

> Yeah, you're right on the button there. I did my checking assuming that
> PG_active+PG_slab were safe to use. The following is an untested patch that
> I probably got details wrong in but it illustrates where virt_to_page()
> starts cropping up.

Yes you need to come up with a way to not use virt_to_page otherwise slab
performance is significantly impacted. On NUMA we are already doing a page
struct lookup on free in slab. If you would save the page struct pointer
there and reuse it then you would not have an issue at least on free.

You still would need to determine which "struct slab" pointer is in use
which will also require similar lookups in varous places.

Transfer of the pfmemalloc flags (guess you must have a pfmemalloc
field in struct slab then) in slab is best be done when allocating and
freeing a slab page from the page allocator.

I think its rather trivial to add the support you want in a non intrusive
way to slub. Slab would require some more thought and discussion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
