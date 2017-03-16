Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA7C26B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 15:04:49 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id r5so46377232qtb.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:04:49 -0700 (PDT)
Received: from mail-ot0-x230.google.com (mail-ot0-x230.google.com. [2607:f8b0:4003:c0f::230])
        by mx.google.com with ESMTPS id h24si2420183otc.289.2017.03.16.12.04.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 12:04:48 -0700 (PDT)
Received: by mail-ot0-x230.google.com with SMTP id 19so67304482oti.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:04:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170316174805.GB13654@dhcp22.suse.cz>
References: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170316174805.GB13654@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 16 Mar 2017 12:04:48 -0700
Message-ID: <CAPcyv4hMt0s7UX=MO9KwakjXG9Uff=8XGR+Uc7YoVWoLqbKeGw@mail.gmail.com>
Subject: Re: [PATCH v4 00/13] mm: sub-section memory hotplug support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hpe.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Logan Gunthorpe <logang@deltatee.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stephen Bates <stephen.bates@microsemi.com>, Linux MM <linux-mm@kvack.org>, Nicolai Stange <nicstange@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Mar 16, 2017 at 10:48 AM, Michal Hocko <mhocko@kernel.org> wrote:
> Hi,
> I didn't get to look through the patch series yet and I might not be
> able before LSF/MM. How urgent is this? I am primarily asking because
> the memory hotplug is really convoluted right now and putting more on
> top doesn't really sound like the thing we really want. I have tried to
> simplify the code [1] already but this is an early stage work so I do
> not want to impose any burden on you. So I am wondering whether this
> is something that needs to be merged very soon or it can wait for the
> rework and hopefully end up being much simpler in the end as well.
>
> What do you think?

In general, I think it's better to add new features after
reworks/cleanup, but it's not clear to me (yet) that the problem you
are trying to solve makes this sub-section enabling for ZONE_DEVICE
any simpler.

> [1] http://lkml.kernel.org/r/20170315091347.GA32626@dhcp22.suse.cz

ZONE_DEVICE pages are never "online". The patch says "Instead we do
page->zone association from move_pfn_range which is called from
online_pages." which means the new scheme currently doesn't comprehend
the sprinkled ZONE_DEVICE hacks in the memory hotplug code.

However, that said, I might take a look at whether the hacks belong in
the auto-online code so that we can share the delayed zone
initialization, but still skip marking the memory online per the
expectations of ZONE_DEVICE. I expect it would be confusing to have
memblock devices in sysfs for ranges that can't be marked online?

Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
