Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id E947F6B0096
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:43:55 -0400 (EDT)
Date: Mon, 13 Aug 2012 14:43:34 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v2 4/6] x86: Add clear_page_nocache
Message-ID: <20120813114334.GA21855@otc-wbsnb-06>
References: <1344524583-1096-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1344524583-1096-5-git-send-email-kirill.shutemov@linux.intel.com>
 <5023F1BC0200007800093EF0@nat28.tlf.novell.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n8g4imXOkfNTN/H1"
Content-Disposition: inline
In-Reply-To: <5023F1BC0200007800093EF0@nat28.tlf.novell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Robert Richter <robert.richter@amd.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Alex Shi <alex.shu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mips@linux-mips.org, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 09, 2012 at 04:22:04PM +0100, Jan Beulich wrote:
> >>> On 09.08.12 at 17:03, "Kirill A. Shutemov" <kirill.shutemov@linux.int=
el.com> wrote:

=2E..

> > ---
> >  arch/x86/include/asm/page.h          |    2 ++
> >  arch/x86/include/asm/string_32.h     |    5 +++++
> >  arch/x86/include/asm/string_64.h     |    5 +++++
> >  arch/x86/lib/Makefile                |    1 +
> >  arch/x86/lib/clear_page_nocache_32.S |   30 ++++++++++++++++++++++++++=
++++
> >  arch/x86/lib/clear_page_nocache_64.S |   29 ++++++++++++++++++++++++++=
+++
>=20
> Couldn't this more reasonably go into clear_page_{32,64}.S?

We don't have clear_page_32.S.

> >+	xorl   %eax,%eax
> >+	movl   $4096/64,%ecx
> >+	.p2align 4
> >+.Lloop:
> >+	decl	%ecx
> >+#define PUT(x) movnti %eax,x*8(%edi) ; movnti %eax,x*8+4(%edi)
>=20
> Is doing twice as much unrolling as on 64-bit really worth it?

Moving 64 bytes per cycle is faster on Sandy Bridge, but slower on
Westmere. Any preference? ;)

Westmere:

 Performance counter stats for './test_unroll32' (20 runs):

      31498.420608 task-clock                #    0.998 CPUs utilized      =
      ( +-  0.25% )
                40 context-switches          #    0.001 K/sec              =
      ( +-  1.40% )
                 0 CPU-migrations            #    0.000 K/sec              =
      ( +-100.00% )
                89 page-faults               #    0.003 K/sec              =
      ( +-  0.13% )
    74,728,231,935 cycles                    #    2.372 GHz                =
      ( +-  0.25% ) [83.34%]
    53,789,969,009 stalled-cycles-frontend   #   71.98% frontend cycles idl=
e     ( +-  0.35% ) [83.33%]
    41,681,014,054 stalled-cycles-backend    #   55.78% backend  cycles idl=
e     ( +-  0.43% ) [66.67%]
    37,992,733,278 instructions              #    0.51  insns per cycle
                                             #    1.42  stalled cycles per =
insn  ( +-  0.05% ) [83.33%]
     3,561,376,245 branches                  #  113.065 M/sec              =
      ( +-  0.05% ) [83.33%]
        27,182,795 branch-misses             #    0.76% of all branches    =
      ( +-  0.06% ) [83.33%]

      31.558545812 seconds time elapsed                                    =
      ( +-  0.25% )

 Performance counter stats for './test_unroll64' (20 runs):

      31564.753623 task-clock                #    0.998 CPUs utilized      =
      ( +-  0.19% )
                39 context-switches          #    0.001 K/sec              =
      ( +-  0.40% )
                 0 CPU-migrations            #    0.000 K/sec
                90 page-faults               #    0.003 K/sec              =
      ( +-  0.12% )
    74,886,045,192 cycles                    #    2.372 GHz                =
      ( +-  0.19% ) [83.33%]
    57,477,323,995 stalled-cycles-frontend   #   76.75% frontend cycles idl=
e     ( +-  0.26% ) [83.34%]
    44,548,142,150 stalled-cycles-backend    #   59.49% backend  cycles idl=
e     ( +-  0.31% ) [66.67%]
    32,940,027,099 instructions              #    0.44  insns per cycle
                                             #    1.74  stalled cycles per =
insn  ( +-  0.05% ) [83.34%]
     1,884,944,093 branches                  #   59.717 M/sec              =
      ( +-  0.05% ) [83.32%]
         1,027,135 branch-misses             #    0.05% of all branches    =
      ( +-  0.56% ) [83.34%]

      31.621001407 seconds time elapsed                                    =
      ( +-  0.19% )

Sandy Bridge:

 Performance counter stats for './test_unroll32' (20 runs):

       8578.382891 task-clock                #    0.997 CPUs utilized      =
      ( +-  0.08% )
                15 context-switches          #    0.000 M/sec              =
      ( +-  2.97% )
                 0 CPU-migrations            #    0.000 M/sec
                84 page-faults               #    0.000 M/sec              =
      ( +-  0.13% )
    29,154,476,597 cycles                    #    3.399 GHz                =
      ( +-  0.08% ) [83.33%]
    11,851,215,147 stalled-cycles-frontend   #   40.65% frontend cycles idl=
e     ( +-  0.20% ) [83.33%]
     1,530,172,593 stalled-cycles-backend    #    5.25% backend  cycles idl=
e     ( +-  1.44% ) [66.67%]
    37,915,778,094 instructions              #    1.30  insns per cycle
                                             #    0.31  stalled cycles per =
