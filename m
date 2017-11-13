Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 774266B0347
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 06:02:39 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m188so6785276pga.22
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 03:02:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z67si1296025pgb.424.2017.11.13.03.02.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 03:02:38 -0800 (PST)
Date: Mon, 13 Nov 2017 12:02:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171113110232.ivd6l52y7j2q2iaq@dhcp22.suse.cz>
References: <AM3PR04MB14892A9D6D2FBCE21B8C1F0FF12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
 <AM3PR04MB14895AE080F9F21E98045D99F12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AM3PR04MB14895AE080F9F21E98045D99F12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ran Wang <ran.wang_1@nxp.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Leo Li <leoyang.li@nxp.com>, Xiaobo Xie <xiaobo.xie@nxp.com>

On Mon 13-11-17 07:33:13, Ran Wang wrote:
> Hello Michal,
> 
> <snip>
> 
> > Date: Fri, 13 Oct 2017 14:00:12 +0200
> > 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Michael has noticed that the memory offline tries to migrate kernel code
> > pages when doing  echo 0 > /sys/devices/system/memory/memory0/online
> > 
> > The current implementation will fail the operation after several failed page
> > migration attempts but we shouldn't even attempt to migrate that memory
> > and fail right away because this memory is clearly not migrateable. This will
> > become a real problem when we drop the retry loop counter resp. timeout.
> > 
> > The real problem is in has_unmovable_pages in fact. We should fail if there
> > are any non migrateable pages in the area. In orther to guarantee that
> > remove the migrate type checks because MIGRATE_MOVABLE is not
> > guaranteed to contain only migrateable pages. It is merely a heuristic.
> > Similarly MIGRATE_CMA does guarantee that the page allocator doesn't
> > allocate any non-migrateable pages from the block but CMA allocations
> > themselves are unlikely to migrateable. Therefore remove both checks.
> > 
> > Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > Tested-by: Michael Ellerman <mpe@ellerman.id.au>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > ---
> >  mm/page_alloc.c | 3 ---
> >  1 file changed, 3 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c index
> > 3badcedf96a7..ad0294ab3e4f 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7355,9 +7355,6 @@ bool has_unmovable_pages(struct zone *zone,
> > struct page *page, int count,
> >  	 */
> >  	if (zone_idx(zone) == ZONE_MOVABLE)
> >  		return false;
> > -	mt = get_pageblock_migratetype(page);
> > -	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
> > -		return false;
> 
> This drop cause DWC3 USB controller fail on initialization with Layerscaper processors
> (such as LS1043A) as below:
> 
> [    2.701437] xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned bus number 1
> [    2.710949] cma: cma_alloc: alloc failed, req-size: 1 pages, ret: -16
> [    2.717411] xhci-hcd xhci-hcd.0.auto: can't setup: -12
> [    2.727940] xhci-hcd xhci-hcd.0.auto: USB bus 1 deregistered
> [    2.733607] xhci-hcd: probe of xhci-hcd.0.auto failed with error -12
> [    2.739978] xhci-hcd xhci-hcd.1.auto: xHCI Host Controller
> 
> And I notice that someone also reported to you that DWC2 got affected recently,
> so do you have the solution now?

Yes. It should be in linux-next. Have a look at the following email
thread: 
http://lkml.kernel.org/r/20171104082500.qvzbb2kw4suo6cgy@dhcp22.suse.cz

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
