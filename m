Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1AEFC6B00DB
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 10:19:23 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr4so3866440pbb.11
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 07:19:22 -0700 (PDT)
Received: from psmtp.com ([74.125.245.102])
        by mx.google.com with SMTP id ph6si9566197pbb.7.2013.10.27.07.19.21
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 07:19:22 -0700 (PDT)
Received: by mail-vb0-f49.google.com with SMTP id w16so3705650vbb.36
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 07:19:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131027135344.GD16735@n2100.arm.linux.org.uk>
References: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi>
	<20131026143617.GA14034@mudshark.cambridge.arm.com>
	<20131027195115.208f40f3@tom-ThinkPad-T410>
	<20131027125036.GJ17447@blackmetal.musicnaut.iki.fi>
	<CACVXFVP2B3=82m_+DfA_oAEW86c=oxQ52G+yj5ncTU1DzP26Bw@mail.gmail.com>
	<20131027135344.GD16735@n2100.arm.linux.org.uk>
Date: Sun, 27 Oct 2013 22:19:20 +0800
Message-ID: <CACVXFVMO4x5cW0+62V7dsmGso8HWCrNUh0_nLH3vYN0U2nk2+A@mail.gmail.com>
Subject: Re: ARM/kirkwood: v3.12-rc6: kernel BUG at mm/util.c:390!
From: Ming Lei <tom.leiming@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>, Will Deacon <will.deacon@arm.com>, Simon Baatz <gmbnomis@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Tejun Heo <tj@kernel.org>, "James E.J. Bottomley" <JBottomley@parallels.com>, Jens Axboe <axboe@kernel.dk>

On Sun, Oct 27, 2013 at 9:53 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Sun, Oct 27, 2013 at 09:16:53PM +0800, Ming Lei wrote:
>> On Sun, Oct 27, 2013 at 8:50 PM, Aaro Koskinen <aaro.koskinen@iki.fi> wrote:
>> >
>> > On ARM v3.9 or older kernels do not trigger this BUG, at seems it only
>> > started to appear with the following commit (bisected):
>> >
>> > commit 1bc39742aab09248169ef9d3727c9def3528b3f3
>> > Author: Simon Baatz <gmbnomis@gmail.com>
>> > Date:   Mon Jun 10 21:10:12 2013 +0100
>> >
>> >     ARM: 7755/1: handle user space mapped pages in flush_kernel_dcache_page
>>
>> The above commit only starts to implement the helper on ARM,
>> but according to Documentation/cachetlb.txt, looks caller of
>> flush_kernel_dcache_page() should make sure the passed
>> 'page' is a user space page.
>
> I think your terminology is off.  flush_kernel_dcache_page() is passed a
> struct page.  These exist for every physical RAM page in the system which
> is under the control of the kernel.  There's no such thing as a "user
> space page" - pages are shared from kernel space into userspace.

It isn't my terminology, and it is from Documentation/cachetlb.txt, :-)
But I admit it isn't good to call it as user space page.

Also pages which belong to slab shouldn't be mapped to user space.

>
> Secondly, flush_kernel_dcache_page() gets used on such pages whether or
> not they're already mapped into userspace (normally they won't be if this
> is the first read of the page.)  This function is only expected to deal
> with kernel-side addresses of the page, ensuring that data in the page
> is visible to the underlying memory.
>
> The last thing to realise is that we already have a function which deals
> with the presence of userspace mappings.  It's called flush_dcache_page().
> If flush_kernel_dcache_page() had to make that decision, then there's no
> point in flush_kernel_dcache_page() existing - we might as well just call
> flush_dcache_page() directly.
>
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

I think callers of flush_kernel_dcache_page() should make sure that,
not just arm implements the helper, so I am wondering if arch code
needs the test.

>
>  arch/arm/mm/flush.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
> index 6d5ba9afb16a..eebb275a67fb 100644
> --- a/arch/arm/mm/flush.c
> +++ b/arch/arm/mm/flush.c
> @@ -316,6 +316,10 @@ EXPORT_SYMBOL(flush_dcache_page);
>   */
>  void flush_kernel_dcache_page(struct page *page)
>  {
> +       /* Ignore slab pages */
> +       if (PageSlab(page))
> +               return;
> +
>         if (cache_is_vivt() || cache_is_vipt_aliasing()) {
>                 struct address_space *mapping;
>


Thanks,
-- 
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
