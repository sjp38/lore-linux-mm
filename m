Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A055B6B02F3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 19:05:57 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h64so28868973iod.9
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:05:57 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id c199si3727512itc.50.2017.06.27.16.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 16:05:56 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id h134so26627954iof.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:05:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1497544976-7856-4-git-send-email-s.mesoraca16@gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com> <1497544976-7856-4-git-send-email-s.mesoraca16@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 27 Jun 2017 16:05:55 -0700
Message-ID: <CAGXu5jJTEoeGs8uBdHYdBJwacOp2b22ySrn-V8T93qaD4cv65A@mail.gmail.com>
Subject: Re: [RFC v2 3/9] Creation of "check_vmflags" LSM hook
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-security-module <linux-security-module@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Smalley <sds@tycho.nsa.gov>, John Johansen <john.johansen@canonical.com>

On Thu, Jun 15, 2017 at 9:42 AM, Salvatore Mesoraca
<s.mesoraca16@gmail.com> wrote:
> Creation of a new LSM hook to check if a given configuration of vmflags,
> for a new memory allocation request, should be allowed or not.
> It's placed in "do_mmap", "do_brk_flags" and "__install_special_mapping".

I like this. I think this is something the other LSMs should be
checking too. (Though I wonder if it would be helpful to include the
VMA in the hook, though it does exist yet, so... hmm.)

-Kees

>
> Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
> ---
>  include/linux/lsm_hooks.h |  7 +++++++
>  include/linux/security.h  |  6 ++++++
>  mm/mmap.c                 | 13 +++++++++++++
>  security/security.c       |  5 +++++
>  4 files changed, 31 insertions(+)
>
> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> index bd274db..33dab16 100644
> --- a/include/linux/lsm_hooks.h
> +++ b/include/linux/lsm_hooks.h
> @@ -483,6 +483,11 @@
>   *     @reqprot contains the protection requested by the application.
>   *     @prot contains the protection that will be applied by the kernel.
>   *     Return 0 if permission is granted.
> + * @check_vmflags:
> + *     Check if the requested @vmflags are allowed.
> + *     @vmflags contains requested the vmflags.
> + *     Return 0 if the operation is allowed to continue otherwise return
> + *     the appropriate error code.
>   * @file_lock:
>   *     Check permission before performing file locking operations.
>   *     Note: this hook mediates both flock and fcntl style locks.
> @@ -1477,6 +1482,7 @@
>                                 unsigned long prot, unsigned long flags);
>         int (*file_mprotect)(struct vm_area_struct *vma, unsigned long reqprot,
>                                 unsigned long prot);
> +       int (*check_vmflags)(vm_flags_t vmflags);
>         int (*file_lock)(struct file *file, unsigned int cmd);
>         int (*file_fcntl)(struct file *file, unsigned int cmd,
>                                 unsigned long arg);
> @@ -1747,6 +1753,7 @@ struct security_hook_heads {
>         struct list_head mmap_addr;
>         struct list_head mmap_file;
>         struct list_head file_mprotect;
> +       struct list_head check_vmflags;
>         struct list_head file_lock;
>         struct list_head file_fcntl;
>         struct list_head file_set_fowner;
> diff --git a/include/linux/security.h b/include/linux/security.h
> index af675b5..8701872 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -300,6 +300,7 @@ int security_mmap_file(struct file *file, unsigned long prot,
>  int security_mmap_addr(unsigned long addr);
>  int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
>                            unsigned long prot);
> +int security_check_vmflags(vm_flags_t vmflags);
>  int security_file_lock(struct file *file, unsigned int cmd);
>  int security_file_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
>  void security_file_set_fowner(struct file *file);
> @@ -823,6 +824,11 @@ static inline int security_file_mprotect(struct vm_area_struct *vma,
>         return 0;
>  }
>
> +static inline int security_check_vmflags(vm_flags_t vmflags)
> +{
> +       return 0;
> +}
> +
>  static inline int security_file_lock(struct file *file, unsigned int cmd)
>  {
>         return 0;
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f82741e..132061b 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1311,6 +1311,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  {
>         struct mm_struct *mm = current->mm;
>         int pkey = 0;
> +       int error;
>
>         *populate = 0;
>
> @@ -1363,6 +1364,10 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>         vm_flags |= calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
>                         mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
>
> +       error = security_check_vmflags(vm_flags);
> +       if (error)
> +               return error;
> +
>         if (flags & MAP_LOCKED)
>                 if (!can_do_mlock())
>                         return -EPERM;
> @@ -2833,6 +2838,10 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
>                 return -EINVAL;
>         flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
>
> +       error = security_check_vmflags(flags);
> +       if (error)
> +               return error;
> +
>         error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
>         if (offset_in_page(error))
>                 return error;
> @@ -3208,6 +3217,10 @@ static struct vm_area_struct *__install_special_mapping(
>         int ret;
>         struct vm_area_struct *vma;
>
> +       ret = security_check_vmflags(vm_flags);
> +       if (ret)
> +               return ERR_PTR(ret);
> +
>         vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
>         if (unlikely(vma == NULL))
>                 return ERR_PTR(-ENOMEM);
> diff --git a/security/security.c b/security/security.c
> index 42c8028..7e45846 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -900,6 +900,11 @@ int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
>         return call_int_hook(file_mprotect, 0, vma, reqprot, prot);
>  }
>
> +int security_check_vmflags(vm_flags_t vmflags)
> +{
> +       return call_int_hook(check_vmflags, 0, vmflags);
> +}
> +
>  int security_file_lock(struct file *file, unsigned int cmd)
>  {
>         return call_int_hook(file_lock, 0, file, cmd);
> --
> 1.9.1
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
