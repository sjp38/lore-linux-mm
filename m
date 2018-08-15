Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4E76B0003
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:05:40 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id c21-v6so598622pgw.0
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 07:05:40 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0097.outbound.protection.outlook.com. [104.47.42.97])
        by mx.google.com with ESMTPS id f18-v6si24241723pgi.300.2018.08.15.07.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 15 Aug 2018 07:05:38 -0700 (PDT)
From: Pavel Tatashin <Pavel.Tatashin@microsoft.com>
Subject: RE: [RFC PATCH 0/3] Do not touch pages in remove_memory path
Date: Wed, 15 Aug 2018 14:05:35 +0000
Message-ID: 
 <DM5PR21MB0508CEC7F586EBC89D2CCFBB9D3F0@DM5PR21MB0508.namprd21.prod.outlook.com>
References: <20180807133757.18352-1-osalvador@techadventures.net>
In-Reply-To: <20180807133757.18352-1-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "osalvador@techadventures.net" <osalvador@techadventures.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "david@redhat.com" <david@redhat.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "logang@deltatee.com" <logang@deltatee.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

> This tries to fix [1], which was reported by David Hildenbrand, and also
> does some cleanups/refactoring.

Hi Oscar,

I would like to review this work. Are you in process of sending a new versi=
on? If so, I will wait for it.

Thank you,
Pavel

>=20
> I am sending this as RFC to see if the direction I am going is right befo=
re
> spending more time into it.
> And also to gather feedback about hmm/zone_device stuff.
> The code compiles and I tested it successfully with normal memory-hotplug
> operations.
>=20
> Here we go:
>=20
> With the following scenario:
>=20
> 1) We add memory
> 2) We do not online it
> 3) We remove the memory
>=20
> an invalid access is being made to those pages.
>=20
> The reason is that the pages are initialized in online_pages() path:
>=20
>         /   online_pages
>         |    move_pfn_range
> ONLINE  |     move_pfn_range_to_zone
> PAGES   |      ...
>         |      memmap_init_zone
>=20
> But depending on our policy about onlining the pages by default, we might=
 not
> online them right after having added the memory, and so, those pages migh=
t
> be
> left unitialized.
>=20
> This is a problem because we access those pages in arch_remove_memory:
>=20
> ...
> if (altmap)
>         page +=3D vmem_altmap_offset(altmap);
>         zone =3D page_zone(page);
> ...
>=20
> So we are accessing unitialized data basically.
>=20
>=20
> Currently, we need to have the zone from arch_remove_memory to all the
> way down
> because
>=20
> 1) we call __remove_zone zo shrink spanned pages from pgdat/zone
> 2) we get the pgdat from the zone
>=20
> Number 1 can be fixed by moving __remove_zone back to offline_pages(),
> where it should be.
> This, besides fixing the bug, will make the code more consistent because =
all
> the reveserse
> operations from online_pages() will be made in offline_pages().
>=20
> Number 2 can be fixed by passing nid instead of zone.
>=20
> The tricky part of all this is the hmm code and the zone_device stuff.
>=20
> Fixing the calls to arch_remove_memory in the arch code is easy, but
> arch_remove_memory
> is being used in:
>=20
> kernel/memremap.c: devm_memremap_pages_release()
> mm/hmm.c:          hmm_devmem_release()
>=20
> I did my best to get my head around this, but my knowledge in that area i=
s 0,
> so I am pretty sure
> I did not get it right.
>=20
> The thing is:
>=20
> devm_memremap_pages(), which is the counterpart of
> devm_memremap_pages_release(),
> calls arch_add_memory(), and then calls move_pfn_range_to_zone() (to
> ZONE_DEVICE).
> So it does not go through online_pages().
> So there I call shrink_pages() (it does pretty much as __remove_zone) bef=
ore
> calling
> to arch_remove_memory.
> But as I said, I do now if that is right.
>=20
> [1] https://patchwork.kernel.org/patch/10547445/
>=20
> Oscar Salvador (3):
>   mm/memory_hotplug: Add nid parameter to arch_remove_memory
>   mm/memory_hotplug: Create __shrink_pages and move it to offline_pages
>   mm/memory_hotplug: Refactor shrink_zone/pgdat_span
>=20
>  arch/ia64/mm/init.c            |   6 +-
>  arch/powerpc/mm/mem.c          |  13 +--
>  arch/s390/mm/init.c            |   2 +-
>  arch/sh/mm/init.c              |   6 +-
>  arch/x86/mm/init_32.c          |   6 +-
>  arch/x86/mm/init_64.c          |  10 +--
>  include/linux/memory_hotplug.h |   8 +-
>  kernel/memremap.c              |   9 +-
>  mm/hmm.c                       |   6 +-
>  mm/memory_hotplug.c            | 190 +++++++++++++++++++++--------------=
------
>  mm/sparse.c                    |   4 +-
>  11 files changed, 127 insertions(+), 133 deletions(-)
>=20
> --
> 2.13.6
