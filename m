Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB286B0315
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 05:11:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h21so32632832pfk.13
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 02:11:22 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id b80si1476275pfb.79.2017.06.16.02.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 02:11:21 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id y7so5221535pfd.3
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 02:11:21 -0700 (PDT)
Date: Fri, 16 Jun 2017 17:11:17 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 11/14] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
Message-ID: <20170616091117.GA4716@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-12-mhocko@kernel.org>
 <20170616081142.GA3871@WeideMacBook-Pro.local>
 <20170616084555.GD30580@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
In-Reply-To: <20170616084555.GD30580@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 16, 2017 at 10:45:55AM +0200, Michal Hocko wrote:
>On Fri 16-06-17 16:11:42, Wei Yang wrote:
>> Well, I love this patch a lot. We don't need to put the hotadd memory in=
 one
>> zone and move it to another. This looks great!
>>=20
>> On Mon, May 15, 2017 at 10:58:24AM +0200, Michal Hocko wrote:
>> >From: Michal Hocko <mhocko@suse.com>
>> >
>> [...]
>> +
>> >+void move_pfn_range_to_zone(struct zone *zone,
>> >+		unsigned long start_pfn, unsigned long nr_pages)
>> >+{
>> >+	struct pglist_data *pgdat =3D zone->zone_pgdat;
>> >+	int nid =3D pgdat->node_id;
>> >+	unsigned long flags;
>> >+	unsigned long i;
>> >+
>> >+	if (zone_is_empty(zone))
>> >+		init_currently_empty_zone(zone, start_pfn, nr_pages);
>> >+
>> >+	clear_zone_contiguous(zone);
>> >+
>> >+	/* TODO Huh pgdat is irqsave while zone is not. It used to be like th=
at before */
>> >+	pgdat_resize_lock(pgdat, &flags);
>> >+	zone_span_writelock(zone);
>> >+	resize_zone_range(zone, start_pfn, nr_pages);
>> >+	zone_span_writeunlock(zone);
>> >+	resize_pgdat_range(pgdat, start_pfn, nr_pages);
>> >+	pgdat_resize_unlock(pgdat, &flags);
>> >+
>> >+	/*
>> >+	 * TODO now we have a visible range of pages which are not associated
>> >+	 * with their zone properly. Not nice but set_pfnblock_flags_mask
>> >+	 * expects the zone spans the pfn range. All the pages in the range
>> >+	 * are reserved so nobody should be touching them so we should be safe
>> >+	 */
>> >+	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn, MEMMAP_HOT=
PLUG);
>> >+	for (i =3D 0; i < nr_pages; i++) {
>> >+		unsigned long pfn =3D start_pfn + i;
>> >+		set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
>> > 	}
>>=20
>> memmap_init_zone()->__init_single_page()->set_page_links()
>>=20
>> Do I miss something that you call set_page_links() explicitly here?
>
>I guess you are right. Not sure why I've done this explicitly. I've most
>probably just missed that. Could you post a patch that removes the for
>loop.
>

Sure, I will come up with two patches based on you auto-latest branch.

>Thanks!
>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQ6C1AAoJEKcLNpZP5cTdbqEP/AuOPq0IA6aw7Pd1Kb75o6c/
9SRvNz7dlG7/9+wOs1QIN/3xxl+rDn0rbFOHXztZLkVATQwQfkTw4F2pfUhRUieS
AF3v9fHfzRCWgEi5gyyOA7wWNWyvegr2CU0KuWoKlABiBdJiGHjJEESJ2TEMOz0t
+2oMTMBw1PzStNL7ZM0UM+MflduHJSzQ7j+xT3RliyhDvGxouHcz5VBjLxiefsbw
0kqesAD8XPUMu/nXsZOrcDfYCSiFi9SmpCUSUdoiRo9lR+5LSZ9lI5GMxTfySfOO
/X2Eek64H0trR/B9F/7cbNMj67yD+8q1AVk5+lyKsPJF0fVNV9zxLO2lEbAb/2ho
YoJ5OyIaxVjsH+bfvyZhoJNMT4/wkw+5Li6NjHPVyAQ9vb7pgHgJysSwYfnGuHE3
Z+y9gKNqwxxtCieSfmxhbXgR93Zj7EvvDhRth4JZpf1Kv5yK6a5wRtkZsBky330z
1RTFwO0FtCmuvQCLm4pxBnSN+U34DJ6wx/R0B25p7r/nUTcz6QFiB23gBizsnRkE
CA72U12ZtkMmRKqgl+FTRy51lnRiizHqZgzAv0gliCMU1Tkn2rRJ3VMErgzuSEkx
jbOvOadioFPUTwoE6NEdQgBnbv8C+LSGDKeC7gTscYZPq/8v8nuEyyxIeBfl/gk9
3IpjZrSKjAklGr+GGzNB
=Yesu
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
