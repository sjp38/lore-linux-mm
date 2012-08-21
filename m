Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 3336E6B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 23:56:09 -0400 (EDT)
From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH]mm: fix-up zone present pages
Date: Tue, 21 Aug 2012 05:55:40 +0200
References: <5031DB52.9030806@gmail.com>
In-Reply-To: <5031DB52.9030806@gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201208210555.41312.ptesarik@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wujianguo <wujianguo106@gmail.com>
Cc: tony.luck@intel.com, fenghua.yu@intel.com, dhowells@redhat.com, tj@kernel.org, mgorman@suse.de, yinghai@kernel.org, minchan.kim@gmail.com, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, aarcange@redhat.com, davem@davemloft.net, hannes@cmpxchg.org, liuj97@gmail.com, wency@cn.fujitsu.com, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jiang.liu@huawei.com, guohanjun@huawei.com, qiuxishi@huawei.com

Dne Po 20. srpna 2012 08:38:10 wujianguo napsal(a):
> From: Jianguo Wu <wujianguo@huawei.com>
>=20
> Hi all,
> 	I think zone->present_pages indicates pages that buddy system can
> management, it should be:
> 	zone->present_pages =3D spanned pages - absent pages - bootmem pages,
> but now:
> 	zone->present_pages =3D spanned pages - absent pages - memmap pages.
> spanned pages=EF=BC=9Atotal size, including holes.
> absent pages: holes.
> bootmem pages: pages used in system boot, managed by bootmem allocator.
> memmap pages: pages used by page structs.

Absolutely. The memory allocated to page structs should be counted in.

> This may cause zone->present_pages less than it should be.
> For example, numa node 1 has ZONE_NORMAL and ZONE_MOVABLE,
> it's memmap and other bootmem will be allocated from ZONE_MOVABLE,
> so ZONE_NORMAL's present_pages should be spanned pages - absent pages,
> but now it also minus memmap pages(free_area_init_core), which are actual=
ly
> allocated from ZONE_MOVABLE. When offline all memory of a zone, This will
> cause zone->present_pages less than 0, because present_pages is unsigned
> long type, it is actually a very large integer, it indirectly caused
> zone->watermark[WMARK_MIN] become a large
> integer(setup_per_zone_wmarks()), than cause totalreserve_pages become a
> large integer(calculate_totalreserve_pages()), and finally cause memory
> allocating failure when fork process(__vm_enough_memory()).
>=20
> [root@localhost ~]# dmesg
> -bash: fork: Cannot allocate memory
>=20
> I think bug described in http://marc.info/?l=3Dlinux-mm&m=3D1345021827141=
86&w=3D2
> is also caused by wrong zone present pages.

And yes, I can confirm that the bug I reported is caused by a too low numbe=
r=20
for the present pages counter. Your patch does fix the bug for me.

Thanks!
Petr Tesarik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
