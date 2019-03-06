Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D05C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 11:44:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A24A52064A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 11:44:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A24A52064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30D698E0003; Wed,  6 Mar 2019 06:44:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BD028E0002; Wed,  6 Mar 2019 06:44:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AC318E0003; Wed,  6 Mar 2019 06:44:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B6BC08E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 06:44:48 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x47so6131645eda.8
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 03:44:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=19/dyx0KVPyUNRgBJ8gBC4lPt3fOkQs7jZ6i3InBSec=;
        b=YH1Ho9n40c4OauGO5fUgQl7zwIJ2LijPCIkZ252iP1tNum8x8lEB7uRHSD0J9qUO5J
         RXGMB3DoLhjc3IIxZcH+H2GaiPvkMFV/O8lwE22GsnJZ1hdMhIIbUypQcgylvWtZlz2o
         4JAKZkQD1zkMcyJDW3oY2aWgIRKv+4MQbtFocb2mVjMhFvvB4c9RztWP5efrnLyRflC+
         WmPaKKo7QQ9+KpkpWLNhLixXupeMp77vuXVR4lN+gp+1nFXDiz5jNy84A0D+5D6EdcXb
         2ZcN/tFVkYM17BjdrBkCMqfHTP9Yi2wdy1AfjYq7Uvl/zHlz4DvFEXMuriOMX3FIFkeJ
         P0wQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVT17K16hbxAxhU6rOxnF65+M2fLs1C5bcanyCyXBx0ytuan+Zv
	RqSs3FoQlY3gHdkuWeYR2d/sMEW7YoX2MhjF33Z0T/wvjOB/NvDkXaDNW1xpjtXG8K5djqlTHDX
	5LBErvbG60LFc+Sdm73BJ4FNYcADWRRWZhtLnQ9pnsggC/piKcfLmpRYnQu/i9r4=
X-Received: by 2002:a50:97b3:: with SMTP id e48mr23635429edb.159.1551872688283;
        Wed, 06 Mar 2019 03:44:48 -0800 (PST)
X-Google-Smtp-Source: APXvYqyTEgNjLhsG1UIHVIdam8cfWpV0tTDU5Bcd+wNzEAXibBM9GDJGbvdb0y+KTw1dIIUpsrh5
X-Received: by 2002:a50:97b3:: with SMTP id e48mr23635342edb.159.1551872686699;
        Wed, 06 Mar 2019 03:44:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551872686; cv=none;
        d=google.com; s=arc-20160816;
        b=H7FX5QutG2y1/6RciVMzO9mq22Tkf5Ci71uu4MegeWLqWXgULvVo/ifM6nyvZAeHai
         TUtmXgRZxiDB4KqB5dNDF6YV2IT+ehpHS6bsBwVm32XVKZYWiFWdQjEA302+vQMVi+5L
         llzH7M9Dw9eokY4JA2gR3SEp+6MXkEi8VsOeKyy+a5NWrOQbTu9QY8dmKxY5YJYr5o7r
         AbtsXDcxz34iLFgvkREup10J97dIm2pL5b891J7YctiKvhXbMuAcoQrzT9F2PQZbfrIq
         aROoVIwwhXuHvpif1BkNmjlWkh1cqkKpWIjyBJedLthwCYBAk+PfvgkFmJUgUJMSXPlT
         6HJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=19/dyx0KVPyUNRgBJ8gBC4lPt3fOkQs7jZ6i3InBSec=;
        b=l95wc37IPyyl6Xy/cIIxJK9SLs7cO/ZoXI+99amuyahHXmp/z6Xfhw+EbLuGTj+m04
         AytDwWq7I802V6g7ewkxWIrStWrzH2C6BWy6+y7N0wj/u1yFR1djkWeeIR0vqOFKTf2h
         pSwuRKetmDErF54bOU8U4PbdIPTBXdvCYalhom8mQmqVkH44Sa5Aa3W+TPqBx3atVTZm
         VOaOSw90Y+WXVvkK6b4jpOIaaPa028RKQ/TdDfgL8GA4yfgnlkqiRMa9OAJcR5bi7RKR
         EzE6ThZ7vh+Y84rsniL9metvgGlM560Y/hUsNIjxa2yc2KQMcSkPL9/5GBq/RiubFWYc
         rPuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4si549035ejr.141.2019.03.06.03.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 03:44:46 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F303BBABC;
	Wed,  6 Mar 2019 11:44:45 +0000 (UTC)
Date: Wed, 6 Mar 2019 12:44:43 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org,
	mpe@ellerman.id.au, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Message-ID: <20190306114443.GG4603@dhcp22.suse.cz>
References: <20190301220814.97339-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190301220814.97339-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 01-03-19 17:08:14, Qian Cai wrote:
> When onlining a memory block with DEBUG_PAGEALLOC, it unmaps the pages
> in the block from kernel, However, it does not map those pages while
> offlining at the beginning. As the result, it triggers a panic below
> while onlining on ppc64le as it checks if the pages are mapped before
> unmapping. However, the imbalance exists for all arches where
> double-unmappings could happen. Therefore, let kernel map those pages in
> generic_online_page() before they have being freed into the page
> allocator for the first time where it will set the page count to one.

OK, hooking into generic_online_page makes much more sense than the
previous attempt (inside offlining path).

