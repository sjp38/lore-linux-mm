Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id B6C816B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 18:47:37 -0500 (EST)
MIME-Version: 1.0
Message-ID: <a06fbc6b-8731-4bfe-82ff-05e8d14d8595@default>
Date: Wed, 6 Feb 2013 15:47:29 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv3 5/6] zswap: add to mm/
References: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359409767-30092-6-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130129062756.GH4752@blaptop> <51080658.7060709@linux.vnet.ibm.com>
In-Reply-To: <51080658.7060709@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCHv3 5/6] zswap: add to mm/
>=20
> On 01/29/2013 12:27 AM, Minchan Kim wrote:
> > First feeling is it's simple and nice approach.
> > Although we have some problems to decide policy, it could solve by late=
r patch
> > so I hope we make basic infrasture more solid by lots of comment.
>=20
> Thanks very much for the review!
> >
> > Another question.
> >
> > What's the benefit of using mempool for zsmalloc?
> > As you know, zsmalloc doesn't use mempool as default.
> > I guess you see some benefit. if so, zram could be changed.
> > If we can change zsmalloc's default scheme to use mempool,
> > all of customer of zsmalloc could be enhanced, too.
>=20
> In the case of zswap, through experimentation, I found that adding a
> mempool behind the zsmalloc pool added some elasticity to the pool.
> Fewer stores failed if we kept a small reserve of pages around instead
> of having to go back to the buddy allocator who, under memory
> pressure, is more likely to reject our request.
>=20
> I don't see this situation being applicable to all zsmalloc users
> however.  I don't think we want incorporate it directly into zsmalloc
> for now.  The ability to register custom page alloc/free functions at
> pool creation time allows users to do something special, like back
> with a mempool, if they want to do that.

(sorry, still catching up on backlog after being gone last week)

IIUC, by using mempool, you are essentially setting aside a
special cache of pageframes that only zswap can use (or other
users of mempool, I don't know what other subsystems use it).
So one would expect that fewer stores would fail if more
pageframes are available to zswap, the same as if you had
increased zswap_max_pool_percent by some small fraction.

But by setting those pageframes aside, you are keeping them from
general use, which may be a use with a higher priority as determined
by the mm system.

This seems wrong to me.  Should every subsystem hide a bunch of
pageframes away in case it might need them?

Or am I missing something?

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
