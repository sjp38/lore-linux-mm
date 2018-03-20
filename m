Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D7AA36B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 18:15:16 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z11-v6so1923416plo.21
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 15:15:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j10sor791825pfe.94.2018.03.20.15.15.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 15:15:15 -0700 (PDT)
Date: Tue, 20 Mar 2018 15:15:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: =?UTF-8?Q?Re=3A_=E7=AD=94=E5=A4=8D=3A_=E7=AD=94=E5=A4=8D=3A_=5BPATCH=5D_mm=2Fmemcontrol=2Ec=3A_speed_up_to_force_empty_a_memory_cgroup?=
In-Reply-To: <56508bd0-e8d7-55fd-5109-c8dacf26b13e@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1803201514340.14003@chino.kir.corp.google.com>
References: <1521448170-19482-1-git-send-email-lirongqing@baidu.com> <20180319085355.GQ23100@dhcp22.suse.cz> <2AD939572F25A448A3AE3CAEA61328C23745764B@BC-MAIL-M28.internal.baidu.com> <20180319103756.GV23100@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C2374589DC@BC-MAIL-M28.internal.baidu.com> <alpine.DEB.2.20.1803191044310.177918@chino.kir.corp.google.com> <20180320083950.GD23100@dhcp22.suse.cz> <alpine.DEB.2.20.1803201327060.167205@chino.kir.corp.google.com>
 <56508bd0-e8d7-55fd-5109-c8dacf26b13e@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Li,Rongqing" <lirongqing@baidu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed, 21 Mar 2018, Andrey Ryabinin wrote:

> >>> It would probably be best to limit the 
> >>> nr_pages to the amount that needs to be reclaimed, though, rather than 
> >>> over reclaiming.
> >>
> >> How do you achieve that? The charging path is not synchornized with the
> >> shrinking one at all.
> >>
> > 
> > The point is to get a better guess at how many pages, up to 
> > SWAP_CLUSTER_MAX, that need to be reclaimed instead of 1.
> > 
> >>> If you wanted to be invasive, you could change page_counter_limit() to 
> >>> return the count - limit, fix up the callers that look for -EBUSY, and 
> >>> then use max(val, SWAP_CLUSTER_MAX) as your nr_pages.
> >>
> >> I am not sure I understand
> >>
> > 
> > Have page_counter_limit() return the number of pages over limit, i.e. 
> > count - limit, since it compares the two anyway.  Fix up existing callers 
> > and then clamp that value to SWAP_CLUSTER_MAX in 
> > mem_cgroup_resize_limit().  It's a more accurate guess than either 1 or 
> > 1024.
> > 
> 
> JFYI, it's never 1, it's always SWAP_CLUSTER_MAX.
> See try_to_free_mem_cgroup_pages():
> ....	
> 	struct scan_control sc = {
> 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
> 

Is SWAP_CLUSTER_MAX the best answer if I'm lowering the limit by 1GB?
