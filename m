Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC00B2808F6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 18:46:59 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y17so136650544pgh.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 15:46:59 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0130.outbound.protection.outlook.com. [104.47.40.130])
        by mx.google.com with ESMTPS id n8si7811431pll.303.2017.03.09.15.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 15:46:58 -0800 (PST)
Message-ID: <58C1E948.9020306@cs.rutgers.edu>
Date: Thu, 9 Mar 2017 17:46:16 -0600
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] Enable parallel page migration
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com> <ef5efef8-a8c5-a4e7-ffc7-44176abec65c@linux.vnet.ibm.com> <20170309150904.pnk6ejeug4mktxjv@suse.de> <2a2827d0-53d0-175b-8ed4-262629e01984@nvidia.com> <20170309221522.hwk4wyaqx2jonru6@suse.de>
In-Reply-To: <20170309221522.hwk4wyaqx2jonru6@suse.de>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enig230AB448C8C0DF2269928DE5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Nellans <dnellans@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--------------enig230AB448C8C0DF2269928DE5
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Mel,

Thanks for pointing out the problems in this patchset.

It was my intern project done in NVIDIA last summer. I only used
micro-benchmarks to demonstrate the big memory bandwidth utilization gap
between base page migration and THP migration along with serialized page
migration vs parallel page migration.

Here are cross-socket serialized page migration results from calling
move_pages() syscall:

In x86_64, a Intel two-socket E5-2640v3 box,
single 4KB base page migration takes 62.47 us, using 0.06 GB/s BW,
single 2MB THP migration takes 658.54 us, using 2.97 GB/s BW,
512 4KB base page migration takes 1987.38 us, using 0.98 GB/s BW.

In ppc64, a two-socket Power8 box,
single 64KB base page migration takes 49.3 us, using 1.24 GB/s BW,
single 16MB THP migration takes 2202.17 us, using 7.10 GB/s BW,
256 64KB base page migration takes 2543.65 us, using 6.14 GB/s BW.

THP migration is not slow at all when compared to a group of equivalent
base page migrations.

For 1-thread vs 8-thread THP migration:
In x86_64,
1-thread 2MB THP migration takes 658.54 us, using 2.97 GB/s BW,
8-thread 2MB THP migration takes 227.76 us, using 8.58 GB/s BW.

In ppc64,
1-thread 16MB THP migration takes 2202.17 us, using 7.10 GB/s BW,
8-thread 16MB THP migration takes 1223.87 us, using 12.77 GB/s BW.

This big increase on BW utilization is the motivation of pushing this
patchset.

>=20
> So the key potential issue here in my mind is that THP migration is too=
 slow
> in some cases. What I object to is improving that using a high priority=

> workqueue that potentially starves other CPUs and pollutes their cache
> which is generally very expensive.

I might not completely agree with this. Using a high priority workqueue
can guarantee page migration work is done ASAP. Otherwise, we completely
lose the speedup brought by parallel page migration, if data copy
threads have to wait.

I understand your concern on CPU utilization impact. I think checking
CPU utilization and only using idle CPUs could potentially avoid this
problem.

>=20
> Lets look at the core of what copy_huge_page does in mm/migrate.c which=

> is the function that gets parallelised by the series in question. For
> a !HIGHMEM system, it's woefully inefficient. Historically, it was an
> implementation that would work generically which was fine but maybe not=

> for future systems. It was also fine back when hugetlbfs was the only h=
uge
> page implementation and COW operations were incredibly rare on the grou=
nds
> due to the risk that they could terminate the process with prejudice.
>=20
> The function takes a huge page, splits it into PAGE_SIZE chunks, kmap_a=
tomics
> the source and destination for each PAGE_SIZE chunk and copies it. The
> parallelised version does one kmap and copies it in chunks assuming the=

> THP is fully mapped and accessible. Fundamentally, this is broken in th=
e
> generic sense as the kmap is not guaranteed to make the whole page nece=
ssary
> but it happens to work on !highmem systems.  What is more important to
> note is that it's multiple preempt and pagefault enables and disables
> on a per-page basis that happens 512 times (for THP on x86-64 at least)=
,
> all of which are expensive operations depending on the kernel config an=
d
> I suspect that the parallisation is actually masking that stupid overhe=
ad.

You are right on kmap, I think making this patchset depend on !HIGHMEM
can avoid the problem. It might not make sense to kmap potentially 512
base pages to migrate a THP in a system with highmem.

>=20
> At the very least, I would have expected an initial attempt of one patc=
h that
> optimised for !highmem systems to ignore kmap, simply disable preempt (=
if
> that is even necessary, I didn't check) and copy a pinned physical->phy=
sical
> page as a single copy without looping on a PAGE_SIZE basis and see how
> much that gained. Do it initially for THP only and worry about gigantic=

> pages when or if that is a problem.

I can try this out to show how much improvement we can obtain from
existing THP migration, which is shown in the data above.

>=20
> That would be patch 1 of a series.  Maybe that'll be enough, maybe not =
but
> I feel it's important to optimise the serialised case as much as possib=
le
> before considering parallelisation to highlight and justify why it's
> necessary[1]. If nothing else, what if two CPUs both parallelise a migr=
ation
> at the same time and end up preempting each other? Between that and the=

> workqueue setup, it's potentially much slower than an optimised serial =
copy.
>=20
> It would be tempting to experiment but the test case was not even inclu=
ded
> with the series (maybe it's somewhere else)[2]. While it's obvious how
> such a test case could be constructed, it feels unnecessary to construc=
t
> it when it should be in the changelog.

Do you mean performing multiple parallel page migrations at the same
time and show all the page migration time?


--=20
Best Regards,
Yan Zi


--------------enig230AB448C8C0DF2269928DE5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJYwelqAAoJEEGLLxGcTqbMpLgIAJ4laqF6RLuGU5pd1iq487Fk
k3xsMdVFISchr8AIJUayaQfD/b074eyRk8s5kprclbLG4+QAeHRhdexlWwuONVus
GQTUlFWm2ZuFu+A0tZRtWuln6rJ8h1po0o7Q9z4KW7GE4BVVyjNVPAvXtM4kjsF6
hnQYfoknANRnTKAWb1D/wtvU0C+ftfxJkWpw7x3RMC1spUybbZBFEQFuFYIEBvHA
kVH9BIlGwAhWpxTA5ONIyZfBIo+BOwTNHabG5gKzRszwk7hyuaRiu39dabOUky63
3WHO59yeNXojSu7WuHq5f9qC97+GHUrrEt1xYh6xxnco54Gv/4ZYVdFeU1iO9bk=
=yU1Q
-----END PGP SIGNATURE-----

--------------enig230AB448C8C0DF2269928DE5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
