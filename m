Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25FA86B0279
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 19:53:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 86so13128614pfq.11
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 16:53:16 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id s13si896259plj.570.2017.06.26.16.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 16:53:15 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id u36so2034580pgn.3
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 16:53:15 -0700 (PDT)
Date: Tue, 27 Jun 2017 07:53:12 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 3/4] mm/hotplug: make __add_pages() iterate on
 memory_block and split __add_section()
Message-ID: <20170626235312.GE53180@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-4-richard.weiyang@gmail.com>
 <559864c6-6ad6-297a-3094-8abecbd251b9@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="lkTb+7nhmha7W+c3"
Content-Disposition: inline
In-Reply-To: <559864c6-6ad6-297a-3094-8abecbd251b9@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org


--lkTb+7nhmha7W+c3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 26, 2017 at 12:50:14AM -0700, John Hubbard wrote:
>On 06/24/2017 07:52 PM, Wei Yang wrote:
>> Memory hotplug unit is memory_block which contains one or several
>> mem_section. The current logic is iterating on each mem_section and add =
or
>> adjust the memory_block every time.
>>=20
>> This patch makes the __add_pages() iterate on memory_block and split
>> __add_section() to two functions: __add_section() and __add_memory_block=
().
>>=20
>> The first one would take care of each section data and the second one wo=
uld
>> register the memory_block at once, which makes the function more clear a=
nd
>> natural.
>>=20
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  drivers/base/memory.c | 17 +++++------------
>>  mm/memory_hotplug.c   | 27 +++++++++++++++++----------
>>  2 files changed, 22 insertions(+), 22 deletions(-)
>>=20
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index b54cfe9cd98b..468e5ad1bc87 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -705,19 +705,12 @@ int register_new_memory(int nid, struct mem_sectio=
n *section)
>> =20
>>  	mutex_lock(&mem_sysfs_mutex);
>> =20
>> -	mem =3D find_memory_block(section);
>> -	if (mem) {
>> -		mem->section_count++;
>> -		put_device(&mem->dev);
>> -	} else {
>> -		ret =3D init_memory_block(&mem, section, MEM_OFFLINE);
>> -		if (ret)
>> -			goto out;
>> -		mem->section_count++;
>> -	}
>> +	ret =3D init_memory_block(&mem, section, MEM_OFFLINE);
>> +	if (ret)
>> +		goto out;
>> +	mem->section_count =3D sections_per_block;
>
>Hi Wei,
>
>Things have changed...the register_new_memory() routine is accepting a sin=
gle section,
>but instead of registering just that section, it is registering a containi=
ng block.
>(That works, because apparently the approach is to make sections_per_block=
 =3D=3D 1,
>and eventually kill sections, if I am reading all this correctly.)
>

The original function is a little confusing. Actually it tries to register a
memory_block while it register it for several times, on each present
mem_section actually.

This change here will register the whole memory_block at once.

You would see in next patch it will accept the start section number instead=
 of
a section, while maybe more easy to understand it.

BTW, I don't get your point on kill sections when sections_per_block =3D=3D=
 The
original function is a little confusing. Actually it tries to register a
memory_block while it register it for several times, on each present
mem_section actually.

This change here will register the whole memory_block at once.

You would see in next patch it will accept the start section number instead=
 of
a section, while maybe more easy to understand it.

BTW, I don't get your point on kill sections when sections_per_block =3D=3D=
 1.
Would you rephrase this?

>So, how about this: let's add a line to the function comment:=20
>
>* Register an entire memory_block.
>

May look good, let me have a try.

