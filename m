From: Neil Brown <neilb@suse.de>
Date: Tue, 12 Aug 2008 15:35:14 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18593.8466.965002.476705@notabene.brown>
Subject: Re: [PATCH 05/30] mm: slb: add knowledge of reserve pages
In-Reply-To: message from Peter Zijlstra on Thursday July 24
References: <20080724140042.408642539@chello.nl>
	<20080724141529.635920366@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thursday July 24, a.p.zijlstra@chello.nl wrote:
> Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
> contexts that are entitled to it. This is done to ensure reserve pages don't
> leak out and get consumed.

This looks good (we are still missing slob though, aren't we :-( )

> @@ -1526,7 +1540,7 @@ load_freelist:
>  	object = c->page->freelist;
>  	if (unlikely(!object))
>  		goto another_slab;
> -	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
> +	if (unlikely(PageSlubDebug(c->page) || c->reserve))
>  		goto debug;

This looks suspiciously like debugging code that you have left in.
Is it??

> @@ -265,7 +267,8 @@ struct array_cache {
>  	unsigned int avail;
>  	unsigned int limit;
>  	unsigned int batchcount;
> -	unsigned int touched;
> +	unsigned int touched:1,
> +		     reserve:1;

This sort of thing always worries me.
It is a per-cpu data structure so you won't get SMP races corrupting
fields.  But you do get read-modify-write in place of simple updates.
I guess it's not a problem..  But it worries me :-)


NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
