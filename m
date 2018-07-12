Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 136426B000A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 22:48:50 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id h89-v6so3852685wrh.15
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 19:48:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j19-v6sor921669wmf.26.2018.07.11.19.48.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 19:48:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180711085407.GB20050@dhcp22.suse.cz>
References: <CGME20180709122019eucas1p2340da484acfcc932537e6014f4fd2c29@eucas1p2.samsung.com>
 <20180709121956.20200-1-m.szyprowski@samsung.com> <20180709122019eucas1p2340da484acfcc932537e6014f4fd2c29~-sqTPJKij2939229392eucas1p2j@eucas1p2.samsung.com>
 <CAAmzW4PPNYhUj_MeZox+ddq8MjXqnJs_AJ3xkayf710udD1pSg@mail.gmail.com>
 <20180710095056.GE14284@dhcp22.suse.cz> <CAAmzW4P1m_T77DfQzDD6ysGaOF46++-0gwRaOajmo6ef=VYp=A@mail.gmail.com>
 <20180711085407.GB20050@dhcp22.suse.cz>
From: Joonsoo Kim <js1304@gmail.com>
Date: Thu, 12 Jul 2018 11:48:47 +0900
Message-ID: <CAAmzW4M3KADCZD9+B2h7=WsYksGtg-GzYRCJjbqK5Scceynrrg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/cma: remove unsupported gfp_mask parameter from cma_alloc()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, iommu@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@lst.de>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Chris Zankel <chris@zankel.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Joerg Roedel <joro@8bytes.org>, Sumit Semwal <sumit.semwal@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Laura Abbott <labbott@redhat.com>, linaro-mm-sig@lists.linaro.org

2018-07-11 17:54 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 11-07-18 16:35:28, Joonsoo Kim wrote:
>> 2018-07-10 18:50 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
>> > On Tue 10-07-18 16:19:32, Joonsoo Kim wrote:
>> >> Hello, Marek.
>> >>
>> >> 2018-07-09 21:19 GMT+09:00 Marek Szyprowski <m.szyprowski@samsung.com>:
>> >> > cma_alloc() function doesn't really support gfp flags other than
>> >> > __GFP_NOWARN, so convert gfp_mask parameter to boolean no_warn parameter.
>> >>
>> >> Although gfp_mask isn't used in cma_alloc() except no_warn, it can be used
>> >> in alloc_contig_range(). For example, if passed gfp mask has no __GFP_FS,
>> >> compaction(isolation) would work differently. Do you have considered
>> >> such a case?
>> >
>> > Does any of cma_alloc users actually care about GFP_NO{FS,IO}?
>>
>> I don't know. My guess is that cma_alloc() is used for DMA allocation so
>> block device would use it, too. If fs/block subsystem initiates the
>> request for the device,
>> it would be possible that cma_alloc() is called with such a flag.
>> Again, I don't know
>> much about those subsystem so I would be wrong.
>
> The patch converts existing users and none of them really tries to use
> anything other than GFP_KERNEL [|__GFP_NOWARN] so this doesn't seem to
> be the case. Should there be a new user requiring more restricted
> gfp_mask we should carefuly re-evaluate and think how to support it.

One of existing user is general DMA layer and it takes gfp flags that is
provided by user. I don't check all the DMA allocation sites but how do
you convince that none of them try to use anything other
than GFP_KERNEL [|__GFP_NOWARN]?

Thanks.
