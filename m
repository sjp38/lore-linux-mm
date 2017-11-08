Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84410440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 10:57:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v78so2495300pfk.8
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 07:57:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si3926013plb.531.2017.11.08.07.57.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 07:57:49 -0800 (PST)
Date: Wed, 8 Nov 2017 16:57:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm/memory_hotplug: make it possible to offline
 blocks with reserved pages
Message-ID: <20171108155740.z7fwptk3jg6rc7mv@dhcp22.suse.cz>
References: <20171108130155.25499-1-vkuznets@redhat.com>
 <20171108142528.vsrkkqw6fihxdjio@dhcp22.suse.cz>
 <87y3nglqyi.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y3nglqyi.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Alex Ng <alexng@microsoft.com>

On Wed 08-11-17 16:39:49, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Wed 08-11-17 14:01:55, Vitaly Kuznetsov wrote:
> >> Hyper-V balloon driver needs to hotplug memory in smaller chunks and to
> >> workaround Linux's 128Mb allignment requirement so it does a trick: partly
> >> populated 128Mb blocks are added and then a custom online_page_callback
> >> hook checks if the particular page is 'backed' during onlining, in case it
> >> is not backed it is left in Reserved state. When the host adds more pages
> >> to the block we bring them online from the driver (see
> >> hv_bring_pgs_online()/hv_page_online_one() in drivers/hv/hv_balloon.c).
> >> Eventually the whole block becomes fully populated and we hotplug the next
> >> 128Mb. This all works for quite some time already.
> >
> > Why does HyperV needs to workaround the section size limit in the first
> > place? We are allocation memmap for the whole section anyway so it won't
> > save any memory. So the whole thing sounds rather dubious to me.
> >
> 
> Memory hotplug requirements in Windows are different, they have 2Mb
> granularity, not 128Mb like we have in Linux x86.
> 
> Imagine there's a request to add 32Mb of memory comming from the
> Hyper-V host. What can we do? Don't add anything at all and wait till
> we're suggested to add > 128Mb and then add a section or the current
> approach.

Use a different approach than memory hotplug. E.g. memory balloning.

> >> What is not working is offlining of such partly populated blocks:
> >> check_pages_isolated_cb() callback will not pass with a sinle Reserved page
> >> and we end up with -EBUSY. However, there's no reason to fail offlining in
> >> this case: these pages are already offline, we may just skip them. Add the
> >> appropriate workaround to test_pages_isolated().
> >
> > How do you recognize pages reserved by other users. You cannot simply
> > remove them, it would just blow up.
> >
> 
> I exepcted sumothing like that, thus RFC. Is there a way to detect pages
> which were never onlined? E.g. it is Reserved and count == 0?

That would be quite tricky. But I am not convinced that the whole thing
makes any sense at all. We are in fact always creating the full section
so onlining only a part of it sounds really dubious to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
