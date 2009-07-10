Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A7A436B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 10:58:45 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d693761e-2f2b-4d8c-ae4f-7f22479f6c0f@default>
Date: Fri, 10 Jul 2009 08:23:07 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
In-Reply-To: <4A567E3B.90609@codemonkey.ws>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > But IMHO this is a corollary of the fundamental difference.  CMM2's
> > is more the "VMware" approach which is that OS's should never have
> > to be modified to run in a virtual environment.  (Oh, but maybe
> > modified just slightly to make the hypervisor a little less
> > clueless about the OS's resource utilization.)
>=20
> While I always enjoy a good holy war, I'd like to avoid one=20
> here because=20
> I want to stay on the topic at hand.

Oops, sorry, I guess that was a bit inflammatory.  What I meant to
say is that inferring resource utilization efficiency is a very
hard problem and VMware (and I'm sure IBM too) has done a fine job
with it; CMM2 explicitly provides some very useful information from
within the OS to the hypervisor so that it doesn't have to infer
that information; but tmem is trying to go a step further by making
the cooperation between the OS and hypervisor more explicit
and directly beneficial to the OS.

> If there was one change to tmem that would make it more=20
> palatable, for=20
> me it would be changing the way pools are "allocated".  Instead of=20
> getting an opaque handle from the hypervisor, I would force=20
> the guest to=20
> allocate it's own memory and to tell the hypervisor that it's a tmem=20
> pool.

An interesting idea but one of the nice advantages of tmem being
completely external to the OS is that the tmem pool may be much
larger than the total memory available to the OS.  As an extreme
example, assume you have one 1GB guest on a physical machine that
has 64GB physical RAM.  The guest now has 1GB of directly-addressable
memory and 63GB of indirectly-addressable memory through tmem.
That 63GB requires no page structs or other data structures in the
guest.  And in the current (external) implementation, the size
of each pool is constantly changing, sometimes dramatically so
the guest would have to be prepared to handle this.  I also wonder
if this would make shared-tmem-pools more difficult.

I can see how it might be useful for KVM though.  Once the
core API and all the hooks are in place, a KVM implementation of
tmem could attempt something like this.

> The big advantage of keeping the tmem pool part of the normal set of=20
> guest memory is that you don't introduce new challenges with=20
> respect to memory accounting.  Whether or not tmem is directly=20
> accessible from the guest, it is another memory resource.  I'm
> certain that you'll want to do accounting of how much tmem is being
> consumed by each guest

Yes, the Xen implementation of tmem does accounting on a per-pool
and a per-guest basis and exposes the data via a privileged
"tmem control" hypercall.

> and I strongly suspect that you'll want to do tmem accounting on a=20
> per-process=20
> basis.  I also suspect that doing tmem limiting for things=20
> like cgroups would be desirable.

This can be done now if each process or cgroup creates a different
tmem pool.  The proposed patch doesn't do this, but it certainly
seems possible.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
