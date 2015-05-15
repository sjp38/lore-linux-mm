Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2AD6B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 11:35:52 -0400 (EDT)
Received: by pdea3 with SMTP id a3so13993171pde.2
        for <linux-mm@kvack.org>; Fri, 15 May 2015 08:35:52 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id ix6si3111022pac.46.2015.05.15.08.35.51
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 08:35:51 -0700 (PDT)
Date: Fri, 15 May 2015 11:35:50 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH 0/3] Allow user to request memory to be locked on page
 fault
Message-ID: <20150515153550.GA2454@akamai.com>
References: <1431113626-19153-1-git-send-email-emunson@akamai.com>
 <20150508124203.6679b1d35ad9555425003929@linux-foundation.org>
 <20150511180631.GA1227@akamai.com>
 <20150513150036.GG1227@akamai.com>
 <20150514080812.GC6433@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Content-Disposition: inline
In-Reply-To: <20150514080812.GC6433@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 14 May 2015, Michal Hocko wrote:

> On Wed 13-05-15 11:00:36, Eric B Munson wrote:
> > On Mon, 11 May 2015, Eric B Munson wrote:
> >=20
> > > On Fri, 08 May 2015, Andrew Morton wrote:
> > >=20
> > > > On Fri,  8 May 2015 15:33:43 -0400 Eric B Munson <emunson@akamai.co=
m> wrote:
> > > >=20
> > > > > mlock() allows a user to control page out of program memory, but =
this
> > > > > comes at the cost of faulting in the entire mapping when it is
> > > > > allocated.  For large mappings where the entire area is not neces=
sary
> > > > > this is not ideal.
> > > > >=20
> > > > > This series introduces new flags for mmap() and mlockall() that a=
llow a
> > > > > user to specify that the covered are should not be paged out, but=
 only
> > > > > after the memory has been used the first time.
> > > >=20
> > > > Please tell us much much more about the value of these changes: the=
 use
> > > > cases, the behavioural improvements and performance results which t=
he
> > > > patchset brings to those use cases, etc.
> > > >=20
> > >=20
> > > To illustrate the proposed use case I wrote a quick program that mmaps
> > > a 5GB file which is filled with random data and accesses 150,000 pages
> > > from that mapping.  Setup and processing were timed separately to
> > > illustrate the differences between the three tested approaches.  the
> > > setup portion is simply the call to mmap, the processing is the
> > > accessing of the various locations in  that mapping.  The following
> > > values are in milliseconds and are the averages of 20 runs each with a
> > > call to echo 3 > /proc/sys/vm/drop_caches between each run.
> > >=20
> > > The first mapping was made with MAP_PRIVATE | MAP_LOCKED as a baselin=
e:
> > > Startup average:    9476.506
> > > Processing average: 3.573
> > >=20
> > > The second mapping was simply MAP_PRIVATE but each page was passed to
> > > mlock() before being read:
> > > Startup average:    0.051
> > > Processing average: 721.859
> > >=20
> > > The final mapping was MAP_PRIVATE | MAP_LOCKONFAULT:
> > > Startup average:    0.084
> > > Processing average: 42.125
> > >=20
> >=20
> > Michal's suggestion of changing protections and locking in a signal
> > handler was better than the locking as needed, but still significantly
> > more work required than the LOCKONFAULT case.
> >=20
> > Startup average:    0.047
> > Processing average: 86.431
>=20
> Have you played with batching? Has it helped? Anyway it is to be
> expected that the overhead will be higher than a single mmap call. The
> question is whether you can live with it because adding a new semantic
> to mlock sounds trickier and MAP_LOCKED is tricky enough already...
>=20

I reworked the experiment to better cover the batching solution.  The
same 5GB data file is used, however instead of 150,000 accesses at
regular intervals, the test program now does 15,000,000 accesses to
random pages in the mapping.  The rest of the setup remains the same.

mmap with MAP_LOCKED:
Setup avg:      11821.193
Processing avg: 3404.286

mmap with mlock() before each access:
Setup avg:      0.054
Processing avg: 34263.201

mmap with PROT_NONE and signal handler and batch size of 1 page:
With the default value in max_map_count, this gets ENOMEM as I attempt
to change the permissions, after upping the sysctl significantly I get:
Setup avg:      0.050
Processing avg: 67690.625

mmap with PROT_NONE and signal handler and batch size of 8 pages:
Setup avg:      0.098
Processing avg: 37344.197

mmap with PROT_NONE and signal handler and batch size of 16 pages:
Setup avg:      0.0548
Processing avg: 29295.669

mmap with MAP_LOCKONFAULT:
Setup avg:      0.073
Processing avg: 18392.136

The signal handler in the batch cases faulted in memory in two steps to
avoid having to know the start and end of the faulting mapping.  The
first step covers the page that caused the fault as we know that it will
be possible to lock.  The second step speculatively tries to mlock and
mprotect the batch size - 1 pages that follow.  There may be a clever
way to avoid this without having the program track each mapping to be
covered by this handeler in a globally accessible structure, but I could
not find it.

These results show that if the developer knows that a majority of the
mapping will be used, it is better to try and fault it in at once,
otherwise MAP_LOCKONFAULT is significantly faster.

Eric

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVVhJWAAoJELbVsDOpoOa9WYAP/3ov0vZPI/nakqAuXYzn2jqU
1Dv9ox2VB8OOYQ7rwRVnpS+yJ7uxXSHHiKZLwBOiCI6nRCAlPmropUW8M+2UsdLV
i/hvNzA4IuazdL2LqZ/w8pLD9wLtbP+9EqFP5ELbmNxmZyakXctGtxpsa+YUXoZM
viRheOLn9A6qkZvGqDo6A9jMckXRuvd2x7dG4M/qjSPTVGBq573/qFmcOzNqHRZ9
PQptov2DdetLXYLBIMoU9kb/cK9EHja8fL/vOyB53DScGcMBLNCcjFJIaPz33wy0
Jdm4/rJIW5SYF3D4V1UvcJY54MdumOiKkidGIPYsqOApyTiUmc6PK/fZxWz2/P6b
ab4AOBOHNYrURr45nDbgI0/exrvezuOlqnH4xvZTkZKuprx/pMaWFsv07oECfBpm
iQk7AcTzoF6j8k+UAl8so+VbZ9m5/FSvR+TAMkNb1mtACVL7Y3gAMcuQG7rap3fN
lJoe72b4MRpXfBaD/sdW1Q9Zi9SelcEzrV8jPZiEbRHyIQC0UkYRrL6wCM+lClV0
xj8A/y3LD9Kq+k4S0s7oSc65n1EEejx3SumZ3JoWxno1aNT2RI5c7sclxmaviGr0
Ro2Gbb0HwrlH2yXwGKkC8jEayG7NzDCZVlXHJ6j6SSGABaLD5DWbaDgzIhT8lGtL
xI28uUdrt/3kVWpHEZr3
=ycZg
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
