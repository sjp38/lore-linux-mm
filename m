Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1758E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 13:54:31 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id t7-v6so9140125ljg.9
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 10:54:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor13149193lfl.69.2019.01.02.10.54.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 10:54:29 -0800 (PST)
MIME-Version: 1.0
References: <20181224132751.GA22184@jordon-HP-15-Notebook-PC>
In-Reply-To: <20181224132751.GA22184@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 3 Jan 2019 00:28:19 +0530
Message-ID: <CAFqt6za2_BOZaynNV2iVkLCjadzyR_bOJog=R6j43dDCDwgFzw@mail.gmail.com>
Subject: Re: [PATCH v5 8/9] xen/gntdev.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Mon, Dec 24, 2018 at 6:53 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> ---
>  drivers/xen/gntdev.c | 11 ++++-------
>  1 file changed, 4 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index b0b02a5..430d4cb 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>         int index = vma->vm_pgoff;
>         int count = vma_pages(vma);
>         struct gntdev_grant_map *map;
> -       int i, err = -EINVAL;
> +       int err = -EINVAL;
>
>         if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
>                 return -EINVAL;
> @@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>                 goto out_put_map;
>
>         if (!use_ptemod) {
> -               for (i = 0; i < count; i++) {
> -                       err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
> -                               map->pages[i]);
> -                       if (err)
> -                               goto out_put_map;
> -               }

Looking into the original code, the loop should run from i =0 to *i <
map->count*.
There is no error check for *count > map->count* and we might end up
overrun the map->pages[i] boundary.

While converting this code with suggested vm_insert_range(), this can be fixed.


> +               err = vm_insert_range(vma, vma->vm_start, map->pages, count);
> +               if (err)
> +                       goto out_put_map;
>         } else {
>  #ifdef CONFIG_X86
>                 /*
> --
> 1.9.1
>
