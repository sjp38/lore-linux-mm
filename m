Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 61A7B6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 20:10:53 -0400 (EDT)
Date: Mon, 2 Jul 2012 20:10:51 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 00/12] Swap-over-NFS without deadlocking V8
Message-ID: <20120703001051.GA5508@mgebm.net>
References: <1340976805-5799-1-git-send-email-mgorman@suse.de>
 <20120701172254.GB2470@mgebm.net>
 <20120702143556.GT14154@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ReaqsoxgOBHFXBhH"
Content-Disposition: inline
In-Reply-To: <20120702143556.GT14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 02 Jul 2012, Mel Gorman wrote:

> On Sun, Jul 01, 2012 at 01:22:54PM -0400, Eric B Munson wrote:
> > On Fri, 29 Jun 2012, Mel Gorman wrote:
> >=20
> > > Changelog since V7
> > >   o Rebase to linux-next 20120629
> > >   o bi->page_dma instead of bi->page in intel driver
> > >   o Build fix for !CONFIG_NET					(sebastian)
> > >   o Restore PF_MEMALLOC flags correctly in all cases		(jlayton)
> > >=20
> > > Changelog since V6
> > >   o Rebase to linux-next 20120622
> > >=20
> > > Changelog since V5
> > >   o Rebase to v3.5-rc3
> > >=20
> > > Changelog since V4
> > >   o Catch if SOCK_MEMALLOC flag is cleared with rmem tokens	(davem)
> > >=20
> > > Changelog since V3
> > >   o Rebase to 3.4-rc5
> > >   o kmap pages for writing to swap				(akpm)
> > >   o Move forward declaration to reduce chance of duplication	(akpm)
> > >=20
> > > Changelog since V2
> > >   o Nothing significant, just rebases. A radix tree lookup is replace=
d with
> > >     a linear search would be the biggest rebase artifact
> > >=20
> > > This patch series is based on top of "Swap-over-NBD without deadlocki=
ng v14"
> > > as it depends on the same reservation of PF_MEMALLOC reserves logic.
> > >=20
> > > When a user or administrator requires swap for their application, they
> > > create a swap partition and file, format it with mkswap and activate =
it with
> > > swapon. In diskless systems this is not an option so if swap if requi=
red
> > > then swapping over the network is considered.  The two likely scenari=
os
> > > are when blade servers are used as part of a cluster where the form f=
actor
> > > or maintenance costs do not allow the use of disks and thin clients.
> > >=20
> > > The Linux Terminal Server Project recommends the use of the Network
> > > Block Device (NBD) for swap but this is not always an option.  There =
is
> > > no guarantee that the network attached storage (NAS) device is running
> > > Linux or supports NBD. However, it is likely that it supports NFS so =
there
> > > are users that want support for swapping over NFS despite any perform=
ance
> > > concern. Some distributions currently carry patches that support swap=
ping
> > > over NFS but it would be preferable to support it in the mainline ker=
nel.
> > >=20
> > > Patch 1 avoids a stream-specific deadlock that potentially affects TC=
P.
> > >=20
> > > Patch 2 is a small modification to SELinux to avoid using PFMEMALLOC
> > > 	reserves.
> > >=20
> > > Patch 3 adds three helpers for filesystems to handle swap cache pages.
> > > 	For example, page_file_mapping() returns page->mapping for
> > > 	file-backed pages and the address_space of the underlying
> > > 	swap file for swap cache pages.
> > >=20
> > > Patch 4 adds two address_space_operations to allow a filesystem
> > > 	to pin all metadata relevant to a swapfile in memory. Upon
> > > 	successful activation, the swapfile is marked SWP_FILE and
> > > 	the address space operation ->direct_IO is used for writing
> > > 	and ->readpage for reading in swap pages.
> > >=20
> > > Patch 5 notes that patch 3 is bolting
> > > 	filesystem-specific-swapfile-support onto the side and that
> > > 	the default handlers have different information to what
> > > 	is available to the filesystem. This patch refactors the
> > > 	code so that there are generic handlers for each of the new
> > > 	address_space operations.
> > >=20
> > > Patch 6 adds an API to allow a vector of kernel addresses to be
> > > 	translated to struct pages and pinned for IO.
> > >=20
> > > Patch 7 adds support for using highmem pages for swap by kmapping
> > > 	the pages before calling the direct_IO handler.
> > >=20
> > > Patch 8 updates NFS to use the helpers from patch 3 where necessary.
> > >=20
> > > Patch 9 avoids setting PF_private on PG_swapcache pages within NFS.
> > >=20
> > > Patch 10 implements the new swapfile-related address_space operations
> > > 	for NFS and teaches the direct IO handler how to manage
> > > 	kernel addresses.
> > >=20
> > > Patch 11 prevents page allocator recursions in NFS by using GFP_NOIO
> > > 	where appropriate.
> > >=20
> > > Patch 12 fixes a NULL pointer dereference that occurs when using
> > > 	swap-over-NFS.
> > >=20
> > > With the patches applied, it is possible to mount a swapfile that is =
on an
> > > NFS filesystem. Swap performance is not great with a swap stress test=
 taking
> > > roughly twice as long to complete than if the swap device was backed =
by NBD.
> >=20
> > To test this set I am using memory cgroups to force swap usage.  I am s=
eeing
> > the cgroup controller killing my processes instead of using the nfs swa=
pfile.
> >=20
>=20
> How sure are you that this is not a cgroup bug? For dirty file data on so=
me
> kernels, cgroups can prematurely kill processes if pages are not being
> cleaned fast enough. I would not expect the same problem for anonymous
> pages but it's worth considering. Please also test with a normal swapfile.
>=20
> If OOM is disabled and the process hangs, try capturing a sysrq+t and
> see where the process is stuck.
>=20

It looks like the problem is with cgroups, when I run without cgroups and l=
imit
memory on the boot command line everything works fine.  To test I limited t=
he
machine to 1G of ram then ran several memory benchmarks with work set sizes=
 of
1.5G, all completed successfully with my swap file located on an NFS share.

Tested-by: Eric B Munson <emunson@mgebm.net>

--ReaqsoxgOBHFXBhH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJP8jiLAAoJEH65iIruGRnNH5MIAIUzripnqPwPKbTI/GQLicbh
EgKVK+9r8lSKmrYWFfvVP+mqBV1udMV69SnsFCAmOXzCmP94kxT8oWdaRg/Rto0r
qVNtR6K/pTIIlSqOBRGxG5k+6iUBDxRuBIqPEm27hH0s18oCc7hauokpceTo5bFh
YDGSR3cTZK44j6QapunkDmk6+zlwr6iIc/OuAQDEo06Oij0c9fZcyyvwFHo0WbBR
EqNSmp/HqLqbc3PLyX3yCq6GIS8zkSlgPGpMGgmMqjqNPcAdGVzrSHVly6EhSh2v
Xvl0BqsC2MVgsfxLvyu2PWs7g14rAHGPq0r3zCf78H4wiZIhwoGNyngG+Puzd0Y=
=6W1z
-----END PGP SIGNATURE-----

--ReaqsoxgOBHFXBhH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
