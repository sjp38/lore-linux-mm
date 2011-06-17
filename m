Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 86AFB6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 11:22:00 -0400 (EDT)
Message-ID: <4DFB710D.7000902@cslab.ece.ntua.gr>
Date: Fri, 17 Jun 2011 18:21:49 +0300
From: Vasileios Karakasis <bkk@cslab.ece.ntua.gr>
MIME-Version: 1.0
Subject: [BUG] Invalid return address of mmap() followed by mbind() in multithreaded
 context
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF399A103AF0F92181929BAC1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF399A103AF0F92181929BAC1
Content-Type: multipart/mixed;
 boundary="------------090403070101080809030509"

This is a multi-part message in MIME format.
--------------090403070101080809030509
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

I am implementing a multithreaded numa aware code where each thread
mmap()'s an anonymous private region and then mbind()'s it to its local
node. The threads are performing a series of such mmap() + mbind()
operations. My program crashed with SIGSEGV and I noticed that mmap()
returned an invalid address.

I am sending you a simple program that reproduces the error. The program
creates two threads and each thread starts allocating pages and then
binds them to the local node 0. After a number of iterations the program
crashes as it tries to dereference the address returned by mmap(). The
bug doesn't come up when using a single thread, neither when using only
mmap().

I am running a 2.6.39.1 kernel on a 64-bit dual-core machine, but I
tracked this bug back down to the 2.6.34.9 version.

This bug also affects libnuma.

Regards,
--=20
V.K.


#include <assert.h>
#include <sys/mman.h>
#include <pthread.h>
#include <numaif.h>

#define NR_ITER 10240
#define PAGE_SIZE 4096

