Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62BDD6B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 04:10:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p85so11295292lfg.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 01:10:54 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id kc2si11728255wjc.61.2016.07.28.01.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 01:10:53 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o80so9927967wme.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 01:10:52 -0700 (PDT)
Date: Thu, 28 Jul 2016 10:10:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Question]page allocation failure: order:2, mode:0x2000d1
Message-ID: <20160728081051.GA1000@dhcp22.suse.cz>
References: <b3127e70-4fca-9e11-62e5-7a8f3da9d044@huawei.com>
 <5d0d3274-a893-8453-fb3d-87981dd38cfa@suse.cz>
 <578E2FBF.2080405@huawei.com>
 <2c8255c9-e449-d245-8554-0ed258d594ed@suse.cz>
 <7d9da183-38bf-96ef-a30c-db8b7dc9aafb@huawei.com>
 <20160720074723.GA11256@dhcp22.suse.cz>
 <5799B948.6080308@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5799B948.6080308@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Vlastimil Babka <vbabka@suse.cz>, minchan@kernel.org, mgorman@suse.de, iamjoonsoo.kim@lge.com, mina86@mina86.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, cl@linux.com, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>

On Thu 28-07-16 15:50:32, Xishi Qiu wrote:
> On 2016/7/20 15:47, Michal Hocko wrote:
> 
> > On Wed 20-07-16 09:33:30, Yisheng Xie wrote:
> >>
> >>
> >> On 2016/7/19 22:14, Vlastimil Babka wrote:
> >>> On 07/19/2016 03:48 PM, Xishi Qiu wrote:
> > [...]
> >>>> mode:0x2000d1 means it expects to alloc from zone_dma, (on arm64 zone_dma is 0-4G)
> >>>
> >>> Yes, but I don't see where the __GFP_DMA comes from. The backtrace
> >>> suggests it's alloc_thread_info_node() which uses THREADINFO_GFP
> >>> which is GFP_KERNEL | __GFP_NOTRACK. There shouldn't be __GFP_DMA,
> >>> even on arm64. Are there some local modifications to the kernel
> >>> source?
> >>>
> >>>> The page cache is very small(active_file:292kB inactive_file:240kB),
> >>>> so did_some_progress may be zero, and will not retry, right?
> >>>
> >>> Could be, and then __alloc_pages_may_oom() has this:
> >>>
> >>>         /* The OOM killer does not needlessly kill tasks for lowmem */
> >>>         if (ac->high_zoneidx < ZONE_NORMAL)
> >>>                 goto out;
> >>>
> >>> So no oom and no faking progress for non-costly order that would
> >>> result in retry, because of that mysterious __GFP_DMA...
> >>
> >> hi Vlastimil,
> >> We do make change and add __GFP_DMA flag here for our platform driver's problem.
> > 
> > Why would you want to force thread_info to the DMA zone?
> > 
> 
> Hi Michal,
> 
> Because of our platform driver's problem, so we change the code(add GFP_DMA) to let
> it alloc from zone_dma. (on arm64 zone_dma is 0-4G)

Why would any platform driver need to access kernel thread in the DMA
zone?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
