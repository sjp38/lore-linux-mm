Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 639616B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 11:57:27 -0500 (EST)
MIME-Version: 1.0
Message-ID: <04499111-84c1-45a2-a8e8-5c86a2447b56@default>
Date: Mon, 5 Mar 2012 08:57:19 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: (un)loadable module support for zcache
References: <CABv5NL-SquBQH8W+K1CXNBQQWqHyYO+p3Y9sPqsbfZKp5EafTg@mail.gmail.com>
In-Reply-To: <CABv5NL-SquBQH8W+K1CXNBQQWqHyYO+p3Y9sPqsbfZKp5EafTg@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilendir <ilendir@googlemail.com>, linux-mm@kvack.org
Cc: sjenning@linux.vnet.ibm.com, Konrad Wilk <konrad.wilk@oracle.com>, fschmaus@gmail.com, Andor Daam <andor.daam@googlemail.com>, i4passt@lists.informatik.uni-erlangen.de, devel@linuxdriverproject.org, Nitin Gupta <ngupta@vflare.org>

> From: Ilendir [mailto:ilendir@googlemail.com]
> Subject: (un)loadable module support for zcache
>=20
> While experimenting with zcache on various systems, we discovered what
> seems to be a different impact on CPU and power consumption, varying
> from system to system and workload. While there has been some research
> effort about the effect of on-line memory compression on power
> consumption [1], the trade-off, for example when using SSDs or on
> mobile platforms (e.g. Android), remains still unclear. Therefore it
> would be desirable to improve the possibilities to study this effects
> on the example of zcache. But zcache is missing an important feature:
> dynamic disabling and enabling. This is a big obstacle for further
> analysis.
> Since we have to do some free-to-choose work on a Linux related topic
> while doing an internship at the University in Erlangen, we'd like to
> implement this feature.
>=20
> Moreover, if we achieve our goal, the way to an unloadable zcache
> module isn't far way. If that is accomplished, one of the blockers to
> get zcache out of the staging tree is gone.
>=20
> Any advice is appreciated.
>=20
> Florian Schmaus
> Stefan Hengelein
> Andor Daam

Hi Florian, Stefan, and Andor --

Thanks for your interest in zcache development!

I see you've sent your original email separately to different lists
so I will try to combine them into one cc list now so hopefully
there will be one thread.

Your idea of studying power consumption tradeoffs is interesting
and the work to allow zcache to be installed as a module will
also be very useful.

I have given some thought on what would be necessary to allow
zcache (or Xen tmem, or RAMster) to be insmod'ed and rmmod'ed.
There are two main technical difficulties that I see.  There
may be more but let's start with these two.

First, the "tmem frontend" code in cleancache and frontswap
assumes that a "tmem backend" (such as zcache, Xen tmem, or
RAMster) has already registered when filesystems are mounted
(for cleancache) and when swapon is run (for frontswap).
If no tmem backend has yet registered when the mount (or swapon)
is invoked, then cleancache_enabled (or frontswap_enabled) has
not been set to 1, and the corresponding init_fs/init routine
has not been called and no tmem "pool" gets created.

Then if zcache later registers with cleancache/frontend, it
is too late... there are no mounts or swapons to trigger the
calls that create the tmem pools.  As result, all gets and
puts and flushes will fail, and zcache does not work.

I think the answer here is for cleancache (and frontswap) to
support "lazy pool creation".  If a backend has not yet
registered when an init_fs/init call is made, cleancache
(or frontswap) must record the attempt and generate a valid
"fake poolid" to return.  Any calls to put/get/flush with
a fake poolid is ignored as the zcache module is not
yet loaded.  Later, when zcache is insmod'ed, it will attempt
to register and cleancache must then call the init_fs/init
routines (to "lazily" create the pools), obtain a "real poolid"
from zcache for each pool and "map" the fake poolid to the real
poolid on EVERY get/put/flush and on pool destroy (umount/swapoff).

I think all changes for this will be in mm/cleancache.c and
mm/frontswap.c... the backend does not need to know anything
about it.

This implementation will not be hard, but there may be a few
corner cases that you will need to ensure are correct, and
of course you will need to ensure that any coding changes follow
proper Linux coding styles.

Second issue: When zcache gets rmmod'ed, there is an issue of
coherency.  You need to ensure that if zcache goes through

=09insmod -> rmmod -> insmod

that no stale data remains in any tmem pool.  If any
stale data remains, a "get" of the old data may result in
data corruption.

The problem is that there may be millions of pages in
cleancache and flushing those pages may take a very long
time.  The user will not want to wait that long.  And
for frontswap, frontswap_shrink must be called and since
every page in frontswap contains real user data, you must
ensure that all pages get decompressed and removed from
frontswap either into physical RAM or a physical swap disk.
(See frontswap_shrink in frontswap.c and frontswap_selfshrink
in the RAMster code.) This may take a very VERY long time.

So rmmod cannot complete until all the data in cleancache
is freed and all the data in frontswap is repatriated to RAM
or swap disk.

I don't have an easy answer for this one.  It may be possible
to have "zombie" lists of partially destroyed pages and a
kernel thread that (after rmmod completes) walks the list and
frees or frontswap_shrinks the pages.  I will leave this
to you to solve... it is likely the hardest problem for
making zcache work as a module.  If you can't get it to work,
it would still be useful to be able to "insmod" zcache,
even if "rmmod" is not possible.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
