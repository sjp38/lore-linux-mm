Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 09F466B039F
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 21:11:43 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m28so95508570pgn.14
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 18:11:43 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id d185si2268297pgc.362.2017.03.27.18.11.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 18:11:42 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id 79so17146599pgf.0
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 18:11:41 -0700 (PDT)
Date: Tue, 28 Mar 2017 09:11:37 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC] calc_memmap_size() isn't accurate and one suggestion to improve
Message-ID: <20170328011137.GA8655@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@techsingularity.net, jiang.liu@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, tj@kernel.org, mingo@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi, masters,

# What I found

I found the function calc_memmap_size() may not be that accurate to get the
pages for memmap.

The reason is:

> memmap is allocated on a node base,
> while the calculation is on a zone base

This applies both to SPARSEMEM and FLATMEM.

For example, on my laptop with 6G memory, all the memmap space is allocated
=66rom ZONE_NORMAL.

# My suggestion=20

Current code path is:

    sparse_init()                          <- memmap allocated
    zone_sizes_init()
        free_area_init_nodes()
	    calculate_node_totalpages()
	    free_area_init_core()          <- where we do the calculation

=46rom the code snippet, memmap is already allocated in memblock, which
means we can get the information by comparing memblock.memory and
memblock.reserved.

My suggestion is to record this information in pg_data_t in
calculate_node_totalpages(), which is already doing the calculation on each
zone's spanned_pages and present_pages.

# Other solutions came to my mind

1. Assume all the memmap is allocated from the highest zone.

Pro:

Easy to calculate

Cor:

Not good to do this assumption. How to set the boundary. And there is the c=
ase
memory is allocated bottom-up.

2. Record the memmap area for each allocation

Pro:

Accurate and exact the size and zone index is recorded.

Cor:

Too expensive, especially when VMEMMAP && !ALLOC_MEM_MAP_TOGETHER. There wo=
uld
be too many.

# Look for you comment

This code path applies to most of the arch, while I am not 100% for sure th=
is
applies to all the arch. If isn't, this change may not be a good one.

The solution looks good to me, while I may miss some corner case or some
important facts.

Willing to hear from you :-)

--=20
Wei Yang
Help you, Help me

--=20
Wei Yang
Help you, Help me

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJY2bhJAAoJEKcLNpZP5cTdYUsP/2OaqgfN7EM08yP9cRV+I2Xp
3eUSANJGDRCRIKYhprfpXyvfPdnpnMOO+Hy/H2orrt3C2dxQa93s+IIXjH0PCyNS
KlbC/T3bwHksVTqFifqllKAbs5nttbOvCf8lr/xs8RtMEb4+kjDWC3dRlPwDezU5
Q1RurBV3N4u4qlpC2rzvV8K6PvoSPFwOjomDFOOrH+lrHrYUdZPo2XuNtrGgyUPt
+Y0j0MGugIM2fCcspyFeuobF1JReDH0a5bCSEtHyQcF0u14/U1cyAnxXYuVVG98r
CyZUZ7toI1n+a8ChpyyYqTVYshY/aT50mn+5FYNOKxnl9FMmQ1KcFk0VWjyYYoTh
10IVPzgVwc687MEUr+B4/oW1DyRu2reHQunY673XFIOwtn4tPdv/sNKSn3U7F69f
Bz3AwIB/3GiFjq69yNvWdaJcauLGqN2WEGQFEn6xytqUR1ZyroOytzJVLA+p0GBD
irnVHAkIQLk/wYlios72+aeWe8ALrac7SS8JT0LSczYHnyjRLm3jb3PONzo8U3rF
7sAbsLSoRz2V30ws2rjo1NLhq2vvFlHpowtq8p60zwxTblPZdR4AdbYkD4EU6YaK
9C6YcRM6eZcVSYyiUhMQ8FzdqjOZ5bfoU8T3W1FV8X5Z0Cz+lK/URhn1n1ctKfqO
rVuSHYUNVqatnzU/SqeV
=dbgO
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
