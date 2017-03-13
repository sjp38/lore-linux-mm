Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 00C136B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:21:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d66so12917346wmi.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 02:21:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k203si10082943wmk.155.2017.03.13.02.21.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 02:21:47 -0700 (PDT)
Date: Mon, 13 Mar 2017 10:21:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WTH is going on with memory hotplug sysf interface (was: Re:
 [RFC PATCH] mm, hotplug: get rid of auto_online_blocks)
Message-ID: <20170313092145.GG31518@dhcp22.suse.cz>
References: <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
 <20170310135807.GI3753@dhcp22.suse.cz>
 <20170310155333.GN3753@dhcp22.suse.cz>
 <20170310190037.fifahjd47joim6zy@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170310190037.fifahjd47joim6zy@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Zhang Zhen <zhenzhang.zhang@huawei.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Fri 10-03-17 13:00:37, Reza Arbab wrote:
> On Fri, Mar 10, 2017 at 04:53:33PM +0100, Michal Hocko wrote:
> >OK, so while I was playing with this setup some more I probably got why
> >this is done this way. All new memblocks are added to the zone Normal
> >where they are accounted as spanned but not present.
> 
> It's not always zone Normal. See zone_for_memory(). This leads to a
> workaround for having to do online_movable in descending block order.
> Instead of this:
> 
> 1. probe block 34, probe block 33, probe block 32, ...
> 2. online_movable 34, online_movable 33, online_movable 32, ...
> 
> you can online_movable the first block before adding the rest:

I do I enforce that behavior when the probe happens automagically?

> 1. probe block 32, online_movable 32
> 2. probe block 33, probe block 34, ...
> 	- zone_for_memory() will cause these to start Movable
> 3. online 33, online 34, ...
> 	- they're already in Movable, so online_movable is equivalentr
> 
> I agree with your general sentiment that this stuff is very nonintuitive.

My criterion for nonintuitive is probably different because I would call
this _completely_unusable_. Sorry for being so loud about this but the
more I look into this area the more WTF code I see. This has seen close
to zero review and seems to be building up more single usecase code on
top of previous. We need to change this, seriously!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