>That makes it clearer that we're dealing in blocks, even though the memsec=
tion*
>argument is passed in.
>
>> =20
>> -	if (mem->section_count =3D=3D sections_per_block)
>> -		ret =3D register_mem_sect_under_node(mem, nid);
>> +	ret =3D register_mem_sect_under_node(mem, nid);
>>  out:
>>  	mutex_unlock(&mem_sysfs_mutex);
>>  	return ret;
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index a79a83ec965f..14a08b980b59 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -302,8 +302,7 @@ void __init register_page_bootmem_info_node(struct p=
glist_data *pgdat)
>>  }
>>  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
>> =20
>> -static int __meminit __add_section(int nid, unsigned long phys_start_pf=
n,
>> -		bool want_memblock)
>> +static int __meminit __add_section(int nid, unsigned long phys_start_pf=
n)
>>  {
>>  	int ret;
>>  	int i;
>> @@ -332,6 +331,18 @@ static int __meminit __add_section(int nid, unsigne=
d long phys_start_pfn,
>>  		SetPageReserved(page);
>>  	}
>> =20
>> +	return 0;
>> +}
>> +
>> +static int __meminit __add_memory_block(int nid, unsigned long phys_sta=
rt_pfn,
>> +		bool want_memblock)
>> +{
>> +	int ret;
>> +
>> +	ret =3D __add_section(nid, phys_start_pfn);
>> +	if (ret)
>> +		return ret;
>> +
>>  	if (!want_memblock)
>>  		return 0;
>> =20
>> @@ -347,15 +358,10 @@ static int __meminit __add_section(int nid, unsign=
ed long phys_start_pfn,
>>  int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>>  			unsigned long nr_pages, bool want_memblock)
>>  {
>> -	unsigned long i;
>> +	unsigned long pfn;
>>  	int err =3D 0;
>> -	int start_sec, end_sec;
>>  	struct vmem_altmap *altmap;
>> =20
>> -	/* during initialize mem_map, align hot-added range to section */
>> -	start_sec =3D pfn_to_section_nr(phys_start_pfn);
>> -	end_sec =3D pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
>> -
>>  	altmap =3D to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
>>  	if (altmap) {
>>  		/*
>> @@ -370,8 +376,9 @@ int __ref __add_pages(int nid, unsigned long phys_st=
art_pfn,
>>  		altmap->alloc =3D 0;
>>  	}
>> =20
>> -	for (i =3D start_sec; i <=3D end_sec; i++) {
>> -		err =3D __add_section(nid, section_nr_to_pfn(i), want_memblock);
>> +	for (pfn; pfn < phys_start_pfn + nr_pages;
>> +			pfn +=3D sections_per_block * PAGES_PER_SECTION) {
>

yep

>A pages_per_block variable would be nice here, too.
>
>thanks,
>john h
>
>> +		err =3D __add_memory_block(nid, pfn, want_memblock);
>> =20
>>  		/*
>>  		 * EEXIST is finally dealt with by ioresource collision
>>=20

--=20
Wei Yang
Help you, Help me

--lkTb+7nhmha7W+c3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZUZ5oAAoJEKcLNpZP5cTduwEQALcalOJAby1dP/5T2eXRspZB
38WSZR9Tn6RDwVE9P/QWqv1AAa51LlQPv+t8uMNA42xXDbo/pXqgEiQuxoLXyZVI
CJEY4RBdfbYEXuiYvrLVkz5lG6BkPRQh0UfAUfSHMkmdpCyLCfiCJ/ylsKjDc0kT
7xJNj9bSLpaXW0oCURpnpvVQI/R7msXEH/4IAYrhFhvkMs8MkeCfNHbu3AlXVHsf
Nyxzhuy1s7kbVFxATXOtPH+O6k1oo2+9Kx6lnxY9mw8T1UM5mUgLd9nZbX19pWLI
kUIor2/9x5YhXAV8Vat+Oac/d/Mp3h0XJq3uS2lnsnpVz6b7C00wW2kzkf56z5yz
gNDagA5h7c07gYJX6pV2y2+K06FLON23LJqfmKFOdOfDQDBEPLpD26rvQBgJ2sNL
uhiSrjIHo06eoqv1GMPNBVgJz7Dxs9+jdkY3lR7q/OmFjE9qOUWB5W1efeDJGsgk
aVetyNkiq7vynTrSgbDer1k1NNDI3GaO2p2VsvcT3vHKLFgoicxLRwB9ANW8f9hn
tfWPlD1+vMbMDLhnIDy3OTwwy+U5cZlu6r2WoAd03+Ld9itVxZRQax58Xc5vn6Ly
5mwI5+Aw2cUtxjgjuhSJk0nihAFe0/av2qy3b9tsnCs+BiJLSj56SYF3uFkvw2z2
M65Mh6yHAjIqpMVPnhFH
=0RmB
-----END PGP SIGNATURE-----

--lkTb+7nhmha7W+c3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
