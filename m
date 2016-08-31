Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C55D76B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:01:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f128so120888161qkd.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:01:13 -0700 (PDT)
Received: from mail-ua0-x22a.google.com (mail-ua0-x22a.google.com. [2607:f8b0:400c:c08::22a])
        by mx.google.com with ESMTPS id k1si160655uak.192.2016.08.31.08.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 08:01:13 -0700 (PDT)
Received: by mail-ua0-x22a.google.com with SMTP id q42so34742157uaq.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:01:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160826171317.3944-4-dsafonov@virtuozzo.com>
References: <20160826171317.3944-1-dsafonov@virtuozzo.com> <20160826171317.3944-4-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 31 Aug 2016 08:00:52 -0700
Message-ID: <CALCETrW=TrX9YLVbQmGQQjFcCeguNz6f9LhQdEJg4qPdibKhhw@mail.gmail.com>
Subject: Re: [PATCHv3 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Andrew Lutomirski <luto@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On Fri, Aug 26, 2016 at 10:13 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Add API to change vdso blob type with arch_prctl.
> As this is usefull only by needs of CRIU, expose
> this interface under CONFIG_CHECKPOINT_RESTORE.
>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: x86@kernel.org
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Pavel Emelyanov <xemul@virtuozzo.com>
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
> ---
>  arch/x86/entry/vdso/vma.c         | 45 ++++++++++++++++++++++++++++++---------
>  arch/x86/include/asm/vdso.h       |  2 ++
>  arch/x86/include/uapi/asm/prctl.h |  6 ++++++
>  arch/x86/kernel/process_64.c      | 25 ++++++++++++++++++++++
>  4 files changed, 68 insertions(+), 10 deletions(-)
>
> diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
> index 5bcb25a9e573..dad2b2d8ff03 100644
> --- a/arch/x86/entry/vdso/vma.c
> +++ b/arch/x86/entry/vdso/vma.c
> @@ -176,6 +176,16 @@ static int vvar_fault(const struct vm_special_mapping *sm,
>         return VM_FAULT_SIGBUS;
>  }
>
> +static const struct vm_special_mapping vdso_mapping = {
> +       .name = "[vdso]",
> +       .fault = vdso_fault,
> +       .mremap = vdso_mremap,
> +};
> +static const struct vm_special_mapping vvar_mapping = {
> +       .name = "[vvar]",
> +       .fault = vvar_fault,
> +};
> +
>  /*
>   * Add vdso and vvar mappings to current process.
>   * @image          - blob to map
> @@ -188,16 +198,6 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
>         unsigned long text_start;
>         int ret = 0;
>
> -       static const struct vm_special_mapping vdso_mapping = {
> -               .name = "[vdso]",
> -               .fault = vdso_fault,
> -               .mremap = vdso_mremap,
> -       };
> -       static const struct vm_special_mapping vvar_mapping = {
> -               .name = "[vvar]",
> -               .fault = vvar_fault,
> -       };
> -
>         if (down_write_killable(&mm->mmap_sem))
>                 return -EINTR;
>
> @@ -256,6 +256,31 @@ static int map_vdso_randomized(const struct vdso_image *image)
>         return map_vdso(image, addr);
>  }
>
> +int map_vdso_once(const struct vdso_image *image, unsigned long addr)
> +{
> +       struct mm_struct *mm = current->mm;
> +       struct vm_area_struct *vma;
> +
> +       down_write(&mm->mmap_sem);
> +       /*
> +        * Check if we have already mapped vdso blob - fail to prevent
> +        * abusing from userspace install_speciall_mapping, which may
> +        * not do accounting and rlimit right.
> +        * We could search vma near context.vdso, but it's a slowpath,
> +        * so let's explicitely check all VMAs to be completely sure.
> +        */
> +       for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +               if (vma->vm_private_data == &vdso_mapping ||
> +                               vma->vm_private_data == &vvar_mapping) {

Should probably also check that vm_ops == &special_mapping_vmops,
which means that maybe there should be a:

static inline bool vma_is_special_mapping(const struct vm_area_struct
*vma, const struct vm_special_mapping &sm);

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
