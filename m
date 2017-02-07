Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDA6A6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:32:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 204so153973140pge.5
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:32:49 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 26si4347570pfo.243.2017.02.07.07.32.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 07:32:48 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 19so9526454pfo.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:32:48 -0800 (PST)
Date: Tue, 7 Feb 2017 23:32:47 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170207153247.GB31837@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
 <20170207094557.GE5065@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="eJnRUKwClWJh1Khz"
Content-Disposition: inline
In-Reply-To: <20170207094557.GE5065@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--eJnRUKwClWJh1Khz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 07, 2017 at 10:45:57AM +0100, Michal Hocko wrote:
>On Mon 06-02-17 23:43:14, Wei Yang wrote:
>> The whole memory space is divided into several zones and nodes may have =
no
>> page in some zones. In this case, the __absent_pages_in_range() would
>> return 0, since the range it is searching for is an empty range.
>>=20
>> Also this happens more often to those nodes with higher memory range when
>> there are more nodes, which is a trend for future architectures.
>
>I do not understand this part. Why would we see more zones with zero pfn
>range in higher memory ranges.
>

Based on my understanding, zone boundary is fixed address. For example, on
x84_64, ZONE_DMA is < 16M, ZONE_DMA32 is < 4G. And similar rules apply to
sparc, ia64, s390 as shown in the comment of ZONE definition.

For example, currently we see a server with 8 NUMA nodes and with 4T memory.
Those zone boundaries may all sits in the first node range, so that the nod=
es
with higher memory range may all sits in the last zone, which is ZONE_NORMA=
L I
think. During the memory initialization, for each node we still iterate on
each zone and calculate the memory range in each zone. By doing so, those
nodes with higher memory range will see several empty zones.

>> This patch checks the zone range after clamp and adjustment, return 0 if
>> the range is an empty range.
>
>I assume the whole point of this patch is to save
>__absent_pages_in_range which iterates over all memblock regions, right?

Yes, you are right. Since we know there is no overlap, it is not necessary =
to
do the iteration on memblock.

>Is there any reason why for_each_mem_pfn_range cannot be changed to
>honor the given start/end pfns instead? I can imagine that a small zone
>would see a similar pointless iterations...
>

Hmm... No special reason, just not thought about this implementation. And
actually I just do the similar thing as in zone_spanned_pages_in_node(), in
which also return 0 when there is no overlap.

BTW, I don't get your point. You wish to put the check in
for_each_mem_pfn_range() definition?

>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  mm/page_alloc.c | 5 +++++
>>  1 file changed, 5 insertions(+)
>>=20
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6de9440e3ae2..51c60c0eadcb 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5521,6 +5521,11 @@ static unsigned long __meminit zone_absent_pages_=
in_node(int nid,
>>  	adjust_zone_range_for_zone_movable(nid, zone_type,
>>  			node_start_pfn, node_end_pfn,
>>  			&zone_start_pfn, &zone_end_pfn);
>> +
>> +	/* If this node has no page within this zone, return 0. */
>> +	if (zone_start_pfn =3D=3D zone_end_pfn)
>> +		return 0;
>> +
>>  	nr_absent =3D __absent_pages_in_range(nid, zone_start_pfn, zone_end_pf=
n);
>> =20
>>  	/*
>> --=20
>> 2.11.0
>>=20
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--eJnRUKwClWJh1Khz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYmeifAAoJEKcLNpZP5cTd4gQP/054pUoEJoUc90rWVVcCxn53
zjflDKOkZ5VybV3VCng0tHJQ4onJICPTX5+efs7BHrktNAiNiOG5X1sWiLsQvqoy
LVSN5MjmCW59nvoRfK95JBsYQWbU785+7NbHIO0pSM+ly5fRhuISUIoOdh273JPE
+yUwun0UO4QFc50kflhdQ/m8tA9YXsmb0eh0EEHeyoDMzI3S1gMyb0i+VxIpLfhA
l9EzB0WS6QVYzb2GE2CfAHzD+Bw+fc945Ofpid7xhWOYlZ1Me4QFheXgpxNLrtGa
5CDcjMLGJOLay6pIkTQGRJF/w6ySEnif1GI2XYiZ9WRm9Z/E12j0SuV6JOlRQ7JI
/xaOTo5YLRbkegqHWhHg1/ztGSYmbRCLwms7yIrZ4v2+bqi1TWFcwNPF98MLVYiM
I6Avn2hkChictzlZHqShHpVFDT/XxYQN0yedFaOT2MGuCAhmoNRWDkHTafKbOL0q
tuJDc8an31qyYn5LjPU9zf5aIN7SI8S+bNV4RI7ubZgSsVKpJMTc2Pc9IhFZB06U
2yFZoCKm6Wuqymv4HVOD9eXntHregRQfVJ9ab/7DEyyw8c/+xg9ViQ9R0/KF/3Mx
CpDF807PFaqnwzkJHgNY6dJQFAtwH1MjjCaTMcDPmDtpE6olG2KoFTz4QeP4eIDx
wZ+BrHmv9GscdtQFxGkh
=t7jD
-----END PGP SIGNATURE-----

--eJnRUKwClWJh1Khz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
