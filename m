Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DA7156B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 12:13:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <426e84ca-be31-40ac-a4c1-42cd9677d86c@default>
Date: Sun, 12 Jul 2009 09:28:38 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
In-Reply-To: <4A59AAF1.1030102@redhat.com>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > That 63GB requires no page structs or other data structures in the
> > guest.  And in the current (external) implementation, the size
> > of each pool is constantly changing, sometimes dramatically so
> > the guest would have to be prepared to handle this.  I also wonder
> > if this would make shared-tmem-pools more difficult. =20
>=20
> Having no struct pages is also a downside; for example this=20
> guest cannot=20
> have more than 1GB of anonymous memory without swapping like mad. =20
> Swapping to tmem is fast but still a lot slower than having=20
> the memory=20
> available.

Yes, true.  Tmem offers little additional advantage for workloads
that have a huge variation in working set size that is primarily
anonymous memory.  That larger scale "memory shaping" is left to
ballooning and hotplug.

> tmem makes life a lot easier to the hypervisor and to the guest, but=20
> also gives up a lot of flexibility.  There's a difference=20
> between memory=20
> and a very fast synchronous backing store.

I don't see that it gives up that flexibility.  System adminstrators
are still free to size their guests properly.  Tmem's contribution
is in environments that are highly dynamic, where the only
alternative is really sizing memory maximally (and thus wasting
it for the vast majority of time in which the working set is smaller).

> > I can see how it might be useful for KVM though.  Once the
> > core API and all the hooks are in place, a KVM implementation of
> > tmem could attempt something like this.
> >   =20
>=20
> My worry is that tmem for kvm leaves a lot of niftiness on the table,=20
> since it was designed for a hypervisor with much simpler memory=20
> management.  kvm can already use spare memory for backing guest swap,=20
> and can already convert unused guest memory to free memory=20
> (by swapping=20
> it).  tmem doesn't really integrate well with these capabilities.

I'm certainly open to identifying compromises and layer modifications
that help meet the needs of both Xen and KVM (and others).  For
example, if we can determine that the basic hook placement for
precache/preswap (or even just precache for KVM) can be built
on different underlying layers, that would be great!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
