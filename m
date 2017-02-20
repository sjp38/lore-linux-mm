Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C9CD26B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 13:34:58 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id l135so14868784lfl.6
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 10:34:58 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id c195si9917194lfe.369.2017.02.20.10.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 10:34:57 -0800 (PST)
Received: by mail-lf0-x241.google.com with SMTP id z127so7274441lfa.2
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 10:34:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170103213653.GB18167@dhcp22.suse.cz>
References: <20161101194332.23961-1-lstoakes@gmail.com> <CAA5enKbithCrbZjw=dZkjkk2dHwyaOmp6MF1tUbPi3WQv3p41A@mail.gmail.com>
 <20170103213653.GB18167@dhcp22.suse.cz>
From: Lorenzo Stoakes <lstoakes@gmail.com>
Date: Mon, 20 Feb 2017 18:34:36 +0000
Message-ID: <CAA5enKbdH_oo7U_RjFA3ZipHL8QSnE+oAi9McFb7z7ZHrcNERA@mail.gmail.com>
Subject: Re: [PATCH] drivers/virt: use get_user_pages_unlocked()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Kumar Gala <galak@kernel.crashing.org>, Mihai Caraman <mihai.caraman@freescale.com>, Greg KH <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>

On 3 January 2017 at 21:36, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 03-01-17 21:14:20, Lorenzo Stoakes wrote:
>> Just a gentle ping on this :) I think this might be a slightly
>> abandoned corner of the kernel so not sure who else to ping to get
>> this moving.
>
> Maybe Andrew can pick it up?
> http://lkml.kernel.org/r/20161101194332.23961-1-lstoakes@gmail.com
>

Hi all, since the merge window has opened thought I'd give another
gentle nudge on this - Andrew, are you ok to pick this up? For
convenience the raw patch is at
https://marc.info/?l=linux-mm&m=147802941732512&q=raw I've checked and
it still applies. Let me know if you want me to simply resend this or
if there is anything else I can do to nudge this along!

Thanks, Lorenzo

>> On 1 November 2016 at 19:43, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
>> > Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
>> > and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.
>> >
>> > Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
>> > ---
>> >  drivers/virt/fsl_hypervisor.c | 7 ++-----
>> >  1 file changed, 2 insertions(+), 5 deletions(-)
>> >
>> > diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
>> > index 150ce2a..d3eca87 100644
>> > --- a/drivers/virt/fsl_hypervisor.c
>> > +++ b/drivers/virt/fsl_hypervisor.c
>> > @@ -243,11 +243,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
>> >         sg_list = PTR_ALIGN(sg_list_unaligned, sizeof(struct fh_sg_list));
>> >
>> >         /* Get the physical addresses of the source buffer */
>> > -       down_read(&current->mm->mmap_sem);
>> > -       num_pinned = get_user_pages(param.local_vaddr - lb_offset,
>> > -               num_pages, (param.source == -1) ? 0 : FOLL_WRITE,
>> > -               pages, NULL);
>> > -       up_read(&current->mm->mmap_sem);
>> > +       num_pinned = get_user_pages_unlocked(param.local_vaddr - lb_offset,
>> > +               num_pages, pages, (param.source == -1) ? 0 : FOLL_WRITE);
>> >
>> >         if (num_pinned != num_pages) {
>> >                 /* get_user_pages() failed */
>> > --
>> > 2.10.2
>> >
>>
>>
>>
>> --
>> Lorenzo Stoakes
>> https://ljs.io
>
> --
> Michal Hocko
> SUSE Labs



-- 
Lorenzo Stoakes
https://ljs.io

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
