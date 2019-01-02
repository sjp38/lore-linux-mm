Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D37528E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 05:53:29 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id g12-v6so8893116lji.3
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 02:53:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24-v6sor29614892ljy.1.2019.01.02.02.53.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 02:53:27 -0800 (PST)
MIME-Version: 1.0
References: <20181224132658.GA22166@jordon-HP-15-Notebook-PC>
In-Reply-To: <20181224132658.GA22166@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 2 Jan 2019 16:23:15 +0530
Message-ID: <CAFqt6zZU6c3MyVQpCegntu1ZxtFri=HMwZJ3xg+tCxRARo3zMA@mail.gmail.com>
Subject: Re: [PATCH v5 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, pawel@osciak.com, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Mon, Dec 24, 2018 at 6:53 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range to map range of kernel memory
> to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> ---
>  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> index 015e737..898adef 100644
> --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> @@ -328,28 +328,19 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
>  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
>  {
>         struct vb2_dma_sg_buf *buf = buf_priv;
> -       unsigned long uaddr = vma->vm_start;
> -       unsigned long usize = vma->vm_end - vma->vm_start;
> -       int i = 0;
> +       unsigned long page_count = vma_pages(vma);
> +       int err;
>
>         if (!buf) {
>                 printk(KERN_ERR "No memory to map\n");
>                 return -EINVAL;
>         }
>
> -       do {
> -               int ret;
> -
> -               ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
> -               if (ret) {
> -                       printk(KERN_ERR "Remapping memory, error: %d\n", ret);
> -                       return ret;
> -               }
> -
> -               uaddr += PAGE_SIZE;
> -               usize -= PAGE_SIZE;
> -       } while (usize > 0);
> -
> +       err = vm_insert_range(vma, vma->vm_start, buf->pages, page_count);
> +       if (err) {
> +               printk(KERN_ERR "Remapping memory, error: %d\n", err);
> +               return err;
> +       }
>

Looking into the original code -
drivers/media/common/videobuf2/videobuf2-dma-sg.c

Inside vb2_dma_sg_alloc(),
           ...
           buf->num_pages = size >> PAGE_SHIFT;
           buf->dma_sgt = &buf->sg_table;

           buf->pages = kvmalloc_array(buf->num_pages, sizeof(struct page *),
                                                       GFP_KERNEL | __GFP_ZERO);
           ...

buf->pages has index upto  *buf->num_pages*.

now inside vb2_dma_sg_mmap(),

           unsigned long usize = vma->vm_end - vma->vm_start;
           int i = 0;
           ...
           do {
                 int ret;

                 ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
                 if (ret) {
                           printk(KERN_ERR "Remapping memory, error:
%d\n", ret);
                           return ret;
                 }

                uaddr += PAGE_SIZE;
                usize -= PAGE_SIZE;
           } while (usize > 0);
           ...
is it possible for any value of  *i  > (buf->num_pages)*,
buf->pages[i] is going to overrun the page boundary ?