insn  ( +-  0.00% ) [83.34%]
     3,590,533,447 branches                  #  418.556 M/sec              =
      ( +-  0.01% ) [83.35%]
        26,500,765 branch-misses             #    0.74% of all branches    =
      ( +-  0.01% ) [83.34%]

       8.604638449 seconds time elapsed                                    =
      ( +-  0.08% )

 Performance counter stats for './test_unroll64' (20 runs):

       8463.789963 task-clock                #    0.997 CPUs utilized      =
      ( +-  0.07% )
                14 context-switches          #    0.000 M/sec              =
      ( +-  1.70% )
                 0 CPU-migrations            #    0.000 M/sec              =
      ( +-100.00% )
                85 page-faults               #    0.000 M/sec              =
      ( +-  0.12% )
    28,763,328,688 cycles                    #    3.398 GHz                =
      ( +-  0.07% ) [83.32%]
    13,517,462,952 stalled-cycles-frontend   #   47.00% frontend cycles idl=
e     ( +-  0.14% ) [83.33%]
     1,356,208,859 stalled-cycles-backend    #    4.72% backend  cycles idl=
e     ( +-  1.42% ) [66.68%]
    32,885,492,141 instructions              #    1.14  insns per cycle
                                             #    0.41  stalled cycles per =
insn  ( +-  0.00% ) [83.34%]
     1,912,094,072 branches                  #  225.915 M/sec              =
      ( +-  0.02% ) [83.34%]
           305,896 branch-misses             #    0.02% of all branches    =
      ( +-  1.05% ) [83.33%]

       8.488304839 seconds time elapsed                                    =
      ( +-  0.07% )

$ cat test.c
#include <stdio.h>
#include <sys/mman.h>

#define SIZE 1024*1024*1024

void clear_page_nocache_sse2(void *page) __attribute__((regparm(1)));

int main(int argc, char** argv)
{
        char *p;
        unsigned long i, j;

        p =3D mmap(NULL, SIZE, PROT_WRITE|PROT_READ,
                        MAP_PRIVATE|MAP_ANONYMOUS|MAP_POPULATE, -1, 0);
        for(j =3D 0; j < 100; j++) {
                for(i =3D 0; i < SIZE; i +=3D 4096) {
                        clear_page_nocache_sse2(p + i);
                }
        }

        return 0;
}
$ cat clear_page_nocache_unroll32.S
=2Eglobl clear_page_nocache_sse2
=2Ealign 4,0x90
clear_page_nocache_sse2:
=2Ecfi_startproc
        mov    %eax,%edx
        xorl   %eax,%eax
        movl   $4096/32,%ecx
        .p2align 4
=2ELloop_sse2:
        decl    %ecx
#define PUT(x) movnti %eax,x*4(%edx)
        PUT(0)
        PUT(1)
        PUT(2)
        PUT(3)
        PUT(4)
        PUT(5)
        PUT(6)
        PUT(7)
#undef PUT
        lea     32(%edx),%edx
        jnz     .Lloop_sse2
        nop
        ret
=2Ecfi_endproc
=2Etype clear_page_nocache_sse2, @function
=2Esize clear_page_nocache_sse2, .-clear_page_nocache_sse2
$ cat clear_page_nocache_unroll64.S
=2Eglobl clear_page_nocache_sse2
=2Ealign 4,0x90
clear_page_nocache_sse2:
=2Ecfi_startproc
        mov    %eax,%edx
        xorl   %eax,%eax
        movl   $4096/64,%ecx
        .p2align 4
=2ELloop_sse2:
        decl    %ecx
#define PUT(x) movnti %eax,x*8(%edx) ; movnti %eax,x*8+4(%edx)
        PUT(0)
        PUT(1)
        PUT(2)
        PUT(3)
        PUT(4)
        PUT(5)
        PUT(6)
        PUT(7)
#undef PUT
        lea     64(%edx),%edx
        jnz     .Lloop_sse2
        nop
        ret
=2Ecfi_endproc
=2Etype clear_page_nocache_sse2, @function
=2Esize clear_page_nocache_sse2, .-clear_page_nocache_sse2

--=20
 Kirill A. Shutemov

--n8g4imXOkfNTN/H1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQKOhmAAoJEAd+omnVudOMHkEP/A7UHD4QMEL2dJd8I/shucOu
0nkj9L9KH3hKJHzBs+Qr+512UiWH5pNUuW4TuqNd4QZL1I0C5lJ9RxJeVwxVysvH
KCL2XyAO8AuAHWTpJ/2rvEdktpEibI1ky2tfvxRFg1bHwUZ8mJ/EDhSVqauQ5oUM
GyMqlsvPTB3TUGXp554KpaG507k6sWq5DJF7LB/9FWsKS6koyA+Dx/uUoDYnkGcW
zlRV07GkyjH0HuvlhIsp9/FHV5qXwPDO1BahRfo1knFw8SdWC48vTOWGfDbgx5y7
kndl3gYreG59HeSq8YOguD4oSaKxaJlAgWplOjeYamTuKlpozY3behmgE3ZoxH0c
xvgRVe8D69dKGqJWjDctDOTAb3Qa391fJ92fnkci7YzNedfsSzkdhLlpyjJH9Bh9
ez4+ZPvRHrIim854LyFn/g98NWGQXy+33//SCgU5f5Lo7O5DHshOsY4Lxuc476PJ
sZo3wOdGoAOoUWTTnpr4Cb/B1GEDEYuJ/YdfMNWlpWCBG3T6g/LDcxqSjivlNFAu
MkADxNkzKq3MlEdKfoqofzsQq2NxY4iyLWiEZeZ/sp6cnG6VhcbVYR3x3nX2FgEy
1gWUOT1KNZqAU01XtF4H5P5Ie/rOe32U3HELEJiTNmNQjcIPbsRNBnJRhI1yA+CL
MqSoymi0iq8J3qtkCJaP
=sj4L
-----END PGP SIGNATURE-----

--n8g4imXOkfNTN/H1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
