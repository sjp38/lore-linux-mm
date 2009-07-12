Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D7CC76B005D
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 16:42:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <675faabd-bc61-46ed-af91-d7b4d7db8d14@default>
Date: Sun, 12 Jul 2009 13:59:08 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
In-Reply-To: <4A5A1D15.1090809@redhat.com>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


> > anonymous memory.  That larger scale "memory shaping" is left to
> > ballooning and hotplug.
>=20
> And this is where the policy problems erupt.  When do you balloon in=20
> favor of tmem?  which guest do you balloon? do you leave it to the=20
> administrator? there's the host's administrator and the guests'=20
> administrators.
> :
> CMM2 solves this neatly by providing information to the host.=20

As with CMM2, ballooning is for larger scale memory shaping.
Tmem provides a safety valve if the shaping is too aggressive
(and thus encourages more aggressive ballooning).  So they
are complementary.  Tmem also provides plenty of information
to the host that can be used to fine tune ballooning policy
if desired (and this can be done in userland and/or management
tools).
=20
> > I don't see that it gives up that flexibility.  System adminstrators
> > are still free to size their guests properly.  Tmem's contribution
> > is in environments that are highly dynamic, where the only
> > alternative is really sizing memory maximally (and thus wasting
> > it for the vast majority of time in which the working set=20
> is smaller).
>=20
> I meant that once a page is converted to tmem, there's a=20
> limited amount=20
> of things you can do with it compared to normal memory.  For example=20
> tmem won't help with a dcache intensive workload.

Yes that's true.  But that's part of the point of tmem.  Tmem
isn't just providing benefits to a single guest.  It's
providing "memory liquidity" (Jeremy's term, but I like it)
which benefits the collective of guests on a machine and
across the data center.  For KVM+CMM2, I suppose this might be
less valuable because of the more incestuous relationship
between the host and guests.

> > I'm certainly open to identifying compromises and layer=20
> modifications
> > that help meet the needs of both Xen and KVM (and others).  For
> > example, if we can determine that the basic hook placement for
> > precache/preswap (or even just precache for KVM) can be built
> > on different underlying layers, that would be great!
>=20
> I'm not sure preswap/precache by itself justifies tmem since=20
> it can be=20
> emulated by backing the disk with a cached file.

I don't see that it can... though perhaps it can in the KVM
world.

> What I'm missing in=20
> tmem is the ability for the hypervisor to take a global view=20
> on memory;=20
> instead it's forced to look at memory and tmem separately. =20

Again, I guess I see this as one of the key values of tmem.
Memory *does* have different attributes and calling out the
differences in some cases allows more flexibility to the
whole collective of guests with very little impact to any
one guest.

P.S.  I have to mostly disconnect from this discussion for
a few days except for short replies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
