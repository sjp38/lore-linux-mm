Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1536B6D81
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:24:40 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id y19so1033433ioq.1
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:24:40 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id n136si5861414itb.122.2018.12.03.23.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:24:38 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
Date: Tue, 4 Dec 2018 07:21:16 +0000
Message-ID: <20181204072116.GA24446@hori1.linux.bs1.fc.nec.co.jp>
References: <20181203100309.14784-1-mhocko@kernel.org>
In-Reply-To: <20181203100309.14784-1-mhocko@kernel.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B37C8DEADD258948B64BA709B5D5B46E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Stable tree <stable@vger.kernel.org>

On Mon, Dec 03, 2018 at 11:03:09AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>=20
> We have received a bug report that an injected MCE about faulty memory
> prevents memory offline to succeed. The underlying reason is that the
> HWPoison page has an elevated reference count and the migration keeps
> failing. There are two problems with that. First of all it is dubious
> to migrate the poisoned page because we know that accessing that memory
> is possible to fail. Secondly it doesn't make any sense to migrate a
> potentially broken content and preserve the memory corruption over to a
> new location.
>=20
> Oscar has found out that it is the elevated reference count from
> memory_failure that is confusing the offlining path. HWPoisoned pages
> are isolated from the LRU list but __offline_pages might still try to
> migrate them if there is any preceding migrateable pages in the pfn
> range. Such a migration would fail due to the reference count but
> the migration code would put it back on the LRU list. This is quite
> wrong in itself but it would also make scan_movable_pages stumble over
> it again without any way out.
>=20
> This means that the hotremove with hwpoisoned pages has never really
> worked (without a luck). HWPoisoning really needs a larger surgery
> but an immediate and backportable fix is to skip over these pages during
> offlining. Even if they are still mapped for some reason then
> try_to_unmap should turn those mappings into hwpoison ptes and cause
> SIGBUS on access. Nobody should be really touching the content of the
> page so it should be safe to ignore them even when there is a pending
> reference count.
>=20
> Debugged-by: Oscar Salvador <osalvador@suse.com>
> Cc: stable
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> I am sending this as an RFC now because I am not fully sure I see all
> the consequences myself yet. This has passed a testing by Oscar but I
> would highly appreciate a review from Naoya about my assumptions about
> hwpoisoning. E.g. it is not entirely clear to me whether there is a
> potential case where the page might be still mapped.

One potential case is ksm page, for which we give up unmapping and leave
it unmapped. Rather than that I don't have any idea, but any new type of
page would be potentially categorized to this class.

> I have put
> try_to_unmap just to be sure. It would be really great if I could drop
> that part because then it is not really great which of the TTU flags to
> use to cover all potential cases.
>=20
> I have marked the patch for stable but I have no idea how far back it
> should go. Probably everything that already has hotremove and hwpoison
> code.

Yes, maybe this could be ported to all active stable trees.

>=20
> Thanks in advance!
>=20
>  mm/memory_hotplug.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
>=20
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c6c42a7425e5..08c576d5a633 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -34,6 +34,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/memblock.h>
>  #include <linux/compaction.h>
> +#include <linux/rmap.h>
> =20
>  #include <asm/tlbflush.h>
> =20
> @@ -1366,6 +1367,17 @@ do_migrate_range(unsigned long start_pfn, unsigned=
 long end_pfn)
>  			pfn =3D page_to_pfn(compound_head(page))
>  				+ hpage_nr_pages(page) - 1;
> =20
> +		/*
> +		 * HWPoison pages have elevated reference counts so the migration woul=
d
> +		 * fail on them. It also doesn't make any sense to migrate them in the
> +		 * first place. Still try to unmap such a page in case it is still map=
ped.
> +		 */
> +		if (PageHWPoison(page)) {
> +			if (page_mapped(page))
> +				try_to_unmap(page, TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS);
> +			continue;
> +		}
> +

I think this looks OK (no better idea.)

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

I wondered why I didn't find this for long, and found that my testing only
covered the case where PageHWPoison is the first page of memory block.
scan_movable_pages() considers PageHWPoison as non-movable, so do_migrate_r=
ange()
started with pfn after the PageHWPoison and never tried to migrate it
(so effectively ignored every PageHWPoison as the above code does.)

Thanks,
Naoya Horiguchi

>  		if (!get_page_unless_zero(page))
>  			continue;
>  		/*
> --=20
> 2.19.1
>=20
> =
