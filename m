Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31C018E00FB
	for <linux-mm@kvack.org>; Sun, 27 Jan 2019 11:32:04 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id k22-v6so3998784ljk.12
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 08:32:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24-v6sor9059489ljy.1.2019.01.27.08.32.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 27 Jan 2019 08:32:01 -0800 (PST)
MIME-Version: 1.0
References: <CGME20190111150806epcas2p4ecaac58547db019e7dc779349d495f4d@epcas2p4.samsung.com>
 <20190111151154.GA2819@jordon-HP-15-Notebook-PC> <241810e0-2288-c59b-6c21-6d853d9fe84a@samsung.com>
 <CAFqt6zbYHq-pS=rGx+3ncJ7rO-LvL5=iOou21oguKjrc=3qouA@mail.gmail.com> <febb9775-20da-69d5-4f0e-cd87253eb8f9@samsung.com>
In-Reply-To: <febb9775-20da-69d5-4f0e-cd87253eb8f9@samsung.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 27 Jan 2019 22:01:52 +0530
Message-ID: <CAFqt6zazAymL69a6_JHF4SjHRC_NB8zSA=E-hC-dQ71hS9mKcA@mail.gmail.com>
Subject: Re: [PATCH 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range_buggy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

Hi Marek,

On Fri, Jan 25, 2019 at 5:58 PM Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
>
> Hi Souptick,
>
> On 2019-01-25 05:55, Souptick Joarder wrote:
> > On Tue, Jan 22, 2019 at 8:37 PM Marek Szyprowski
> > <m.szyprowski@samsung.com> wrote:
> >> On 2019-01-11 16:11, Souptick Joarder wrote:
> >>> Convert to use vm_insert_range_buggy to map range of kernel memory
> >>> to user vma.
> >>>
> >>> This driver has ignored vm_pgoff. We could later "fix" these drivers
> >>> to behave according to the normal vm_pgoff offsetting simply by
> >>> removing the _buggy suffix on the function name and if that causes
> >>> regressions, it gives us an easy way to revert.
> >> Just a generic note about videobuf2: videobuf2-dma-sg is ignoring vm_p=
goff by design. vm_pgoff is used as a 'cookie' to select a buffer to mmap a=
nd videobuf2-core already checks that. If userspace provides an offset, whi=
ch doesn't match any of the registered 'cookies' (reported to userspace via=
 separate v4l2 ioctl), an error is returned.
> > Ok, it means once the buf is selected, videobuf2-dma-sg should always
> > mapped buf->pages[i]
> > from index 0 ( irrespective of vm_pgoff value). So although we are
> > replacing the code with
> > vm_insert_range_buggy(), *_buggy* suffix will mislead others and
> > should not be used.
> > And if we replace this code with  vm_insert_range(), this will
> > introduce bug for *non zero*
> > value of vm_pgoff.
> >
> > Please correct me if my understanding is wrong.
>
> You are correct. IMHO the best solution in this case would be to add
> following fix:
>
>
> diff --git a/drivers/media/common/videobuf2/videobuf2-core.c
> b/drivers/media/common/videobuf2/videobuf2-core.c
> index 70e8c3366f9c..ca4577a7d28a 100644
> --- a/drivers/media/common/videobuf2/videobuf2-core.c
> +++ b/drivers/media/common/videobuf2/videobuf2-core.c
> @@ -2175,6 +2175,13 @@ int vb2_mmap(struct vb2_queue *q, struct
> vm_area_struct *vma)
>          goto unlock;
>      }
>
> +    /*
> +     * vm_pgoff is treated in V4L2 API as a 'cookie' to select a buffer,
> +     * not as a in-buffer offset. We always want to mmap a whole buffer
> +     * from its beginning.
> +     */
> +    vma->vm_pgoff =3D 0;
> +
>      ret =3D call_memop(vb, mmap, vb->planes[plane].mem_priv, vma);
>
>  unlock:
> diff --git a/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> index aff0ab7bf83d..46245c598a18 100644
> --- a/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> +++ b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> @@ -186,12 +186,6 @@ static int vb2_dc_mmap(void *buf_priv, struct
> vm_area_struct *vma)
>          return -EINVAL;
>      }
>
> -    /*
> -     * dma_mmap_* uses vm_pgoff as in-buffer offset, but we want to
> -     * map whole buffer
> -     */
> -    vma->vm_pgoff =3D 0;
> -
>      ret =3D dma_mmap_attrs(buf->dev, vma, buf->cookie,
>          buf->dma_addr, buf->size, buf->attrs);
>
> --
>
> Then you can simply use non-buggy version of your function in
> drivers/media/common/videobuf2/videobuf2-dma-sg.c.
>
> I can send above as a formal patch if you want.

Thanks for the patch.
I will fold this changes along with current patch in v2.

>
> > So what your opinion about this patch ? Shall I drop this patch from
> > current series ?
> > or,
> > There is any better way to handle this scenario ?
> >
> >
> >>> There is an existing bug inside gem_mmap_obj(), where user passed
> >>> length is not checked against buf->num_pages. For any value of
> >>> length > buf->num_pages it will end up overrun buf->pages[i],
> >>> which could lead to a potential bug.
> > It is not gem_mmap_obj(), it should be vb2_dma_sg_mmap().
> > Sorry about it.
> >
> > What about this issue ? Does it looks like a valid issue ?
>
> It is already handled in vb2_mmap(). Such call will be rejected.
>
>
> > ...
>
> Best regards
> --
> Marek Szyprowski, PhD
> Samsung R&D Institute Poland
>
