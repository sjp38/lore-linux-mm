Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id A26AF6B00DA
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 10:18:23 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id un1so6784523pbc.33
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 07:18:23 -0700 (PDT)
Received: from psmtp.com ([74.125.245.200])
        by mx.google.com with SMTP id sj5si10476057pab.255.2013.10.27.07.18.21
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 07:18:22 -0700 (PDT)
Received: by mail-ea0-f182.google.com with SMTP id o10so1690758eaj.13
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 07:18:19 -0700 (PDT)
Date: Sun, 27 Oct 2013 15:18:17 +0100
From: Simon Baatz <gmbnomis@gmail.com>
Subject: Re: ARM/kirkwood: v3.12-rc6: kernel BUG at mm/util.c:390!
Message-ID: <20131027141817.GA13436@schnuecks.de>
References: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi>
 <20131026143617.GA14034@mudshark.cambridge.arm.com>
 <20131027195115.208f40f3@tom-ThinkPad-T410>
 <20131027125036.GJ17447@blackmetal.musicnaut.iki.fi>
 <CACVXFVP2B3=82m_+DfA_oAEW86c=oxQ52G+yj5ncTU1DzP26Bw@mail.gmail.com>
 <20131027135344.GD16735@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131027135344.GD16735@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Ming Lei <tom.leiming@gmail.com>, Aaro Koskinen <aaro.koskinen@iki.fi>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Tejun Heo <tj@kernel.org>, "James E.J. Bottomley" <JBottomley@parallels.com>, Jens Axboe <axboe@kernel.dk>

Hi Russell,

On Sun, Oct 27, 2013 at 01:53:44PM +0000, Russell King - ARM Linux wrote:
> On Sun, Oct 27, 2013 at 09:16:53PM +0800, Ming Lei wrote:
> > On Sun, Oct 27, 2013 at 8:50 PM, Aaro Koskinen <aaro.koskinen@iki.fi> wrote:
> > >
> So...
> 
> flush_kernel_dcache_page() is expected to take a struct page pointer.
> This struct page pointer is part of the kernel's array of struct pages
> which identifies every single physical page under the control of the
> kernel.
> 
> Arguably, it should not crash if passed a page which has been allocated
> to the slab cache; as this is not a page cache page,
> flush_kernel_dcache_page() should merely ignore the call to it and
> simply return on these.  So this makes total sense:

In this respect, flush_kernel_dcache_page() is following
flush_dcache_page(). For example in crypto/scatterwalk.c:

static void scatterwalk_pagedone(struct scatter_walk *walk, int out,
                                 unsigned int more)
{
        if (out) {
                struct page *page;

                page = sg_page(walk->sg) + ((walk->offset - 1) >>
PAGE_SHIFT);
                if (!PageSlab(page))
                        flush_dcache_page(page);
        }
... 


or in drivers/ata/libata-sff.c:

...
        if (!do_write && !PageSlab(page))
                flush_dcache_page(page);
...


(Probably, both cases should have used
flush_kernel_dcache_page() in the first place). If we say that this
check belongs in flush_kernel_dcache_page() we should also put it
into flush_dcache_page(), no?

- Simon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
