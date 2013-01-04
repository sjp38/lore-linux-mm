Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 4C4DA6B005A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 13:45:25 -0500 (EST)
MIME-Version: 1.0
Message-ID: <04baa5af-0278-480d-9a3f-844f948e7672@default>
Date: Fri, 4 Jan 2013 10:45:08 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 7/8] zswap: add to mm/
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>
 <0e91c1e5-7a62-4b89-9473-09fff384a334@default>
 <50E32255.60901@linux.vnet.ibm.com> <50E4588E.6080001@linux.vnet.ibm.com>
 <28a63847-7659-44c4-9c33-87f5d50b2ea0@default>
 <50E479AD.9030502@linux.vnet.ibm.com>
 <9955b9e0-731b-4cbf-9db0-683fcd32f944@default>
 <20130103073339.GF3120@dastard>
 <ac37f7ce-b15a-40f8-9da7-858dea3651b9@default>
 <20130104023030.GK3120@dastard>
In-Reply-To: <20130104023030.GK3120@dastard>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Dave Chinner [mailto:david@fromorbit.com]
> Subject: Re: [PATCH 7/8] zswap: add to mm/

Hi Dave --

Thanks for your continued helpful feedback and expertise!
=20
> > Given the above, do you think either compressed-anonymous-pages or
> > compressed-pagecache-pages are suitable candidates for the shrinker
> > infrastructure?
>=20
> I don't know all the details of what you are trying to do, but you
> seem to be describing a two-level heirarchy - a pool of compressed
> data and a pool of uncompressed data, and under memory pressure are
> migrating data from the uncompressed pool to the compressed pool. On
> access, you are migrating back the other way.  Hence it seems to me
> that you could implement the process of migration from the
> uncompressed pool to the compressed pool as a shrinker so that it
> only happens as a result of memory pressure....

I suppose that would be an option, but the current triggers
for compression are: (for anonymous pages) the decision by
the MM subsystem to swap-out a specific page; and (for
pagecache pages) the decision by the MM subsystem to reclaim
a specific pagecache page.  This is all handled by the cleancache
and frontswap APIs/hooks that Linus merged at 3.0/3.5.

This approach leveraged all the existing MM mechanisms to
ensure that all existing memory pressure valves are honored
unchanged, and also ensures that MM has selected the lowest
priority pages (and thus presumably the pages least likely
to be directly addressed soon).

You're correct that the normal trigger for decompression is
access, but this is handled through frontswap/cleancache
hooks in the existing pagefault paths.  So this also honors
all existing memory pressure mechanisms.

So, it is the "abnormal" decompression triggers that we are
mostly exploring here:  For anonymous pages, we reach a point
where zcache/zswap is "full" and we wish we would have used
the swap disk for the LRU pages... so we need to decompress
some pages and move them to the "real" swap device.  And for
pagecache pages, we somehow determine that we need to throw
away some zpages, and we'd like to throw away as few zpages
as possible (preferably in some kind of LRU order), while
freeing up as many wholepages as possible.

This last is the only current (feebly attempted) use of the
shrinker API.

> > Note that compressed anonymous pages are always dirty so
> > cannot be "reclaimed" as such.  But the mechanism that Seth
> > and I are working on causes compressed anonymous pages to
> > be decompressed and then sent to backing store, which does
> > (eventually, after I/O latency) free up pageframes.
>=20
> The lack of knowledge I have about zcache/zswap means I might be
> saying something stupid, but why wouldn't you simply write the
> uncompressed page to the backing store and then compress it on IO
> completion? If you have to uncompress it for the application to
> either modify the page again or write it to the backing store,
> doesn't it make things much simpler if the cache only holds clean
> pages? And if it only holds clean pages, then another shrinker could
> be used to keep the size of it in check....

A good point, and this is actually already implemented as an option.
(See frontswap_writethrough_enabled.)  But it has the unfortunate
side effect of generating a lot of swap-disk write traffic that,
in many circumstances, could have been completely avoided.
For some reason, performance also sucked... though that was
never investigated so may have been some silly bug and we should
revisit it.
=20
> > In your opinion,
> > then, should they be managed by core MM, or by shrinker-controlled
> > caches, by some combination, or independently of either?
>=20
> I think the entire MM could be run by the shrinker based reclaim
> infrastructure. You should probably have a read of the discussions
> in this thread to get an idea of where we are trying to get to with
> the shrinker infrastructure:
>=20
> https://lkml.org/lkml/2012/11/27/567
>=20
> (Warning: I don't say very nice things about the zcache/ramster
> shrinkers in that patch series. :/ )

Heh.  No offense taken.  I hope your brain has recovered and you
managed to avoid tearing out your eyeballs.  That code was definitely
not ready for primetime and not really even ready for staging,
but had to be published due to various unfortunate circumstances.

If you have suggestions for other improvements (in addition
to your broader patchset), we would be eager for your help!

> > Can slab today suitably manage "larger" objects that exceed
> > half-PAGESIZE?  Or "larger" objects, such as 35%-PAGESIZE where
> > there would be a great deal of fragmentation?
>=20
> Have a look at how the kernel heap is implemented:
>=20
> <snip>
>=20
> i.e. it's implemented as a bunch of power-of-2 sized slab caches,
> with object sizes that range up to 4MB. IIRC, SLUB is better suited
> to odd sized objects than SLAB due to it's ability to have multiple
> pages per slab even for objects smaller than page sized......

Hmmm... I was unclear.  *All* objects (aka zpages) stored by zcache/zswap
are less than PAGESIZE, and a large percent are between PAGESIZE/2
and PAGESIZE, and a large percent are between PAGESIZE/3 and PAGESIZE/2.
I don't believe slab (or slub or kmalloc) can handle these efficiently
without significant fragmentation, though it may be my poor understanding
of slab/slub.
=20
> > If so, we should definitely consider slab as an alternative
> > for zpage allocation.
>=20
> Or you could just use kmalloc... ;)
>=20
> As I said initially - don't think of whether you need to use slab
> allocation or otherwise. Start with simple allocation, a tracking
> mechanism and a rudimetary shrinker, and then optimise allocation and
> reclaim once you understand the limitations of the simple
> solution....

Indeed.  I think that's where we are at... optimising the reclaim
now that we understand the limitations of the rudimentary (eye-clawing-out)
shrinker.  Please help if you have ideas!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
