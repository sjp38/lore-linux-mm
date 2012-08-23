Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 1668C6B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 23:49:08 -0400 (EDT)
Date: Thu, 23 Aug 2012 12:49:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/4] ARM: dma-mapping: IOMMU allocates pages from pool with
 GFP_ATOMIC
Message-ID: <20120823034935.GC5369@bbox>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
 <1345630830-9586-3-git-send-email-hdoyu@nvidia.com>
 <CAHQjnOOF7Ca-Dz8K_zcS=gxQsJvKYaWA3tqUeK1RSd-wLYZ44w@mail.gmail.com>
 <20120822.163648.3800987367886904.hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120822.163648.3800987367886904.hdoyu@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>

On Wed, Aug 22, 2012 at 03:36:48PM +0200, Hiroshi Doyu wrote:
> Hi,
> 
> KyongHo Cho <pullip.cho@samsung.com> wrote @ Wed, 22 Aug 2012 14:47:00 +0200:
> 
> > vzalloc() call in __iommu_alloc_buffer() also causes BUG() in atomic context.
> 
> Right.
> 
> I've been thinking that kzalloc() may be enough here, since
> vzalloc() was introduced to avoid allocation failure for big chunk of
> memory, but I think that it's unlikely that the number of page array
> can be so big. So I propose to drop vzalloc() here, and just simply to
> use kzalloc only as below(*1).
> 
> For example, 
> 
> 1920(H) x 1080(W) x 4(bytes) ~= 8MiB
> 
> For 8 MiB buffer,
>   8(MiB) * 1024 = 8192(KiB)
>   8192(KiB) / 4(KiB/page) = 2048 pages
>   sizeof(struct page *) = 4 bytes
>   2048(pages) * 4(bytes/page) = 8192(bytes) = 8(KiB)
>   8(KiB) / 4(KiB/page) = 2 pages
> 
> If the above estimation is right(I hope;)), the necessary pages are
> _at most_ 2 pages. If the system gets into the situation to fail to
> allocate 2 contiguous pages, that's real the problem. I guess that
> that kind of fragmentation problem would be solved with page migration
> or something, especially nowadays devices are getting larger memories.

In atomic context, VM have no choice except relying on kswapd so
high order allocation can fail easily when memory fragementation
is high.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
