Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mARAeegW022439
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 27 Nov 2008 19:40:40 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1755D45DD72
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 19:40:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ED1D645DE4E
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 19:40:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C96D01DB8037
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 19:40:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 87281E08001
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 19:40:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 1/2] mm: pagecache allocation gfp fixes
In-Reply-To: <1227781737.25160.3.camel@penberg-laptop>
References: <20081127101837.GJ28285@wotan.suse.de> <1227781737.25160.3.camel@penberg-laptop>
Message-Id: <20081127193943.3CF3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 27 Nov 2008 19:40:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Frustratingly, gfp_t is really divided into two classes of flags. One are the
> > context dependent ones (can we sleep? can we enter filesystem? block subsystem?
> > should we use some extra reserves, etc.). The other ones are the type of memory
> > required and depend on how the algorithm is implemented rather than the point
> > at which the memory is allocated (highmem? dma memory? etc).
> > 
> > Some of functions which allocate a page and add it to page cache take a gfp_t,
> > but sometimes those functions or their callers aren't really doing the right
> > thing: when allocating pagecache page, the memory type should be
> > mapping_gfp_mask(mapping). When allocating radix tree nodes, the memory type
> > should be kernel mapped (not highmem) memory. The gfp_t argument should only
> > really be needed for context dependent options.
> > 
> > This patch doesn't really solve that tangle in a nice way, but it does attempt
> > to fix a couple of bugs. find_or_create_page changes its radix-tree allocation
> > to only include the main context dependent flags in order so the pagecache
> > page may be allocated from arbitrary types of memory without affecting the
> > radix-tree. Then grab_cache_page_nowait() is changed to allocate radix-tree
> > nodes with GFP_NOFS, because it is not supposed to reenter the filesystem.
> > 
> > Filesystems should be careful about exactly what semantics they want and what
> > they get when fiddling with gfp_t masks to allocate pagecache. One should be
> > as liberal as possible with the type of memory that can be used, and same
> > for the the context specific flags.
> > 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Looks good to me.
> 
> Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

me too.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
