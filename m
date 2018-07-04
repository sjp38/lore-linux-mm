Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7426B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 04:22:00 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id t18-v6so1404101uaj.2
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 01:22:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f96-v6sor1140984vki.199.2018.07.04.01.21.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 01:21:58 -0700 (PDT)
MIME-Version: 1.0
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
 <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com> <20180704075410.GF22503@dhcp22.suse.cz>
In-Reply-To: <20180704075410.GF22503@dhcp22.suse.cz>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 4 Jul 2018 10:21:45 +0200
Message-ID: <CAMuHMdU_m0+BeTnCwU0qm-3G+-9apa41dTcZDV9cGT84W8x=fA@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Michael,

On Wed, Jul 4, 2018 at 9:54 AM Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 04-07-18 09:44:14, Geert Uytterhoeven wrote:
> [...]
> > ------------[ cut here ]------------
> > WARNING: CPU: 0 PID: 0 at mm/memblock.c:230
> > memblock_find_in_range_node+0x11c/0x1be
> > memblock: bottom-up allocation failed, memory hotunplug may be affected
>
> This only means that hotplugable memory might contain non-movable memory
> now. But does your system even support memory hotplug. I would be really

No it doesn't.

> surprised. So I guess we just want this instead
> diff --git a/mm/memblock.c b/mm/memblock.c
> index cc16d70b8333..c0dde95593fd 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -228,7 +228,8 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
>                  * so we use WARN_ONCE() here to see the stack trace if
>                  * fail happens.
>                  */
> -               WARN_ONCE(1, "memblock: bottom-up allocation failed, memory hotunplug may be affected\n");
> +               WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
> +                                       "memblock: bottom-up allocvation failed, memory hotunplug may be affected\n");
>         }
>
>         return __memblock_find_range_top_down(start, end, size, align, nid,

Thanks, that does the trick!

Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
