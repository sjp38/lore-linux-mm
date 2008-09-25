Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
From: Keith Packard <keithp@keithp.com>
In-Reply-To: <20080925003021.GC23494@wotan.suse.de>
References: <20080923091017.GB29718@wotan.suse.de>
	 <1222185029.4873.157.camel@koto.keithp.com>
	 <20080925003021.GC23494@wotan.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-qB69KT6kU4LYvg5BL+O+"
Date: Wed, 24 Sep 2008 18:20:22 -0700
Message-Id: <1222305622.4343.166.camel@koto.keithp.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: keithp@keithp.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-qB69KT6kU4LYvg5BL+O+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-09-25 at 02:30 +0200, Nick Piggin wrote:

> Pity. Anyway, I accept that, let's move on.

Well, the goal is to "eventually" get to use fds so that at least some
of our common operations can use regular sys calls. But, not having
those trapped in the shmem layer may end up being a feature as we'll get
to watch more closely, although dealing with the actual pread/pwrite
semantics doesn't look entirely like fun.

> I guess so. A big problem of ioctls is just that they had been easier to
> add so they got less thought and review ;) If your ioctls are stable,
> correct, cross platform etc. then I guess that's the best you can do.

One does what one can. Of course, in this case, 'cross platform' is just
x86/x86_64 as we're talking Intel integrated graphics. When (if?) we
figure out how to create a common interface across multiple cards for
some of these operations, we'll probably discover mistakes. We have
tried to be careful, but we cannot test in any other environment.

> Well, no not a seperate filesystem to do the pageable backing store, but
> a filesystem to do your object management. If there was a need for pageab=
le
> RAM backing store, then you would still go back to the pageable allocator=
.=20

Now that you've written one, we could go back and think about building a
file system and using fds for our operations. It would be a whole lot
easier than starting from scratch.

> You can map them to userspace if you just take a page at a time and inser=
t
> them into the page tables at fault time (or mmap time if you prefer).
> Currently, this will mean that mmapped pages would not be swappable; is
> that a problem?

Yes. We leave a lot of objects mapped to user space as mmap isn't
exactly cheap. We're trying to use pread/pwrite for as much bulk I/O as
we can, but at this point, we're still mapping most of the pages we
allocate into user space and leaving them. Things like textures and
render buffers will get mmapped if there are any software fallbacks.
Other objects, like vertex buffers, will almost always end up mapped.

One of our explicit design goals was to make sure user space couldn't
ever pin arbitrary amounts of memory; I'd hate to go back on that as it
seems like an important property for any subsystem designed to support
regular user applications in a general purpose desktop environment. I
don't want to trust user space to do the right thing, I want to enforce
that from kernel space.

--=20
keith.packard@intel.com

--=-qB69KT6kU4LYvg5BL+O+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBI2udWQp8BWwlsTdMRAqbzAJ4vNXC0Qsrl75bmWCZ2aJDpkULUIQCgkkKr
UoFa/ki728jkSWvnzxg5Gik=
=NF/g
-----END PGP SIGNATURE-----

--=-qB69KT6kU4LYvg5BL+O+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
