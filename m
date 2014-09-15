Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB516B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 10:25:03 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id p10so6327998pdj.9
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:25:03 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id pf5si23282515pdb.190.2014.09.15.07.25.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 07:25:02 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 15 Sep 2014 22:20:14 +0800
Subject: RE: [RFC v2] arm:extend the reserved mrmory for initrd to be page
 aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB4D6F19@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB491609@CNBJMBX05.corpusers.net>,<20140915113325.GD12361@n2100.arm.linux.org.uk>
In-Reply-To: <20140915113325.GD12361@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>

Great!
yeah, you are right,
just keep the change in free_initrd_mem( ) is ok.
we don't need keep reserved memory to be aligned ,

Thanks!

________________________________________
From: Russell King - ARM Linux [linux@arm.linux.org.uk]
Sent: Monday, September 15, 2014 7:33 PM
To: Wang, Yalin
Cc: 'Will Deacon'; 'linux-kernel@vger.kernel.org'; 'linux-arm-kernel@lists.=
infradead.org'; 'linux-mm@kvack.org'; 'linux-arm-msm@vger.kernel.org'
Subject: Re: [RFC v2] arm:extend the reserved mrmory for initrd to be page =
     aligned

On Mon, Sep 15, 2014 at 07:07:20PM +0800, Wang, Yalin wrote:
> this patch extend the start and end address of initrd to be page aligned,
> so that we can free all memory including the un-page aligned head or tail
> page of initrd, if the start or end address of initrd are not page
> aligned, the page can't be freed by free_initrd_mem() function.

Better, but I think it's more complicated than it needs to be:

> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  arch/arm/mm/init.c   | 19 +++++++++++++++++--
>  arch/arm64/mm/init.c | 37 +++++++++++++++++++++++++++++++++----
>  2 files changed, 50 insertions(+), 6 deletions(-)
>
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index 659c75d..8490b70 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -277,6 +277,8 @@ phys_addr_t __init arm_memblock_steal(phys_addr_t siz=
e, phys_addr_t align)
>  void __init arm_memblock_init(const struct machine_desc *mdesc)
>  {
>       /* Register the kernel text, kernel data and initrd with memblock. =
*/
> +     phys_addr_t phys_initrd_start_orig __maybe_unused;
> +     phys_addr_t phys_initrd_size_orig __maybe_unused;
>  #ifdef CONFIG_XIP_KERNEL
>       memblock_reserve(__pa(_sdata), _end - _sdata);
>  #else
> @@ -289,6 +291,13 @@ void __init arm_memblock_init(const struct machine_d=
esc *mdesc)
>               phys_initrd_size =3D initrd_end - initrd_start;
>       }
>       initrd_start =3D initrd_end =3D 0;
> +     phys_initrd_start_orig =3D phys_initrd_start;
> +     phys_initrd_size_orig =3D phys_initrd_size;
> +     /* make sure the start and end address are page aligned */
> +     phys_initrd_size =3D round_up(phys_initrd_start + phys_initrd_size,=
 PAGE_SIZE);
> +     phys_initrd_start =3D round_down(phys_initrd_start, PAGE_SIZE);
> +     phys_initrd_size -=3D phys_initrd_start;
> +
>       if (phys_initrd_size &&
>           !memblock_is_region_memory(phys_initrd_start, phys_initrd_size)=
) {
>               pr_err("INITRD: 0x%08llx+0x%08lx is not a memory region - d=
isabling initrd\n",
> @@ -305,9 +314,10 @@ void __init arm_memblock_init(const struct machine_d=
esc *mdesc)
>               memblock_reserve(phys_initrd_start, phys_initrd_size);
>
>               /* Now convert initrd to virtual addresses */
> -             initrd_start =3D __phys_to_virt(phys_initrd_start);
> -             initrd_end =3D initrd_start + phys_initrd_size;
> +             initrd_start =3D __phys_to_virt(phys_initrd_start_orig);
> +             initrd_end =3D initrd_start + phys_initrd_size_orig;
>       }
> +

I think all the above is entirely unnecessary.  The memblock APIs
(especially memblock_reserve()) will mark the overlapped pages as reserved
- they round down the starting address, and round up the end address
(calculated from start + size).

Hence, this:

> @@ -636,6 +646,11 @@ static int keep_initrd;
>  void free_initrd_mem(unsigned long start, unsigned long end)
>  {
>       if (!keep_initrd) {
> +             if (start =3D=3D initrd_start)
> +                     start =3D round_down(start, PAGE_SIZE);
> +             if (end =3D=3D initrd_end)
> +                     end =3D round_up(end, PAGE_SIZE);
> +
>               poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
>               free_reserved_area((void *)start, (void *)end, -1, "initrd"=
);
>       }

is the only bit of code you likely need to achieve your goal.

Thinking about this, I think that you are quite right to align these.
The memory around the initrd is defined to be system memory, and we
already free the pages around it, so it *is* wrong not to free the
partial initrd pages.

Good catch.

--
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
