Date: Fri, 27 Oct 2006 10:28:34 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 2/3] Create compat_sys_migrate_pages
Message-Id: <20061027102834.5db261af.sfr@canb.auug.org.au>
In-Reply-To: <Pine.LNX.4.64.0610261158130.2802@schroedinger.engr.sgi.com>
References: <20061026132659.2ff90dd1.sfr@canb.auug.org.au>
	<20061026133305.b0db54e6.sfr@canb.auug.org.au>
	<Pine.LNX.4.64.0610261158130.2802@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__27_Oct_2006_10_28_34_+1000_=/0fdBc0o0p1Ku9J"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: LKML <linux-kernel@vger.kernel.org>, ppc-dev <linuxppc-dev@ozlabs.org>, paulus@samba.org, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Signature=_Fri__27_Oct_2006_10_28_34_+1000_=/0fdBc0o0p1Ku9J
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Thu, 26 Oct 2006 12:00:30 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
>
> On Thu, 26 Oct 2006, Stephen Rothwell wrote:
>
> > This is needed on bigendian 64bit architectures. The obvious way to do
> > this (taking the other compat_ routines in this file as examples) is to
> > use compat_alloc_user_space and copy the bitmasks back there, however you
> > cannot call compat_alloc_user_space twice for a single system call and
> > this method saves two copies of the bitmasks.
>
> Well this means also that sys_mbind and sys_set_mempolicy are also
> broken because these functions also use get_nodes().

No they aren't because they have compat routines that convert the bitmaps
before calling the "normal" syscall.  They, importantly, only use
compat_alloc_user_space once each.

> Fixing get_nodes() to do the proper thing would fix all of these
> without having to touch sys_migrate_pages or creating a compat_ function
> (which usually is placed in kernel/compat.c)

You need the compat_ version of the syscalls to know if you were called
from a 32bit application in order to know if you may need to fixup the
bitmaps that are passed from/to user mode.

--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__27_Oct_2006_10_28_34_+1000_=/0fdBc0o0p1Ku9J
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFQVK3FdBgD/zoJvwRApyiAJ9bErnB/elH+cfVrgRfzDqE8JqcsQCfbE3K
kO4zt/MP8zf3yO2rBQ/L1Eg=
=gkUC
-----END PGP SIGNATURE-----

--Signature=_Fri__27_Oct_2006_10_28_34_+1000_=/0fdBc0o0p1Ku9J--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
