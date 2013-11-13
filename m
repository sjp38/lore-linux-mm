Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE236B00A2
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 11:10:53 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rq2so617184pbb.20
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 08:10:53 -0800 (PST)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id pl10si24001438pbc.358.2013.11.13.08.10.50
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 08:10:51 -0800 (PST)
Date: Wed, 13 Nov 2013 17:10:22 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: hugetlbfs: fix hugetlbfs optimization
Message-ID: <20131113161022.GI15985@redhat.com>
References: <20131105221017.GI3835@redhat.com>
 <CALnjE+prqCg2ZAMLQBQjY0OqmW2ofjioUoS25pa8Y93somc8Gg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALnjE+prqCg2ZAMLQBQjY0OqmW2ofjioUoS25pa8Y93somc8Gg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin Shelar <pshelar@nicira.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, gregkh@linuxfoundation.org, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, hannes@cmpxchg.org, mel@csn.ul.ie, riel@redhat.com, minchan@kernel.org, andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, linux-mm@kvack.org

On Tue, Nov 12, 2013 at 11:22:50AM -0800, Pravin Shelar wrote:
> On Tue, Nov 5, 2013 at 2:10 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > Hi,
> >
> > this patch is an alternative implementation of the hugetlbfs directio
> > optimization discussed earlier. We've been looking into this with
> > Khalid last week and an earlier version of this patch (fully
> > equivalent as far as CPU overhead is concerned) was benchmarked by
> > Khalid and it didn't degrade performance compared to the PageHuge
> > check in current upstream code, so we should be good.
> >
> > The patch applies cleanly only after reverting
> > 7cb2ef56e6a8b7b368b2e883a0a47d02fed66911, it's much easier to review
> > it in this form as it avoids all the alignment changes. I'll resend to
> > Andrew against current upstream by squashing it with the revert after
> > reviews.
> >
> > I wished to remove the _mapcount tailpage refcounting for slab and
> > hugetlbfs tails too, but if the last put_page of a slab tail happens
> > after the slab page isn't a slab page anymore (but still compound as
> > it wasn't freed yet because of the tail pin), a VM_BUG_ON would
> > trigger during the last (unpinning) put_page(slab_tail) with the
> > mapcount underflow:
> >
> >                         VM_BUG_ON(page_mapcount(page) <= 0);
> >
> > Not even sure if any driver is doing anything like that, but the
> > current code would allow it, Pravin should know more about when
> > exactly in which conditions the last put_page is done on slab tail
> > pages.
> >
> Yes, This can happen when slab object is directly passed for IO and it
> is done in few filesystems (ocfs, xfs) when I checked last time.

About the slab case however, it cannot be that the tail pin obtained
with get_page(tail_page), is the last reference on the compound
page when it gets released through put_page.

kfree/kmem_cache_free would allow reuse of the whole compound page as
a different slab object without passing through the buddy allocator,
so totally disregarding any tail page pin. So in short I believe it's
safe to remove the mapcount refcounting from slab tail page pinning
because all tail pins should be released before the
kfree/kmem_cache_free, and in turn before the PG_slab flag has been
cleared (which happens before the slab code releases the last
reference count on the slab page to free it). It is also safe to for
hugetlbfs as the hugetlbfs destructor is wiped only after the last
hugetlbfs reference count has been released and no more put_page can
happen then.

So I think we've room for optimizations to fill the performance gap
compared to the PageHuge check at the top of put_page (which also
skips the mapcount tail page refcounting), but I would keep the
optimization to skip the tail page refcounting incremental, and it
makes sense to apply it to slab too if we do it, so we keep the
hugetlbfs and slab cases identical (which is simpler to maintain).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
