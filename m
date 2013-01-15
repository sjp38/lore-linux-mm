Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 8A0696B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 14:05:25 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig][RFC] ARM: dma-mapping: Add DMA attribute to skip iommu mapping
Date: Tue, 15 Jan 2013 19:05:11 +0000
References: <1357639944-12050-1-git-send-email-abhinav.k@samsung.com> <50F570A4.70606@samsung.com>
In-Reply-To: <50F570A4.70606@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201301151905.11704.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Abhinav Kochhar <abhinav.k@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, inki.dae@samsung.com

On Tuesday 15 January 2013, Marek Szyprowski wrote:
> I'm sorry, but from my perspective this patch and the yet another dma
> attribute shows that there is something fishy happening in the exynos-drm
> driver. Creating a mapping in DMA address space is the MAIN purpose of
> the DMA mapping subsystem, so adding an attribute which skips this
> operation already should give you a sign of warning that something is
> not used right.
> 
> It looks that dma-mapping in the current state is simply not adequate
> for this driver. I noticed that DRM drivers are already known for
> implementing a lots of common code for their own with slightly changed
> behavior, like custom page manager/allocator. It looks that exynos-drm
> driver grew to the point where it also needs such features. It already
> contains custom code for CPU cache handling, IOMMU and contiguous
> memory special cases management. I would advise to drop DMA-mapping
> API completely, avoid adding yet another dozen of DMA attributes useful
> only for one driver and implement your own memory manager with direct
> usage of IOMMU API, alloc_pages() and dma_alloc_pages_from_contiguous().
> This way DMA mapping subsystem can be kept simple, robust and easy to
> understand without confusing or conflicting parts.

Makes sense. DRM drivers and KVM are the two cases where you typically
want to use the iommu API rather than the dma-mapping API, because you
need protection between multiple concurrent user contexts.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
