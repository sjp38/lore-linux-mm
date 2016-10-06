Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 035956B0038
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 13:57:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id j85so3803416wmj.5
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 10:57:33 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id o3si18959264wme.46.2016.10.06.10.57.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Oct 2016 10:57:32 -0700 (PDT)
Date: Thu, 6 Oct 2016 18:57:22 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: DMA-API: cpu touching an active dma mapped cacheline
Message-ID: <20161006175722.GU1041@n2100.armlinux.org.uk>
References: <20161006153443.GT1041@n2100.armlinux.org.uk>
 <CAPcyv4j8fWqwAaX5oCdg5atc+vmp57HoAGT6AfBFwaCiv0RbAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4j8fWqwAaX5oCdg5atc+vmp57HoAGT6AfBFwaCiv0RbAQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Oct 06, 2016 at 09:55:27AM -0700, Dan Williams wrote:
> On Thu, Oct 6, 2016 at 8:34 AM, Russell King - ARM Linux
> <linux@armlinux.org.uk> wrote:
> > Hi,
> >
> > With DMA API debugging enabled, I'm seeing this splat from it, which to
> > me looks like the DMA API debugging is getting too eager for it's own
> > good.
> >
> > The fact of the matter is that the VM passes block devices pages to be
> > written out to disk which are page cache pages, which may be looked up
> > and written to by write() syscalls and via mmap() mappings.  For example,
> > take the case of a writable shared mapping of a page backed by a file on
> > a disk - the VM will periodically notice that the page has been dirtied,
> > and schedule a writeout to disk.  The disk driver has no idea that the
> > page is still mapped - and arguably it doesn't matter.
> >
> > So, IMHO this whole "the CPU is touching a DMA mapped buffer" is quite
> > bogus given our VM behaviour: we have never guaranteed exclusive access
> > to DMA buffers.
> >
> > I don't see any maintainer listed for lib/dma-debug.c, but I see the
> > debug_dma_assert_idle() stuff was introduced by Dan via akpm in 2014.
> 
> Hmm, there are benign cases where this happens, but there's also one's
> that lead to data corruption as was the case with the NET_DMA receive
> offload.  Perhaps this change is enough to distinguish between the two
> cases:
> 
> diff --git a/lib/dma-debug.c b/lib/dma-debug.c
> index fcfa1939ac41..dd18235097d0 100644
> --- a/lib/dma-debug.c
> +++ b/lib/dma-debug.c
> @@ -597,7 +597,7 @@ void debug_dma_assert_idle(struct page *page)
>         }
>         spin_unlock_irqrestore(&radix_lock, flags);
> 
> -       if (!entry)
> +       if (!entry || entry->direction != DMA_FROM_DEVICE)
>                 return;
> 
>         cln = to_cacheline_number(entry);
> 
> ...because the problem in the NET_DMA case was that the engine was
> writing to page that the process no longer cared about because the cpu
> had written to it causing a cow copy to be established.  In the disk
> DMA case its fine if the DMA is acting on stale results in a
> DMA_TO_DEVICE operation.

Yes, that seems to avoid the warning for me from an initial test - I'm
not sure how reproducable it is yet though.

Thanks for the patch.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
