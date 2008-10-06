Received: by nf-out-0910.google.com with SMTP id c10so1255991nfd.6
        for <linux-mm@kvack.org>; Mon, 06 Oct 2008 01:16:19 -0700 (PDT)
Date: Mon, 6 Oct 2008 11:17:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081006081717.GA20072@localhost.localdomain>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name> <20081003080244.GC25408@elte.hu> <20081003092550.GA8669@localhost.localdomain> <87abdintds.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
Content-Disposition: inline
In-Reply-To: <87abdintds.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 06, 2008 at 08:13:19AM +0200, Andi Kleen wrote:
> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
> >
> >>=20
> >> but more generally, we already have ADDR_LIMIT_3GB support on x86.
> >
> > Does ADDR_LIMIT_3GB really work?
>=20
> As Arjan pointed out it only takes effect on exec()
>=20
> andi@basil:~/tsrc> cat tstack2.c
> #include <stdio.h>
> int main(void)
> {
>         void *p =3D &p;
>         printf("%p\n", &p);
>         return 0;
> }
> andi@basil:~/tsrc> gcc -m32 tstack2.c  -o tstack2
> andi@basil:~/tsrc> ./tstack2=20
> 0xff807d70
> andi@basil:~/tsrc> linux32 --3gb ./tstack2=20
> 0xbfae2840

Which kernel do you use?
Does it work only when compiled with -m32?

$ cat 1.c
#include <stdio.h>
int main(void)
{
        void *p =3D &p;
        printf("%p\n", &p);
        return 0;
}
$ gcc 1.c
$ linux32 --3gb ./a.out
0x7fffa667e7b8

> >> Why=20
> >> should support for ADDR_LIMIT_32BIT be added?
> >
> > It's useful for user mode qemu when you try emulate 32-bit target on=20
> > x86_64. For example, if shmat(2) return addres above 32-bit, target will
> > get SIGSEGV on access to it.
>=20
> The traditional way in mmap() to handle this is to give it a search
> hint < 4GB and then free the memory again/fail if the result was >4GB.

mmap() has MAP_32BIT flag on x86_64.

> Unfortunately that doesn't work for shmat() because the address argument
> is not a search hint, but a fixed address.=20
>=20
> I presume you need this for the qemu syscall emulation. For a standard
> application I would just recommend to use mmap with tmpfs instead
> (sysv shm is kind of obsolete). For shmat() emulation the cleanest way
> would be probably to add a new flag to shmat() that says that address
> is a search hint, not a fixed address. Then implement it the way recommen=
ded
> above.

I prefer one handle to switch application to 32-bit address mode. Why is it
wrong?

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjpyY0ACgkQbWYnhzC5v6rhxwCffulzlOtbVhIeJBHv8XzP8T0l
sUwAnjKE0r50clXUSCGBC6IcW7cSPZXu
=L/t1
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
