Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 856CA6B0389
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 12:35:40 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u48so22551487wrc.0
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 09:35:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u2si10178894wmd.38.2017.03.19.09.35.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 09:35:39 -0700 (PDT)
Date: Sun, 19 Mar 2017 12:35:31 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 00/13] mm: sub-section memory hotplug support
Message-ID: <20170319163531.GA25835@dhcp22.suse.cz>
References: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170316174805.GB13654@dhcp22.suse.cz>
 <CAPcyv4hMt0s7UX=MO9KwakjXG9Uff=8XGR+Uc7YoVWoLqbKeGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hMt0s7UX=MO9KwakjXG9Uff=8XGR+Uc7YoVWoLqbKeGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hpe.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Logan Gunthorpe <logang@deltatee.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stephen Bates <stephen.bates@microsemi.com>, Linux MM <linux-mm@kvack.org>, Nicolai Stange <nicstange@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

On Thu 16-03-17 12:04:48, Dan Williams wrote:
> On Thu, Mar 16, 2017 at 10:48 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > Hi,
> > I didn't get to look through the patch series yet and I might not be
> > able before LSF/MM. How urgent is this? I am primarily asking because
> > the memory hotplug is really convoluted right now and putting more on
> > top doesn't really sound like the thing we really want. I have tried to
> > simplify the code [1] already but this is an early stage work so I do
> > not want to impose any burden on you. So I am wondering whether this
> > is something that needs to be merged very soon or it can wait for the
> > rework and hopefully end up being much simpler in the end as well.
> >
> > What do you think?
> 
> In general, I think it's better to add new features after
> reworks/cleanup, but it's not clear to me (yet) that the problem you
> are trying to solve makes this sub-section enabling for ZONE_DEVICE
> any simpler.
> 
> > [1] http://lkml.kernel.org/r/20170315091347.GA32626@dhcp22.suse.cz
> 
> ZONE_DEVICE pages are never "online". The patch says "Instead we do
> page->zone association from move_pfn_range which is called from
> online_pages." which means the new scheme currently doesn't comprehend
> the sprinkled ZONE_DEVICE hacks in the memory hotplug code.

I hope we can get rid of those...
 
> However, that said, I might take a look at whether the hacks belong in
> the auto-online code so that we can share the delayed zone
> initialization, but still skip marking the memory online per the
> expectations of ZONE_DEVICE.

I think this should be trivial. AFAIU it should be sufficient to split
my move_pfn_range into online_pfn_range which would do the MMOP_ONLINE*
handling and the real move_pfn_range which would do the zone specific
association. Your devm_memremap_pages would then call this
move_pfn_range after arch_add_memory. Or am I overlooking something?

I would still have to addapt your changes to remove hardcoded section
aligned expectations but that shouldn't be a big problem I guess. I
still haven't looked into those deeply to fully understand them.

> I expect it would be confusing to have
> memblock devices in sysfs for ranges that can't be marked online?

Well, if their only valid_zone would be ZONE_DEVICE then I believe it
shouldn't be confusing much.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
