Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
From: Keith Packard <keithp@keithp.com>
In-Reply-To: <20080923091017.GB29718@wotan.suse.de>
References: <20080923091017.GB29718@wotan.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Wi7jWSAPPNQq53uke8P2"
Date: Tue, 23 Sep 2008 08:50:29 -0700
Message-Id: <1222185029.4873.157.camel@koto.keithp.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: keithp@keithp.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-Wi7jWSAPPNQq53uke8P2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-09-23 at 11:10 +0200, Nick Piggin wrote:

> So I promised I would look at this again, because I (and others) have som=
e
> issues with exporting shmem_file_setup for DRM-GEM to go off and do thing=
s
> with.

Thanks for looking at this again.

> The rationale for using shmem seems to be that pageable "objects" are nee=
ded,
> and they can't be created by userspace because that would be ugly for som=
e
> reason, and/or they are required before userland is running.

Right, creating them from user space was just a mild inconvenience as
we'd have to come up with suitable names. The semantics don't match
exactly as most of the time we never need the filename later, but some
objects will be referenced later on so we'd need to be able to come up
with a persistent name at that point.

The real issue is that we need to create objects early in the kernel
initialization sequence to provide storage for the console frame buffer,
long before user space starts up. Lacking this, we wouldn't be able to
present early kernel initialization messages to the user.

> I particularly don't like the idea of exposing these vfs objects to rando=
m
> drivers because they're likely to get things wrong or become out of synch
> or unreviewed if things change. I suggested a simple pageable object allo=
cator
> that could live in mm and hide the exact details of how shmem / pagecache
> works. So I've coded that up quickly.

Thanks for trying another direction; let's see if that will work for us.

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

Sure, we've looked at using regular file descriptors for these objects
and it almost works, except for a few things:

 1) We create a lot of these objects. The X server itself may have tens
    of thousands of objects in use at any one time (my current session
    with gitk and firefox running is using 1565 objects). Right now, the
    maximum number of fds supported by 'normal' kernel configurations
    is somewhat smaller than this. Even when the kernel is fixed to
    support lifting this limit, we'll be at the mercy of existing user
    space configurations for normal applications.

 2) More annoyingly, applications which use these objects also use
    select(2) and depend on being able to represent the 'real' file
    descriptors in a compact space near zero. Sticking a few thousand
    of these new objects into the system would require some ability to
    relocate the descriptors up higher in fd space. This could also
    be done in user space using dup2, but that would require managing
    file descriptor allocation in user space.

 3) The pread/pwrite/mmap functions that we use need additional flags
    to indicate some level of application 'intent'. In particular, we
    need to know whether the data is being delivered only to the GPU
    or whether the CPU will need to look at it in the future. This
    drives the kind of memory access used within the kernel and has
    a significant performance impact.

If (when?) we can figure out solutions to these issues, we'd love to
revisit the descriptor allocation plan.

> If my cursory reading is correct, then my allocator won't work so well as=
 a
> drop in replacement because one isn't allowed to know about the filp behi=
nd
> the pageable object. It would also indicate some serious crack smoking by
> anyone who thinks open(2), pread(2), mmap(2), etc is ugly in comparison..=
.

Yes, we'd like to be able to use regular system calls for our API, right
now we haven't figured out how to do that.

> So please, nobody who worked on that code is allowed to use ugly as an
> argument. Technical arguments are fine, so let's try to cover them.

I think we're looking for a mechanism that we know how to use and which
will allow us to provide compatibility with user space going forward.
Hiding the precise semantics of the object storage behind our
ioctl-based API means that we can completely replace in the future
without affecting user space.

> BTW. without knowing much of either the GEM or the SPU subsystems, the
> GEM problem seems similar to SPU. Did anyone look at that code? Was it ev=
er
> considered to make the object allocator be a filesystem? That way you cou=
ld
> control the backing store to the objects yourself, those that want pageab=
le
> memory could use the following allocator, the ioctls could go away,
> you could create your own objects if needed before userspace is up...

Yes, we've considered doing a separate file system, but as we'd start by
copying shmem directly, we're unsure how that would be received. It
seems like sharing the shmem code in some sensible way is a better plan.

We just need anonymous pages that we can read/write/map to kernel and
user space. Right now, shmem provides that functionality and is used by
two kernel subsystems (sysv IPC and tmpfs). It seems like any new API
should support all three uses rather than being specific to GEM.

> The API allows creation and deletion of memory objects, pinning and
> unpinning of address ranges within an object, mapping ranges of an object
> in KVA, dirtying ranges of an object, and operating on pages within the
> object.

The only question I have is whether we can map these objects to user
space; the other operations we need are fairly easily managed by just
looking at objects one page at a time. Of course, getting to the 'fast'
memcpy variants that the current vfs_write path finds may be a trick,
but we should be able to figure that out.

--=20
keith.packard@intel.com

--=-Wi7jWSAPPNQq53uke8P2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBI2RBFQp8BWwlsTdMRAqi7AKCEJi5iZmYfQqX2gq87TfdR9wQmgQCfV4vG
8EBhW0I/MV9+Pu4ESE1Cgyo=
=8FP6
-----END PGP SIGNATURE-----

--=-Wi7jWSAPPNQq53uke8P2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
