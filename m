Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3276B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 08:40:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b86so9712129wmi.6
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 05:40:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j89si19533186edc.36.2017.06.01.05.40.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 05:40:25 -0700 (PDT)
Date: Thu, 1 Jun 2017 14:40:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: fix MMOP_ONLINE_KEEP behavior
Message-ID: <20170601124022.GC9091@dhcp22.suse.cz>
References: <20170601083746.4924-1-mhocko@kernel.org>
 <20170601083746.4924-2-mhocko@kernel.org>
 <ad200307-63d1-fe6f-cbc6-09c8cb431b8a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ad200307-63d1-fe6f-cbc6-09c8cb431b8a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 01-06-17 14:32:42, Vlastimil Babka wrote:
> On 06/01/2017 10:37 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Heiko Carstens has noticed that the MMOP_ONLINE_KEEP is broken currently
> > $ grep . memory3?/valid_zones
> > memory34/valid_zones:Normal Movable
> > memory35/valid_zones:Normal Movable
> > memory36/valid_zones:Normal Movable
> > memory37/valid_zones:Normal Movable
> > 
> > $ echo online_movable > memory34/state
> > $ grep . memory3?/valid_zones
> > memory34/valid_zones:Movable
> > memory35/valid_zones:Movable
> > memory36/valid_zones:Movable
> > memory37/valid_zones:Movable
> > 
> > $ echo online > memory36/state
> > $ grep . memory3?/valid_zones
> > memory34/valid_zones:Movable
> > memory36/valid_zones:Normal
> > memory37/valid_zones:Movable
> > 
> > so we have effectivelly punched a hole into the movable zone. The
> > problem is that move_pfn_range() check for MMOP_ONLINE_KEEP is wrong.
> > It only checks whether the given range is already part of the movable
> > zone which is not the case here as only memory34 is in the zone. Fix
> > this by using allow_online_pfn_range(..., MMOP_ONLINE_KERNEL) if that
> > is false then we can be sure that movable onlining is the right thing to
> > do.
> > 
> > Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Tested-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Fixes: "mm, memory_hotplug: do not associate hotadded memory to zones until online"
> 
> Just fold it there before sending to Linus, right?

I do not have a strong preference. The changelog could still be helpful
for reference. The original patch is quite large and details like this
are likely to get lost there.

> 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
