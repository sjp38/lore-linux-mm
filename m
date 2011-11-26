Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C57E66B0070
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 09:00:33 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so4591784vbb.14
        for <linux-mm@kvack.org>; Sat, 26 Nov 2011 06:00:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPM=9txtWiQuF+jNZXDogCMy+nsM=00Bv3uxAiu5oKnn-KxjAA@mail.gmail.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
	<1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
	<CAPM=9tzjO7poyz_uYFFgONxzuTB86kKej8f2XBDHLGdUPZHvjg@mail.gmail.com>
	<CAPM=9txtWiQuF+jNZXDogCMy+nsM=00Bv3uxAiu5oKnn-KxjAA@mail.gmail.com>
Date: Sat, 26 Nov 2011 15:00:31 +0100
Message-ID: <CAKMK7uE14gOsTUYZknmSArkzG2zSSbpDeU0dxqAtLVUmvh-5bA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Daniel Vetter <daniel@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org

On Fri, Nov 25, 2011 at 17:28, Dave Airlie <airlied@gmail.com> wrote:
> I've rebuilt my PRIME interface on top of dmabuf to see how it would work,
>
> I've got primed gears running again on top, but I expect all my object
> lifetime and memory ownership rules need fixing up (i.e. leaks like a
> sieve).
>
> http://cgit.freedesktop.org/~airlied/linux/log/?h=drm-prime-dmabuf
>
> has the i915/nouveau patches for the kernel to produce the prime interface.

I've noticed that your implementations for get_scatterlist (at least
for the i915 driver) doesn't return the sg table mapped into the
device address space. I've checked and the documentation makes it
clear that this should be the case (and we really need this to support
certain insane hw), but the get/put_scatterlist names are a bit
misleading. Proposal:

- use struct sg_table instead of scatterlist like you've already done
in you branch. Simply more consistent with the dma api.

- rename get/put_scatterlist into map/unmap for consistency with all
the map/unmap dma api functions. The attachement would then serve as
the abstract cookie to the backing storage, similar to how struct page
* works as an abstract cookie for dma_map/unmap_page. The only special
thing is that struct device * parameter because that's already part of
the attachment.

- add new wrapper functions dma_buf_map_attachment and
dma_buf_unmap_attachement to hide all the pointer/vtable-chasing that
we currently expose to users of this interface.

Comments?

Cheers, Daniel
-- 
Daniel Vetter
daniel.vetter@ffwll.ch - +41 (0) 79 364 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
