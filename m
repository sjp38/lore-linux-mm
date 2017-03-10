Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06D1E28092A
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 10:53:38 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y51so29630135wry.6
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 07:53:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r3si13376235wra.194.2017.03.10.07.53.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 07:53:36 -0800 (PST)
Date: Fri, 10 Mar 2017 16:53:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WTH is going on with memory hotplug sysf interface (was: Re:
 [RFC PATCH] mm, hotplug: get rid of auto_online_blocks)
Message-ID: <20170310155333.GN3753@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
 <1488462828-174523-1-git-send-email-imammedo@redhat.com>
 <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
 <20170310135807.GI3753@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170310135807.GI3753@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Fri 10-03-17 14:58:07, Michal Hocko wrote:
[...]
> This would explain why onlining from the last block actually works but
> to me this sounds like a completely crappy behavior. All we need to
> guarantee AFAICS is that Normal and Movable zones do not overlap. I
> believe there is even no real requirement about ordering of the physical
> memory in Normal vs. Movable zones as long as they do not overlap. But
> let's keep it simple for the start and always enforce the current status
> quo that Normal zone is physically preceeding Movable zone.
> Can somebody explain why we cannot have a simple rule for Normal vs.
> Movable which would be:
> 	- block [pfn, pfn+block_size] can be Normal if
> 	  !zone_populated(MOVABLE) || pfn+block_size < ZONE_MOVABLE->zone_start_pfn
> 	- block [pfn, pfn+block_size] can be Movable if
> 	  !zone_populated(NORMAL) || ZONE_NORMAL->zone_end_pfn < pfn

OK, so while I was playing with this setup some more I probably got why
this is done this way. All new memblocks are added to the zone Normal
where they are accounted as spanned but not present. When we do
online_movable we just cut from the end of the Normal zone and move it
to Movable zone. This sounds really awkward. What was the reason to go
this way? Why cannot we simply add those pages to the zone at the online
time?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
