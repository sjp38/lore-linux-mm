Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 32FAF8E0001
	for <linux-mm@kvack.org>; Sun, 23 Sep 2018 18:42:24 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s2-v6so3298630qth.0
        for <linux-mm@kvack.org>; Sun, 23 Sep 2018 15:42:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t36-v6si6434399qtc.217.2018.09.23.15.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Sep 2018 15:42:23 -0700 (PDT)
Date: Mon, 24 Sep 2018 06:42:07 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180923224206.GA13618@ming.t460p>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de>
 <87h8ij0zot.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87h8ij0zot.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Fri, Sep 21, 2018 at 03:04:18PM +0200, Vitaly Kuznetsov wrote:
> Christoph Hellwig <hch@lst.de> writes:
> 
> > On Wed, Sep 19, 2018 at 05:15:43PM +0800, Ming Lei wrote:
> >> 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
> >> yes, is it a stable rule?
> >
> > This is the assumption in a lot of the kernel, so I think if somethings
> > breaks this we are in a lot of pain.
> 
> It seems that SLUB debug breaks this assumption. Kernel built with
> 
> CONFIG_SLUB_DEBUG=y
> CONFIG_SLUB=y
> CONFIG_SLUB_DEBUG_ON=y
> 
> And the following patch:
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index 3b20607d581b..56713b201921 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -1771,3 +1771,28 @@ void __init arch_reserve_mem_area(acpi_physical_address addr, size_t size)
>         e820__range_add(addr, size, E820_TYPE_ACPI);
>         e820__update_table_print();
>  }
> +
> +#define KMALLOCS 16
> +
> +static __init int kmalloc_check_512(void)
> +{
> +       void *buf[KMALLOCS];
> +       int i;
> +
> +       pr_info("kmalloc_check_512: start\n");
> +
> +       for (i = 0; i < KMALLOCS; i++) {
> +               buf[i] = kmalloc(512, GFP_KERNEL);
> +       }
> +
> +       for (i = 0; i < KMALLOCS; i++) {
> +               pr_info("%lx %x\n", (unsigned long)buf[i], ((unsigned long)buf[i]) % 512);
> +               kfree(buf[i]);
> +       }
> +
> +       pr_info("kmalloc_check_512: done\n");
> +
> +       return 0;
> +}
> +
> +late_initcall(kmalloc_check_512);
> 
> gives me the following output:
> 
> [    8.417468] kmalloc_check_512: start
> [    8.429572] ffff9a3258bb09f8 1f8
> [    8.435513] ffff9a3258bb70a8 a8
> [    8.441352] ffff9a3258bb0d48 148
> [    8.447139] ffff9a3258bb6d58 158
> [    8.452864] ffff9a3258bb1098 98
> [    8.458536] ffff9a3258bb6a08 8
> [    8.464103] ffff9a3258bb13e8 1e8
> [    8.469534] ffff9a3258bb66b8 b8
> [    8.474907] ffff9a3258bb1738 138
> [    8.480214] ffff9a3258bb6368 168
> [    8.480217] ffff9a3258bb1a88 88
> [    8.496178] ffff9a3258bb6018 18
> [    8.501218] ffff9a3258bb1dd8 1d8
> [    8.506138] ffff9a3258bb5cc8 c8
> [    8.511010] ffff9a3258bb2128 128
> [    8.515795] ffff9a3258bb5978 178
> [    8.520517] kmalloc_check_512: done
> 
> (without SLUB_DEBUG_ON all addresses are 512b aligned).

Even some of buffer address is _not_ L1 cache size aligned, this way is
totally broken wrt. DMA to/from this buffer.

So this issue has to be fixed in slab debug side.

Thanks,
Ming
