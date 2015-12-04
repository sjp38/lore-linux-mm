Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 90C826B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 08:43:21 -0500 (EST)
Received: by pfu207 with SMTP id 207so26587947pfu.2
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 05:43:21 -0800 (PST)
Received: from m50-132.163.com (m50-132.163.com. [123.125.50.132])
        by mx.google.com with ESMTP id w16si19526953pfa.221.2015.12.04.05.43.19
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 05:43:20 -0800 (PST)
Date: Fri, 4 Dec 2015 21:43:02 +0800
From: Geliang Tang <geliangtang@163.com>
Subject: Re: [PATCH v2] mm/slab.c: use list_{empty_careful,last_entry} in
 drain_freelist
Message-ID: <20151204134302.GA6388@bogon>
References: <3ea815dc52bf1a2bb5e324d7398315597900be84.1449151365.git.geliangtang@163.com>
 <alpine.DEB.2.20.1512030850390.7483@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1512030850390.7483@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geliang Tang <geliangtang@163.com>

On Thu, Dec 03, 2015 at 08:53:21AM -0600, Christoph Lameter wrote:
> On Thu, 3 Dec 2015, Geliang Tang wrote:
> 
> >  	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
> >
> >  		spin_lock_irq(&n->list_lock);
> > -		p = n->slabs_free.prev;
> > -		if (p == &n->slabs_free) {
> > +		if (list_empty_careful(&n->slabs_free)) {
> 
> We have taken the lock. Why do we need to be "careful"? list_empty()
> shoudl work right?

Yes. list_empty() is OK.

> 
> >  			spin_unlock_irq(&n->list_lock);
> >  			goto out;
> >  		}
> >
> > -		page = list_entry(p, struct page, lru);
> > +		page = list_last_entry(&n->slabs_free, struct page, lru);
> 
> last???

The original code delete the page from the tail of slabs_free list.

> 
> Would the the other new function that returns NULL on the empty list or
> the pointer not be useful here too and save some code?

Sorry, I don't really understand what do you mean. Can you please specify
it a little bit?

Thanks.

- Geliang

> 
> This patch seems to make it difficult to understand the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
