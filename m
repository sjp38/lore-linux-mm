Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 6097F6B010D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 08:47:10 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so263155lag.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 05:47:08 -0700 (PDT)
Message-ID: <506D8547.3060505@openvz.org>
Date: Thu, 04 Oct 2012 16:47:03 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [mmotm] get rid of the remaining VM_RESERVED usage
References: <20121004113428.GD27536@dhcp22.suse.cz>
In-Reply-To: <20121004113428.GD27536@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

All right.
VM_RESERVED can be replaced with (VM_DONTEXPAND | VM_DONTDUMP) or VM_IO

Michal Hocko wrote:
> Hi Andrew, Konstantin,
> it seems that these slipped through when VM_RESERVED was removed by
> broken-out/mm-kill-vma-flag-vm_reserved-and-mm-reserved_vm-counter.patch
>
> I hope I didn't screw anything... Please merge it with the original
> patch if it looks correctly.
> ---
>   drivers/media/video/meye.c                      |    2 +-
>   drivers/media/video/omap/omap_vout.c            |    2 +-
>   drivers/media/video/sn9c102/sn9c102_core.c      |    1 -
>   drivers/media/video/usbvision/usbvision-video.c |    2 --
>   drivers/media/video/videobuf-dma-sg.c           |    2 +-
>   drivers/media/video/videobuf-vmalloc.c          |    2 +-
>   drivers/media/video/videobuf2-memops.c          |    2 +-
>   drivers/media/video/vino.c                      |    2 +-
>   drivers/staging/media/easycap/easycap_main.c    |    2 +-
>   9 files changed, 7 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/media/video/meye.c b/drivers/media/video/meye.c
> index 7bc7752..e5a76da 100644
> --- a/drivers/media/video/meye.c
> +++ b/drivers/media/video/meye.c
> @@ -1647,7 +1647,7 @@ static int meye_mmap(struct file *file, struct vm_area_struct *vma)
>
>   	vma->vm_ops =&meye_vm_ops;
>   	vma->vm_flags&= ~VM_IO;	/* not I/O memory */
> -	vma->vm_flags |= VM_RESERVED;	/* avoid to swap out this VMA */
> +	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
>   	vma->vm_private_data = (void *) (offset / gbufsize);
>   	meye_vm_open(vma);
>
> diff --git a/drivers/media/video/omap/omap_vout.c b/drivers/media/video/omap/omap_vout.c
> index 88cf9d9..45797aa 100644
> --- a/drivers/media/video/omap/omap_vout.c
> +++ b/drivers/media/video/omap/omap_vout.c
> @@ -910,7 +910,7 @@ static int omap_vout_mmap(struct file *file, struct vm_area_struct *vma)
>
>   	q->bufs[i]->baddr = vma->vm_start;
>
> -	vma->vm_flags |= VM_RESERVED;
> +	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
>   	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
>   	vma->vm_ops =&omap_vout_vm_ops;
>   	vma->vm_private_data = (void *) vout;
> diff --git a/drivers/media/video/sn9c102/sn9c102_core.c b/drivers/media/video/sn9c102/sn9c102_core.c
> index 19ea780..c28b75b 100644
> --- a/drivers/media/video/sn9c102/sn9c102_core.c
> +++ b/drivers/media/video/sn9c102/sn9c102_core.c
> @@ -2127,7 +2127,6 @@ static int sn9c102_mmap(struct file* filp, struct vm_area_struct *vma)
>   	}
>
>   	vma->vm_flags |= VM_IO;
> -	vma->vm_flags |= VM_RESERVED;
>
>   	pos = cam->frame[i].bufmem;
>   	while (size>  0) { /* size is page-aligned */
> diff --git a/drivers/media/video/usbvision/usbvision-video.c b/drivers/media/video/usbvision/usbvision-video.c
> index 9bd8f08..e776a6c 100644
> --- a/drivers/media/video/usbvision/usbvision-video.c
> +++ b/drivers/media/video/usbvision/usbvision-video.c
> @@ -1089,9 +1089,7 @@ static int usbvision_v4l2_mmap(struct file *file, struct vm_area_struct *vma)
>   		return -EINVAL;
>   	}
>
> -	/* VM_IO is eventually going to replace PageReserved altogether */
>   	vma->vm_flags |= VM_IO;
> -	vma->vm_flags |= VM_RESERVED;	/* avoid to swap out this VMA */
>
>   	pos = usbvision->frame[i].data;
>   	while (size>  0) {
> diff --git a/drivers/media/video/videobuf-dma-sg.c b/drivers/media/video/videobuf-dma-sg.c
> index f300dea..828e7c1 100644
> --- a/drivers/media/video/videobuf-dma-sg.c
> +++ b/drivers/media/video/videobuf-dma-sg.c
> @@ -582,7 +582,7 @@ static int __videobuf_mmap_mapper(struct videobuf_queue *q,
>   	map->count    = 1;
>   	map->q        = q;
>   	vma->vm_ops   =&videobuf_vm_ops;
> -	vma->vm_flags |= VM_DONTEXPAND | VM_RESERVED;
> +	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
>   	vma->vm_flags&= ~VM_IO; /* using shared anonymous pages */
>   	vma->vm_private_data = map;
>   	dprintk(1, "mmap %p: q=%p %08lx-%08lx pgoff %08lx bufs %d-%d\n",
> diff --git a/drivers/media/video/videobuf-vmalloc.c b/drivers/media/video/videobuf-vmalloc.c
> index df14258..2ff7fcc 100644
> --- a/drivers/media/video/videobuf-vmalloc.c
> +++ b/drivers/media/video/videobuf-vmalloc.c
> @@ -270,7 +270,7 @@ static int __videobuf_mmap_mapper(struct videobuf_queue *q,
>   	}
>
>   	vma->vm_ops          =&videobuf_vm_ops;
> -	vma->vm_flags       |= VM_DONTEXPAND | VM_RESERVED;
> +	vma->vm_flags       |= VM_DONTEXPAND | VM_DONTDUMP;
>   	vma->vm_private_data = map;
>
>   	dprintk(1, "mmap %p: q=%p %08lx-%08lx (%lx) pgoff %08lx buf %d\n",
> diff --git a/drivers/media/video/videobuf2-memops.c b/drivers/media/video/videobuf2-memops.c
> index 504cd4c..051ea35 100644
> --- a/drivers/media/video/videobuf2-memops.c
> +++ b/drivers/media/video/videobuf2-memops.c
> @@ -163,7 +163,7 @@ int vb2_mmap_pfn_range(struct vm_area_struct *vma, unsigned long paddr,
>   		return ret;
>   	}
>
> -	vma->vm_flags		|= VM_DONTEXPAND | VM_RESERVED;
> +	vma->vm_flags		|= VM_DONTEXPAND | VM_DONTDUMP;
>   	vma->vm_private_data	= priv;
>   	vma->vm_ops		= vm_ops;
>
> diff --git a/drivers/media/video/vino.c b/drivers/media/video/vino.c
> index aae1720..cc9110c 100644
> --- a/drivers/media/video/vino.c
> +++ b/drivers/media/video/vino.c
> @@ -3950,7 +3950,7 @@ found:
>
>   	fb->map_count = 1;
>
> -	vma->vm_flags |= VM_DONTEXPAND | VM_RESERVED;
> +	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
>   	vma->vm_flags&= ~VM_IO;
>   	vma->vm_private_data = fb;
>   	vma->vm_file = file;
> diff --git a/drivers/staging/media/easycap/easycap_main.c b/drivers/staging/media/easycap/easycap_main.c
> index 8269c77..4afa93d 100644
> --- a/drivers/staging/media/easycap/easycap_main.c
> +++ b/drivers/staging/media/easycap/easycap_main.c
> @@ -2246,7 +2246,7 @@ static int easycap_mmap(struct file *file, struct vm_area_struct *pvma)
>   	JOT(8, "\n");
>
>   	pvma->vm_ops =&easycap_vm_ops;
> -	pvma->vm_flags |= VM_RESERVED;
> +	pvma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
>   	if (file)
>   		pvma->vm_private_data = file->private_data;
>   	easycap_vma_open(pvma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
