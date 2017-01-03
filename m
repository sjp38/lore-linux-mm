Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5DE6B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 15:23:43 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id x140so111725340lfa.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 12:23:43 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id h99si41161697lfi.54.2017.01.03.12.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 12:23:41 -0800 (PST)
Received: by mail-lf0-x242.google.com with SMTP id x140so28991841lfa.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 12:23:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161101194337.24015-1-lstoakes@gmail.com>
References: <20161101194337.24015-1-lstoakes@gmail.com>
From: Lorenzo Stoakes <lstoakes@gmail.com>
Date: Tue, 3 Jan 2017 20:23:20 +0000
Message-ID: <CAA5enKai6Gq7gCf6mmuXJwZrds5N8s9JAtNGxy1vAJD1zSmb2Q@mail.gmail.com>
Subject: Re: [PATCH] drm/via: use get_user_pages_unlocked()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@kernel.org>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Lorenzo Stoakes <lstoakes@gmail.com>

Hi All,

Just a gentle ping on this one :)

Cheers, Lorenzo

On 1 November 2016 at 19:43, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
> Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
> and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.
>
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> ---
>  drivers/gpu/drm/via/via_dmablit.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
> index 1a3ad76..98aae98 100644
> --- a/drivers/gpu/drm/via/via_dmablit.c
> +++ b/drivers/gpu/drm/via/via_dmablit.c
> @@ -238,13 +238,9 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
>         vsg->pages = vzalloc(sizeof(struct page *) * vsg->num_pages);
>         if (NULL == vsg->pages)
>                 return -ENOMEM;
> -       down_read(&current->mm->mmap_sem);
> -       ret = get_user_pages((unsigned long)xfer->mem_addr,
> -                            vsg->num_pages,
> -                            (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0,
> -                            vsg->pages, NULL);
> -
> -       up_read(&current->mm->mmap_sem);
> +       ret = get_user_pages_unlocked((unsigned long)xfer->mem_addr,
> +                       vsg->num_pages, vsg->pages,
> +                       (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0);
>         if (ret != vsg->num_pages) {
>                 if (ret < 0)
>                         return ret;
> --
> 2.10.2
>



-- 
Lorenzo Stoakes
https://ljs.io

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
