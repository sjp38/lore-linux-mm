Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id A5ADB6B0075
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 03:31:54 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR500ER6GWMOZ40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 07 Aug 2013 08:31:52 +0100 (BST)
Message-id: <1375860711.17079.16.camel@AMDC1943>
Subject: Re: [RFC PATCH 1/4] zbud: use page ref counter for zbud pages
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Wed, 07 Aug 2013 09:31:51 +0200
In-reply-to: <20130806185104.GD5765@medulla.variantweb.net>
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
 <1375771361-8388-2-git-send-email-k.kozlowski@samsung.com>
 <20130806185104.GD5765@medulla.variantweb.net>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Bob Liu <bob.liu@oracle.com>

Hi Seth,

On wto, 2013-08-06 at 13:51 -0500, Seth Jennings wrote:
> I like the idea.  I few things below.  Also agree with Bob the
> s/rebalance/adjust/ for rebalance_lists().
OK.

> s/else if/if/ since the if above returns if true.
Sure.

> > +		/* zbud_free() or zbud_alloc() */
> > +		int freechunks = num_free_chunks(zhdr);
> > +		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
> > +	} else {
> > +		/* zbud_alloc() */
> > +		list_add(&zhdr->buddy, &pool->buddied);
> > +	}
> > +	/* Add/move zbud page to beginning of LRU */
> > +	if (!list_empty(&zhdr->lru))
> > +		list_del(&zhdr->lru);
> 
> We don't want to reinsert to the LRU list if we have called zbud_free()
> on a zbud page that previously had two buddies.  This code causes the
> zbud page to move to the front of the LRU list which is not what we want.

Right, I'll fix it.


> > @@ -326,10 +370,10 @@ found:
> >  void zbud_free(struct zbud_pool *pool, unsigned long handle)
> >  {
> >  	struct zbud_header *zhdr;
> > -	int freechunks;
> > 
> >  	spin_lock(&pool->lock);
> >  	zhdr = handle_to_zbud_header(handle);
> > +	BUG_ON(zhdr->last_chunks == 0 && zhdr->first_chunks == 0);
> 
> Not sure we need this.  Maybe, at most, VM_BUG_ON()?

Actually it is somehow a leftover after debugging so I don't mind
removing it completely.


> > @@ -411,11 +438,24 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
> >  		return -EINVAL;
> >  	}
> >  	for (i = 0; i < retries; i++) {
> > +		if (list_empty(&pool->lru)) {
> > +			/*
> > +			 * LRU was emptied during evict calls in previous
> > +			 * iteration but put_zbud_page() returned 0 meaning
> > +			 * that someone still holds the page. This may
> > +			 * happen when some other mm mechanism increased
> > +			 * the page count.
> > +			 * In such case we succedded with reclaim.
> > +			 */
> > +			return 0;
> > +		}
> >  		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
> > +		BUG_ON(zhdr->first_chunks == 0 && zhdr->last_chunks == 0);
> 
> Again here.
I agree.


Thanks for comments,
Krzysztof


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
