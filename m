Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 4DF236B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 12:26:15 -0500 (EST)
MIME-Version: 1.0
Message-ID: <28a63847-7659-44c4-9c33-87f5d50b2ea0@default>
Date: Wed, 2 Jan 2013 09:26:07 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>>
 <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>>
 <0e91c1e5-7a62-4b89-9473-09fff384a334@default>
 <50E32255.60901@linux.vnet.ibm.com> <50E4588E.6080001@linux.vnet.ibm.com>
In-Reply-To: <50E4588E.6080001@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> Subject: Re: [PATCH 7/8] zswap: add to mm/
>=20
> On 01/01/2013 09:52 AM, Seth Jennings wrote:
> > On 12/31/2012 05:06 PM, Dan Magenheimer wrote:
> >> A second related issue that concerns me is that, although you
> >> are now, like zcache2, using an LRU queue for compressed pages
> >> (aka "zpages"), there is no relationship between that queue and
> >> physical pageframes.  In other words, you may free up 100 zpages
> >> out of zswap via zswap_flush_entries, but not free up a single
> >> pageframe.  This seems like a significant design issue.  Or am
> >> I misunderstanding the code?
> >
> > You understand correctly.  There is room for optimization here and it
> > is something I'm working on right now.
>=20
> It's the same "design issue" that the slab shrinkers have, and they are
> likely to have some substantially consistently smaller object sizes.

Understood Dave.  However if one compares the total percentage
of RAM used for zpages by zswap vs the total percentage of RAM
used by slab, I suspect that the zswap number will dominate,
perhaps because zswap is storing primarily data and slab is
storing primarily metadata?

I don't claim to be any kind of expert here, but I'd imagine
that MM doesn't try to manage the total amount of slab space
because slab is "a cost of doing business".  However, for
in-kernel compression to be widely useful, IMHO it will be
critical for MM to somehow load balance between total pageframes
used for compressed pages vs total pageframes used for
normal pages, just as today it needs to balance between
active and inactive pages.
=20
> >> A third concern is about scalability... the locking seems very
> >
> > The reason the coarse lock isn't a problem for zswap like the hash
>=20
> Lock hold times don't often dominate lock cost these days.  The limiting
> factor tends to be the cost of atomic operations to bring the cacheline
> over to the CPUs acquiring the lock.

[I'll bow out of the scalability discussion as long as someone
else is thinking about it.]

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
