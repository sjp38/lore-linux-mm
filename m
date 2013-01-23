Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id C22346B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 18:05:45 -0500 (EST)
MIME-Version: 1.0
Message-ID: <e59b7d62-67f5-4afb-8c8e-d422d3e82832@default>
Date: Wed, 23 Jan 2013 15:05:22 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [LSF/MM TOPIC]swap improvements for fast SSD
References: <766b9855-adf5-47ce-9484-971f88ff0e54@default>
In-Reply-To: <766b9855-adf5-47ce-9484-971f88ff0e54@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shli@fusionio.com
Cc: linux-mm@kvack.org

I would be very interested in this topic.

> Because of high density, low power and low price, flash storage (SSD) is =
a good
> candidate to partially replace DRAM. A quick answer for this is using SSD=
 as
> swap. But Linux swap is designed for slow hard disk storage. There are a =
lot of
> challenges to efficiently use SSD for swap:
>=20
> 1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
> 2. TLB flush overhead. To reclaim one page, we need at least 2 TLB flush.=
 This
> overhead is very high even in a normal 2-socket machine.
> 3. Better swap IO pattern. Both direct and kswapd page reclaim can do swa=
p,
> which makes swap IO pattern is interleave. Block layer isn't always effic=
ient
> to do request merge. Such IO pattern also makes swap prefetch hard.

Shaohua --

Have you considered the possibility of subverting the block layer entirely
and accessing the SSD like slow RAM rather than a fast I/O device?  E.g.
something like NVME and as in this paper?

http://static.usenix.org/events/fast12/tech/full_papers/Yang.pdf=20

If you think this could be an option, it could make a very
interesting backend to frontswap (something like ramster).

Dan

> 4. Swap map scan overhead. Swap in-memory map scan scans an array, which =
is
> very inefficient, especially if swap storage is fast.
> 5. SSD related optimization, mainly discard support
> 6. Better swap prefetch algorithm. Besides item 3, sequentially accessed =
pages
> aren't always in LRU list adjacently, so page reclaim will not swap such =
pages
> in adjacent storage sectors. This makes swap prefetch hard.
> 7. Alternative page reclaim policy to bias reclaiming anonymous page.
> Currently reclaim anonymous page is considering harder than reclaim file =
pages,
> so we bias reclaiming file pages. If there are high speed swap storage, w=
e are
> considering doing swap more aggressively.
> 8. Huge page swap. Huge page swap can solve a lot of problems above, but =
both
> THP and hugetlbfs don't support swap.
>=20
> I had some progresses in these areas recently:
> http://marc.info/?l=3Dlinux-mm&m=3D134665691021172&w=3D2
> http://marc.info/?l=3Dlinux-mm&m=3D135336039115191&w=3D2
> http://marc.info/?l=3Dlinux-mm&m=3D135882182225444&w=3D2
> http://marc.info/?l=3Dlinux-mm&m=3D135754636926984&w=3D2
> http://marc.info/?l=3Dlinux-mm&m=3D135754634526979&w=3D2
> But a lot of problems remain. I'd like to discuss the issues at the meeti=
ng.
>=20
> Thanks,
> Shaohua
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
