Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>
	 <200708061559.41680.phillips@phunq.net>
	 <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
	 <200708061649.56487.phillips@phunq.net>
	 <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TSLl3Bk2SZx6A4pimT9Y"
Date: Wed, 08 Aug 2007 09:24:25 +0200
Message-Id: <1186557865.7182.86.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

--=-TSLl3Bk2SZx6A4pimT9Y
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-08-07 at 15:18 -0700, Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Daniel Phillips wrote:
>=20
> > > AFAICT: This patchset is not throttling processes but failing
> > > allocations.
> >=20
> > Failing allocations?  Where do you see that?  As far as I can see,=20
> > Peter's patch set allows allocations to fail exactly where the user has=
=20
> > always specified they may fail, and in no new places.  If there is a=20
> > flaw in that logic, please let us know.
>=20
> See the code added to slub: Allocations are satisfied from the reserve=20
> patch or they are failing.

Allocations are satisfied from the reserve IFF the allocation context is
entitled to the reserve, otherwise it will try to allocate a new slab.
And that is exactly like any other low mem situation, allocations do
fail under pressure, but not more so with this patch.

> > > The patchset does not reconfigure the memory reserves as=20
> > > expected.
> >=20
> > What do you mean by that?  Expected by who?
>=20
> What would be expected it some recalculation of min_freekbytes?

And I have been telling you:

        if (alloc_flags & ALLOC_HIGH)
                min -=3D min / 2;
        if (alloc_flags & ALLOC_HARDER)
                min -=3D min / 4;

so the reserve is 3/8 of min_freekbytes, a fixed limit is required.


> > > Code is added that is supposedly not used.
> >=20
> > What makes you think that?
>=20
> Because the argument is that performance does not matter since the code=20
> patchs are not used.

The argument is that once you hit these code paths, you don't much care
for performance, not the other way around.

> > And I suspect that we =20
> > have the same issues as in earlier releases with various corner cases
> > > not being covered.
> >=20
> > Do you have an example?
>=20
> Try NUMA constraints and zone limitations.

How exactly are these failing, the breaking out of the policy boundaries
in the reserve path is not different from IRQ context allocations not
honouring them.

> > > If it  ever is on a large config then we are in very deep trouble by
> > > the new code paths themselves that serialize things in order to give
> > > some allocations precendence over the other allocations that are made
> > > to fail ....
> >=20
> > You mean by allocating the reserve memory on the wrong node in NUMA? =20
>=20
> No I mean all 1024 processors of our system running into this fail/succee=
d=20
> thingy that was added.

You mean to say, 1024 cpus running into the kmem_cache wide reserve
slab, yeah if that happens that will hurt.

I just instrumented the kernel to find the allocations done under
PF_MEMALLOC for a heavy (non-swapping) reclaim load:

localhost ~ # cat /proc/ip_trace=20
79	[<000000006001c140>] do_ubd_request+0x97/0x176
1	[<000000006006dfef>] allocate_slab+0x44/0x9a
165	[<00000000600e75d7>] new_handle+0x1d/0x47
1	[<00000000600ee897>] __jbd_kmalloc+0x18/0x1a
141	[<00000000600eeb2d>] journal_alloc_journal_head+0x15/0x6f
1	[<0000000060136907>] current_io_context+0x38/0x95
1	[<0000000060139634>] alloc_as_io_context+0x18/0x95

this is from about 15 mins of load-5 trashing file backed reclaim.

So sadly I was mistaken, you will run into it, albeit from the numbers
its not very frequent. (and here I though that path was fully covered
with mempools)

> > That is on a code path that avoids destroying your machine performance=20
> > or killing the machine entirely as with current kernels, for which a=20
>=20
> As far as I know from our systems: The current kernels do not kill the=20
> machine if the reserves are configured the right way.

AFAIK the current kernels do not allow for swap over nfs and a bunch of
other things.

The scenario I'm interested in is (two machines: client [A]/server [B]):

 1) networked machine [A] runs swap-over-net (NFS/iSCSI)
 2) someone trips over the NFS/iSCSI server's [B] ethernet cable
   / someone does /etc/init.d/nfs stop

 3) the machine [A] stops dead in its tracks in the middle of reclaim
 4) the machine [A] keeps on receiving unrelated network traffic for
    whatever other purpose the machine served

   - time passes -

 5) cable gets reconnected / nfs server started [B]
 6) client [A] succeeds with the reconnect and happily continues its
    swapping life.

Between 4-5 it needs to receive and discard an unspecified amount of
network traffic while user-space is basically frozen solid.

FWIW this scenario works here.

> > few cachelines pulled to another node is a small price to pay.  And you=
=20
> > are free to use your special expertise in NUMA to make those fallback=20
> > paths even more efficient, but first you need to understand what they=20
> > are doing and why.
>=20
> There is your problem. The justification is not clear at all and the=20
> solution likely causes unrelated problems.

The situation I'm wanting to avoid is during 3), the machine will slowly
but steadily freeze over as userspace allocations start to block on
outstanding swap-IO.

Since I need a fixed reserve to operate 4), I do not want these slowly
freezing processes to 'accidentally' gobble up slabs allocated from the
reserve for more important matters.

So what the modification to the slab allocator does is:

 - if there is a reserve slab:
   - if the context allows access to the reserves
     - serve object
   - otherwise try to allocate a new slab
     - if this succeeds
       - remove the reserve slab since clearly the pressure is gone
       - serve from the new slab
     - otherwise fail

Now that 'fail'-part scares you, however, note that __GFP_WAIT
allocations will stick in the allocate part for a while, just like
regular low memory situations.


Anyway, I'm in a bit of a mess having proven even file backed reclaim
hits these paths.

 1) I'm reluctant to add #ifdef in core allocation paths
 2) I'm reluctant to add yet another NR_CPUS array to struct kmem_cache

Christoph, does this all explain the situation?

--=-TSLl3Bk2SZx6A4pimT9Y
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGuW+pXA2jU0ANEf4RAjr8AJ0fXKXZKUWLVAQmCBNLul6W5nG60gCeMwM5
IH2kZ86iHFjkNuHmxpAldWA=
=tEdO
-----END PGP SIGNATURE-----

--=-TSLl3Bk2SZx6A4pimT9Y--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
