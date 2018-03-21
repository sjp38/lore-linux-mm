Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 891E76B000A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 05:59:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i64so2058677wmd.8
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 02:59:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k66si3108742wrc.14.2018.03.21.02.59.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 02:59:15 -0700 (PDT)
Date: Wed, 21 Mar 2018 10:59:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSNOiDnrZTlpI06IFtQQVRD?= =?utf-8?Q?H=5D?=
 mm/memcontrol.c: speed up to force empty a memory cgroup
Message-ID: <20180321095913.GE23100@dhcp22.suse.cz>
References: <20180319085355.GQ23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com>
 <20180319103756.GV23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374589DC@BC-MAIL-M28.internal.baidu.com>
 <alpine.DEB.2.20.1803191044310.177918@chino.kir.corp.google.com>
 <20180320083950.GD23100@dhcp22.suse.cz>
 <alpine.DEB.2.20.1803201327060.167205@chino.kir.corp.google.com>
 <56508bd0-e8d7-55fd-5109-c8dacf26b13e@virtuozzo.com>
 <alpine.DEB.2.20.1803201514340.14003@chino.kir.corp.google.com>
 <e265c518-968b-8669-ad22-671c781ad96e@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e265c518-968b-8669-ad22-671c781ad96e@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: David Rientjes <rientjes@google.com>, "Li,Rongqing" <lirongqing@baidu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed 21-03-18 01:35:05, Andrey Ryabinin wrote:
> On 03/21/2018 01:15 AM, David Rientjes wrote:
> > On Wed, 21 Mar 2018, Andrey Ryabinin wrote:
> > 
> >>>>> It would probably be best to limit the 
> >>>>> nr_pages to the amount that needs to be reclaimed, though, rather than 
> >>>>> over reclaiming.
> >>>>
> >>>> How do you achieve that? The charging path is not synchornized with the
> >>>> shrinking one at all.
> >>>>
> >>>
> >>> The point is to get a better guess at how many pages, up to 
> >>> SWAP_CLUSTER_MAX, that need to be reclaimed instead of 1.
> >>>
> >>>>> If you wanted to be invasive, you could change page_counter_limit() to 
> >>>>> return the count - limit, fix up the callers that look for -EBUSY, and 
> >>>>> then use max(val, SWAP_CLUSTER_MAX) as your nr_pages.
> >>>>
> >>>> I am not sure I understand
> >>>>
> >>>
> >>> Have page_counter_limit() return the number of pages over limit, i.e. 
> >>> count - limit, since it compares the two anyway.  Fix up existing callers 
> >>> and then clamp that value to SWAP_CLUSTER_MAX in 
> >>> mem_cgroup_resize_limit().  It's a more accurate guess than either 1 or 
> >>> 1024.
> >>>
> >>
> >> JFYI, it's never 1, it's always SWAP_CLUSTER_MAX.
> >> See try_to_free_mem_cgroup_pages():
> >> ....	
> >> 	struct scan_control sc = {
> >> 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
> >>
> > 
> > Is SWAP_CLUSTER_MAX the best answer if I'm lowering the limit by 1GB?
> > 
> 
> Absolutely not. I completely on your side here. 
> I've tried to fix this recently - http://lkml.kernel.org/r/20180119132544.19569-2-aryabinin@virtuozzo.com
> I guess that Andrew decided to not take my patch, because Michal wasn't
> happy about it (see mail archives if you want more details).

I was unhappy about the explanation and justification of the patch. It
is still not clear to me why try_to_free_mem_cgroup_pages with a single
target should be slower than multiple calls of this function with
smaller batches when the real reclaim is still SWAP_CLUSTER_MAX batched.

There is also a theoretical risk of over reclaim. Especially with large
targets.

-- 
Michal Hocko
SUSE Labs
