Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id A34B98E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:27:50 -0500 (EST)
Received: by mail-ua1-f69.google.com with SMTP id o13so455271uad.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:27:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v195sor43564367vkv.69.2019.01.16.06.27.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 06:27:49 -0800 (PST)
MIME-Version: 1.0
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com> <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 16 Jan 2019 15:27:35 +0100
Message-ID: <CAMuHMdWKPj-2Let44rmaVwh-b6kkGg+0cFPQ-+3k9LP86pB7NA@mail.gmail.com>
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of memblock_alloc*()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS" <devicetree@vger.kernel.org>, kasan-dev@googlegroups.com, alpha <linux-alpha@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, linux-mips@vger.kernel.org, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, arcml <linux-snps-arc@lists.infradead.org>, linux-um@lists.infradead.org, USB list <linux-usb@vger.kernel.org>, linux-xtensa@linux-xtensa.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Openrisc <openrisc@lists.librecores.org>, sparclinux <sparclinux@vger.kernel.org>, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, the arch/x86 maintainers <x86@kernel.org>, xen-devel@lists.xenproject.org

Hi Mike,

On Wed, Jan 16, 2019 at 2:46 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> Add check for the return value of memblock_alloc*() functions and call
> panic() in case of error.
> The panic message repeats the one used by panicing memblock allocators with
> adjustment of parameters to include only relevant ones.
>
> The replacement was mostly automated with semantic patches like the one
> below with manual massaging of format strings.
>
> @@
> expression ptr, size, align;
> @@
> ptr = memblock_alloc(size, align);
> + if (!ptr)
> +       panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,

In general, you want to use %zu for size_t

> size, align);
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Thanks for your patch!

>  74 files changed, 415 insertions(+), 29 deletions(-)

I'm wondering if this is really an improvement?
For the normal memory allocator, the trend is to remove printing of errors
from all callers, as the core takes care of that.

> --- a/arch/alpha/kernel/core_marvel.c
> +++ b/arch/alpha/kernel/core_marvel.c
> @@ -83,6 +83,9 @@ mk_resource_name(int pe, int port, char *str)
>
>         sprintf(tmp, "PCI %s PE %d PORT %d", str, pe, port);
>         name = memblock_alloc(strlen(tmp) + 1, SMP_CACHE_BYTES);
> +       if (!name)
> +               panic("%s: Failed to allocate %lu bytes\n", __func__,

%zu, as strlen() returns size_t.

> +                     strlen(tmp) + 1);
>         strcpy(name, tmp);
>
>         return name;
> @@ -118,6 +121,9 @@ alloc_io7(unsigned int pe)
>         }
>
>         io7 = memblock_alloc(sizeof(*io7), SMP_CACHE_BYTES);
> +       if (!io7)
> +               panic("%s: Failed to allocate %lu bytes\n", __func__,

%zu, as sizeof() returns size_t.
Probably there are more. Yes, it's hard to get them right in all callers.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
