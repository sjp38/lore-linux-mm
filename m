Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6AE56B6A1B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 11:27:19 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r16so7125077pgr.15
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:27:19 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o89si15136176pfk.223.2018.12.03.08.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 08:27:18 -0800 (PST)
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CF3B021508
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 16:27:17 +0000 (UTC)
Received: by mail-wr1-f46.google.com with SMTP id t27so12846567wra.6
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:27:17 -0800 (PST)
MIME-Version: 1.0
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com> <1543852035-26634-7-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1543852035-26634-7-git-send-email-rppt@linux.ibm.com>
From: Rob Herring <robh@kernel.org>
Date: Mon, 3 Dec 2018 10:27:02 -0600
Message-ID: <CABGGisySdgSma1bSF2Bk586Vf461o-U2f3w9UMgHJcVucQ0oFA@mail.gmail.com>
Subject: Re: [PATCH v2 6/6] arm, unicore32: remove early_alloc*() wrappers
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, davem@davemloft.net, gxt@pku.edu.cn, Greentime Hu <green.hu@gmail.com>, jonas@southpole.se, Michael Ellerman <mpe@ellerman.id.au>, mhocko@suse.com, Michal Simek <monstr@monstr.eu>, msalter@redhat.com, Paul Mackerras <paulus@samba.org>, dalias@libc.org, linux@armlinux.org.uk, stefan.kristiansson@saunalahti.fi, shorne@gmail.com, deanbo422@gmail.com, ysato@users.sourceforge.jp, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

On Mon, Dec 3, 2018 at 9:48 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On arm and unicore32i the early_alloc_aligned() and and early_alloc() are
> oneliner wrappers for memblock_alloc.
>
> Replace their usage with direct call to memblock_alloc.
>
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/arm/mm/mmu.c       | 11 +++--------
>  arch/unicore32/mm/mmu.c | 12 ++++--------
>  2 files changed, 7 insertions(+), 16 deletions(-)
>
> diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
> index 0a04c9a5..57de0dd 100644
> --- a/arch/arm/mm/mmu.c
> +++ b/arch/arm/mm/mmu.c
> @@ -719,14 +719,9 @@ EXPORT_SYMBOL(phys_mem_access_prot);
>
>  #define vectors_base() (vectors_high() ? 0xffff0000 : 0)
>
> -static void __init *early_alloc_aligned(unsigned long sz, unsigned long align)
> -{
> -       return memblock_alloc(sz, align);
> -}
> -
>  static void __init *early_alloc(unsigned long sz)

Why not get rid of this wrapper like you do on unicore?

>  {
> -       return early_alloc_aligned(sz, sz);
> +       return memblock_alloc(sz, sz);
>  }
