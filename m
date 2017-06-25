Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9ACDC6B0292
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 20:14:17 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u36so80335997pgn.5
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 17:14:17 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id j25si6167176pgn.409.2017.06.24.17.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 17:14:16 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id e187so10765463pgc.3
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 17:14:16 -0700 (PDT)
Date: Sun, 25 Jun 2017 08:14:13 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 11/14] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
Message-ID: <20170625001413.GA43522@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-12-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="WIyZ46R2i8wDzkSu"
Content-Disposition: inline
In-Reply-To: <20170515085827.16474-12-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 15, 2017 at 10:58:24AM +0200, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
[...]
>+void move_pfn_range_to_zone(struct zone *zone,
>+		unsigned long start_pfn, unsigned long nr_pages)
>+{
>+	struct pglist_data *pgdat =3D zone->zone_pgdat;
>+	int nid =3D pgdat->node_id;
>+	unsigned long flags;
>+	unsigned long i;

This is an unused variable:

  mm/memory_hotplug.c: In function =E2=80=98move_pfn_range_to_zone=E2=80=99:
  mm/memory_hotplug.c:895:16: warning: unused variable =E2=80=98i=E2=80=99 =
[-Wunused-variable]

Do you suggest me to write a patch or you would fix it in your later rework?

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
>=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--WIyZ46R2i8wDzkSu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZTwBVAAoJEKcLNpZP5cTdenEP/1AkHjHqkfOfFd30ID2h4MfU
dgLCqNauA7c8oRAsT4JIfGhDzweueF6plyDJq4Rl8terOYW8c2Yu0NflisJX9GTQ
SCAlkYIxI2t5Vj8cPkBIEQE2/dLjKtmEq4tJjUngtLtvaOl054qzkdeTxHhIN553
L5ZG9cuw91gz4C0jPUNUHU4sh6FdBRPCLe+OZwaarI8ZMX4H8w3bfLScCXzhHIHG
K2evDLGpBPFc6kit1B/uhJuDlU2X1gPdrttSBtpfnySG/HDaLzg4Mv02dEHIju0t
zrEP7bOVOryG9JPuVrgbTFQxmdlINkJDyu3ecsbeE+mbTkZK9Fssdbc0aINxpHwG
b5H11BJ0XOChT/rJF9kHGv1aMJZtk9YtCm4/2XbbOglKu+Tllq67An23l1AOYeik
m4knWyFdMWDHrYNS7mD3nJXQjFLyB+Mf5nzi6wF+3yaofBrc/qTdUQJI1Ls84iO0
YpYUGwUwuWMpALJYeAxOCeGRD9MQNnSeoLWcmsG6OxuZv9oAgP/JkG1n/xfCFq72
lJqGbq0inKlouizUQ3v56IiqmTXdv6j96SU9SdBGJn1b9bbVk2xCUwYMRhwqDaYk
9HNHR18PyVFIr/dD6/c4D9EG+QuoBL64hmyyCpmnz/pia22EnPRoRV568FnepUpe
JcYzMxsvuPjJM6AcSd1I
=ZVRy
-----END PGP SIGNATURE-----

--WIyZ46R2i8wDzkSu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
