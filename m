Received: by ik-out-1112.google.com with SMTP id c21so1137079ika.6
        for <linux-mm@kvack.org>; Fri, 03 Oct 2008 02:24:51 -0700 (PDT)
Date: Fri, 3 Oct 2008 12:25:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081003092550.GA8669@localhost.localdomain>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name> <20081003080244.GC25408@elte.hu>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="X1bOJ3K7DJ5YkBrT"
Content-Disposition: inline
In-Reply-To: <20081003080244.GC25408@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 03, 2008 at 10:02:44AM +0200, Ingo Molnar wrote:
>=20
> * Kirill A. Shutemov <kirill@shutemov.name> wrote:
>=20
> > -	/* for MAP_32BIT mappings we force the legact mmap base */
> > -	if (!test_thread_flag(TIF_IA32) && (flags & MAP_32BIT))
> > +	/* for MAP_32BIT mappings and ADDR_LIMIT_32BIT personality we force t=
he
> > +	 * legact mmap base
> > +	 */
>=20
> please use the customary multi-line comment style:
>=20
>   /*
>    * Comment .....
>    * ...... goes here:
>    */
>=20
> and you might use the opportunity to fix the s/legact/legacy typo as=20
> well.

Ok, I'll fix it.

>=20
> but more generally, we already have ADDR_LIMIT_3GB support on x86.

Does ADDR_LIMIT_3GB really work?

$ cat 1.c
#include <stdio.h>
#include <sys/personality.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#define ADDR_LIMIT_3GB 0x8000000

int main(void)
{
        int id;
        void *shm;

        personality(ADDR_LIMIT_3GB);

        id =3D shmget(0x123456, 1, IPC_CREAT | 0600);
        shm =3D shmat(id, NULL, 0);
        printf("shm: %p\n", shm);
        shmdt(shm);

        return 0;
}
$ gcc -Wall 1.c
$ sudo ./a.out=20
shm: 0x7f4fca755000

> Why=20
> should support for ADDR_LIMIT_32BIT be added?

It's useful for user mode qemu when you try emulate 32-bit target on=20
x86_64. For example, if shmat(2) return addres above 32-bit, target will
get SIGSEGV on access to it.

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--X1bOJ3K7DJ5YkBrT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjl5R4ACgkQbWYnhzC5v6phHgCfUVMJE9tqR47xaAQXaw1z4W9R
jZkAn1y1ty3SgfLEgaG+E0h2+SPUEdAZ
=vsUG
-----END PGP SIGNATURE-----

--X1bOJ3K7DJ5YkBrT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