void *thread_func(void *args)
{
    unsigned char *addr;
    int err, i;
    unsigned long node =3D 0x1;

    for (i =3D 0; i < NR_ITER; i++) {
        addr =3D mmap(0, PAGE_SIZE, PROT_READ | PROT_WRITE,
                    MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
        if (addr =3D=3D (void *) -1) {
            assert(0 && "mmap failed");
        }
        *addr =3D 0;

        err =3D mbind(addr, PAGE_SIZE, MPOL_BIND, &node, sizeof(node), 0)=
;
        if (err < 0) {
            assert(0 && "mbind failed");
        }
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

--------------090403070101080809030509
Content-Type: application/pgp-keys;
 name="0x17A67A9C.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0x17A67A9C.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.10 (GNU/Linux)

mQGiBENcm2URBACj6CgSinpfmIwniRJJkWYgn1zrZdHZxW+ZFVp1GJxAE7zkd/NX
z8C2ZcDW6dBgtCmNMgythflvIuTVJx/6fZJcVe5Y5YU9RxIoBHI2BhyxEKEbQ3oW
rGWlXt9QIf0zc0RKGpTuE6XmRr8JUuI/JvBSzE6/SnRtmzqg/AMdyxRjvwCg8/lm
VYqnIxX/0+L18U5WfgpOZGsD/0YS9ann3vCkRWgT4mQdGBA3oHHQQMlpxJeva409
UiYnlUTGySw8yNiC+a8Jeklv6TH1JM/l7nZzJJR49800oyw7TYgwbrXI6bp2F4PU
7bI2Fz5nmvX/z2Be/XP+rfYp6ItYBQ5QOXk7Yj6LY+sXS4s2BcP0IpSiqSGxT80c
rbkaA/sH2MPry2d8EqVUbb+1zYs3RCQ6+0wtUbRHnSI8yhWKEw4GZcwsBfshNGhV
e4t9F5xFpROCJe+uBeIl5lCzlywYDyjEnS4cfFkVKJ2MjXPqrF53T7k3Nw1/iA3u
NfXRMzjjDQeJ8toYciu1i7+sL309m73oj+nqfJVvtX8LZWw+z7QuVmFzaWxlaW9z
IEsuIEthcmFrYXNpcyA8YmtrQGNzbGFiLmVjZS5udHVhLmdyPohjBBMRAgAjBgsJ
CAcDAgQVAggDBBYCAwECHgECF4AFAkxArL4FCRJKEtMACgkQHUHhfRemepxq9ACe
KCjvjKwXxi1ma5a6tUKs55OadTYAoNZTi6i7UFPsPn4kkr7buA259qJjiGMEExEC
ACMFAkNcm2UFCQWjmoAGCwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRAdQeF9F6Z6
nKD3AKDCmqk62drTmkvYTE/JyQ25OsCN/ACfbye1hOZCEIKH2NYpk2p80alx8c2I
YwQTEQIAIwYLCQgHAwIEFQIIAwQWAgMBAh4BAheABQJI7gUzBQkJU9DOAAoJEB1B
4X0XpnqcX3YAn3C+lRbO/s8G8p2vumlHFzKLu/VGAJkBbFj7hzUSKPZOd+SgeNJT
UFGUkIhjBBMRAgAjBgsJCAcDAgQVAggDBBYCAwECHgECF4AFAkkIiBEFCQluU6wA
CgkQHUHhfRemepzcaACfYM7cXDp5uYTOdgZXopewwDvTHLIAnA1E12YEbs1OyF+p
wMxxVEiHwa9puQQNBENcnbwQEADsbm26j/NhEPJ1oksnw0oC1i8SkW5m0LIySa7E
PuU7tI/RMMClxRmOztjthWB3BDbqIJF5ZIfGwwqlvDn6RWOMct2uTS/XtQPjJZcK
vJaL1+YQnNoFUTpnzVJKOgnUcb52MV129etIlTM/Pav+U7241uds3m1IKjpvNI8S
uG8wcQy1HxLBKxP32vPCUJOEcy4bLVMKlopBtqvGiweurNIvJaNAAHJuS6bbCyPl
mzG/sHTVC1FvCR+TE4NQPxRCWom05AW4ZbpRLTZX1TghTJ4plvBBSovTTfHEo0if
7j0PNbFdSU+I7/okpDWB1AdP0RqK/bsRctA6ROg1hAJMmF/b3dYWMow5poHETIeM
TgTecOsUc+nwteO9zSgy0UaI384pkqZ7CGfrocM2s5HepDlH3UQklsuw25EzgnCT
Hrj8e+S5mW2gZM4bs2u+n0g0BeRrhWoxz+DNwxwgCovoHvs6yeRtibkQuCXemoxb
ryamKwo+c/j52sURa2h0dPtvR/+tyg/Bs4ly9KJStCXiGPF+gMNgyfPM2pkhqE9Q
rsVhZq+NWIGcQZIlCEGJlewantwy0VsiuCKQVQfOyz1si+50TSGPUp2WahNOrKBi
S4TnlHcorfVnwy9gMV8BsAhy8Y8AGgYfJPGdYEPBbc8OjIx/3nIrZpIOHGpLFMtk
deWi8wADBhAA5hkkXW1Ig61sQ5cIBBRjEsqbOvbF3oStWXXOIBo83ec4ebzclpRP
mszndRgUupPs9/snMHDQHvHCFV2+LbA+y6mE7lXHT6zza0sPejUZrnz8bY4lUXI9
S6P38nJzbZAHiybGQMbaPI4YV+bCYLF4a8V4pJ/m+rEn5ZvQU48I8oH0nBPhS5Hd
8bWsza+Njr3V3hr22isW9/cz+w7nTXbFjLVpNtdTr2HlB/T143NgLFU2IyToi437
SxO5denkVDK66GxZ0a1EAHaaC1PImdTtYWjd/9t/MVFqtL4qrbun8bHldQnjFVIE
m+MPiLmTbn53CChJ/3gNaYL+S0S4cxPLOBdEdZ62AnVtlvuE/S1aKGvhV5KvCafk
qx0Pqv3FNyBhJqVVYfGA98MIJRHDWBO4uw8BVHh/5KpH+WIpn6zMyBx04DBGNvZP
UinKsbKY7kIy0jB+9LE3vwqYPnQj79GAAxvnOqkwrhhbXIP+TqaeahPVe3MBIxDg
0nwsToRtd6f6WipDLOgYLA2rc4KdJ9kYTmyn1DJWx6N6WE20dwd6HVo+6Tp+hQTf
ZZj+KjTsa/C47HbGpu2QZ+dtEOxHSiiBLqnNH7Bc7KozuoTCzNzIEGxUfjmvbYht
SlfchiK/+MJFzpi6ot/7hIOoYwqoTVPzZTr3vzKfEgTylPLXpH2JJgaITAQYEQIA
DAUCTECtBQUJEkoQxQAKCRAdQeF9F6Z6nNgbAKC+KGnNaTKJPx5VTurjEp9mW215
qgCdEHEBN5VcuGHZ5q/BfHeSXLcApFY=3D
=3DMPxZ
-----END PGP PUBLIC KEY BLOCK-----

--------------090403070101080809030509--

--------------enigF399A103AF0F92181929BAC1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk37cQ0ACgkQHUHhfRemepznJACfRGDGTwPW+7AXeloMxDWJiidd
v/wAoOriGHCKuKuNxuJ1Igvsy8cBGbxe
=lseu
-----END PGP SIGNATURE-----

--------------enigF399A103AF0F92181929BAC1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
