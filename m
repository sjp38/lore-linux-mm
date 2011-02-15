Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A8EA98D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 11:55:18 -0500 (EST)
Received: by qwa26 with SMTP id 26so280133qwa.14
        for <linux-mm@kvack.org>; Tue, 15 Feb 2011 08:55:16 -0800 (PST)
Date: Tue, 15 Feb 2011 11:55:10 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 0/5] fix up /proc/$pid/smaps to not split huge pages
Message-ID: <20110215165510.GA2550@mgebm.net>
References: <20110209195406.B9F23C9F@kernel>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Content-Disposition: inline
In-Reply-To: <20110209195406.B9F23C9F@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 09 Feb 2011, Dave Hansen wrote:

> Andrea, after playing with this for a week or two, I'm quite a bit
> more confident that it's not causing much harm.  Seems a fairly
> low-risk feature.  Could we stick these somewhere so they'll at
> least hit linux-next for the 2.6.40 cycle perhaps?
>=20
> --
>=20
> I'm working on some more reports that transparent huge pages and
> KSM do not play nicely together.  Basically, whenever THP's are
> present along with KSM, there is a lot of attrition over time,
> and we do not see much overall progress keeping THP's around:
>=20
> 	http://sr71.net/~dave/ibm/038_System_Anonymous_Pages.png
>=20
> (That's Karl Rister's graph, thanks Karl!)
>=20
> However, I realized that we do not currently have a nice way to
> find out where individual THP's might be on the system.  We
> have an overall count, but no way of telling which processes or
> VMAs they might be in.
>=20
> I started to implement this in the /proc/$pid/smaps code, but
> quickly realized that the lib/pagewalk.c code unconditionally
> splits THPs up.  This set reworks that code a bit and, in the
> end, gives you a per-map count of the numbers of huge pages.
> It also makes it possible for page walks to _not_ split THPs.
>=20

I have been running these patches on top of 2.6.38-rc4 all
morning and looked at a number of smaps files for processes
using THP areas.  They don't seem to be pulled apart as my
AnonHugePages: counter in meminfo is stable.

I am noticing in smaps that KernelPageSize is wrong of areas
that have been merged into THP.  For instance:

7ff852a00000-7ff852c00000 rw-p 00000000 00:00 0=20
Size:               2048 kB
Rss:                2048 kB
Pss:                2048 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:      2048 kB
Referenced:         2048 kB
Anonymous:          2048 kB
AnonHugePages:      2048 kB
Swap:                  0 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB
Locked:                0 kB

The entire mapping is contained in a THP but the
KernelPageSize shows 4kb.  For cases where the mapping might
have mixed page sizes this may be okay, but for this
particular mapping the 4kb page size is wrong.

Tested-by: Eric B Munson <emunson@mgebm.net>

--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNWq/uAAoJEH65iIruGRnNiEQH/1t8WlbMPXxK4G8HmgHhQiSj
MominANJ7iDW9OmeV8xuL1rEwB3BoQeyhhs1QUm0FkBS3yEzvId9khIc+SwG+2nd
D8m8edWLz7riQxsMc938EEhCPCWgqmCP0iQRIzs7HHToH1PEupxrM2i9o9vvQ+xb
ZjuINAolRykXkGqMWhWAAGCl29id/NW06xiKy9ddxPtWv4qaHBeKh5McwickI78x
sB3Eps2hlrT1JzkLpoQWZ+dDaZ5gfvuLPZoE8R5Kv79Z+Rzm3zE2iCDiPkUNaaS8
XlX2tuT4Q/czI4gbaHo3B5r8rmn3GS/fBIg/g0OrqXIRFDkrTu2zyHdUAegwTnw=
=l1un
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
