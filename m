Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD2606B0003
	for <linux-mm@kvack.org>; Sat, 26 May 2018 20:31:58 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id t14-v6so5949804ual.11
        for <linux-mm@kvack.org>; Sat, 26 May 2018 17:31:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a127-v6sor2082276vka.139.2018.05.26.17.31.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 17:31:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
References: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Sat, 26 May 2018 17:31:56 -0700
Message-ID: <CAGXu5j+PHzDwnJxJwMJ=WuhacDn_vJWe9xZx+Kbsh28vxOGRiA@mail.gmail.com>
Subject: Re: [PATCH] proc: prevent a task from writing on its own /proc/*/mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jann Horn <jannh@google.com>
Cc: Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-security-module <linux-security-module@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dave@stgolabs.net>

On Sat, May 26, 2018 at 7:50 AM, Salvatore Mesoraca
<s.mesoraca16@gmail.com> wrote:
> Prevent a task from opening, in "write" mode, any /proc/*/mem
> file that operates on the task's mm.
> /proc/*/mem is mainly a debugging means and, as such, it shouldn't
> be used by the inspected process itself.
> Current implementation always allow a task to access its own
> /proc/*/mem file.
> A process can use it to overwrite read-only memory, making
> pointless the use of security_file_mprotect() or other ways to
> enforce RO memory.

I went through some old threads from 2012 when e268337dfe26 was
introduced, and later when things got looked at during DirtyCOW. There
was discussion about removing FOLL_FORCE (in order to block writes on
a read-only memory region). But that was much more general, touched
ptrace, etc. I think this patch would be okay, since it's specific to
the proc "self" mem interface, not remote processes (via ptrace). This
patch would also have blocked the /proc/self/mem path to DirtyCOW
(though not ptrace), so that would be nice if we have similar issues
in the future. So, as long as this doesn't break anything, I'm for it
in general. I've CCed Linus and Jann too, since they've stared at this
a lot too. :P

Note that you're re-checking the mm-check-for-self in mm_access().
That's used in /proc and for process_vm_write(). Ptrace (and
mm_access()) uses ptrace_may_access() for stuff (which has a similar
check to bypass LSMs), so I'd be curious what would happen if this
logic was plumbed into mm_access() instead of into proc_mem_open().
(Does anything open /proc/$pid files for writing? Does anything using
process_vm_write() on itself?)

-Kees

>
> Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
> ---
>  fs/proc/base.c       | 25 ++++++++++++++++++-------
>  fs/proc/internal.h   |  3 ++-
>  fs/proc/task_mmu.c   |  4 ++--
>  fs/proc/task_nommu.c |  2 +-
>  4 files changed, 23 insertions(+), 11 deletions(-)
>
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 1a76d75..01ecfec 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -762,8 +762,9 @@ static int proc_single_open(struct inode *inode, struct file *filp)
>         .release        = single_release,
>  };
>
> -
> -struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
> +struct mm_struct *proc_mem_open(struct inode *inode,
> +                               unsigned int mode,
> +                               fmode_t f_mode)
>  {
>         struct task_struct *task = get_proc_task(inode);
>         struct mm_struct *mm = ERR_PTR(-ESRCH);
> @@ -773,10 +774,20 @@ struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
>                 put_task_struct(task);
>
>                 if (!IS_ERR_OR_NULL(mm)) {
> -                       /* ensure this mm_struct can't be freed */
> -                       mmgrab(mm);
> -                       /* but do not pin its memory */
> -                       mmput(mm);
> +                       /*
> +                        * Prevent this interface from being used as a mean
> +                        * to bypass memory restrictions, including those
> +                        * imposed by LSMs.
> +                        */
> +                       if (mm == current->mm &&
> +                           f_mode & FMODE_WRITE)
> +                               mm = ERR_PTR(-EACCES);
> +                       else {
> +                               /* ensure this mm_struct can't be freed */
> +                               mmgrab(mm);
> +                               /* but do not pin its memory */
> +                               mmput(mm);
> +                       }
>                 }
>         }
>
> @@ -785,7 +796,7 @@ struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
>
>  static int __mem_open(struct inode *inode, struct file *file, unsigned int mode)
>  {
> -       struct mm_struct *mm = proc_mem_open(inode, mode);
> +       struct mm_struct *mm = proc_mem_open(inode, mode, file->f_mode);
>
>         if (IS_ERR(mm))
>                 return PTR_ERR(mm);
> diff --git a/fs/proc/internal.h b/fs/proc/internal.h
> index 0f1692e..8d38cc7 100644
> --- a/fs/proc/internal.h
> +++ b/fs/proc/internal.h
> @@ -275,7 +275,8 @@ struct proc_maps_private {
>  #endif
>  } __randomize_layout;
>
> -struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode);
> +struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode,
> +                               fmode_t f_mode);
>
>  extern const struct file_operations proc_pid_maps_operations;
>  extern const struct file_operations proc_tid_maps_operations;
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index c486ad4..efb6535 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -227,7 +227,7 @@ static int proc_maps_open(struct inode *inode, struct file *file,
>                 return -ENOMEM;
>
>         priv->inode = inode;
> -       priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
> +       priv->mm = proc_mem_open(inode, PTRACE_MODE_READ, file->f_mode);
>         if (IS_ERR(priv->mm)) {
>                 int err = PTR_ERR(priv->mm);
>
> @@ -1534,7 +1534,7 @@ static int pagemap_open(struct inode *inode, struct file *file)
>  {
>         struct mm_struct *mm;
>
> -       mm = proc_mem_open(inode, PTRACE_MODE_READ);
> +       mm = proc_mem_open(inode, PTRACE_MODE_READ, file->f_mode);
>         if (IS_ERR(mm))
>                 return PTR_ERR(mm);
>         file->private_data = mm;
> diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
> index 5b62f57..dc38516 100644
> --- a/fs/proc/task_nommu.c
> +++ b/fs/proc/task_nommu.c
> @@ -280,7 +280,7 @@ static int maps_open(struct inode *inode, struct file *file,
>                 return -ENOMEM;
>
>         priv->inode = inode;
> -       priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
> +       priv->mm = proc_mem_open(inode, PTRACE_MODE_READ, file->f_mode);
>         if (IS_ERR(priv->mm)) {
>                 int err = PTR_ERR(priv->mm);
>
> --
> 1.9.1
>



-- 
Kees Cook
Pixel Security
