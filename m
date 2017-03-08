Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46F88831CE
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 03:00:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 77so43625893pgc.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 00:00:49 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id h5si2485207pln.273.2017.03.08.00.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 00:00:46 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 77so2676380pgc.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 00:00:46 -0800 (PST)
Date: Wed, 8 Mar 2017 16:00:42 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 2/2] mm/sparse: add last_section_nr in sparse_init()
 to reduce some iteration cycle
Message-ID: <20170308080042.GA18355@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170211021829.9646-1-richard.weiyang@gmail.com>
 <20170211021829.9646-2-richard.weiyang@gmail.com>
 <20170211022400.GA19050@mtj.duckdns.org>
 <CADZGycbxtoXXxCeg-nHjzGmHA72VnA=-td+hNaNqN67Vq2JuKg@mail.gmail.com>
 <CADZGycapTYxdxwHacFYiECZQ23uPDARQcahw_9zuKrNu-wG63g@mail.gmail.com>
 <20170306194225.GB19696@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="VS++wcV0S1rZb1Fb"
Content-Disposition: inline
In-Reply-To: <20170306194225.GB19696@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 06, 2017 at 02:42:25PM -0500, Tejun Heo wrote:
>Hello, Wei.
>
>On Fri, Feb 17, 2017 at 10:12:31PM +0800, Wei Yang wrote:
>> > And compare the ruling with the iteration for the loop to be (1UL <<
>> > 5) and (1UL << 19).
>> > The runtime is 0.00s and 0.04s respectively. The absolute value is not=
 much.
>
>systemd-analyze usually does a pretty good job of breaking down which
>phase took how long.  It might be worthwhile to test whether the
>improvement is actually visible during the boot.
>

Hi, Tejun

Thanks for your suggestion. I have tried systemd-analyze to measure the
effect, while looks not good.

Result without patch
-------------------------
Startup finished in 7.243s (kernel) + 25.034s (userspace) =3D 32.277s
Startup finished in 7.254s (kernel) + 19.816s (userspace) =3D 27.071s
Startup finished in 7.272s (kernel) + 4.363s (userspace) =3D 11.636s
Startup finished in 7.258s (kernel) + 24.319s (userspace) =3D 31.577s
Startup finished in 7.262s (kernel) + 9.481s (userspace) =3D 16.743s
Startup finished in 7.266s (kernel) + 14.766s (userspace) =3D 22.032s

Avg =3D 7.259s

Result with patch
-------------------------
Startup finished in 7.262s (kernel) + 14.294s (userspace) =3D 21.557s
Startup finished in 7.264s (kernel) + 19.519s (userspace) =3D 26.783s
Startup finished in 7.266s (kernel) + 4.730s (userspace) =3D 11.997s
Startup finished in 7.258s (kernel) + 9.514s (userspace) =3D 16.773s
Startup finished in 7.258s (kernel) + 14.371s (userspace) =3D 21.629s
Startup finished in 7.258s (kernel) + 14.627s (userspace) =3D 21.885s

Avg =3D 7.261s

It looks the effect is not obvious. Maybe the improvement is not good
enough :(

>> >> * Do we really need to add full reverse iterator to just get the
>> >>   highest section number?
>> >>
>> >
>> > You are right. After I sent out the mail, I realized just highest pfn
>> > is necessary.
>
>That said, getting efficient is always great as long as the added
>complexity is justifiably small enough.  If you can make the change
>simple enough, it'd be a lot easier to merge.
>

Agree.

I have replaced the reverse iteration with a simple last pfn return. The te=
st
result above is based on the new version.

>Thanks.
>
>--=20
>tejun

--=20
Wei Yang
Help you, Help me

--VS++wcV0S1rZb1Fb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYv7oqAAoJEKcLNpZP5cTdW0IP/RYXTERjwzLqnqPOGHm8OsHX
cqT8+4RLUK70SwOnwLh58BFkssM7V4oq/zaR9mGze3z5er+U+UFdXKRry/x6t5KR
GgHDHzxBVaFuFwDZ8mEDhvcJbnH2/AxS2RLsI49tWPgImBeb+bX8LV2X07Dl7U78
tFkttZ3Fa1VZRNyFGTNEPeuB5U+/RaC5Xa+EkXfuraju1icDh2xN3f2M7+/dOSpr
ACGLl7Ug3/B6eBQPUh8ll5pJBpaQoYP/efAZ6xLdIPybsPO7tPxDCEvCVHrhg6tO
kQVm2nPjOiq4/tpOvRENtdp+VlEdBMSItVlJ651OW2D6Johnl+XIjPzyaAzjgx6Y
0znAbmDBsG+qbuyR7SWt24A095XlXOTaBsxpcMgZnbgEkODcNpqqzQUIsTr0mXj3
XzH2LsTZUMTKmkbIqE393aPeq1yl+w0krQ9gN3pEJRmOU7nGcfqOMH2AErEDkl95
BXFlfEOWaMzDLgs6Uj7r5BVj3TSCduzKmtaQeDhq/pTXA3utD5rq/cuJ6lf8tSkI
+U8GhJ3iu44yl09jvG8IrOil2j62ndb2hoapELMlocOhPQvrmcZ7t8lW8eu3HHsi
HcPG6Vj3k93Pjmvc5v464TXx8pgKcVDXBkkT8OHWO9p3s3VeDjJ7B0fcXT2D1dwg
w08jZLsbelG/ek+CFdfq
=FhWU
-----END PGP SIGNATURE-----

--VS++wcV0S1rZb1Fb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
