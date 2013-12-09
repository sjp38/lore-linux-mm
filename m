Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA696B012C
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 18:22:05 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so6366259pbc.38
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 15:22:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id yd9si8590599pab.321.2013.12.09.15.22.03
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 15:22:03 -0800 (PST)
Date: Mon, 9 Dec 2013 15:22:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, page_alloc: make __GFP_NOFAIL really not fail
Message-Id: <20131209152202.df3d4051d7dc61ada7c420a9@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1312091355360.11026@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312091355360.11026@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Dec 2013 13:56:37 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> __GFP_NOFAIL specifies that the page allocator cannot fail to return
> memory.  Allocators that call it may not even check for NULL upon
> returning.
> 
> It turns out GFP_NOWAIT | __GFP_NOFAIL or GFP_ATOMIC | __GFP_NOFAIL can
> actually return NULL.  More interestingly, processes that are doing
> direct reclaim and have PF_MEMALLOC set may also return NULL for any
> __GFP_NOFAIL allocation.

__GFP_NOFAIL is a nasty thing and making it pretend to work even better
is heading in the wrong direction, surely?  It would be saner to just
disallow these even-sillier combinations.  Can we fix up the current
callers then stick a WARN_ON() in there?

> This patch fixes it so that the page allocator never actually returns
> NULL as expected for __GFP_NOFAIL.  It turns out that no code actually
> does anything as crazy as GFP_ATOMIC | __GFP_NOFAIL currently, so this
> is more for correctness than a bug fix for that issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
