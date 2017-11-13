Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB7C6B0331
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 02:33:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s11so9936195pgc.13
        for <linux-mm@kvack.org>; Sun, 12 Nov 2017 23:33:19 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0078.outbound.protection.outlook.com. [104.47.0.78])
        by mx.google.com with ESMTPS id d6si13306256plo.114.2017.11.12.23.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 12 Nov 2017 23:33:17 -0800 (PST)
From: Ran Wang <ran.wang_1@nxp.com>
Subject: RE: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Date: Mon, 13 Nov 2017 07:33:13 +0000
Message-ID: <AM3PR04MB14895AE080F9F21E98045D99F12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
References: <AM3PR04MB14892A9D6D2FBCE21B8C1F0FF12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
In-Reply-To: <AM3PR04MB14892A9D6D2FBCE21B8C1F0FF12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Leo Li <leoyang.li@nxp.com>, Xiaobo Xie <xiaobo.xie@nxp.com>

Hello Michal,

<snip>

> Date: Fri, 13 Oct 2017 14:00:12 +0200
>=20
> From: Michal Hocko <mhocko@suse.com>
>=20
> Michael has noticed that the memory offline tries to migrate kernel code
> pages when doing  echo 0 > /sys/devices/system/memory/memory0/online
>=20
> The current implementation will fail the operation after several failed p=
age
> migration attempts but we shouldn't even attempt to migrate that memory
> and fail right away because this memory is clearly not migrateable. This =
will
> become a real problem when we drop the retry loop counter resp. timeout.
>=20
> The real problem is in has_unmovable_pages in fact. We should fail if the=
re
> are any non migrateable pages in the area. In orther to guarantee that
> remove the migrate type checks because MIGRATE_MOVABLE is not
> guaranteed to contain only migrateable pages. It is merely a heuristic.
> Similarly MIGRATE_CMA does guarantee that the page allocator doesn't
> allocate any non-migrateable pages from the block but CMA allocations
> themselves are unlikely to migrateable. Therefore remove both checks.
>=20
> Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Tested-by: Michael Ellerman <mpe@ellerman.id.au>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/page_alloc.c | 3 ---
>  1 file changed, 3 deletions(-)
>=20
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c index
> 3badcedf96a7..ad0294ab3e4f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7355,9 +7355,6 @@ bool has_unmovable_pages(struct zone *zone,
> struct page *page, int count,
>  	 */
>  	if (zone_idx(zone) =3D=3D ZONE_MOVABLE)
>  		return false;
> -	mt =3D get_pageblock_migratetype(page);
> -	if (mt =3D=3D MIGRATE_MOVABLE || is_migrate_cma(mt))
> -		return false;

This drop cause DWC3 USB controller fail on initialization with Layerscaper=
 processors
(such as LS1043A) as below:

[    2.701437] xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned b=
us number 1
[    2.710949] cma: cma_alloc: alloc failed, req-size: 1 pages, ret: -16
[    2.717411] xhci-hcd xhci-hcd.0.auto: can't setup: -12
[    2.727940] xhci-hcd xhci-hcd.0.auto: USB bus 1 deregistered
[    2.733607] xhci-hcd: probe of xhci-hcd.0.auto failed with error -12
[    2.739978] xhci-hcd xhci-hcd.1.auto: xHCI Host Controller

And I notice that someone also reported to you that DWC2 got affected recen=
tly,
so do you have the solution now?

Best regards

Ran
>=20
>  	pfn =3D page_to_pfn(page);
>  	for (found =3D 0, iter =3D 0; iter < pageblock_nr_pages; iter++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
