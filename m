Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0B30831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 08:33:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y22so1497731wry.1
        for <linux-mm@kvack.org>; Thu, 04 May 2017 05:33:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y39si1936063wrd.240.2017.05.04.05.33.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 05:33:29 -0700 (PDT)
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
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <398b341c-5fa7-1ad7-0840-752fa1908921@suse.cz>
Date: Thu, 4 May 2017 14:33:24 +0200
MIME-Version: 1.0
In-Reply-To: <20170502130326.GJ14593@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On 05/02/2017 03:03 PM, Michal Hocko wrote:
> On Tue 02-05-17 10:06:01, Vlastimil Babka wrote:
>> On 04/27/2017 05:06 PM, Michal Hocko wrote:
>>> On Tue 25-04-17 12:42:57, Joonsoo Kim wrote:
>>>> On Mon, Apr 24, 2017 at 03:09:36PM +0200, Michal Hocko wrote:
>>>>> On Mon 17-04-17 11:02:12, Joonsoo Kim wrote:
>>>>>> On Thu, Apr 13, 2017 at 01:56:15PM +0200, Michal Hocko wrote:
>>>>>>> On Wed 12-04-17 10:35:06, Joonsoo Kim wrote:
>>> [...]
>>>>> not for free. For most common configurations where we have ZONE_DMA,
>>>>> ZONE_DMA32, ZONE_NORMAL and ZONE_MOVABLE all the 3 bits are already
>>>>> consumed so a new zone will need a new one AFAICS.
>>>>
>>>> Yes, it requires one more bit for a new zone and it's handled by the patch.
>>>
>>> I am pretty sure that you are aware that consuming new page flag bits
>>> is usually a no-go and something we try to avoid as much as possible
>>> because we are in a great shortage there. So there really have to be a
>>> _strong_ reason if we go that way. My current understanding that the
>>> whole zone concept is more about a more convenient implementation rather
>>> than a fundamental change which will solve unsolvable problems with the
>>> current approach. More on that below.
>>
>> I don't see it as such a big issue. It's behind a CONFIG option (so we
>> also don't need the jump labels you suggest later) and enabling it
>> reduces the number of possible NUMA nodes (not page flags). So either
>> you are building a kernel for android phone that needs CMA but will have
>> a single NUMA node, or for a large server with many nodes that won't
>> have CMA. As long as there won't be large servers that need CMA, we
>> should be fine (yes, I know some HW vendors can be very creative, but
>> then it's their problem?).
> 
> Is this really about Android/UMA systems only? My quick grep seems to disagree
> $ git grep CONFIG_CMA=y
> arch/arm/configs/exynos_defconfig:CONFIG_CMA=y
> arch/arm/configs/imx_v6_v7_defconfig:CONFIG_CMA=y
> arch/arm/configs/keystone_defconfig:CONFIG_CMA=y
> arch/arm/configs/multi_v7_defconfig:CONFIG_CMA=y
> arch/arm/configs/omap2plus_defconfig:CONFIG_CMA=y
> arch/arm/configs/tegra_defconfig:CONFIG_CMA=y
> arch/arm/configs/vexpress_defconfig:CONFIG_CMA=y
> arch/arm64/configs/defconfig:CONFIG_CMA=y
> arch/mips/configs/ci20_defconfig:CONFIG_CMA=y
> arch/mips/configs/db1xxx_defconfig:CONFIG_CMA=y
> arch/s390/configs/default_defconfig:CONFIG_CMA=y
> arch/s390/configs/gcov_defconfig:CONFIG_CMA=y
> arch/s390/configs/performance_defconfig:CONFIG_CMA=y
> arch/s390/defconfig:CONFIG_CMA=y
> 
> I am pretty sure s390 and ppc support NUMA and aim at supporting really
> large systems. 

I don't see ppc there, and s390 commit adding CMA as default provides no
info. Heiko/Martin, could you share what does s390 use CMA for? Thanks.

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

I still hope that generic enterprise/desktop distributions can disable
it, and it's only used for small devices with custom kernels.

The config burden is already there in any case, it just translates to
extra migratetype and fastpath hooks, not extra zone and potentially
less nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
