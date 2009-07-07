Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACF06B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 15:51:07 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <92d23660-c8a3-4107-aee6-ec251ff65b99@default>
Date: Tue, 7 Jul 2009 12:53:06 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
In-Reply-To: <4A5385AD.9000800@redhat.com>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> From: Rik van Riel [mailto:riel@redhat.com]

> Dan Magenheimer wrote:
> > "Preswap" IS persistent, but for various reasons may not always be
> > available for use, again due to factors that may not be=20
> visible to the
> > kernel (but, briefly, if the kernel is being "good" and has=20
> shared its
> > resources nicely, then it will be able to use preswap, else=20
> it will not).
> > Once a page is put, a get on the page will always succeed.=20
>=20
> What happens when all of the free memory on a system
> has been consumed by preswap by a few guests?
> Will the system be unable to start another guest,

The default policy (and only policy implemented as of now) is
that no guest is allowed to use more than max_mem for the
sum of directly-addressable memory (e.g. RAM) and persistent
tmem (e.g. preswap).  So if a guest is using its default
memory=3D=3Dmax_mem and is doing no ballooning, nothing can
be put in preswap by that guest.
=20
> or is there some way to free the preswap memory?

Yes and no.  There is no way externally to free preswap
memory, but an in-guest userland root service can write to sysfs
to affect preswap size.  This essentially does a partial
swapoff on preswap if there is sufficient (directly addressable)
guest RAM available.  (I have this prototyped as part of
the xenballoond self-ballooning service in xen-unstable.)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
