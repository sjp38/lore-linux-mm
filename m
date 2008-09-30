Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
From: Eric Anholt <eric@anholt.net>
In-Reply-To: <20080923091017.GB29718@wotan.suse.de>
References: <20080923091017.GB29718@wotan.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Kmgad1jb77/jvWd9ZI7N"
Date: Mon, 29 Sep 2008 18:10:05 -0700
Message-Id: <1222737005.21655.61.camel@vonnegut.anholt.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: keith.packard@intel.com, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-Kmgad1jb77/jvWd9ZI7N
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-09-23 at 11:10 +0200, Nick Piggin wrote:
> Hi,
>=20
> So I promised I would look at this again, because I (and others) have som=
e
> issues with exporting shmem_file_setup for DRM-GEM to go off and do thing=
s
> with.
>=20
> The rationale for using shmem seems to be that pageable "objects" are nee=
ded,
> and they can't be created by userspace because that would be ugly for som=
e
> reason, and/or they are required before userland is running.
>=20
> I particularly don't like the idea of exposing these vfs objects to rando=
m
> drivers because they're likely to get things wrong or become out of synch
> or unreviewed if things change. I suggested a simple pageable object allo=
cator
> that could live in mm and hide the exact details of how shmem / pagecache
> works. So I've coded that up quickly.

Hiding the details of shmem and the pagecache sounds pretty good to me
(since we've got it wrong at least twice so far).  Hopefully the result
isn't even more fragile code on our part.

> Upon actually looking at how "GEM" makes use of its shmem_file_setup filp=
, I
> see something strange... it seems that userspace actually gets some kind =
of
> descriptor, a descriptor to an object backed by this shmem file (let's ca=
ll it
> a "file descriptor"). Anyway, it turns out that userspace sometimes needs=
 to
> pread, pwrite, and mmap these objects, but unfortunately it has no direct=
 way
> to do that, due to not having open(2)ed the files directly. So what GEM d=
oes
> is to add some ioctls which take the "file descriptor" things, and derive=
s
> the shmem file from them, and then calls into the vfs to perform the oper=
ation.
>=20
> If my cursory reading is correct, then my allocator won't work so well as=
 a
> drop in replacement because one isn't allowed to know about the filp behi=
nd
> the pageable object. It would also indicate some serious crack smoking by
> anyone who thinks open(2), pread(2), mmap(2), etc is ugly in comparison..=
.

I think the explanation for this got covered in other parts of the
thread, but drm_gem.c comments at the top also cover it.

> So please, nobody who worked on that code is allowed to use ugly as an
> argument. Technical arguments are fine, so let's try to cover them.
>=20
> BTW. without knowing much of either the GEM or the SPU subsystems, the
> GEM problem seems similar to SPU. Did anyone look at that code? Was it ev=
er
> considered to make the object allocator be a filesystem? That way you cou=
ld
> control the backing store to the objects yourself, those that want pageab=
le
> memory could use the following allocator, the ioctls could go away,
> you could create your own objects if needed before userspace is up...

Yes, we definitely considered a filesystem (it would be nice for
debugging to be able to look at object contents from a debugger process
\easily).  However, once we realized that fds just wouldn't work (we're
allocating objects in a library, so we couldn't just dup2 them up high,
and we couldn't rely on being able to up the open file limit for the
process), shmem seemed to already be exactly what we wanted, and we
assumed that whatever future API changes in the couple of VFS and
pagecache calls we made would be easier to track than duplicating all of
shmem.c into our driver.

I'm porting our stuff to test on your API now, and everything looks
straightforward except for mmap.  For that I seem to have three options:

1) Implement a range allocator on the DRM device and have a hashtable of
ranges to objects, then have a GEM hook in the mmap handler of the drm
device when we find we're in one of those ranges.

This was the path that TTM took.  Since we have different paths to
mmapping objects (direct backing store access, or aperture access,
though the second isn't in my tree yet), it means we end up having
multiple offsets to represent different mmap types, or multiplying the
size of the range and having the top half of the range mean the other
mmap type.

2) Create a kernel-internal filesystem and get struct files for the
objects.

This is the method that seemed like the right thing to do in the linux
style, so I've been trying to figure that part out.  I've been assured
that libfs makes my job easy here, but as I look at it I'm less sure.
The sticking point to me is how the page list I get from your API ends
up getting used by simple_file_* and generic_file_*.  And, in the future
where the pageable memory allocator is actually pageable while mmapped,
what does the API I get to consume look like, roughly?

3) Use shmem_file_setup()

This was what we originally went with.  It got messy when we wanted a
different mmap path, so that we had to do one of 1) or 2) anyway.

Also, I'm looking at a bunch of spu*.c code, and I'm having a hard time
finding something relevant for us, but maybe I'm not looking in the
right place.  Can you elaborate on that comment?

--=20
Eric Anholt
eric@anholt.net                         eric.anholt@intel.com



--=-Kmgad1jb77/jvWd9ZI7N
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEUEABECAAYFAkjhfGwACgkQHUdvYGzw6vd9JACY5RR3xKpIbPINc3tqPzMNn2ey
SwCeKFkw89FJ1xmlu1OCn4PooBl2LNw=
=eof9
-----END PGP SIGNATURE-----

--=-Kmgad1jb77/jvWd9ZI7N--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
