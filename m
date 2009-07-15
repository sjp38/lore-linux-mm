Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 04CBE6B004F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 09:52:44 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4668282C75E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 10:51:32 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RYU5VJMOPCHd for <linux-mm@kvack.org>;
	Wed, 15 Jul 2009 10:51:32 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DFC0582C763
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 10:51:25 -0400 (EDT)
Date: Wed, 15 Jul 2009 10:31:54 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm: Warn once when a page is freed with PG_mlocked set
 V2
In-Reply-To: <20090715125822.GB29749@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0907151027410.23643@gentwo.org>
References: <20090715125822.GB29749@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009, Mel Gorman wrote:

> -static inline int free_pages_check(struct page *page)
> +static inline int free_pages_check(struct page *page, int wasMlocked)
>  {
> +	WARN_ONCE(wasMlocked, KERN_WARNING
> +		"Page flag mlocked set for process %s at pfn:%05lx\n"
> +		"page:%p flags:0x%lX\n",
> +		current->comm, page_to_pfn(page),
> +		page, page->flags|__PG_MLOCKED);
> +
>  	if (unlikely(page_mapcount(page) |

There is already a free_page_mlocked() that is only called if the mlock
bit is set. Move it into there to avoid having to run two checks in the
hot codee path?

Also __free_pages_ok() now has a TestClearMlocked in the hot code path.
Would it be possible to get rid of the unconditional use of an atomic
operation? Just check the bit and clear it later in free_page_mlocked()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
