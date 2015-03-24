Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id A0C2F6B0070
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:39:38 -0400 (EDT)
Received: by ieclw3 with SMTP id lw3so61826906iec.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:39:38 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id vu1si8917512igc.35.2015.03.24.07.39.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 07:39:38 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so73614402igb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:39:37 -0700 (PDT)
Message-ID: <55117724.6030102@gmail.com>
Date: Tue, 24 Mar 2015 10:39:32 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>	<550A5FF8.90504@gmail.com>	<CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>	<20150323051731.GA2616341@devbig257.prn2.facebook.com> <CADpJO7zk8J3q7Bw9NibV9CzLarO+YkfeshyFTTq=XeS5qziBiA@mail.gmail.com>
In-Reply-To: <CADpJO7zk8J3q7Bw9NibV9CzLarO+YkfeshyFTTq=XeS5qziBiA@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="XS1wJbCjV1BPoLF1q09GXFEk2cJ6xqVA5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksey Kandratsenka <alkondratenko@gmail.com>, Shaohua Li <shli@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XS1wJbCjV1BPoLF1q09GXFEk2cJ6xqVA5
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 24/03/15 01:25 AM, Aliaksey Kandratsenka wrote:
>=20
> Well, I don't have any workloads. I'm just maintaining a library that
> others run various workloads on. Part of the problem is lack of good
> and varied malloc benchmarks which could allow us that prevent
> regression. So this makes me a bit more cautious on performance
> matters.
>=20
> But I see your point. Indeed I have no evidence at all that exclusive
> locking might cause observable performance difference.

I'm sure it matters but I expect you'd need *many* cores running many
threads before it started to outweigh the benefit of copying pages
instead of data.

Thinking about it a bit more, it would probably make sense for mremap to
start with the optimistic assumption that the reader lock is enough here
when using MREMAP_NOHOLE|MREMAP_FIXED. It only needs the writer lock if
the destination mapping is incomplete or doesn't match, which is an edge
case as holes would mean thread unsafety.

An ideal allocator will toggle on PROT_NONE when overcommit is disabled
so this assumption would be wrong. The heuristic could just be adjusted
to assume the dest VMA will match with MREMAP_NOHOLE|MREMAP_FIXED when
full memory accounting isn't enabled. The fallback would never ended up
being needed in existing use cases that I'm aware of, and would just add
the overhead of a quick lock, O(log n) check and unlock with the reader
lock held anyway. Another flag isn't really necessary.

>>> Another notable thing is how mlock effectively disables MADV_DONTNEED=
 for
>>> jemalloc{1,2} and tcmalloc, lowers page faults count and thus improve=
s
>>> runtime. It can be seen that tcmalloc+mlock on thp-less configuration=
 is
>>> slightly better on runtime to glibc. The later spends a ton of time i=
n
>>> kernel,
>>> probably handling minor page faults, and the former burns cpu in user=
 space
>>> doing memcpy-s. So "tons of memcpys" seems to be competitive to what =
glibc
>>> is
>>> doing in this benchmark.
>>
>> mlock disables MADV_DONTNEED, so this is an unfair comparsion. With it=
,
>> allocator will use more memory than expected.
>=20
> Do not agree with unfair. I'm actually hoping MADV_FREE to provide
> most if not all of benefits of mlock in this benchmark. I believe it's
> not too unreasonable expectation.

MADV_FREE will still result in as many page faults, just no zeroing.

I get ~20k requests/s with jemalloc on the ebizzy benchmark with this
dual core ivy bridge laptop. It jumps to ~60k requests/s with MADV_FREE
IIRC, but disabling purging via MALLOC_CONF=3Dlg_dirty_mult:-1 leads to
3.5 *million* requests/s. It has a similar impact with TCMalloc.

>> I'm kind of confused why we talk about THP, mlock here. When applicati=
on
>> uses allocator, it doesn't need to be forced to use THP or mlock. Can =
we
>> forcus on normal case?
>=20
> See my note on mlock above.
>=20
> THP it is actually "normal". I know for certain, that many production
> workloads are run on boxes with THP enabled. Red Hat famously ships
> it's distros with THP set to "always". And I also know that some other
> many production workloads are run on boxes with THP disabled. Also, as
> seen above, "teleporting" pages is more efficient with THP due to much
> smaller overhead of moving those pages. So I felt it was important not
> to omit THP in my runs.

Yeah, it's quite normal for it to be enabled. Allocators might as well
give up on fine-grained purging when it is though :P. I think it only
really makes sense to purge at 2M boundaries in multiples of 2M if it's
going to end up breaking any other purging over the long-term.

I was originally only testing with THP since Arch uses "always" but I
realized it had an enormous impact and started testing without it too.


--XS1wJbCjV1BPoLF1q09GXFEk2cJ6xqVA5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVEXcnAAoJEPnnEuWa9fIqBXUP/RtGjxqw7OgT3Yjv6FMAdOYy
KGyvAERQPn/udDjCzNtdziELDgrMeMUiADbWVvg669H5Mha16s5agIQVzh4qgfOZ
gCthv2SwGcy45fZ73lx0RMAKD9wcaVc5Md7SpEz4YbzTTJc1fHpSKGlB1dl54iGm
zNRmwe2/dgxhlyjogywforgwZAC6R4y9abD3A7q6bCJqWjwLlV9pL2PWJYNPA+0w
WMZkYovU40dy9zO6vJKNX88F16lsMoP+bFeKWFXPrQr49zhLueU97yXeVDsobIWW
1ir8JV2pz+tQUmmD8vC2sCu/+DBXDWFK/qzb+F9ork0U99UxTEwAXOxLXv27L0iL
s2ma7QX0f1XgZYRx9X7MeorxZXwFxFu+sSeNXlMT+iiRz54wgsSxkDUyj06P/Isd
FOlkWo1moIGswgtathg1fEzaUzJaFjYaA4UkbpCf+vxHV4IXOh93Xqdlkk5FFUJI
wAIY/CpwGdX7SZKN8W9TX7jKvMn0HmwT3NRyJ6Aq8NSQ4oAxbcUG1mEBvidj6Oxo
V3Go2BiFvRGFzVqem6BOhItOOOlXNz1rxUULzElk4U/ig4Sx+UqtDVLdJe6NE/EW
NCdpXyR8w55yd1CisvL12dOlk6WcfOMdfSfen7ZaQg90dVCJULozhTwmO1lfF10v
t2/CvPP7GaQMdpOrUCot
=Qm7v
-----END PGP SIGNATURE-----

--XS1wJbCjV1BPoLF1q09GXFEk2cJ6xqVA5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
