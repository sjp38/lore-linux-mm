Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5631182F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 18:37:14 -0500 (EST)
Received: by ioll68 with SMTP id l68so72835772iol.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 15:37:14 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id 78si4116810ioc.91.2015.11.04.15.37.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 15:37:13 -0800 (PST)
Received: by igpw7 with SMTP id w7so117632639igp.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 15:37:13 -0800 (PST)
Subject: Re: [PATCH 5/8] mm: move lazily freed pages to inactive list
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-6-git-send-email-minchan@kernel.org>
 <20151104205504.GA9927@cmpxchg.org> <563A7D21.6040505@gmail.com>
 <20151104225527.GA25941@cmpxchg.org>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <563A9681.3070102@gmail.com>
Date: Wed, 4 Nov 2015 18:36:33 -0500
MIME-Version: 1.0
In-Reply-To: <20151104225527.GA25941@cmpxchg.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="k9fBlQIoXhTtk4U9C25rE2uO0iN1dlXss"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--k9fBlQIoXhTtk4U9C25rE2uO0iN1dlXss
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

>>> It probably makes sense to stop thinking about them as anonymous page=
s
>>> entirely at this point when it comes to aging. They're really not. Th=
e
>>> LRU lists are split to differentiate access patterns and cost of page=

>>> stealing (and restoring). From that angle, MADV_FREE pages really hav=
e
>>> nothing in common with in-use anonymous pages, and so they shouldn't
>>> be on the same LRU list.
>>>
>>> That would also fix the very unfortunate and unexpected consequence o=
f
>>> tying the lazy free optimization to the availability of swap space.
>>>
>>> I would prefer to see this addressed before the code goes upstream.
>>
>> I don't think it would be ideal for these potentially very hot pages t=
o
>> be dropped before very cold pages were swapped out. It's the kind of
>> tuning that needs to be informed by lots of real world experience and
>> lots of testing. It wouldn't impact the API.
>=20
> What about them is hot? They contain garbage, you have to write to
> them before you can use them. Granted, you might have to refetch
> cachelines if you don't do cacheline-aligned populating writes, but
> you can do a lot of them before it's more expensive than doing IO.

It's hot because applications churn through memory via the allocator.

Drop the pages and the application is now churning through page faults
and zeroing rather than simply reusing memory. It's not something that
may happen, it *will* happen. A page in the page cache *may* be reused,
but often won't be, especially when the I/O patterns don't line up well
with the way it works.

The whole point of the feature is not requiring the allocator to have
elaborate mechanisms for aging pages and throttling purging. That ends
up resulting in lots of memory held by userspace where the kernel can't
reclaim it under memory pressure. If it's dropped before page cache, it
isn't going to be able to replace any of that logic in allocators.

The page cache is speculative. Page caching by allocators is not really
speculative. Using MADV_FREE on the pages at all is speculative. The
memory is probably going to be reused fairly soon (unless the process
exits, and then it doesn't matter), but purging will end up reducing
memory usage for the portions that aren't.

It would be a different story for a full unpinning/pinning feature since
that would have other use cases (speculative caches), but this is really
only useful in allocators.

>> Whether MADV_FREE is useful as an API vs. something like a pair of
>> system calls for pinning and unpinning memory is what should be worrie=
d
>> about right now. The internal implementation just needs to be correct
>> and useful right now, not perfect. Simpler is probably better than it
>> being more well tuned for an initial implementation too.
>=20
> Yes, it wouldn't impact the API, but the dependency on swap is very
> random from a user experience and severely limits the usefulness of
> this. It should probably be addressed before this gets released. As
> this involves getting the pages off the anon LRU, we need to figure
> out where they should go instead.

=46rom a user perspective, it doesn't depend on swap. It's just slower
without swap because it does what MADV_DONTNEED does. The current
implementation can be dropped in where MADV_DONTNEED was previously used.=



--k9fBlQIoXhTtk4U9C25rE2uO0iN1dlXss
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOpaBAAoJEPnnEuWa9fIqNWQP/01G5iVFVBbIQokH2gppoWyl
TWD9nzJvQ2ZO9zmTSk3RVDfxXIo4y6G8VUVBuENQvLY/pqYue6zRfUcfBkeQxae2
je61D4U1GVeVYB3lF7kWQ/GYT1rjvOYeKLT/xraRwaa64QemkjYa39zeTwgxXiTh
yM547phlordgZrCoxicFEeyJ3Hcu+XXgSGCrV4EERNw0Bfhwvue89wHBeLfDACEW
I8qJUFEy6JW2lz1lWYIVexnLEDolvY+vZr4gC41rfTlAl+0h/WnR64iSHO8LHlZD
Phasl3qFKDwC3T2gsAUbS1/RjTPmFXYXfnWuKSR4PDoYSGnjWLP6LtloMdS4I63P
z62kucTIYZwp2EDDYw8usaRo41tJACBi3Edw2bOEOcQrhRQrzRwwr8+KTlYmJ9Xo
1P1bw6sPrnH489k2yFH3SLfgrw1K8RkfIxEIHcboNrC0MwdoY/NUJDl6wtmUvpx+
3EvnI8Wh0tsRNg02B4RzeOIfFxllqxGKJG+IqHFMVeWA9K1yriG/6GAl6qAvOKnD
HueRdzvoj470F2urMeYWOmwGqUlYDKv1cEwVudGFoDiPeBNDq/+1tfovFPEa4R6Q
Tocoobef0eXMsVYpIXNfH2kNUcw6aWXg2yVBbJuD0l7J+UwZ5qPTlbwnqiI689/O
xqA3vFtsG1pI4TUYjJ9w
=Q/En
-----END PGP SIGNATURE-----

--k9fBlQIoXhTtk4U9C25rE2uO0iN1dlXss--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
