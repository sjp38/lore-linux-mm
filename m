Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 50F8A6B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 20:08:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <0be9e88e-7b0d-471d-8d49-6dc593dd43be@default>
Date: Wed, 2 Jun 2010 17:06:37 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 2/7] Cleancache (was Transcendent Memory): core files
References: <20100528173550.GA12219@ca-server1.us.oracle.com
 20100602122900.6c893a6a.akpm@linux-foundation.org>
In-Reply-To: <20100602122900.6c893a6a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> From: Andrew Morton [mailto:akpm@linux-foundation.org]

Thanks very much for taking the time for feedback!  I hope
I can answer all of your questions... bear with me if some
of the answers are a bit long.

> > +extern struct cleancache_ops *cleancache_ops;
>=20
> Why does this exist?  If there's only ever one cleancache_ops
> system-wide then we'd be better off doing
>=20
> =09(*cleancache_ops.init_fs)()
>=20
> and save a zillion pointer hops.
>=20
> If instead there are different flavours of cleancache_ops then making
> this pointer a system-wide singleton seems an odd decision.

It is intended that there be different flavours but only
one can be used in any running kernel.  A driver file/module
claims the cleancache_ops pointer (and should check to ensure
it is not already claimed).  And if nobody claims cleancache_ops,
the hooks should be as non-intrusive as possible.

Also note that the operations occur on the order of the number
of I/O's, so definitely a lot, but "zillion" may be a bit high. :-)

If you think this is a showstoppper, it could be changed
to be bound only at compile-time, but then (I think) the claimer
could never be a dynamically-loadable module.
=20
> All these undocumeted functions would appear to be racy and buggy if
> the passed-in page isn't locked.  But because they're undocumented, I
> don't know if "the page must be locked" was an API requirement and I
> ain't going to go and review all callers.

True.  The passed-in pages are assumed to be locked and,
I believe, they are at all call sites.  I'm not sure if
this is possible/easy, but maybe I can put a BUG_ON(if !locked)
in the routines to enforce and document this (and document
it also with prose elsewhere).

> Please completely document the sysfs API, preferably in the changelogs.
> It's the first thing reviewers should look at, because it's one thing
> we can never change.  And Documentation/ABI/ is a place for permanent
> documentation.

OK, will do.=20
=20
> I'm a bit surprised that cleancache and frontswap have their sticky
> fingers so deep inside swap and filesystems and the VFS.
>=20
> I'd have thought that the places where pages are added to the caches
> would be highly concentrated in the page-reclaim page eviction code,
> and that for reads the place where pages are retrieved would be at the
> pagecache/swapcache <-> I/O boundary.  Those transition points are
> reasonably narrow and seem to be the obvious site at which to interpose
> a cache, but it wasn't done that way.

Hmmm...  I think those transition points are exactly where the
get/put/flush hooks are placed and I don't see how they can
be reduced.

The filesystem init hooks are almost entirely to allow different fs's
to "opt in" to cleancache, with one exception in btrfs since btrfs
goes around VFS in one case.  And frontswap has one init call
per swap type (all in one place).

The core hooks for frontswap are also very few and brief.  The
lengthy part of the patch is because the pages in frontswap are
persistent and must be managed with a (one-bit-per-page) data
structure.

Plus, there's a lot of patch-bulk due to the sysfs calls
and a lot of comments.

> In core MM there's been effort to treat swap-backed and file-backed
> pages
> in the same manner (indeed in a common manner) and that effort has been
> partially successful.  These changes are going in the other direction.

But IMHO they are going the other direction for a very good
reason.  Much of the value of cleancache comes from cleanly
separating clean pagecache pages from dirty pages.  Frontswap
is always dealing with dirty pages.

But in any case, all the hooks are still very brief and if
swap_writepage/swap_readpage ever got merged into file-backed
MM code, there would need to be some test to differentiate
swap-backed pages from file-backed pages and the slightly
different frontswap-vs-cleancache calls would be in different
parts of the if/else, but I don't think otherwise would
interfere with attempts to "treat [them] in the same manner".

> There have been any number of compressed-swap and compressed-file
> projects (if not compressed-pagecache).  Where do cleancache/frontswap
> overlap those and which is superior?

The primary target of cleancache/frontswap isn't compression
(see below), though that is a nice feature that is provided
by the Xen Transcendent Memory implementation.

For kernel-only use, Nitin Gupta's position is that the cleancache
interface will work nicely for in-kernel compressed-pagecache.
He feels differently for frontswap though.

> And the big vague general issue: where's the value?  What does all this
> code buy us?  Why would we want to include it in Linux?  When Aunt
> Tillie unwraps her shiny new kernel, what would she notice was
> different?

A fair question so let me provide an honest answer.  Like many
recent KVM changes, there is a very compelling reason to do this
for virtualized Linux and a less-compelling-but-still-possibly-
useful reason for non-virtualized Linux.

First non-virtualized (since I know you are less interested in
the virtualized case and I hope to keep your attention for a
bit longer):  Cleancache/frontswap provide interfaces for
a new pseudo-RAM memory type that conceptually lies between
fast kernel-directly-addressable RAM and slower DMA/asynchronous
devices.  Disallowing direct kernel or userland reads/writes
to this pseudo-RAM is ideal when data is transformed to a different
form and size (such as with compression) or secretly moved
(as might be useful for write-balancing for some RAM-like devices).
Evicted page-cache pages and swap pages are a great use for
this kind of slower-than-RAM-but-much-faster-than-disk
pseudo-RAM and the cleancache/frontswap "page-object-oriented"
specification provides a nice way to read and write and
indirectly identify the pages.  There may be other uses too.

In the virtual case, the whole point of virtualization is to
statistically multiplex physical resources across the varying
demands of multiple virtual machines.  This is really hard to
do with RAM and efforts to do it well with no kernel changes
have essentially failed (except in some well-publicized=20
special-case workloads).  Cleancache and frontswap, with a
fairly small impact on the kernel, provide a huge amount of
flexibility for more dynamic, flexible RAM multiplexing.
(Think IBM's Collaborative Memory Management but much simpler.)

If you are interested in understanding this better, I can
go on with a lot more information, but that's it in a nutshell.

Thanks again!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