> On the other hand, it works fine during the boot, because at least for
> IBM POWER8, it does,
> 
> early_setup
>   early_init_mmu
>     harsh__early_init_mmu
>       htab_initialize [1]
>         htab_bolt_mapping [2]
> 
> where it effectively map all memblock regions just like
> kernel_map_linear_page(), so later mem_init() -> memblock_free_all()
> will unmap them just fine without any imbalance. On other arches without
> this imbalance checking, it still unmap them once at the most.
> 
> [1]
> for_each_memblock(memory, reg) {
>         base = (unsigned long)__va(reg->base);
>         size = reg->size;
> 
>         DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
>                 base, size, prot);
> 
>         BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
>                 prot, mmu_linear_psize, mmu_kernel_ssize));
>         }
> 
> [2] linear_map_hash_slots[paddr >> PAGE_SHIFT] = ret | 0x80;
> 
> kernel BUG at arch/powerpc/mm/hash_utils_64.c:1815!
> Oops: Exception in kernel mode, sig: 5 [#1]
> LE SMP NR_CPUS=256 DEBUG_PAGEALLOC NUMA pSeries
> CPU: 2 PID: 4298 Comm: bash Not tainted 5.0.0-rc7+ #15
> NIP:  c000000000062670 LR: c00000000006265c CTR: 0000000000000000
> REGS: c0000005bf8a75b0 TRAP: 0700   Not tainted  (5.0.0-rc7+)
> MSR:  800000000282b033 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI,LE>  CR: 28422842
> XER: 00000000
> CFAR: c000000000804f44 IRQMASK: 1
> GPR00: c00000000006265c c0000005bf8a7840 c000000001518200 c0000000013cbcc8
> GPR04: 0000000000080004 0000000000000000 00000000ccc457e0 c0000005c4e341d8
> GPR08: 0000000000000000 0000000000000001 c000000007f4f800 0000000000000001
> GPR12: 0000000000002200 c000000007f4e100 0000000000000000 0000000139c29710
> GPR16: 0000000139c29714 0000000139c29788 c0000000013cbcc8 0000000000000000
> GPR20: 0000000000034000 c0000000016e05e8 0000000000000000 0000000000000001
> GPR24: 0000000000bf50d9 800000000000018e 0000000000000000 c0000000016e04b8
> GPR28: f000000000d00040 0000006420a2f217 f000000000d00000 00ea1b2170340000
> NIP [c000000000062670] __kernel_map_pages+0x2e0/0x4f0
> LR [c00000000006265c] __kernel_map_pages+0x2cc/0x4f0
> Call Trace:
> [c0000005bf8a7840] [c00000000006265c] __kernel_map_pages+0x2cc/0x4f0
> (unreliable)
> [c0000005bf8a78d0] [c00000000028c4a0] free_unref_page_prepare+0x2f0/0x4d0
> [c0000005bf8a7930] [c000000000293144] free_unref_page+0x44/0x90
> [c0000005bf8a7970] [c00000000037af24] __online_page_free+0x84/0x110
> [c0000005bf8a79a0] [c00000000037b6e0] online_pages_range+0xc0/0x150
> [c0000005bf8a7a00] [c00000000005aaa8] walk_system_ram_range+0xc8/0x120
> [c0000005bf8a7a50] [c00000000037e710] online_pages+0x280/0x5a0
> [c0000005bf8a7b40] [c0000000006419e4] memory_subsys_online+0x1b4/0x270
> [c0000005bf8a7bb0] [c000000000616720] device_online+0xc0/0xf0
> [c0000005bf8a7bf0] [c000000000642570] state_store+0xc0/0x180
> [c0000005bf8a7c30] [c000000000610b2c] dev_attr_store+0x3c/0x60
> [c0000005bf8a7c50] [c0000000004c0a50] sysfs_kf_write+0x70/0xb0
> [c0000005bf8a7c90] [c0000000004bf40c] kernfs_fop_write+0x10c/0x250
> [c0000005bf8a7ce0] [c0000000003e4b18] __vfs_write+0x48/0x240
> [c0000005bf8a7d80] [c0000000003e4f68] vfs_write+0xd8/0x210
> [c0000005bf8a7dd0] [c0000000003e52f0] ksys_write+0x70/0x120
> [c0000005bf8a7e20] [c00000000000b000] system_call+0x5c/0x70
> Instruction dump:
> 7fbd5278 7fbd4a78 3e42ffeb 7bbd0640 3a523ac8 7e439378 487a2881 60000000
> e95505f0 7e6aa0ae 6a690080 7929c9c2 <0b090000> 7f4aa1ae 7e439378 487a28dd
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

I can see Andrew has sent the patch to Linus already (btw. was there any
reason to rush this? It's been broken for a long time without anybody
noticing, but whatever).

Just for the reference.
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memory_hotplug.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c4f59ac21014..2a778602a821 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -661,6 +661,7 @@ EXPORT_SYMBOL_GPL(__online_page_free);
>  
>  static void generic_online_page(struct page *page, unsigned int order)
>  {
> +	kernel_map_pages(page, 1 << order, 1);
>  	__free_pages_core(page, order);
>  	totalram_pages_add(1UL << order);
>  #ifdef CONFIG_HIGHMEM
> -- 
> 2.17.2 (Apple Git-113)

-- 
Michal Hocko
SUSE Labs

