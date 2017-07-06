Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF85F6B03E7
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 02:56:55 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z1so2514274wrz.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 23:56:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u76si883243wrc.211.2017.07.05.23.56.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 23:56:54 -0700 (PDT)
Date: Thu, 6 Jul 2017 08:56:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Message-ID: <20170706065649.GC29724@dhcp22.suse.cz>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
 <CADZGycaXs-TsVN2xy_rpFE_ML5_rs=iYN6ZQZsAfjTVHFyLyEQ@mail.gmail.com>
 <20170630083926.GA22923@dhcp22.suse.cz>
 <CADZGyca1-CzaHoR-==DN4kK_YrwmMVnKvowUv-5M4GQP7ZYubg@mail.gmail.com>
 <20170630095545.GF22917@dhcp22.suse.cz>
 <20170630110118.GG22917@dhcp22.suse.cz>
 <20170705231649.GA10155@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170705231649.GA10155@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 06-07-17 07:16:49, Wei Yang wrote:
> On Fri, Jun 30, 2017 at 01:01:18PM +0200, Michal Hocko wrote:
> >On Fri 30-06-17 11:55:45, Michal Hocko wrote:
> >> On Fri 30-06-17 17:39:56, Wei Yang wrote:
> >> > On Fri, Jun 30, 2017 at 4:39 PM, Michal Hocko <mhocko@kernel.org> wrote:
> >> [...]
> >> > > yes and to be honest I do not plan to fix it unless somebody has a real
> >> > > life usecase for it. Now that we allow explicit onlininig type anywhere
> >> > > it seems like a reasonable behavior and this will allow us to remove
> >> > > quite some code which is always a good deal wrt longterm maintenance.
> >> > >
> >> > 
> >> > hmm... the statistics displayed in /proc/zoneinfo would be meaningless
> >> > for zone_normal and zone_movable.
> >> 
> >> Why would they be meaningless? Counters will always reflect the actual
> >> use - if not then it is a bug. And wrt to zone description what is
> >> meaningless about
> >> memory34/valid_zones:Normal
> >> memory35/valid_zones:Normal Movable
> >> memory36/valid_zones:Movable
> >> memory37/valid_zones:Movable Normal
> >> memory38/valid_zones:Movable Normal
> >> memory39/valid_zones:Movable Normal
> >> memory40/valid_zones:Normal
> >> memory41/valid_zones:Movable
> >> 
> >> And
> >> Node 1, zone   Normal
> >>   pages free     65465
> >>         min      156
> >>         low      221
> >>         high     286
> >>         spanned  229376
> >>         present  65536
> >>         managed  65536
> >> [...]
> >>   start_pfn:           1114112
> >> Node 1, zone  Movable
> >>   pages free     65443
> >>         min      156
> >>         low      221
> >>         high     286
> >>         spanned  196608
> >>         present  65536
> >>         managed  65536
> >> [...]
> >>   start_pfn:           1179648
> >> 
> >> ranges are clearly defined as [start_pfn, start_pfn+managed] and managed
> >
> >errr, this should be [start_pfn, start_pfn + spanned] of course.
> >
> 
> The spanned is not adjusted after offline, neither does start_pfn. For example,
> even offline all the movable_zone range, we can still see the spanned.

Which is completely valid. Offline only changes present/managed.

> Below is a result with a little changed kernel to show the start_pfn always.
> The sequence is:
> 1. bootup
> 
> Node 0, zone  Movable
>         spanned  65536
> 	present  0
> 	managed  0
>   start_pfn:           0
> 
> 2. online movable 2 continuous memory_blocks
> 
> Node 0, zone  Movable
>         spanned  65536
> 	present  65536
> 	managed  65536
>   start_pfn:           1310720
> 
> 3. offline 2nd memory_blocks
> 
> Node 0, zone  Movable
>         spanned  65536
> 	present  32768
> 	managed  32768
>   start_pfn:           1310720
> 
> 4. offline 1st memory_blocks
> 
> Node 0, zone  Movable
>         spanned  65536
> 	present  0
> 	managed  0
>   start_pfn:           1310720
> 
> So I am not sure this is still clearly defined?

Could you be more specific what is not clearly defined? You have
offlined all online memory blocks so present/managed is 0 while the
spanned is unchanged because the zone is still defined in range
[1310720, 1376256].

I also do not see how this is related with the discussed patch as there
is no zone interleaving involved.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
