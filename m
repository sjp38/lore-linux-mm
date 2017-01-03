Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB0086B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 16:36:57 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so81005394wmf.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 13:36:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jy9si9528204wjb.149.2017.01.03.13.36.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 13:36:56 -0800 (PST)
Date: Tue, 3 Jan 2017 22:36:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] drivers/virt: use get_user_pages_unlocked()
Message-ID: <20170103213653.GB18167@dhcp22.suse.cz>
References: <20161101194332.23961-1-lstoakes@gmail.com>
 <CAA5enKbithCrbZjw=dZkjkk2dHwyaOmp6MF1tUbPi3WQv3p41A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA5enKbithCrbZjw=dZkjkk2dHwyaOmp6MF1tUbPi3WQv3p41A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Kumar Gala <galak@kernel.crashing.org>, Mihai Caraman <mihai.caraman@freescale.com>, Greg KH <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue 03-01-17 21:14:20, Lorenzo Stoakes wrote:
> Just a gentle ping on this :) I think this might be a slightly
> abandoned corner of the kernel so not sure who else to ping to get
> this moving.

Maybe Andrew can pick it up?
http://lkml.kernel.org/r/20161101194332.23961-1-lstoakes@gmail.com

> On 1 November 2016 at 19:43, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
> > Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
> > and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.
> >
> > Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> > ---
> >  drivers/virt/fsl_hypervisor.c | 7 ++-----
> >  1 file changed, 2 insertions(+), 5 deletions(-)
> >
> > diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
> > index 150ce2a..d3eca87 100644
> > --- a/drivers/virt/fsl_hypervisor.c
> > +++ b/drivers/virt/fsl_hypervisor.c
> > @@ -243,11 +243,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
> >         sg_list = PTR_ALIGN(sg_list_unaligned, sizeof(struct fh_sg_list));
> >
> >         /* Get the physical addresses of the source buffer */
> > -       down_read(&current->mm->mmap_sem);
> > -       num_pinned = get_user_pages(param.local_vaddr - lb_offset,
> > -               num_pages, (param.source == -1) ? 0 : FOLL_WRITE,
> > -               pages, NULL);
> > -       up_read(&current->mm->mmap_sem);
> > +       num_pinned = get_user_pages_unlocked(param.local_vaddr - lb_offset,
> > +               num_pages, pages, (param.source == -1) ? 0 : FOLL_WRITE);
> >
> >         if (num_pinned != num_pages) {
> >                 /* get_user_pages() failed */
> > --
> > 2.10.2
> >
> 
> 
> 
> -- 
> Lorenzo Stoakes
> https://ljs.io

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
