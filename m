Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 440866B0008
	for <linux-mm@kvack.org>; Wed, 30 May 2018 17:08:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e1-v6so2373480pgp.20
        for <linux-mm@kvack.org>; Wed, 30 May 2018 14:08:54 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y5-v6si34160346pfe.134.2018.05.30.14.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 14:08:53 -0700 (PDT)
Received: from mail-qt0-f182.google.com (mail-qt0-f182.google.com [209.85.216.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ABEC020899
	for <linux-mm@kvack.org>; Wed, 30 May 2018 21:08:52 +0000 (UTC)
Received: by mail-qt0-f182.google.com with SMTP id h2-v6so25181639qtp.7
        for <linux-mm@kvack.org>; Wed, 30 May 2018 14:08:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180530052142.24761-1-jaewon31.kim@samsung.com>
References: <CGME20180530052041epcas2p395f2fbf4506d911c127cc4243838fedb@epcas2p3.samsung.com>
 <20180530052142.24761-1-jaewon31.kim@samsung.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Wed, 30 May 2018 16:08:31 -0500
Message-ID: <CAL_JsqJS4CkNd4LeuiPvPV3w1wAHX116WA-akDR3FUi6=fkS3A@mail.gmail.com>
Subject: Re: [PATCH] drivers: of: of_reserved_mem: detect count overflow or
 range overlap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Mitchel Humpherys <mitchelh@codeaurora.org>, Frank Rowand <frowand.list@gmail.com>, devicetree@vger.kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jaewon Kim <jaewon31.kim@gmail.com>

On Wed, May 30, 2018 at 12:21 AM, Jaewon Kim <jaewon31.kim@samsung.com> wrote:
> During development, number of reserved memory region could be increased
> and a new region could be unwantedly overlapped. In that case the new
> region may work well but one of exisiting region could be affected so
> that it would not be defined properly. It may require time consuming
> work to find reason that there is a newly added region.
>
> If a newly added region invoke kernel panic, it will be helpful. This
> patch records if there is count overflow or range overlap, and invoke
> panic if that case.
>
> These are test example based on v4.9.
>
> Case 1 - out of region count
> <3>[    0.000000]  [0:        swapper:    0] OF: reserved mem: not enough space all defined regions.
> <0>[    1.688695]  [6:      swapper/0:    1] Kernel panic - not syncing: overflow on reserved memory, check the latest change
> <4>[    1.688743]  [6:      swapper/0:    1] CPU: 6 PID: 1 Comm: swapper/0 Not tainted 4.9.65+ #10
> <4>[    1.688836]  [6:      swapper/0:    1] Call trace:
> <4>[    1.688869]  [6:      swapper/0:    1] [<ffffff8008095748>] dump_backtrace+0x0/0x248
> <4>[    1.688913]  [6:      swapper/0:    1] [<ffffff8008095b48>] show_stack+0x18/0x28
> <4>[    1.688958]  [6:      swapper/0:    1] [<ffffff8008446e84>] dump_stack+0x98/0xc0
> <4>[    1.689001]  [6:      swapper/0:    1] [<ffffff80081cf784>] panic+0x1e0/0x404
> <4>[    1.689046]  [6:      swapper/0:    1] [<ffffff8008ddcdb8>] check_reserved_mem+0x40/0x50
> <4>[    1.689091]  [6:      swapper/0:    1] [<ffffff8008090190>] do_one_initcall+0x54/0x214
> <4>[    1.689138]  [6:      swapper/0:    1] [<ffffff8009eacf98>] kernel_init_freeable+0x198/0x24c
> <4>[    1.689187]  [6:      swapper/0:    1] [<ffffff8009396950>] kernel_init+0x18/0x144
> <4>[    1.689229]  [6:      swapper/0:    1] [<ffffff800808fa50>] ret_from_fork+0x10/0x40
>
> Case 2 - overlapped region
> <3>[    0.000000]  [0:        swapper:    0] OF: reserved mem: OVERLAP DETECTED!
> <0>[    2.309331]  [2:      swapper/0:    1] Kernel panic - not syncing: reserved memory overlap, check the latest change
> <4>[    2.309398]  [2:      swapper/0:    1] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.9.65+ #14
> <4>[    2.309508]  [2:      swapper/0:    1] Call trace:
> <4>[    2.309546]  [2:      swapper/0:    1] [<ffffff8008121748>] dump_backtrace+0x0/0x248
> <4>[    2.309599]  [2:      swapper/0:    1] [<ffffff8008121b48>] show_stack+0x18/0x28
> <4>[    2.309652]  [2:      swapper/0:    1] [<ffffff80084d2e84>] dump_stack+0x98/0xc0
> <4>[    2.309701]  [2:      swapper/0:    1] [<ffffff800825b784>] panic+0x1e0/0x404
> <4>[    2.309751]  [2:      swapper/0:    1] [<ffffff8008e68dc4>] check_reserved_mem+0x4c/0x50
> <4>[    2.309802]  [2:      swapper/0:    1] [<ffffff800811c190>] do_one_initcall+0x54/0x214
> <4>[    2.309856]  [2:      swapper/0:    1] [<ffffff8009f38f98>] kernel_init_freeable+0x198/0x24c
> <4>[    2.309913]  [2:      swapper/0:    1] [<ffffff8009422950>] kernel_init+0x18/0x144
> <4>[    2.309961]  [2:      swapper/0:    1] [<ffffff800811ba50>] ret_from_fork+0x10/0x40
>
> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> ---
>  drivers/of/of_reserved_mem.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
>
> diff --git a/drivers/of/of_reserved_mem.c b/drivers/of/of_reserved_mem.c
> index 9a4f4246231d..e97d5c5dcc9a 100644
> --- a/drivers/of/of_reserved_mem.c
> +++ b/drivers/of/of_reserved_mem.c
> @@ -65,6 +65,7 @@ int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
>  }
>  #endif
>
> +static bool rmem_overflow;
>  /**
>   * res_mem_save_node() - save fdt node for second pass initialization
>   */
> @@ -75,6 +76,7 @@ void __init fdt_reserved_mem_save_node(unsigned long node, const char *uname,
>
>         if (reserved_mem_count == ARRAY_SIZE(reserved_mem)) {
>                 pr_err("not enough space all defined regions.\n");
> +               rmem_overflow = true;
>                 return;
>         }
>
> @@ -221,6 +223,7 @@ static int __init __rmem_cmp(const void *a, const void *b)
>         return 0;
>  }
>
> +static bool rmem_overlap;
>  static void __init __rmem_check_for_overlap(void)
>  {
>         int i;
> @@ -245,6 +248,7 @@ static void __init __rmem_check_for_overlap(void)
>                         pr_err("OVERLAP DETECTED!\n%s (%pa--%pa) overlaps with %s (%pa--%pa)\n",
>                                this->name, &this->base, &this_end,
>                                next->name, &next->base, &next_end);
> +                       rmem_overlap = true;
>                 }
>         }
>  }
> @@ -419,3 +423,13 @@ struct reserved_mem *of_reserved_mem_lookup(struct device_node *np)
>         return NULL;
>  }
>  EXPORT_SYMBOL_GPL(of_reserved_mem_lookup);
> +
> +static int check_reserved_mem(void)
> +{
> +       if (rmem_overflow)
> +               panic("overflow on reserved memory, check the latest change");
> +       if (rmem_overlap)
> +               panic("overlap on reserved memory, check the latest change");
> +       return 0;
> +}
> +late_initcall(check_reserved_mem);

Just use WARN and avoid this dance you are doing to panic after your
console is up.

Rob
