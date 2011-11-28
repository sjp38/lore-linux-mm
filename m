Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6D26B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 05:33:02 -0500 (EST)
Received: by wwg38 with SMTP id 38so9589315wwg.26
        for <linux-mm@kvack.org>; Mon, 28 Nov 2011 02:32:58 -0800 (PST)
Date: Mon, 28 Nov 2011 11:34:15 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanismch
Message-ID: <20111128103212.GA3840@phenom.ffwll.local>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
 <1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
 <4E98085A.8080803@samsung.com>
 <20111014152139.GA2908@phenom.ffwll.local>
 <000001cc99ff$47cfe960$d76fbc20$%szyprowski@samsung.com>
 <CAO8GWqnNMGwADVnO4-RfJu0TPzHhANBdyctv2RyhCxbBJ0beXw@mail.gmail.com>
 <20111108174122.GA4754@phenom.ffwll.local>
 <20111108175517.GG12913@n2100.arm.linux.org.uk>
 <20111108184314.GB4754@phenom.ffwll.local>
 <000401ccada1$fbdcc030$f3964090$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000401ccada1$fbdcc030$f3964090$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Daniel Vetter' <daniel@ffwll.ch>, "'Clark, Rob'" <rob@ti.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, 'Sumit Semwal' <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, arnd@arndb.de, jesse.barker@linaro.org, 'Sumit Semwal' <sumit.semwal@linaro.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>

On Mon, Nov 28, 2011 at 08:47:31AM +0100, Marek Szyprowski wrote:
> On Tuesday, November 08, 2011 7:43 PM Daniel Vetter wrote:
> > Thanks for the clarification. I think this is another reason why
> > get_scatterlist should return the sg_list already mapped into the device
> > address space - it's more consisten with the other dma apis. Another
> > reason to completely hide everything but mapped addresses is crazy stuff
> > like this
> > 
> > 	mem <---> tiling iommu <-+-> gpu
> > 	                         |
> > 	                         +-> scanout engine
> > 	                         |
> > 				 +-> mpeg decoder
> > 
> > where it doesn't really make sense to talk about the memory backing the
> > dma buffer because that's smeared all over the place due to tiling. IIRC
> > for the case of omap these devices can also access memory through other
> > paths and iommut that don't tile (but just remap like a normal iommu)
> 
> I really don't get why you want to force the exporter to map the buffer into
> clients dma address space. Only the client device might know all the quirks
> required to do this correctly. Exporter should only provide a scatter-list 
> with the memory that belongs to the exported buffer (might be pinned). How
> do you want to solve the following case - the gpu hardware from your diagram
> and a simple usb webcam with generic driver. The application would like to
> export a buffer from the webcam to scanout engine. How the generic webcam 
> driver might know HOW to set up the tiller to create correct mappings for 
> the GPU/scanout? IMHO only a GPU driver is capable of doing that assuming
> it got just a scatter list from the webcam driver.

You're correct that only the gpu knows how to put things into the tiler
(and maybe other devices that have access to it). Let me expand my diagram
so that you're webcam fits into the picture.

 	mem <-+-> tiling iommu <-+-> gpu
 	      |                  |
 	      |                  +-> scanout engine
 	      |                  |
              |                  +-> mpeg decoder
              |                  |                
              |                  |                
              +-> direct dma   <-+
              |                                  
              +-> iommua A <-+-> usb hci                                   
                             |                    
                             +-> other devices                   
                             |                    
                             ...                    

A few notes:
- might not be exactly how omap really looks like
- the devices behind tiler have different device address space windows to
  access the different paths to main memory. No other device can access
  the tiler, iirc.
- your webcam doesn't exist on this because we can't dma from it's memory,
  we can only zero-copy from the memory the usb hci transferred the frame
  to.

Now when when e.g. the scanout engine calls get_scatterlist you only call
dma_map_sg (which does nothing, because there's no iommu that's managed by
the core kernel code for it). The scanout engine will then complain that
your stuff is not contiguous and bail out. Or it is indeed contiguous and
things Just Work.

The much more interesting case is when the mpeg decoder and the gpu share
a buffer (think video on rotating cube or whatever other gui transition
you fancy). Then the omap tiler code can check whether the the device sits
behind the tiler (e.g. with some omap-specific device tree attribute) and
hand out a linear view to a tiled buffer.

In other words, whereever you're currently calling one of the map/unmap
dma api variants, you would call get/put_scatterlist (or better the new
name I'm proposing). So I also don't see your argument about only the
client knows how to map something into address space.

Yours, Daniel
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
