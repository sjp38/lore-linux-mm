Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 596B36B0260
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 10:47:42 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q83so269805793iod.2
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 07:47:42 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z75si541346ioz.219.2016.07.16.07.47.40
        for <linux-mm@kvack.org>;
        Sat, 16 Jul 2016 07:47:41 -0700 (PDT)
Date: Sat, 16 Jul 2016 23:47:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: 4.1.28: memory leak introduced by "mm/swap.c: flush lru pvecs on
 compound page arrival"
Message-ID: <20160716144740.GA29708@bbox>
References: <83d21ffc-eeb8-40f8-7443-8d8291cd5973@ADLINKtech.com>
MIME-Version: 1.0
In-Reply-To: <83d21ffc-eeb8-40f8-7443-8d8291cd5973@ADLINKtech.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Rottmann <Jens.Rottmann@ADLINKtech.com>
Cc: Lukasz Odzioba <lukasz.odzioba@intel.com>, Sasha Levin <sasha.levin@oracle.com>, stable@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 15, 2016 at 09:27:55PM +0200, Jens Rottmann wrote:
> Hi,
> 
> 4.1.y stable commit c5ad33184354260be6d05de57e46a5498692f6d6 (Upstream
> commit 8f182270dfec432e93fae14f9208a6b9af01009f) "mm/swap.c: flush lru
> pvecs on compound page arrival" in 4.1.28 introduces a memory leak.
> 
> Simply running
> 
> while sleep 0.1; do clear; free; done
> 
> shows mem continuously going down, eventually system panics with no
> killable processes left. Using "unxz -t some.xz" instead of sleep brings
> system down within minutes.
> 
> Kmemleak did not report anything. Bisect ended at named commit, and
> reverting only this commit is indeed sufficient to fix the leak. Swap
> partition on/off makes no difference.
> 
> My set-up:
> i.MX6 (ARM Cortex-A9) dual-core, 2 GB RAM. Kernel sources are from
> git.freescale.com i.e. heavily modified by Freescale for i.MX SoCs,
> kernel.org stable patches up to 4.1.28 manually added.
> 
> I tried to reproduce with vanilla 4.1.28, but that wouldn't boot at all
> on my hardware, hangs immediately after "Starting kernel", sorry.
> However there is not a single difference between Freescale and vanilla
> in the whole mm/ subdirectory, so I don't think it's i.MX-specific. I
> didn't cross-check with an x86 system (yet).

I didn't have 4.1 stable tree in my local so just looked at git web
and found __lru_cache_add has a bug.

Please change

static void __lru_cache_add(struct page *page)
{
        struct pagevec *pvec = &get_cpu_var(lru_add_pvec);

        page_cache_get(page);
        if (!pagevec_space(pvec) || PageCompound(page)) <==
                __pagevec_lru_add(pvec);
        put_cpu_var(lru_add_pvec);
}

with

static void __lru_cache_add(struct page *page)
{
        struct pagevec *pvec = &get_cpu_var(lru_add_pvec);

        page_cache_get(page);
        if (!pagevec_add(pvec, page) || PageCompound(page)) <==
                __pagevec_lru_add(pvec);
        put_cpu_var(lru_add_pvec);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
