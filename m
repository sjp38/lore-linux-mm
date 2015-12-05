Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id CE0996B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 21:36:38 -0500 (EST)
Received: by pfnn128 with SMTP id n128so34829521pfn.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 18:36:38 -0800 (PST)
Received: from m50-132.163.com (m50-132.163.com. [123.125.50.132])
        by mx.google.com with ESMTP id he9si23299527pac.102.2015.12.04.18.36.36
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 18:36:37 -0800 (PST)
Date: Sat, 5 Dec 2015 10:36:27 +0800
From: Geliang Tang <geliangtang@163.com>
Subject: Re: [PATCH v2] mm/slab.c: use list_{empty_careful,last_entry} in
 drain_freelist
Message-ID: <20151205023627.GA9812@bogon>
References: <3ea815dc52bf1a2bb5e324d7398315597900be84.1449151365.git.geliangtang@163.com>
 <alpine.DEB.2.20.1512030850390.7483@east.gentwo.org>
 <20151204134302.GA6388@bogon>
 <alpine.DEB.2.20.1512041014440.21427@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1512041014440.21427@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geliang Tang <geliangtang@163.com>

On Fri, Dec 04, 2015 at 10:16:38AM -0600, Christoph Lameter wrote:
> On Fri, 4 Dec 2015, Geliang Tang wrote:
> 
> > On Thu, Dec 03, 2015 at 08:53:21AM -0600, Christoph Lameter wrote:
> > > On Thu, 3 Dec 2015, Geliang Tang wrote:
> > >
> > > >  	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
> > > >
> > > >  		spin_lock_irq(&n->list_lock);
> > > > -		p = n->slabs_free.prev;
> > > > -		if (p == &n->slabs_free) {
> > > > +		if (list_empty_careful(&n->slabs_free)) {
> > >
> > > We have taken the lock. Why do we need to be "careful"? list_empty()
> > > shoudl work right?
> >
> > Yes. list_empty() is OK.
> >
> > >
> > > >  			spin_unlock_irq(&n->list_lock);
> > > >  			goto out;
> > > >  		}
> > > >
> > > > -		page = list_entry(p, struct page, lru);
> > > > +		page = list_last_entry(&n->slabs_free, struct page, lru);
> > >
> > > last???
> >
> > The original code delete the page from the tail of slabs_free list.
> 
> Maybe make the code clearer by using another method to get the page
> pointer?
> 
> > >
> > > Would the the other new function that returns NULL on the empty list or
> > > the pointer not be useful here too and save some code?
> >
> > Sorry, I don't really understand what do you mean. Can you please specify
> > it a little bit?
> 
> I take that back. list_empty is the best choice here.

If we use list_empty(), there will be two list_empty() in the code:

        while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
                spin_lock_irq(&n->list_lock);
                if (list_empty(&n->slabs_free)) {
                        spin_unlock_irq(&n->list_lock);
                        goto out; 
                }
                page = list_last_entry(&n->slabs_free, struct page, lru);
                list_del(&page->lru);
                spin_unlock_irq(&n->list_lock);
        }

Or can we drop the first list_empty() like this? It will function the same as the above code.

        while (nr_freed < tofree) {
                spin_lock_irq(&n->list_lock);
                if (list_empty(&n->slabs_free)) {
                        spin_unlock_irq(&n->list_lock);
                        goto out; 
                }
                page = list_last_entry(&n->slabs_free, struct page, lru);
                list_del(&page->lru);
                spin_unlock_irq(&n->list_lock);
        }

Please let me know which one is better?

Thanks.

- Geliang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
