Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1D46B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 19:23:52 -0500 (EST)
Received: by mail-ve0-f182.google.com with SMTP id jy13so14094390veb.41
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:23:52 -0800 (PST)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id b20si1872960veu.68.2014.02.18.16.23.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 16:23:51 -0800 (PST)
Received: by mail-vc0-f170.google.com with SMTP id hu8so14214710vcb.1
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:23:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140219000352.GP21483@n2100.arm.linux.org.uk>
References: <20140217234644.GA5171@rmk-PC.arm.linux.org.uk>
	<CA+55aFy7ApiQRudxPAd3v5k_apppxRnePHb1HZPH13erqhmX=g@mail.gmail.com>
	<20140219000352.GP21483@n2100.arm.linux.org.uk>
Date: Tue, 18 Feb 2014 16:23:51 -0800
Message-ID: <CA+55aFxZz9ubkj72KHy8PhpsjZb6D7LD+v6jHJTtsD4N6AWPzw@mail.gmail.com>
Subject: Re: [GIT PULL] ARM fixes
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, James Bottomley <James.Bottomley@parallels.com>, Linux SCSI List <linux-scsi@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, ARM SoC <arm@kernel.org>, xen-devel@lists.xenproject.org

On Tue, Feb 18, 2014 at 4:03 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
>
> Almost, but not quite.  If we're going to avoid u64, then dma_addr_t
> woudl be the right type here because we're talking about DMA addresses.

Well, phys_addr_t had better be as big as dma_addr_t, because that's
what the resource management handles.

> We could also switch to keeping this as PFNs - block internally converts
> it to a PFN anyway:

Yeah, that definitely sounds like it would be a good idea.

> Maybe blk_queue_bounce_pfn_limit() so we ensure all users get caught?
>
>> That said, it's admittedly a disgusting name, and I wonder if we
>> should introduce a nicer-named "pfn_to_phys()" that matches the other
>> "xyz_to_abc()" functions we have (including "pfn_to_virt()")
>
> We have these on ARM:
>
> arch/arm/include/asm/memory.h:#define   __pfn_to_phys(pfn)      ((phys_addr_t)(pfn) << PAGE_SHIFT)
> arch/arm/include/asm/memory.h:#define   __phys_to_pfn(paddr)    ((unsigned long)((paddr) >> PAGE_SHIFT))
>
> it probably makes sense to pick those right out, maybe losing the
> __ prefix on them.

Yup.

>>   __va(PFN_PHYS(page_to_pfn(page)));
>
> Wow.  Two things spring to mind there... highmem pages, and don't we
> already have page_address() for that?

Well, that code clearly cannot handle highmem anyway, but yes, it
really smells like xen should use page_address().

Adding Xen people who I didn't add the last time around.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
