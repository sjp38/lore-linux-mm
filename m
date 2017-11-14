Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58B676B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 01:10:05 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h28so16968282pfh.16
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 22:10:05 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50062.outbound.protection.outlook.com. [40.107.5.62])
        by mx.google.com with ESMTPS id n69si1473081pfk.214.2017.11.13.22.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 22:10:03 -0800 (PST)
From: Ran Wang <ran.wang_1@nxp.com>
Subject: RE: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Date: Tue, 14 Nov 2017 06:10:00 +0000
Message-ID: <AM3PR04MB1489AD776D0539665B108A04F1280@AM3PR04MB1489.eurprd04.prod.outlook.com>
References: <AM3PR04MB14892A9D6D2FBCE21B8C1F0FF12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
 <AM3PR04MB14895AE080F9F21E98045D99F12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
 <20171113110232.ivd6l52y7j2q2iaq@dhcp22.suse.cz>
In-Reply-To: <20171113110232.ivd6l52y7j2q2iaq@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Leo Li <leoyang.li@nxp.com>, Xiaobo Xie <xiaobo.xie@nxp.com>

Hi Michal,

> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@kernel.org]
> Sent: Monday, November 13, 2017 7:03 PM
> To: Ran Wang <ran.wang_1@nxp.com>
> Cc: linux-mm@kvack.org; Michael Ellerman <mpe@ellerman.id.au>; Vlastimil
> Babka <vbabka@suse.cz>; Andrew Morton <akpm@linux-foundation.org>;
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>; Reza Arbab
> <arbab@linux.vnet.ibm.com>; Yasuaki Ishimatsu <yasu.isimatu@gmail.com>;
> qiuxishi@huawei.com; Igor Mammedov <imammedo@redhat.com>; Vitaly
> Kuznetsov <vkuznets@redhat.com>; LKML <linux-kernel@vger.kernel.org>;
> Leo Li <leoyang.li@nxp.com>; Xiaobo Xie <xiaobo.xie@nxp.com>
> Subject: Re: [PATCH 1/2] mm: drop migrate type checks from
> has_unmovable_pages
>=20
> On Mon 13-11-17 07:33:13, Ran Wang wrote:
> > Hello Michal,
> >
> > <snip>
> >
> > > Date: Fri, 13 Oct 2017 14:00:12 +0200
> > >
> > > From: Michal Hocko <mhocko@suse.com>
> > >
> > > Michael has noticed that the memory offline tries to migrate kernel
> > > code pages when doing  echo 0 >
> > > /sys/devices/system/memory/memory0/online
> > >
> > > The current implementation will fail the operation after several
> > > failed page migration attempts but we shouldn't even attempt to
> > > migrate that memory and fail right away because this memory is
> > > clearly not migrateable. This will become a real problem when we drop
> the retry loop counter resp. timeout.
> > >
> > > The real problem is in has_unmovable_pages in fact. We should fail
> > > if there are any non migrateable pages in the area. In orther to
> > > guarantee that remove the migrate type checks because
> > > MIGRATE_MOVABLE is not guaranteed to contain only migrateable pages.
> It is merely a heuristic.
> > > Similarly MIGRATE_CMA does guarantee that the page allocator doesn't
> > > allocate any non-migrateable pages from the block but CMA
> > > allocations themselves are unlikely to migrateable. Therefore remove
> both checks.
> > >
> > > Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > Tested-by: Michael Ellerman <mpe@ellerman.id.au>
> > > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > > ---
> > >  mm/page_alloc.c | 3 ---
> > >  1 file changed, 3 deletions(-)
> > >
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c index
> > > 3badcedf96a7..ad0294ab3e4f 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -7355,9 +7355,6 @@ bool has_unmovable_pages(struct zone *zone,
> > > struct page *page, int count,
> > >  	 */
> > >  	if (zone_idx(zone) =3D=3D ZONE_MOVABLE)
> > >  		return false;
> > > -	mt =3D get_pageblock_migratetype(page);
> > > -	if (mt =3D=3D MIGRATE_MOVABLE || is_migrate_cma(mt))
> > > -		return false;
> >
> > This drop cause DWC3 USB controller fail on initialization with
> > Layerscaper processors (such as LS1043A) as below:
> >
> > [    2.701437] xhci-hcd xhci-hcd.0.auto: new USB bus registered, assign=
ed
> bus number 1
> > [    2.710949] cma: cma_alloc: alloc failed, req-size: 1 pages, ret: -1=
6
> > [    2.717411] xhci-hcd xhci-hcd.0.auto: can't setup: -12
> > [    2.727940] xhci-hcd xhci-hcd.0.auto: USB bus 1 deregistered
> > [    2.733607] xhci-hcd: probe of xhci-hcd.0.auto failed with error -12
> > [    2.739978] xhci-hcd xhci-hcd.1.auto: xHCI Host Controller
> >
> > And I notice that someone also reported to you that DWC2 got affected
> > recently, so do you have the solution now?
>=20
> Yes. It should be in linux-next. Have a look at the following email
> thread:
> https://emea01.safelinks.protection.outlook.com/?url=3Dhttp%3A%2F%2Flkml.
> kernel.org%2Fr%2F20171104082500.qvzbb2kw4suo6cgy%40dhcp22.suse.cz&
> data=3D02%7C01%7Cran.wang_1%40nxp.com%7C5e73c6a941fc4f1c10e708d52
> a860c5b%7C686ea1d3bc2b4c6fa92cd99c5c301635%7C0%7C0%7C636461677
> 583607877&sdata=3DzlRxJ4LZwOBsit5qRx9yFT5qfP54wZ0z6G1z%2Bcywf5g%3D
> &reserved=3D0

Thanks for your info, although I fail to open the link you shared, but I go=
t patch
from my colleague and the issue got fix on my side, let you know, thanks.

Best Regards,
Ran
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
