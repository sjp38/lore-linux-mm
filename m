Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 66F126B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:03:45 -0500 (EST)
MIME-Version: 1.0
Message-ID: <3e397e72-5fb3-4f5b-9879-0c8060a172ac@default>
Date: Thu, 21 Feb 2013 14:03:30 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv6 0/8] zswap: compressed swap caching
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <9e251fb2-be82-41d2-b6cd-e46525b263cb@default>
 <512666B2.1020609@linux.vnet.ibm.com>
In-Reply-To: <512666B2.1020609@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCHv6 0/8] zswap: compressed swap caching
>=20
> On 02/21/2013 09:50 AM, Dan Magenheimer wrote:
> >> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> >> Subject: [PATCHv6 0/8] zswap: compressed swap caching
> >>
> >> Changelog:
> >>
> >> v6:
> >> * fix improper freeing of rbtree (Cody)
> >
> > Cody's bug fix reminded me of a rather fundamental question:
> >
> > Why does zswap use a rbtree instead of a radix tree?
> >
> > Intuitively, I'd expect that pgoff_t values would
> > have a relatively high level of locality AND at any one time
> > the set of stored pgoff_t values would be relatively non-sparse.
> > This would argue that a radix tree would result in fewer nodes
> > touched on average for lookup/insert/remove.
>=20
> I considered using a radix tree, but I don't think there is a compelling
> reason to choose a radix tree over a red-black tree in this case
> (explanation below).
>=20
> From a runtime standpoint, a radix tree might be faster.  The swap
> offsets will be largely in linearly bunched groups over the indexed
> range.  However, there are also memory constraints to consider in this
> particular situation.
>=20
> Using a radix tree could result in intermediate radix_tree_node
> allocations in the store (insert) path in addition to the zswap_entry
> allocation.  Since we are under memory pressure, using the red-black
> tree, whose metadata is included in the struct zswap_entry, reduces the
> number of opportunities to fail.
>=20
> On my system, the radix_tree_node structure is 568 bytes.  The
> radix_tree_node cache requires 4 pages per slab, an order-2 page
> allocation.  Growing that cache will be difficult under the pressure.
>=20
> In my mind, cost of even a single node allocation failure resulting in
> an additional page swapped to disk will more that wipe out any possible
> performance advantage using a radix tree might have.

For slab, I agree that makes good sense.  But slub (the default allocator)
falls back, I think, to order-0 if order-2 fails.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
