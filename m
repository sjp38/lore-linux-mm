Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B24AC6B000E
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 10:09:43 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id p142so9285287itp.0
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 07:09:43 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id x186si5927504itg.32.2018.02.19.07.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Feb 2018 07:09:41 -0800 (PST)
Date: Mon, 19 Feb 2018 09:09:38 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
In-Reply-To: <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1802190856340.22119@nuc-kabylake>
References: <20180216160110.641666320@linux.com> <20180216160121.519788537@linux.com> <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Mon, 19 Feb 2018, Mel Gorman wrote:

> The phrasing here is confusing. hackbench is not very intensive in terms of
> memory, it's more fork intensive where I find it extremely unlikely that
> it would hit problems with fragmentation unless memory was deliberately
> fragmented first. Furthermore, the phrasing implies that the minimum order
> used by the page allocator is order 3 which is not what the patch appears
> to do.

It was used to illustrate the performance gain.

> > -		if (!page)
> > +		/*
> > +		 * Continue if no page is found or if our freelist contains
> > +		 * less than the minimum pages of that order. In that case
> > +		 * we better look for a different order.
> > +		 */
> > +		if (!page || area->nr_free < area->min)
> >  			continue;
> >  		list_del(&page->lru);
> >  		rmv_page_order(page);
>
> This is surprising to say the least. Assuming reservations are at order-3,
> this would refuse to split order-3 even if there was sufficient reserved
> pages at higher orders for a reserve. This will cause splits of higher
> orders unnecessarily which could cause other fragmentation-related issues
> in the future.

Well that is intended. We want to preserve a number of pages at a certain
order. If there are higher order pages available then those can be split
and the allocation will succeed while preserving the mininum number of
pages at the reserved order.

> This is similar to a memory pool except it's not. There is no concept of a
> user of high-order reserves accounting for it. Hence, a user of high-order
> pages could allocate the reserve multiple times for long-term purposes
> while starving other allocation requests. This could easily happen for slub
> with min_order set to the same order as the reserve causing potential OOM
> issues. If a pool is to be created, it should be a real pool even if it's
> transparently accessed through the page allocator. It should allocate the
> requested number of pages and either decide to refill is possible or pass
> requests through to the page allocator when the pool is depleted. Also,
> as it stands, an OOM due to the reserve would be confusing as there is no
> hint the failure may have been due to the reserve.

Ok we can add the ->min values to the OOOM report.

This is a crude approach I agree and it does require knowlege of the load
and user patterns. However, what other approach is there to allow the
system to sustain higher order allocations if those are needed? This is an
issue for which no satisfactory solution is present. So a measure like
this would allow a limited use in some situations.

> Access to the pool is unprotected so you might create a reserve for jumbo
> frames only to have them consumed by something else entirely. It's not
> clear if that is even fixable as GFP flags are too coarse.

If its consumed by something else then the parameters or the jumbo frame
setting may be adjusted. This feature is off by default so its only used
for tuning purposes.

> It is not covered in the changelog why MIGRATE_HIGHATOMIC was not
> sufficient for jumbo frames which are generally expected to be allocated
> from atomic context. If there is a problem there then maybe
> MIGRATE_HIGHATOMIC should be made more strict instead of a hack like
> this. It'll be very difficult, if not impossible, for this to be tuned
> properly.

This approach has been in use for a decade or so as mentioned in the patch
description. So please be careful with impossibility claims. This enables
handling of larger contiguous blocks of memory that are requires in some
circumstances and it has been doing that successfully (although with some
tuning effort).

> Finally, while I accept that fragmentation over time is a problem for
> unmovable allocations (fragmentation protection was originally designed
> for THP/hugetlbfs), this is papering over the problem. If greater
> protections are needed then the right approach is to be more strict about
> fallbacks. Specifically, unmovable allocations should migrate all movable
> pages out of migrate_unmovable pageblocks before falling back and that
> can be controlled by policy due to the overhead of migration. For atomic
> allocations, allow fallback but use kcompact or a workqueue to migrate
> movable pages out of migrate_unmovable pageblocks to limit fallbacks in
> the future.

This is also papering over more issues. While these measures may delay
fragmentation some bit more they will not result in a pool of large
pages being available for the system throughout the lifetime of it.

> I'm not a fan of this patch.

I am also not a fan of this patch but this is enabling something that we
wanted for a long time. Consistent ability in a limited way to allocate
large page orders.

Since we have failed to address this in other way this may be the best ad
hoc method to get there. What we have done to address fragmentation so far
are all these preventative measures that get more ineffective as time
progresses while memory sizes increase. Either we do this or we need to
actually do one of the other known measures to address fragmentation like
making inode/dentries movable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
