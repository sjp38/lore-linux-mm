Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41E866B02C3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 04:11:46 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 33so9486434pgx.14
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 01:11:46 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id y10si1361139pgo.124.2017.06.16.01.11.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 01:11:45 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id d5so4903995pfe.1
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 01:11:45 -0700 (PDT)
Date: Fri, 16 Jun 2017 16:11:42 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 11/14] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
Message-ID: <20170616081142.GA3871@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-12-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
In-Reply-To: <20170515085827.16474-12-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Well, I love this patch a lot. We don't need to put the hotadd memory in one
zone and move it to another. This looks great!

On Mon, May 15, 2017 at 10:58:24AM +0200, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
[...]
+
>+void move_pfn_range_to_zone(struct zone *zone,
>+		unsigned long start_pfn, unsigned long nr_pages)
>+{
>+	struct pglist_data *pgdat =3D zone->zone_pgdat;
>+	int nid =3D pgdat->node_id;
>+	unsigned long flags;
>+	unsigned long i;
>+
>+	if (zone_is_empty(zone))
>+		init_currently_empty_zone(zone, start_pfn, nr_pages);
>+
>+	clear_zone_contiguous(zone);
>+
>+	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that =
before */
>+	pgdat_resize_lock(pgdat, &flags);
>+	zone_span_writelock(zone);
>+	resize_zone_range(zone, start_pfn, nr_pages);
>+	zone_span_writeunlock(zone);
>+	resize_pgdat_range(pgdat, start_pfn, nr_pages);
>+	pgdat_resize_unlock(pgdat, &flags);
>+
>+	/*
>+	 * TODO now we have a visible range of pages which are not associated
>+	 * with their zone properly. Not nice but set_pfnblock_flags_mask
>+	 * expects the zone spans the pfn range. All the pages in the range
>+	 * are reserved so nobody should be touching them so we should be safe
>+	 */
>+	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn, MEMMAP_HOTPLU=
G);
>+	for (i =3D 0; i < nr_pages; i++) {
>+		unsigned long pfn =3D start_pfn + i;
>+		set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
> 	}

memmap_init_zone()->__init_single_page()->set_page_links()

Do I miss something that you call set_page_links() explicitly here?

--=20
Wei Yang
Help you, Help me

--AqsLC8rIMeq19msA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIbBAEBCAAGBQJZQ5K9AAoJEKcLNpZP5cTdy24P+I9NC7LQ0mVVp4mF8M36iAus
6BwFp8fa28F8Gh4np7Ksc9XbBYEqFVlJ1fE+U4bBojHslvaeZRNmKZcQHR5QgJ9Q
tFUYVl9gs09HRIdGANhCcy2/kcjGAhJEj051UeqtSDwFBtssDqnCLJfdPa3FuZSN
+vy3vJcUFu97GCnonS+A/HxKyovQEOQYAwufMa6GI11bdM1Ro6HUQcX2V/w2xp4c
dOYaFhqIppzgjHK72O1o9SkAuKC903CEcJ4hEzypw01xf27CGiLq00UhbW5eDnYz
u5kmKz2KCOCSTYTlh9IvYvQbJKd4k8o1HI/vBAREmGBWuAf/Q0aS9Xvo8EaPfCtw
feGBW9ETLnea7LoZP1Why6qarZu/r+crJdiCTPjaPHuLaHdej4xkplnCJRALvqs3
RjgJbcqsj5clIg11GfPgwBzU3nvyM5q1fD/TAnDIlihyRoDPnPe8fVL/xgiGh2qR
9F/Il4OnKM9f7I6d13bcLPXEsyqjHA9L7A/a/RU+sGqH97kmHQzKpDSndHSvkOFF
luRbnClwl6OwzLtH4HmPoXQERPnRvKEgFjXxWJHAUg/wV9oUj8qehytJhtCdL01n
nbgJYoClzC5RLrh5G3j2bNGPrvpGWVwjU9IBkpQ4H5TZp43LOf3yId3Eq9AOk9+/
m+4Rm2mSWEp9iQ+w61s=
=8E87
-----END PGP SIGNATURE-----

--AqsLC8rIMeq19msA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
