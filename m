Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDD766B0005
	for <linux-mm@kvack.org>; Mon, 28 May 2018 05:07:00 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id k136-v6so6873899oih.4
        for <linux-mm@kvack.org>; Mon, 28 May 2018 02:07:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e34-v6sor3503918otd.266.2018.05.28.02.06.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 May 2018 02:06:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
References: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
From: Jann Horn <jannh@google.com>
Date: Mon, 28 May 2018 11:06:38 +0200
Message-ID: <CAG48ez2N8tjyjGbdh+927uf2A_Xtsie=+DL+GZbvBniiO8jNHw@mail.gmail.com>
Subject: Re: [PATCH] proc: prevent a task from writing on its own /proc/*/mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-security-module <linux-security-module@vger.kernel.org>, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dave@stgolabs.net>, Kees Cook <keescook@chromium.org>

On Sat, May 26, 2018 at 4:50 PM, Salvatore Mesoraca
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

I don't have an opinion on the overall patch, but this part looks
buggy: In the error path, you set `mm` to an error pointer, but you
still own the reference that mm_access() took on the old `mm`. The
error path needs to call `mmput(mm)`.
