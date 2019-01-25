Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id D32228E00BD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 01:25:16 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id h11so636298lfc.9
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 22:25:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e21sor2512558lfj.17.2019.01.24.22.25.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 22:25:15 -0800 (PST)
MIME-Version: 1.0
References: <20190111150834.GA2744@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111150834.GA2744@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 25 Jan 2019 11:55:03 +0530
Message-ID: <CAFqt6zYLDrC7CtLawWUAQPyB_M+5H8BikDR6LOm+v0qaq1GvZw@mail.gmail.com>
Subject: Re: [PATCH 3/9] drivers/firewire/core-iso.c: Convert to use vm_insert_range_buggy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, stefanr@s5r6.in-berlin.de, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net

On Fri, Jan 11, 2019 at 8:34 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range_buggy to map range of kernel memory
> to user vma.
>
> This driver has ignored vm_pgoff and mapped the entire pages. We
> could later "fix" these drivers to behave according to the normal
> vm_pgoff offsetting simply by removing the _buggy suffix on the
> function name and if that causes regressions, it gives us an easy
> way to revert.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Any comment on this patch ?

> ---
>  drivers/firewire/core-iso.c | 15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
> index 35e784c..99a6582 100644
> --- a/drivers/firewire/core-iso.c
> +++ b/drivers/firewire/core-iso.c
> @@ -107,19 +107,8 @@ int fw_iso_buffer_init(struct fw_iso_buffer *buffer, struct fw_card *card,
>  int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
>                           struct vm_area_struct *vma)
>  {
> -       unsigned long uaddr;
> -       int i, err;
> -
> -       uaddr = vma->vm_start;
> -       for (i = 0; i < buffer->page_count; i++) {
> -               err = vm_insert_page(vma, uaddr, buffer->pages[i]);
> -               if (err)
> -                       return err;
> -
> -               uaddr += PAGE_SIZE;
> -       }
> -
> -       return 0;
> +       return vm_insert_range_buggy(vma, buffer->pages,
> +                                       buffer->page_count);
>  }
>
>  void fw_iso_buffer_destroy(struct fw_iso_buffer *buffer,
> --
> 1.9.1
>
