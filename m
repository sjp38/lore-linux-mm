Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6AD16B025E
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:05:24 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so195821412pgi.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:05:24 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 64si7172524plk.173.2017.02.08.06.05.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 06:05:23 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 194so15291146pgd.0
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:05:23 -0800 (PST)
Date: Wed, 8 Feb 2017 22:05:18 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170208140518.GA67800@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
 <20170207094557.GE5065@dhcp22.suse.cz>
 <20170207153247.GB31837@WeideMBP.lan>
 <20170207154120.GW5065@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
In-Reply-To: <20170207154120.GW5065@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 07, 2017 at 04:41:21PM +0100, Michal Hocko wrote:
>On Tue 07-02-17 23:32:47, Wei Yang wrote:
>> On Tue, Feb 07, 2017 at 10:45:57AM +0100, Michal Hocko wrote:
>[...]
>> >Is there any reason why for_each_mem_pfn_range cannot be changed to
>> >honor the given start/end pfns instead? I can imagine that a small zone
>> >would see a similar pointless iterations...
>> >
>>=20
>> Hmm... No special reason, just not thought about this implementation. And
>> actually I just do the similar thing as in zone_spanned_pages_in_node(),=
 in
>> which also return 0 when there is no overlap.
>>=20
>> BTW, I don't get your point. You wish to put the check in
>> for_each_mem_pfn_range() definition?
>
>My point was that you are handling one special case (an empty zone) but
>the underlying problem is that __absent_pages_in_range might be wasting
>cycles iterating over memblocks that are way outside of the given pfn
>range. At least this is my understanding. If you fix that you do not
>need the special case, right?

Yep, I think this is a good suggestion. By doing do, this could save iterat=
ing
cycles in __absent_pages_in_range().=20

Hmm, the case is a little bit different in zone_absent_pages_in_node() in c=
ase
there is movable zone in this node. Even __absent_pages_in_range() returns =
0,
it is not a proof that this node has no page in this zone. Which means, we
still need to go through the ZONE_MOVABLE handling part, which is a memblock
iteration too.

Let's take a look whether guard __absent_pages_in_range() internally is
necessary now.

The function itself is invoked at three places:

* numa_meminfo_cover_memory()
* zone_absent_pages_in_node()
* absent_pages_in_range()

The first one is invoked on numa_meminfo which is sanitized by
numa_cleanup_meminfo().
The second one is analysed here.

The third one is invoked at two places:
* numa_meminfo_cover_memory()
* mem_hole_size()

At the first place, it is passed with (0, max_pfn) as parameter, which I th=
ink
is not common to have max_pfn to be 0.
At the second place, the start_pfn and end_pfn is already guarded.

With all those status, currently I choose to put the check in
zone_absent_pages_in_node().

BTW, the ZONE_MOVABLE handling looks strange to me and the comment "Treat
pages to be ZONE_MOVABLE in ZONE_NORMAL as absent pages and vice versa" is
hard to understand. From the code point of view, if zone_type is ZONE_NORMA=
L,
each memblock region between zone_start_pfn and zone_end_pfn would be treat=
ed
as absent pages if it is not mirrored. Do you have some hint on this?

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYmyWdAAoJEKcLNpZP5cTdEJ8P/jsB8jho+t9DFtAkivRCJox2
YmZW9nSRV+8cG1r2IUb1oqLM5LXK7SkQhtnkPBQZ1Utty7fIhXFDvcbpzCffxFYH
XNPSP1vS+nmZ9OF7ncAaPnxAEuTwiwuYVc8XEm3Thr1RnARRw09BryO9hS5d2Kge
TGuZujmTkWUmwXF8MwFsFHa+VsgHQ5wORHl0iFLrdRKSBnUa1sI+GHdR9LfTIAjG
QbAOAO8cHwN7hSreYW97sJc70Fpw7SGH79kOcyKSUU/UVRepxrvCJgpM45t2pYBj
aCH42BwJXv6CFQm9uOgUCgUX9IbpYBcWVPsebhaEoQRsZ69z4wUmAYQjaKFsruui
CceJy6wKipb69gqUHiTNZPuf/ldqNjdJgoOPfTxTaog6NYgTR/ctY7t5tON8pBvd
mXpGPxjTxhpX+giomm9o7qN7eEgEK4V7ljHFqXl1iP961ZqywJzUfrMHHqYp2DMX
sehrNSZuQxtcgPUON+DRHifHd8c6zzGyt7xiK4zuOYzOWJCG3tIXDYoYLqIXngyY
bfNAWhgxym3zIN0KEXq/4LvXCMfnxSUlkLPJUg1ckQwtgKLQr/0LUIiZasq7ylxn
2GQ0tm8LwERIXbwIx+nmn0DRTBvTjNNAIYfK25c2YN13R810R8mq2hKcXCb5DTz0
uxEzyTp3ynb7t1zSVyK3
=NqOp
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
