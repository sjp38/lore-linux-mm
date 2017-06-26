Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 587706B02C3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 19:40:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 76so13664477pgh.11
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 16:40:42 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id 1si897958plo.403.2017.06.26.16.40.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 16:40:41 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id d5so2222921pfe.1
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 16:40:41 -0700 (PDT)
Date: Tue, 27 Jun 2017 07:40:38 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 2/4] mm/hotplug: walk_memroy_range on memory_block uit
Message-ID: <20170626234038.GD53180@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-3-richard.weiyang@gmail.com>
 <eeb06db0-086a-29f9-306d-a702984594df@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="W5WqUoFLvi1M7tJE"
Content-Disposition: inline
In-Reply-To: <eeb06db0-086a-29f9-306d-a702984594df@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org


--W5WqUoFLvi1M7tJE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 26, 2017 at 12:32:40AM -0700, John Hubbard wrote:
>On 06/24/2017 07:52 PM, Wei Yang wrote:
>> hotplug memory range is memory_block aligned and walk_memroy_range guard=
ed
>> with check_hotplug_memory_range(). This is save to iterate on the
>> memory_block base.>=20
>> This patch adjust the iteration unit and assume there is not hole in
>> hotplug memory range.
>
>Hi Wei,
>
>In the patch subject, s/memroy/memory/ , and s/uit/unit/, and
>s/save/safe.
>

Nice.

>Actually, I still have a tough time with it, so maybe the=20
>description above could instead be worded approximately
>like this:
>
>Given that a hotpluggable memory range is now block-aligned,
>it is safe for walk_memory_range to iterate by blocks.
>
>Change walk_memory_range() so that it iterates at block
>boundaries, rather than section boundaries. Also, skip the check
>for whether pages are present in the section, and assume=20
>that there are no holes in the range. (<Insert reason why=20
>that is safe, here>)
>

Sounds better than mine :-)

>
>>=20
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  mm/memory_hotplug.c | 10 ++--------
>>  1 file changed, 2 insertions(+), 8 deletions(-)
>>=20
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index f5d06afc8645..a79a83ec965f 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1858,17 +1858,11 @@ int walk_memory_range(unsigned long start_pfn, u=
nsigned long end_pfn,
>>  	unsigned long pfn, section_nr;
>>  	int ret;
>> =20
>> -	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D PAGES_PER_SECTION) {
>> +	for (pfn =3D start_pfn; pfn < end_pfn;
>> +		pfn +=3D PAGES_PER_SECTION * sections_per_block) {
>
>Here, and in one or two other spots in the patch, it would be nice
>to repeat your approach from patch 0001, where you introduced a
>pages_per_block variable. That definitely helps when reading the code.
>

Sounds nice, let me try to introduce the pages_per_block.

>>  		section_nr =3D pfn_to_section_nr(pfn);
>> -		if (!present_section_nr(section_nr))
>> -			continue;
>
>Why is it safe to assume no holes in the memory range? (Maybe Michal's=20
>patch already covered this and I haven't got that far yet?)
>
>The documentation for this routine says that it walks through all
>present memory sections in the range, so it seems like this patch
>breaks that.
>

Hmm... it is a little bit hard to describe.

First the documentation of the function is a little misleading. When you lo=
ok
at the code, it call the "func" only once for a memory_block, not for every
present mem_section as it says. So have some memory in the memory_block wou=
ld
meet the requirement.

Second, after the check in patch 1, it is for sure the range is memory_block
aligned, which means it must have some memory in that memory_block. It would
be strange if someone claim to add a memory range but with no real memory.

This is why I remove the check here.


>> =20
>>  		section =3D __nr_to_section(section_nr);
>> -		/* same memblock? */
>> -		if (mem)
>> -			if ((section_nr >=3D mem->start_section_nr) &&
>> -			    (section_nr <=3D mem->end_section_nr))
>> -				continue;
>
>Yes, that deletion looks good.
>

=46rom this we can see, if there IS some memory, the function will be invok=
ed
and only invoked once.

>thanks,
>john h
>
>> =20
>>  		mem =3D find_memory_block_hinted(section, mem);
>>  		if (!mem)
>>=20

--=20
Wei Yang
Help you, Help me

--W5WqUoFLvi1M7tJE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZUZt2AAoJEKcLNpZP5cTdD9AQAKrxyXCHPFuHqEqFGOB7NhXt
VOF9Bp2BnXLih8rCjBhmIiGi4dEHC5Tcur+F5RbyJU0NjrEJm7Aykvy51LVXxiBG
OWcMgEYd1G3AF9/v1h4HHe+ZQ064CQQ1FOtE+pY+tVHCeAyNdkRSIySi88ARS6D7
MjLb966hsVQjc2v0seBI57Xpck3VBNGvpwmytWr5r8QZsRzumsoekZ8uJW0UI8qv
llgOMo2j1/3MICjEnmi9SccRNeqywuH8Edb/90DK0So+fHP3yyvGs4gn8Yx2am9F
DGKOaCqmKEtKv9/MY4tbjA2Wp5QzEgeyNhP40G/AijXG0AxE19STOQOXjZIi+6yU
Rs8AoxH6eVf/ODWi0iP8IJlRVdxqH4BFk/X7qJfAXsHcMLmaMZ/H/2rleKoLaFeS
Sd2+0QNxyD6oV3Ne5a4Q1RAAgDPWG4gpvs9+1BFcbwxyPiPMmx4KAe08ejAwMzVq
ZE4I0bbxs9Gdt+6jFPOTxQnANbrm0qC67pRvRrk70ycvLtohDIjjYblCcZKU8yxt
BFXXn4YrC3xykgjIQFAuXRKoHnCo6y15OSPL5FTxIt0x4jNQOHWn/0K6MOlzbcNx
VybSU0DZad6tjBnMjWyM6QVahWcpedm4xsDn03Akiv+Cl9yF/pKkc6R82ceA7PVK
IGKAHLhtmzvwzps41bVC
=bdsL
-----END PGP SIGNATURE-----

--W5WqUoFLvi1M7tJE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
