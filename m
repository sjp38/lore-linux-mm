Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3B66B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 02:54:49 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so15346105pab.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 23:54:49 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id qg8si8125776pac.135.2016.08.23.23.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 23:54:48 -0700 (PDT)
Message-ID: <1472021685.4578.0.camel@linux.intel.com>
Subject: Re: [PATCH] io-mapping: Fixup for different names of writecombine
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Wed, 24 Aug 2016 09:54:45 +0300
In-Reply-To: <20160823202233.4681-1-daniel.vetter@ffwll.ch>
References: <20160823202233.4681-1-daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>

On ti, 2016-08-23 at 22:22 +0200, Daniel Vetter wrote:
> Somehow architectures can't agree on this. And for good measure make
> sure we have a fallback which should work everywhere (fingers
> crossed).
> 
> This is to fix a compile fail on microblaze in gpiolib-of.c, which
> misguidedly includes io-mapping.h (instead of screaming at whichever
> achitecture doesn't correctly pull in asm/io.h from linux/io.h).
> 
> Not tested since there's no reasonable way to get at microblaze
> toolchains :(
> 
> Fixes: ac96b5566926 ("io-mapping.h: s/PAGE_KERNEL_IO/PAGE_KERNEL/")
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> ---
> A include/linux/io-mapping.h | 6 ++++++
> A 1 file changed, 6 insertions(+)
> 
> diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
> index a87dd7fffc0a..f4e33756c09c 100644
> --- a/include/linux/io-mapping.h
> +++ b/include/linux/io-mapping.h
> @@ -123,7 +123,13 @@ io_mapping_init_wc(struct io_mapping *iomap,
> A 	iomap->base = base;
> A 	iomap->size = size;
> A 	iomap->iomem = ioremap_wc(base, size);
> +#ifdef pgprot_noncached_wc /* archs can't agree on a name ... */
> +	iomap->prot = pgprot_noncached_wc(PAGE_KERNEL);
> +#elif pgprot_writecombine

Maybe you meant #elif defined pgprot_writecombine?

Regards, Joonas

> A 	iomap->prot = pgprot_writecombine(PAGE_KERNEL);
> +#else
> +	iomap->prot = pgprot_noncached(PAGE_KERNEL);
> +#endif
> A 
> A 	return iomap;
> A }
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
