Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 173216B0072
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 09:49:18 -0400 (EDT)
Date: Mon, 1 Oct 2012 16:49:48 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 0/3] Virtual huge zero page
Message-ID: <20121001134948.GA5812@otc-wbsnb-06>
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120929134811.GC26989@redhat.com>
 <20120929143006.GC4110@tassilo.jf.intel.com>
 <20120929143737.GF26989@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline
In-Reply-To: <20120929143737.GF26989@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 29, 2012 at 04:37:37PM +0200, Andrea Arcangeli wrote:
> But I agree we need to verify it before taking a decision, and that
> the numbers are better than theory, or to rephrase it "let's check the
> theory is right" :)

Okay, microbenchmark:

% cat test_memcmp.c=20
#include <assert.h>
#include <stdlib.h>
#include <string.h>

#define MB (1024ul * 1024ul)
#define GB (1024ul * MB)

int main(int argc, char **argv)
{
        char *p;
        int i;

        posix_memalign((void **)&p, 2 * MB, 8 * GB);
        for (i =3D 0; i < 100; i++) {
                assert(memcmp(p, p + 4*GB, 4*GB) =3D=3D 0);
                asm volatile ("": : :"memory");
        }
        return 0;
}

huge zero page (initial implementation):

 Performance counter stats for './test_memcmp' (5 runs):

      32356.272845 task-clock                #    0.998 CPUs utilized      =
      ( +-  0.13% )
                40 context-switches          #    0.001 K/sec              =
      ( +-  0.94% )
                 0 CPU-migrations            #    0.000 K/sec              =
   =20
             4,218 page-faults               #    0.130 K/sec              =
      ( +-  0.00% )
    76,712,481,765 cycles                    #    2.371 GHz                =
      ( +-  0.13% ) [83.31%]
    36,279,577,636 stalled-cycles-frontend   #   47.29% frontend cycles idl=
e     ( +-  0.28% ) [83.35%]
     1,684,049,110 stalled-cycles-backend    #    2.20% backend  cycles idl=
e     ( +-  2.96% ) [66.67%]
   134,355,715,816 instructions              #    1.75  insns per cycle    =
   =20
                                             #    0.27  stalled cycles per =
insn  ( +-  0.10% ) [83.35%]
    13,526,169,702 branches                  #  418.039 M/sec              =
      ( +-  0.10% ) [83.31%]
         1,058,230 branch-misses             #    0.01% of all branches    =
      ( +-  0.91% ) [83.36%]

      32.413866442 seconds time elapsed                                    =
      ( +-  0.13% )

virtual huge zero page (the second implementation):

 Performance counter stats for './test_memcmp' (5 runs):

      30327.183829 task-clock                #    0.998 CPUs utilized      =
      ( +-  0.13% )
                38 context-switches          #    0.001 K/sec              =
      ( +-  1.53% )
                 0 CPU-migrations            #    0.000 K/sec              =
   =20
             4,218 page-faults               #    0.139 K/sec              =
      ( +-  0.01% )
    71,964,773,660 cycles                    #    2.373 GHz                =
      ( +-  0.13% ) [83.35%]
    31,191,284,231 stalled-cycles-frontend   #   43.34% frontend cycles idl=
e     ( +-  0.40% ) [83.32%]
       773,484,474 stalled-cycles-backend    #    1.07% backend  cycles idl=
e     ( +-  6.61% ) [66.67%]
   134,982,215,437 instructions              #    1.88  insns per cycle    =
   =20
                                             #    0.23  stalled cycles per =
insn  ( +-  0.11% ) [83.32%]
    13,509,150,683 branches                  #  445.447 M/sec              =
      ( +-  0.11% ) [83.34%]
         1,017,667 branch-misses             #    0.01% of all branches    =
      ( +-  1.07% ) [83.32%]

      30.381324695 seconds time elapsed                                    =
      ( +-  0.13% )

On Westmere-EX virtual huge zero page is ~6.7% faster.

--=20
 Kirill A. Shutemov

--Kj7319i9nmIyA2yE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQaZ97AAoJEAd+omnVudOMGcYP/2ZKAhHb+Eu0CMOfLbW+VfFt
DYGypl4EgPEOd7Ufnkv8sviQS9qwCkF7FO5jcwwjanjraCOeT3gpGie/DkmMD9xi
Zoo6a7u6jENWSK/G6iN4l4dG3Ur5Swn0O8m7VadeGYgzhfaHTQAbYWXcOWYLzk37
79B+gd8cnnvPiT8wThoQ6SY/Fp2MT8ueMqozPSzBqozbN86I+sxbloy38iDl7C3f
CCcmblizQPrtfBEAgq6WywDu1p/fEUqYG+nK1FPcgiFO3pu8qxKjiPrirgU05Sxl
qLoh34C5ugG00xwoSnyoGy4YZU7o4Wz7CxDmtoUa6HjRY1CgQm3huSt8XpyI8sN7
m+n59hqkH5slInPmPTtTm2hnNfe08jpe41+oGrIyK2FBFZjyh7S7i3n2shQKF+eg
9VYO48uEyYpV62JI7jDsO8TutLyX4lN37BJOdT86qtC+zgDc0lVhC95VZ/SHUMGr
l3aSZ2WilTdhuFwF0g090sOO7acpcrKGZcEL2kTBUFCFt1XUbueJcetjSdPCQcZg
LcXKJTsg2p3bXvGmCVLQ/wdLzsDxIaqLBidNIQX8WRPSHqXMYq/DcgWilYmr/UZt
6YSTwxrlkWtHScivU3MIcbLEziXphazGXLmEeOTSET1QzzzkJ2uKVlFW7PI0kFxA
9eGY9d0v3YMizHT2leCX
=i9LO
-----END PGP SIGNATURE-----

--Kj7319i9nmIyA2yE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
