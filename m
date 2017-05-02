Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6626B02F2
	for <linux-mm@kvack.org>; Tue,  2 May 2017 09:43:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h19so1909370wmi.10
        for <linux-mm@kvack.org>; Tue, 02 May 2017 06:43:23 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id y26si15108137wrd.301.2017.05.02.06.43.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 06:43:22 -0700 (PDT)
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop> <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <32ac1107-14a3-fdff-ad48-0e246fec704f@suse.cz>
 <20170502130326.GJ14593@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <2cd6a2c5-6e78-1d34-69b5-97a7de740b06@huawei.com>
Date: Tue, 2 May 2017 16:41:55 +0300
MIME-Version: 1.0
In-Reply-To: <20170502130326.GJ14593@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh
 Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 02/05/17 16:03, Michal Hocko wrote:

> I can imagine that we could make ZONE_CMA configurable in a way that
> only very well defined use cases would be supported so that we can save
> page flags space. But this alone sounds like a maintainability nightmare
> to me. Especially when I consider ZONE_DMA situation. There is simply
> not an easy way to find out whether my HW really needs DMA zone or
> not. Most probably not but it still is configured and hidden behind
> config ZONE_DMA
>         bool "DMA memory allocation support" if EXPERT
>         default y
>         help
>           DMA memory allocation support allows devices with less than 32-bit
>           addressing to allocate within the first 16MB of address space.
>           Disable if no such devices will be used.
> 
>           If unsure, say Y.
> 
> Are we really ready to add another thing like that? How are distribution
> kernels going to handle that?

In practice there are 2 quite opposite scenarios:

- distros that try to cater to (almost) everyone and are constrained in
what they can leave out

- ad-hoc builds (like Android, but also IoT) where the HW is *very* well
known upfront, because it's probably even impossible to make any change
that doesn't involved a rework station.

So maybe the answer is to not have only EXPERT, but rather DISTRO/CUSTOM
with the implications these can bring.

A generic build would assume to be a DISTRO type, but something else, of
more embedded persuasion, could do otherwise.

ZONE_DMA / ZONE_DMA32 actually seem to be perfect candidates for being
replaced by something else, when unused, as I proposed on Friday:

http://marc.info/?l=linux-mm&m=149337033630993&w=2


It might still be that only some cases would be upstreamable, even after
these changes.

But at least some of those might be useful also for non-Android/ non-IoT
scenarios.


---
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
