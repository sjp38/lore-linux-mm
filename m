Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id ABADE6B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 17:27:30 -0400 (EDT)
Received: by qgev79 with SMTP id v79so18719163qge.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 14:27:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i130si23172877qhc.89.2015.09.29.14.27.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 14:27:29 -0700 (PDT)
Date: Tue, 29 Sep 2015 14:27:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] dma-debug: Allow poisoning nonzero allocations
Message-Id: <20150929142727.e95a2d2ebff65dda86315248@linux-foundation.org>
In-Reply-To: <560585EB.3060908@arm.com>
References: <cover.1443178314.git.robin.murphy@arm.com>
	<0405c6131def5aa179ff4ba5d4201ebde89cede3.1443178314.git.robin.murphy@arm.com>
	<20150925124447.GO21513@n2100.arm.linux.org.uk>
	<560585EB.3060908@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "sakari.ailus@iki.fi" <sakari.ailus@iki.fi>, "sumit.semwal@linaro.org" <sumit.semwal@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>

On Fri, 25 Sep 2015 18:35:39 +0100 Robin Murphy <robin.murphy@arm.com> wrote:

> Hi Russell,
> 
> On 25/09/15 13:44, Russell King - ARM Linux wrote:
> > On Fri, Sep 25, 2015 at 01:15:46PM +0100, Robin Murphy wrote:
> >> Since some dma_alloc_coherent implementations return a zeroed buffer
> >> regardless of whether __GFP_ZERO is passed, there exist drivers which
> >> are implicitly dependent on this and pass otherwise uninitialised
> >> buffers to hardware. This can lead to subtle and awkward-to-debug issues
> >> using those drivers on different platforms, where nonzero uninitialised
> >> junk may for instance occasionally look like a valid command which
> >> causes the hardware to start misbehaving. To help with debugging such
> >> issues, add the option to make uninitialised buffers much more obvious.
> >
> > The reason people started to do this is to stop a security leak in the
> > ALSA code: ALSA allocates the ring buffer with dma_alloc_coherent()
> > which used to grab pages and return them uninitialised.  These pages
> > could contain anything - including the contents of /etc/shadow, or
> > your bank details.
> >
> > ALSA then lets userspace mmap() that memory, which means any user process
> > which has access to the sound devices can read data leaked from kernel
> > memory.
> >
> > I think I did bring it up at the time I found it, and decided that the
> > safest thing to do was to always return an initialised buffer - short of
> > constantly auditing every dma_alloc_coherent() user which also mmap()s
> > the buffer into userspace, I couldn't convince myself that it was safe
> > to avoid initialising the buffer.
> >
> > I don't know whether the original problem still exists in ALSA or not,
> > but I do know that there are dma_alloc_coherent() implementations out
> > there which do not initialise prior to returning memory.
> 
> Indeed, I think we've discussed this before, and I don't imagine we'll 
> be changing the actual behaviour of the existing allocators any time soon.

If I'm understanding things correctly, some allocators zero the memory
by default and others do not.  And we have an unknown number of drivers
which are assuming that the memory is zeroed.

Correct?

If so, our options are

a) audit all callers, find the ones which expect zeroed memory but
   aren't passing __GFP_ZERO and fix them.

b) convert all allocators to zero the memory by default.

Obviously, a) is better.  How big a job is it?

This patch will help the process, if people use it.

> >> +	if (IS_ENABLED(CONFIG_DMA_API_DEBUG_POISON) && !(flags & __GFP_ZERO))
> >> +		memset(virt, DMA_ALLOC_POISON, size);
> >> +
> >
> > This is likely to be slow in the case of non-cached memory and large
> > allocations.  The config option should come with a warning.
> 
> It depends on DMA_API_DEBUG, which already has a stern performance 
> warning, is additionally hidden behind EXPERT, and carries a slightly 
> flippant yet largely truthful warning that actually using it could break 
> pretty much every driver in your system; is that not enough?

It might be helpful to provide a runtime knob as well - having to
rebuild&reinstall just to enable/disable this feature is a bit painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
