Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id B8DFC82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 16:48:57 -0500 (EST)
Received: by igpw7 with SMTP id w7so115805889igp.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 13:48:57 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id n135si3865301ion.187.2015.11.04.13.48.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 13:48:57 -0800 (PST)
Received: by igdg1 with SMTP id g1so116118990igd.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 13:48:57 -0800 (PST)
Subject: Re: [PATCH 5/8] mm: move lazily freed pages to inactive list
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-6-git-send-email-minchan@kernel.org>
 <20151104205504.GA9927@cmpxchg.org>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <563A7D21.6040505@gmail.com>
Date: Wed, 4 Nov 2015 16:48:17 -0500
MIME-Version: 1.0
In-Reply-To: <20151104205504.GA9927@cmpxchg.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="SIniK9POceDHqW8AWkRjx172aJX0cGs4j"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SIniK9POceDHqW8AWkRjx172aJX0cGs4j
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

> Even if we're wrong about the aging of those MADV_FREE pages, their
> contents are invalidated; they can be discarded freely, and restoring
> them is a mere GFP_ZERO allocation. All other anonymous pages have to
> be written to disk, and potentially be read back.
>=20
> [ Arguably, MADV_FREE pages should even be reclaimed before inactive
>   page cache. It's the same cost to discard both types of pages, but
>   restoring page cache involves IO. ]

Keep in mind that this is memory the kernel wouldn't be getting back at
all if the allocator wasn't going out of the way to purge it, and they
aren't going to go out of their way to purge it if it means the kernel
is going to steal the pages when there isn't actually memory pressure.

An allocator would be using MADV_DONTNEED if it didn't expect that the
pages were going to be used against shortly. MADV_FREE indicates that it
has time to inform the kernel that they're unused but they could still
be very hot.

> It probably makes sense to stop thinking about them as anonymous pages
> entirely at this point when it comes to aging. They're really not. The
> LRU lists are split to differentiate access patterns and cost of page
> stealing (and restoring). From that angle, MADV_FREE pages really have
> nothing in common with in-use anonymous pages, and so they shouldn't
> be on the same LRU list.
>=20
> That would also fix the very unfortunate and unexpected consequence of
> tying the lazy free optimization to the availability of swap space.
>=20
> I would prefer to see this addressed before the code goes upstream.

I don't think it would be ideal for these potentially very hot pages to
be dropped before very cold pages were swapped out. It's the kind of
tuning that needs to be informed by lots of real world experience and
lots of testing. It wouldn't impact the API.

Whether MADV_FREE is useful as an API vs. something like a pair of
system calls for pinning and unpinning memory is what should be worried
about right now. The internal implementation just needs to be correct
and useful right now, not perfect. Simpler is probably better than it
being more well tuned for an initial implementation too.


--SIniK9POceDHqW8AWkRjx172aJX0cGs4j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOn0hAAoJEPnnEuWa9fIqwqQP/0Mbf4HS1hsGCrhHLcpn9U0o
VA+N8QVO/x4Rb05Qkpm7Nr8ZqJsnda0wqjM7Ei75MXx4Mc6n4xsQnrpCKwtyr+q9
taJZYvpKJjvkaHKt0s9HGTX2dns5+Hdxwmqn0tYqHMPQYXQse55RTgBqtfzZ65N5
CzNzyampw5bSu50e+702un5Ew2ZLeDIop1whzGc2kSWafCTuxv2t1F3JZoWZD7dk
T7A873bxft7aUUQFt+GA4kd7PgsNrN4zdfIB5IucHsFda6Hei8wLe519caPbG9CF
627AAMStLhztFxN9FbW+PozGeh3dP99lgy2RTdWtoVmcNjLQ3qK/8N0L28lF1QXU
iVFChkpW7o8gtnIVdACQSpZD8KtSfYMlUQas4Xg5mXj/tOS45l65FFfZ1mRPXqYg
PEF0AoHcTSH9DXRVB+AOkCFLHIhYlZvYuQeQ1/Tx6G29n8Op29YZUf+eWxVYf0sx
0kyADd3PMSDd8l1l/vugf6AUiRqW52cFjnBzSweVkGZITGqs2+Jf1t1NfI/W0NOw
/sRTwRT00y58lEEy8qZO7/piUzYIoobWpmlowCw2fiGycbOx2VvvUryeSxw0BZxW
XrhbombAt5F/Imz8mI+IoNnQR9BU6GyNdT9vnKc0nBAEjD/raKt606sqXI+nWM8W
qF2Wf2dpy39NE5D3c3To
=hwJg
-----END PGP SIGNATURE-----

--SIniK9POceDHqW8AWkRjx172aJX0cGs4j--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
