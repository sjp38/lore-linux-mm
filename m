Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 994D26B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 23:04:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 62so155683239pft.3
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 20:04:06 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id q63si3024053pfk.166.2017.06.05.20.04.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 20:04:05 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id a70so3365802pge.0
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 20:04:04 -0700 (PDT)
Date: Tue, 6 Jun 2017 11:04:01 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 2/4] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
Message-ID: <20170606030401.GA2259@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-3-mhocko@kernel.org>
 <20170603022440.GA11080@WeideMacBook-Pro.local>
 <20170605064343.GE9248@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="xHFwDpU9dbj6ez1V"
Content-Disposition: inline
In-Reply-To: <20170605064343.GE9248@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 05, 2017 at 08:43:43AM +0200, Michal Hocko wrote:
>On Sat 03-06-17 10:24:40, Wei Yang wrote:
>> Hi, Michal
>>=20
>> Just go through your patch.
>>=20
>> I have one question and one suggestion as below.
>>=20
>> One suggestion:
>>=20
>> This patch does two things to me:
>> 1. Replace __GFP_REPEAT with __GFP_RETRY_MAYFAIL
>> 2. Adjust the logic in page_alloc to provide the middle semantic
>>=20
>> My suggestion is to split these two task into two patches, so that reade=
rs
>> could catch your fundamental logic change easily.
>
>Well, the rename and the change is intentionally tight together. My
>previous patches have removed all __GFP_REPEAT users for low order
>requests which didn't have any implemented semantic. So as of now we
>should only have those users which semantic will not change. I do not
>add any new low order user in this patch so it in fact doesn't change
>any existing semnatic.
>
>>=20
>> On Tue, Mar 07, 2017 at 04:48:41PM +0100, Michal Hocko wrote:
>> >From: Michal Hocko <mhocko@suse.com>
>[...]
>> >@@ -3776,9 +3784,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned i=
nt order,
>> >=20
>> > 	/*
>> > 	 * Do not retry costly high order allocations unless they are
>> >-	 * __GFP_REPEAT
>> >+	 * __GFP_RETRY_MAYFAIL
>> > 	 */
>> >-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>> >+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_MAYFA=
IL))
>> > 		goto nopage;
>>=20
>> One question:
>>=20
>> From your change log, it mentions will provide the same semantic for !co=
stly
>> allocations. While the logic here is the same as before.
>>=20
>> For a !costly allocation with __GFP_REPEAT flag, the difference after th=
is
>> patch is no OOM will be invoked, while it will still continue in the loo=
p.
>
>Not really. There are two things. The above will shortcut retrying if
>there is _no_ __GFP_RETRY_MAYFAIL. If the flags _is_ specified we will
>back of in __alloc_pages_may_oom.
>=20
>> Maybe I don't catch your point in this message:
>>=20
>>   __GFP_REPEAT was designed to allow retry-but-eventually-fail semantic =
to
>>   the page allocator. This has been true but only for allocations reques=
ts
>>   larger than PAGE_ALLOC_COSTLY_ORDER. It has been always ignored for
>>   smaller sizes. This is a bit unfortunate because there is no way to
>>   express the same semantic for those requests and they are considered t=
oo
>>   important to fail so they might end up looping in the page allocator f=
or
>>   ever, similarly to GFP_NOFAIL requests.
>>=20
>> I thought you will provide the same semantic to !costly allocation, or I
>> misunderstand?
>
>yes and that is the case. __alloc_pages_may_oom will back off before OOM
>killer is invoked and the allocator slow path will fail because
>did_some_progress =3D=3D 0;

Thanks for your explanation.

So same "semantic" doesn't mean same "behavior".
1. costly allocations will pick up the shut cut
2. !costly allocations will try something more but finally fail without
invoking OOM.

Hope this time I catch your point.

BTW, did_some_progress mostly means the OOM works to me. Are there some oth=
er
important situations when did_some_progress is set to 1?

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--xHFwDpU9dbj6ez1V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZNhuhAAoJEKcLNpZP5cTdgcMP+QEEn+DP7ZTD9hl54L1ZSimf
2zGeP9BFcv0ZXQls4MTGgb9Q4LReVRqKWjXxQGlJVljF2/kHfjgDuaCQgqYThCQD
CYP/EO0sy0Qf/k2vDxYCX+vALd2bSBl1PgopV5jM4bh0j9jTUURsqcGEe8fVTlnV
B3EXDSc0nq/zxCFIkvQjq6u7LKsXUjzaDPeOz8V/GTVEQCDqUvstKKQJDdrKR+xs
1iIvi8Q+tO/WBhiG6FRqSau7nXi0y37bKs1UocdQTWlCe0gpeIFzdS0X049fMYwu
j4g0/ZqwwgjOcv7cpUv4h2MLwZzOVcYwtLW6PwVBbttRJhiEhknpbbrbY+c4t54o
fsU4lzJPyZnwBJZ1C4IYLX03+/BceIMrKzCzYGBTLsbWosoUHQVt/8sCvk+1EzhT
VozG1N5Gs89ezuqsYJI0kmSOwVGsuyjW+oGbDPiom5+ze/SnQsTr7m9Q0AFYiCWO
mKqzvLE43ZNBG7kMNfD1zBpVn6hsapHeJoOCAYUUPqfPw21+ozg7cxSB4lZ8aR/n
1gdU70/Hqidr8Z8quDjq9j8vs/Qvycgpyvhy29Qo7sK6BABVHxUoN1le9/CPfexA
d0iuJQj3oUABvm870+1MMN9zdF1xD3mjAN8XqEBd+cAZcJLPqBKiCOjV6Re5ckx9
a8vO84OjWxOEiHvPehRH
=e4uB
-----END PGP SIGNATURE-----

--xHFwDpU9dbj6ez1V--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
