Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF0436B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 16:14:42 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id t196so184764607lff.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 13:14:42 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id c21si28197555ljd.60.2017.01.03.13.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 13:14:41 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id t196so26765582lff.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 13:14:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161101194332.23961-1-lstoakes@gmail.com>
References: <20161101194332.23961-1-lstoakes@gmail.com>
From: Lorenzo Stoakes <lstoakes@gmail.com>
Date: Tue, 3 Jan 2017 21:14:20 +0000
Message-ID: <CAA5enKbithCrbZjw=dZkjkk2dHwyaOmp6MF1tUbPi3WQv3p41A@mail.gmail.com>
Subject: Re: [PATCH] drivers/virt: use get_user_pages_unlocked()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@kernel.org>, Kumar Gala <galak@kernel.crashing.org>, Mihai Caraman <mihai.caraman@freescale.com>, Greg KH <gregkh@linuxfoundation.org>

Just a gentle ping on this :) I think this might be a slightly
abandoned corner of the kernel so not sure who else to ping to get
this moving.

On 1 November 2016 at 19:43, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
> Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
> and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.
>
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> ---
>  drivers/virt/fsl_hypervisor.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
> index 150ce2a..d3eca87 100644
> --- a/drivers/virt/fsl_hypervisor.c
> +++ b/drivers/virt/fsl_hypervisor.c
> @@ -243,11 +243,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
>         sg_list = PTR_ALIGN(sg_list_unaligned, sizeof(struct fh_sg_list));
>
>         /* Get the physical addresses of the source buffer */
> -       down_read(&current->mm->mmap_sem);
> -       num_pinned = get_user_pages(param.local_vaddr - lb_offset,
> -               num_pages, (param.source == -1) ? 0 : FOLL_WRITE,
> -               pages, NULL);
> -       up_read(&current->mm->mmap_sem);
> +       num_pinned = get_user_pages_unlocked(param.local_vaddr - lb_offset,
> +               num_pages, pages, (param.source == -1) ? 0 : FOLL_WRITE);
>
>         if (num_pinned != num_pages) {
>                 /* get_user_pages() failed */
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
