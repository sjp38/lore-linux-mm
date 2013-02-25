Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 58C336B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:05:57 -0500 (EST)
MIME-Version: 1.0
Message-ID: <69936094-e2fc-44bd-b179-f567e8681bec@default>
Date: Mon, 25 Feb 2013 09:05:38 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv5 1/8] zsmalloc: add to mm/
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1360780731-11708-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130219091804.GA13989@lge.com> <5123BC4D.1010404@linux.vnet.ibm.com>
 <20130219233733.GA16950@blaptop> <20130222092420.GA8077@lge.com>
 <5127CF34.9040302@linux.vnet.ibm.com>
In-Reply-To: <5127CF34.9040302@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Friday, February 22, 2013 1:04 PM
> To: Joonsoo Kim
> Subject: Re: [PATCHv5 1/8] zsmalloc: add to mm/
>=20
> On 02/22/2013 03:24 AM, Joonsoo Kim wrote:
> >
> > It's my quick thought. So there is no concrete idea.
> > As Seth said, with a FULL list, zsmalloc always access all zspage.
> > So, if we want to know what pages are for zsmalloc, we can know it.
> > The EMPTY list can be used for pool of zsmalloc itself. With it, we don=
't
> > need to free zspage directly, we can keep zspages, so can reduce
> > alloc/free overhead. But, I'm not sure whether it is useful.
>=20
> I think it's a good idea.  zswap actually does this "keeping some free
> pages around for later allocations" outside zsmalloc in a mempool that
> zswap manages.  Minchan once mentioned bringing that inside zsmalloc
> and this would be a way we could do it.

I think it's a very bad idea.  If I understand, the suggestion will
hide away some quantity (possibly a very large quantity) of pages
for the sole purpose of zswap, in case zswap gets around to using them
sometime in the future.  In the meantime, those pages are not available
for use by any other kernel subsystems or by userland processes.
An idle page is a wasted page.

While you might defend the mempool use for a handful of pages,
frontswap writes/reads thousands of pages in a bursty way,
and then can go idle for a very long time.  This may not be
readily apparent with artificially-created memory pressure
from kernbench with -jN (high N).  Leaving thousands
of pages in zswap's personal free list may cause memory pressure
that would otherwise never have existed.

> Just want to be clear that I'd be in favor of looking at this after
> the merge.

I disagree... I think this is exactly the kind of fundamental
MM interaction that should be well understood and resolved
BEFORE anything gets merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
