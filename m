Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C420B2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 04:39:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l81so6115551wmg.8
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 01:39:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k16si5530737wrc.385.2017.06.30.01.39.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 01:39:29 -0700 (PDT)
Date: Fri, 30 Jun 2017 10:39:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Message-ID: <20170630083926.GA22923@dhcp22.suse.cz>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
 <CADZGycaXs-TsVN2xy_rpFE_ML5_rs=iYN6ZQZsAfjTVHFyLyEQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADZGycaXs-TsVN2xy_rpFE_ML5_rs=iYN6ZQZsAfjTVHFyLyEQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 30-06-17 11:09:51, Wei Yang wrote:
> On Thu, Jun 29, 2017 at 3:35 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > From: Michal Hocko <mhocko@suse.com>
> >
> 
> Michal,
> 
> I love the idea very much.
> 
> > Historically we have enforced that any kernel zone (e.g ZONE_NORMAL) has
> > to precede the Movable zone in the physical memory range. The purpose of
> > the movable zone is, however, not bound to any physical memory restriction.
> > It merely defines a class of migrateable and reclaimable memory.
> >
> > There are users (e.g. CMA) who might want to reserve specific physical
> > memory ranges for their own purpose. Moreover our pfn walkers have to be
> > prepared for zones overlapping in the physical range already because we
> > do support interleaving NUMA nodes and therefore zones can interleave as
> > well. This means we can allow each memory block to be associated with a
> > different zone.
> >
> > Loosen the current onlining semantic and allow explicit onlining type on
> > any memblock. That means that online_{kernel,movable} will be allowed
> > regardless of the physical address of the memblock as long as it is
> > offline of course. This might result in moveble zone overlapping with
> > other kernel zones. Default onlining then becomes a bit tricky but still
> 
> As here mentioned, we just remove the restriction for zone_movable.
> For other zones, we still keep the restriction and the order as before.

All other zones except for ZONE_NORMAL are subject of the physical
memory restrictions.
 
> Maybe the title is a little misleading. Audience may thinks no restriction
> for all zones.

I thought the context was clear from the fact that this is a hotplug
related patch. As such we do not allow online_{dma,dma32,normal} we only
allow to online into a kernel zone. I can update the wording but do not
have a good idea how.

[...]
> As I spotted on the previous patch, after several round of online/offline,
> The output of valid_zones will differ.
> 
> For example in this case, after I offline memory37 and 41, I expect this:
> 
>  memory34/valid_zones:Normal
>  memory35/valid_zones:Normal Movable
>  memory36/valid_zones:Normal Movable
>  memory37/valid_zones:Normal Movable
>  memory38/valid_zones:Normal Movable
>  memory39/valid_zones:Normal Movable
>  memory40/valid_zones:Normal Movable
>  memory41/valid_zones:Normal Movable
> 
> While the current result would be
> 
>  memory34/valid_zones:Normal
>  memory35/valid_zones:Normal Movable
>  memory36/valid_zones:Normal Movable
>  memory37/valid_zones:Movable Normal
>  memory38/valid_zones:Movable Normal
>  memory39/valid_zones:Movable Normal
>  memory40/valid_zones:Movable Normal
>  memory41/valid_zones:Movable Normal

You haven't written your sequence of onlining but if you used the same
one as mentioned in the patch then you should get
memory34/valid_zones:Normal
memory35/valid_zones:Normal Movable
memory36/valid_zones:Normal Movable
memory37/valid_zones:Normal Movable
memory38/valid_zones:Normal Movable
memory39/valid_zones:Normal
memory40/valid_zones:Movable Normal
memory41/valid_zones:Movable Normal

Even if you kept 37 as movable and offline 38 you wouldn't get 38-41
movable by default because...

> The reason is the same, we don't adjust the zone's range when offline
> memory.

.. of this.

> This is also a known issue?

yes and to be honest I do not plan to fix it unless somebody has a real
life usecase for it. Now that we allow explicit onlininig type anywhere
it seems like a reasonable behavior and this will allow us to remove
quite some code which is always a good deal wrt longterm maintenance.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
