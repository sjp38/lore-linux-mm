Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 222216B0012
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 19:42:46 -0400 (EDT)
Message-ID: <4DFE8962.3060305@cslab.ece.ntua.gr>
Date: Mon, 20 Jun 2011 02:42:26 +0300
From: Vasileios Karakasis <bkk@cslab.ece.ntua.gr>
MIME-Version: 1.0
Subject: Re: [BUG] Invalid return address of mmap() followed by mbind() in
 multithreaded context
References: <4DFB710D.7000902@cslab.ece.ntua.gr> <20110618181232.GI16236@one.firstfloor.org> <4DFCF13F.50401@cslab.ece.ntua.gr>
In-Reply-To: <4DFCF13F.50401@cslab.ece.ntua.gr>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9B894886CB06E82632418101"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9B894886CB06E82632418101
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I'm sending you a slightly modified version that actually makes clear
how libnuma is affected. If you compile with -DUSE_LIBNUMA, you will get
an EFAULT from mbind() and then crash.

This is the gdb output where the address passed to mbind() is invalid.

(gdb) r
Starting program: a.out
[Thread debugging using libthread_db enabled]
[New Thread 0x7ffff7633700 (LWP 17977)]
a.out: mmap-bug.c:29: thread_func: Assertion `0 && "mbind() failed"' fail=
ed.

Program received signal SIGABRT, Aborted.
0x00007ffff7667a75 in *__GI_raise (sig=3D<value optimized out>)
    at ../nptl/sysdeps/unix/sysv/linux/raise.c:64
64	../nptl/sysdeps/unix/sysv/linux/raise.c: No such file or directory.
	in ../nptl/sysdeps/unix/sysv/linux/raise.c
(gdb) f 3
#3  0x00000000004007b8 in thread_func (args=3D0x0) at mmap-bug.c:29
29	            assert(0 && "mbind() failed");
(gdb) p addr
$1 =3D (unsigned char *) 0x7ffff5c27000 <Address 0x7ffff5c27000 out of bo=
unds>


#include <assert.h>
#include <sys/mman.h>
#include <pthread.h>
#include <numa.h>
#include <numaif.h>

#define NR_ITER 10240
#define PAGE_SIZE 4096

void *thread_func(void *args)
{
    unsigned char *addr;
    int err, i;
    unsigned long node =3D 0x1;

    for (i =3D 0; i < NR_ITER; i++) {
#ifdef USE_LIBNUMA
        addr =3D numa_alloc_onnode(PAGE_SIZE, 0);
#else
        addr =3D mmap(0, PAGE_SIZE, PROT_READ | PROT_WRITE,
                    MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
        if (addr =3D=3D (void *) -1)
            assert(0 && "mmap() failed");

        err =3D mbind(addr, PAGE_SIZE, MPOL_BIND, &node, sizeof(node), 0)=
;
        if (err < 0)
            assert(0 && "mbind() failed");
#endif
        *addr =3D 0;
    }

    return (void *) 0;
}

int main(void)
{
    pthread_t thread;
    pthread_create(&thread, NULL, thread_func, NULL);
    thread_func(NULL);
    pthread_join(thread, NULL);
    return 0;
}



On 06/18/2011 09:41 PM, Vasileios Karakasis wrote:
> That's right, but what I want to demonstrate is that the address
> returned by mmap() is invalid and the dereference crashes the program,
> while it shouldn't. I could equally omit this statement, in which case
> mbind() would fail with EFAULT.
>=20
> On 06/18/2011 09:12 PM, Andi Kleen wrote:
>>
>> mbind() can be only done before the first touch. you're not actually t=
esting=20
>> numa policy.
>>
>> -andi
>=20

--=20
V.K.


--------------enig9B894886CB06E82632418101
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk3+iWkACgkQHUHhfRemepxxhQCgrB6kJq5Sc5mTzFvvNGlBJldU
p/0Anj7OnXvWtYnJnYRnq77j+21BNRcT
=ajpA
-----END PGP SIGNATURE-----

--------------enig9B894886CB06E82632418101--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
