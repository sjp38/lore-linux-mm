Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0709121540370.4067@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>
	 <200709050220.53801.phillips@phunq.net>
	 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
	 <20070905114242.GA19938@wotan.suse.de>
	 <Pine.LNX.4.64.0709050507050.9141@schroedinger.engr.sgi.com>
	 <1189594373.21778.114.camel@twins>
	 <Pine.LNX.4.64.0709121540370.4067@schroedinger.engr.sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oIcS5OoZ2KDnbyFjKL+l"
Date: Thu, 13 Sep 2007 10:19:12 +0200
Message-Id: <1189671552.21778.158.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

--=-oIcS5OoZ2KDnbyFjKL+l
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-09-12 at 15:47 -0700, Christoph Lameter wrote:
> On Wed, 12 Sep 2007, Peter Zijlstra wrote:
>=20
> > > assumes single critical user of memory. There are other consumers of=20
> > > memory and if you have a load that depends on other things than netwo=
rking=20
> > > then you should not kill the other things that want memory.
> >=20
> > The VM is a _critical_ user of memory. And I dare say it is the _most_
> > important user.=20
>=20
> The users of memory are various subsystems. The VM itself of course also=20
> uses memory to manage memory but the important thing is that the VM=20
> provides services to other subsystems

Exactly, and because it services every other subsystem and userspace,
its the most important one, if it doesn't work, nothing else will.

> > Every user of memory relies on the VM, and we only get into trouble if
> > the VM in turn relies on one of these users. Traditionally that has onl=
y
> > been the block layer, and we special cased that using mempools and
> > PF_MEMALLOC.
> >=20
> > Why do you object to me doing a similar thing for networking?
>=20
> I have not seen you using mempools for the networking layer. I would not=20
> object to such a solution. It already exists for other subsystems.

Dude, listen, how often do I have to say this: I cannot use mempools for
the network subsystem because its build on kmalloc! What I've done is
build a replacement for mempools - a reserve system - that does work
similar to mempools but also provides the flexibility of kmalloc.

That is all, no more, no less.

> > The problem of circular dependancies on and with the VM is rather
> > limited to kernel IO subsystems, and we only have a limited amount of
> > them.=20
>=20
> The kernel has to use the filesystems and other subsystems for I/O. These=
=20
> subsystems compete for memory in order to make progress. I would not=20
> consider strictly them part of the VM. The kernel reclaim may trigger I/O=
=20
> in multiple I/O subsystems simultaneously.

I'm confused by this, I've never claimed part of, or such a thing. All
I'm saying is that because of the circular dependency between the VM and
the IO subsystem used for swap (not file backed paging [*], just swap)
you have to do something special to avoid deadlocks.

[*] the dirty limit along with 'atomic' swap ensures that file backed
paging does not get into this tight spot.

> > You talk about something generic, do you mean an approach that is
> > generic across all these subsystems?
>=20
> Yes an approach that is fair and does not allow one single subsystem to=20
> hog all of memory.

I do no such thing! My reserve system works much like mempools, you
reserve a certain amount of pages and use no more.

> > If so, my approach would be it, I can replace mempools as we have them
> > with the reserve system I introduce.
>=20
> Replacing the mempools for the block layer sounds pretty good. But how do=
=20
> these various subsystems that may live in different portions of the syste=
m=20
> for various devices avoid global serialization and livelock through your=20
> system?=20

The reserves are spread over all kernel mapped zones, the slab allocator
is still per cpu, the page allocator tries to get pages from the nearest
node.

> And how is fairness addresses? I may want to run a fileserver on=20
> some nodes and a HPC application that relies on a fiberchannel connection=
=20
> on other nodes. How do we guarantee that the HPC application is not=20
> impacted if the network services of the fileserver flood the system with=20
> messages and exhaust memory?

The network system reserves A pages, the block layer reserves B pages,
once they start getting pages from the reserves they go bean counting,
once they reach their respective limit they stop.

The serialisation impact of the bean counting depends on how
fine-grained you place them, currently I only have a machine wide
network bean counter because the network subsystem is machine wide -
initially I tried to do something per net-device but that doesn't work
out. If someone more skilled in this area comes along and sees a better
way to place the bean counters they are free to do so.

But do notice that the bean counting is only done once we hit the
reserves, the normal mode of operation is not penalised by the extra
overhead thereof.

Also note that mempools also serialise their access once the backing
allocator fails, so I don't differ from them in that respect either.


--=-oIcS5OoZ2KDnbyFjKL+l
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG6PKAXA2jU0ANEf4RAq9FAJsF2vaDMgEDvpFvBlzDnAPanCNtGwCdFXRT
EM6Zs4YnikuU2BYr+v0c4KI=
=Gngz
-----END PGP SIGNATURE-----

--=-oIcS5OoZ2KDnbyFjKL+l--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
