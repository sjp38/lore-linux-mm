Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB7B16B0292
	for <linux-mm@kvack.org>; Sun, 25 Jun 2017 20:20:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3so83601591pfc.4
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 17:20:10 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id b3si7948731pgr.166.2017.06.25.17.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Jun 2017 17:20:09 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id f127so13334823pgc.2
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 17:20:09 -0700 (PDT)
Date: Mon, 26 Jun 2017 08:20:06 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 1/4] mm/hotplug: aligne the hotplugable range with
 memory_block
Message-ID: <20170626002006.GA47120@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-2-richard.weiyang@gmail.com>
 <be965d3a-002b-9a9f-873b-b7237238ac21@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="EVF5PPMfhYS0aIcm"
Content-Disposition: inline
In-Reply-To: <be965d3a-002b-9a9f-873b-b7237238ac21@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 24, 2017 at 08:31:20PM -0700, John Hubbard wrote:
>On 06/24/2017 07:52 PM, Wei Yang wrote:
>> memory hotplug is memory block aligned instead of section aligned.
>>=20
>> This patch fix the range check during hotplug.
>>=20
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  drivers/base/memory.c  | 3 ++-
>>  include/linux/memory.h | 2 ++
>>  mm/memory_hotplug.c    | 9 +++++----
>>  3 files changed, 9 insertions(+), 5 deletions(-)
>>=20
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index c7c4e0325cdb..b54cfe9cd98b 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -31,7 +31,8 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
>> =20
>>  #define to_memory_block(dev) container_of(dev, struct memory_block, dev)
>> =20
>> -static int sections_per_block;
>> +int sections_per_block;
>> +EXPORT_SYMBOL(sections_per_block);
>
>Hi Wei,
>
>Is sections_per_block ever assigned a value? I am not seeing that happen,
>either in this patch, or in the larger patchset.
>

This is assigned in memory_dev_init(). Not in my patch.

>
>> =20
>>  static inline int base_memory_block_id(int section_nr)
>>  {
>> diff --git a/include/linux/memory.h b/include/linux/memory.h
>> index b723a686fc10..51a6355aa56d 100644
>> --- a/include/linux/memory.h
>> +++ b/include/linux/memory.h
>> @@ -142,4 +142,6 @@ extern struct memory_block *find_memory_block(struct=
 mem_section *);
>>   */
>>  extern struct mutex text_mutex;
>> =20
>> +extern int sections_per_block;
>> +
>>  #endif /* _LINUX_MEMORY_H_ */
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 387ca386142c..f5d06afc8645 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1183,11 +1183,12 @@ static int check_hotplug_memory_range(u64 start,=
 u64 size)
>>  {
>>  	u64 start_pfn =3D PFN_DOWN(start);
>>  	u64 nr_pages =3D size >> PAGE_SHIFT;
>> +	u64 page_per_block =3D sections_per_block * PAGES_PER_SECTION;
>
>"pages_per_block" would be a little better.
>
>Also, in the first line of the commit, s/aligne/align/.

Good, thanks.

>
>thanks,
>john h
>
>> =20
>> -	/* Memory range must be aligned with section */
>> -	if ((start_pfn & ~PAGE_SECTION_MASK) ||
>> -	    (nr_pages % PAGES_PER_SECTION) || (!nr_pages)) {
>> -		pr_err("Section-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
>> +	/* Memory range must be aligned with memory_block */
>> +	if ((start_pfn & (page_per_block - 1)) ||
>> +	    (nr_pages % page_per_block) || (!nr_pages)) {
>> +		pr_err("Memory_block-unaligned hotplug range: start 0x%llx, size 0x%l=
lx\n",
>>  				(unsigned long long)start,
>>  				(unsigned long long)size);
>>  		return -EINVAL;
>>=20

--=20
Wei Yang
Help you, Help me

--EVF5PPMfhYS0aIcm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZUFM2AAoJEKcLNpZP5cTd/28QAIuAlQBTl/beFvDbQvMqmnd3
eeNxUymqhmNSuhFujXp2kolPKGNmP9BdvDiyglYujkXRRgBU2O0rHO4eoXBorAc3
7HJui41hN9Q1k46xYGlsp2GZllouFiHzQUPZXZ9rdx3chCnCkdcwAbQNqZ00jfpc
hjAYPem11Pqxr3gwsGcf2j4CxmJRrzHonp6fKI5M1WNbQ311wkJAHxf3mE/V/4+U
Zbzm/wNu7lE9Le3eghXd6qMSLDG2Pdz7A0ZtW5C+FlSSaNfRelQmlW6SXOWUWIYY
UTkZJ+LHD9iBGnidjbLl0G9c8fwkBP+iCaLAQQ+yBbP1OctX0tO4YNeTS3b6Zh9u
pWOyQYXYHyzO8TrnZRc8ZVslZRqb0/nssB7tqLKp7vFfs3fsOC3Ypxy+SaYslFKP
uCpAF5xkqCFJ56n+LOFKG3hi+3et6b2El0uc9C5rscco+afdR0lDwpupxGFDfSHl
VycL6xdLTT+djokc/1lQsQUbbAM84F0jLDko+AMvPzbNreexPl94bogzq8P9LVKF
p8usivjFk2iQn7ZdGCixFOn7C/TI31SmRpuLwWJVgIMVh0uAWL/j8LyHOLcdtmqg
3MiBpg8n12aofg0K9aJBkB4TX2YmU92US1cKPtYxHeBH3tAlATA8yRXhC5fzp4pA
ueIpIdWCi74brIBkyvxf
=ruD8
-----END PGP SIGNATURE-----

--EVF5PPMfhYS0aIcm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
