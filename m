Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id DB9F36B000A
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 00:15:53 -0500 (EST)
Message-ID: <1359609334.31386.40.camel@deadeye.wl.decadent.org.uk>
Subject: Re: Bug#695182: [RFC] Reproducible OOM with just a few sleeps
From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 31 Jan 2013 05:15:34 +0000
In-Reply-To: <201301301940.r0UJeEKa016044@como.maths.usyd.edu.au>
References: <201301301940.r0UJeEKa016044@como.maths.usyd.edu.au>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-C5mSdwImHL/X/YTEORj7"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au, 695182@bugs.debian.org
Cc: dave@linux.vnet.ibm.com, pavel@ucw.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--=-C5mSdwImHL/X/YTEORj7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-01-31 at 06:40 +1100, paul.szabo@sydney.edu.au wrote:
> Dear Pavel and Dave,
>=20
> > The assertion was that 4GB with no PAE passed a forkbomb test (ooming)
> > while 4GB of RAM with PAE hung, thus _PAE_ is broken.
>=20
> Yes, PAE is broken. Still, maybe the above needs slight correction:
> non-PAE HIGHMEM4G passed the "sleep test": no OOM, nothing unexpected;
> whereas PAE OOMed then hung (tested with various RAM from 3GB to 64GB).
>=20
> The feeling I get is that amd64 is proposed as a drop-in replacement for
> PAE, that support and development of PAE is gone, that PAE is dead.

PAE was a stop-gap that kept x86-32 alive on servers until x86-64 came
along (though it was supposed to be ia64...).  That's why I was
surprised you were still trying to run a 32-bit kernel.

The fundamental problem with Linux on 32-bit systems for the past ~10
years has been that RAM sizes approached and exceeded the 32-bit virtual
address space and the kernel can't keep it all mapped.

Whenever a task makes a system call the kernel will continue to use the
same virtual memory mappings to access that task's memory, as well as
its own memory.  Which means both of those have to fit within the
virtual address space.  (The alternative of using separate address
spaces is pretty bad for performance - see OS X as an example.  And it
only helps you as far as 4GB RAM.)

The usual split on 32-bit machines is 3GB virtual address space for each
task and 1GB for the kernel.  Part of that 1GB is reserved for memory-
mapped I/O and temporary mappings, and the rest is mapped to the
beginning of RAM (lowmem).  All the remainder of RAM is highmem,
available for allocation by tasks but not for the kernel's private data
(in general).

Switching to PAE does not change the amount of lowmem, but it does make
hardware page table entries (which of course live in lowmem) twice as
big.  This increases the pressure on lowmem a little, which probably
explains the negative result of your 'sleep test'.  However if you then
try to take full advantage of the 64GB range of PAE, as you saw earlier,
the shortage of lowmem relative to highmem becomes completely untenable.

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-C5mSdwImHL/X/YTEORj7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUQn99ue/yOyVhhEJAQr3uRAAw6ORNglnzg0wm6IqaqamcGKy07+bv1gD
QuPuHq8QLXdY3F9gWG4NenAk1mZH5NyzyUZg/LOKTTbSHZmBcMNa9a941Q7K/Ykv
oolN9qgAwbS1v4yYN3fR+U3hfkNlsfNf+fAicjMMWbZ2fSkHpP72ESUWk/0XMz1P
CBFdOSXczikqPEsHUZBn9RmQG8mmOgVgJmWaIRJ5sXuYQDvW91+yWucQyNEJXCr2
dDreh1rdIK6Gftn94Vf4Y+bVI+XNyFgKoY2AitJ+3uP9XtZAQjgKAHiY1ckDpLsK
wZikLYB01BBqzqLkiHhl3bhZk6RpBO6/2af+6dMd1q8zJcCWmwLYIwyBiWSFWvCC
HzILmmn5TwYAR3J6RdUxa6xPUebdJZcUZG7hlmVnHnfkUMxHVd/Vx0hQKdg4R/Lw
F/DHVldPmnO43U/1xMMGqyOYc16AFuU4qbchOs8xdKkP4neRkcJYs64RLk/aVEMT
E0BqemhdWTSb5aoOYvIeqvw21e3JUXkUGwEostPcJ9tM1Sz+gofpH1jmsHuLJZ8v
srE9N1nmqpzZfrl5HPThRnnvJoQcDPu5f6OHjc2HuRLzPV1SEuSc+vlXa308SAVb
fpeI11zEZuywUnyFj8b8WdjfqgQa1Hy8Xzc10tKz67ZKaWMFWBaSboFVOadbiPcT
1C0U0sFfTeE=
=SBlp
-----END PGP SIGNATURE-----

--=-C5mSdwImHL/X/YTEORj7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
