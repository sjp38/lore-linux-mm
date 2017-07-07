Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C66ED6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 08:41:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 23so7643376wry.4
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 05:41:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o23si2009601wro.277.2017.07.07.05.41.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 05:41:16 -0700 (PDT)
Date: Fri, 7 Jul 2017 14:41:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Message-ID: <20170707124112.GB16187@dhcp22.suse.cz>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
 <CADZGycaXs-TsVN2xy_rpFE_ML5_rs=iYN6ZQZsAfjTVHFyLyEQ@mail.gmail.com>
 <20170630083926.GA22923@dhcp22.suse.cz>
 <CADZGyca1-CzaHoR-==DN4kK_YrwmMVnKvowUv-5M4GQP7ZYubg@mail.gmail.com>
 <20170630095545.GF22917@dhcp22.suse.cz>
 <20170630110118.GG22917@dhcp22.suse.cz>
 <20170705231649.GA10155@WeideMacBook-Pro.local>
 <20170706065649.GC29724@dhcp22.suse.cz>
 <20170707083723.GA19821@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170707083723.GA19821@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 07-07-17 16:37:23, Wei Yang wrote:
> On Thu, Jul 06, 2017 at 08:56:50AM +0200, Michal Hocko wrote:
> >> Below is a result with a little changed kernel to show the start_pfn always.
> >> The sequence is:
> >> 1. bootup
> >> 
> >> Node 0, zone  Movable
> >>         spanned  65536
> >> 	present  0
> >> 	managed  0
> >>   start_pfn:           0
> >> 
> >> 2. online movable 2 continuous memory_blocks
> >> 
> >> Node 0, zone  Movable
> >>         spanned  65536
> >> 	present  65536
> >> 	managed  65536
> >>   start_pfn:           1310720
> >> 
> >> 3. offline 2nd memory_blocks
> >> 
> >> Node 0, zone  Movable
> >>         spanned  65536
> >> 	present  32768
> >> 	managed  32768
> >>   start_pfn:           1310720
> >> 
> >> 4. offline 1st memory_blocks
> >> 
> >> Node 0, zone  Movable
> >>         spanned  65536
> >> 	present  0
> >> 	managed  0
> >>   start_pfn:           1310720
> >> 
> >> So I am not sure this is still clearly defined?
> >
> >Could you be more specific what is not clearly defined? You have
> >offlined all online memory blocks so present/managed is 0 while the
> >spanned is unchanged because the zone is still defined in range
> >[1310720, 1376256].
> >
> 
> The zone is empty after remove these two memory blocks, while we still think
> it is defined in range [1310720, 1376256].

Yes and present/managed shows that the zone is empty. It's range spans
some range but there are no online pages.

> This is what I want to point.

As I've said several times already. This is somemething that _could_ be
fixed but I would rather not to do so until there is a _readl_ usecase
which would depend on it. Especially when we can online any memory block
to the zone you like. We should really strive to reduce the amount of
code rather than keep it just in case without anybody actually using it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
