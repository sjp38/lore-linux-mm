Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 415D7828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 10:48:34 -0500 (EST)
Received: by mail-lf0-f46.google.com with SMTP id c192so201136492lfe.2
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 07:48:34 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id ms9si66936724lbb.112.2016.01.10.07.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 07:48:32 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id t141so4165656lfd.3
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 07:48:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160108232727.GA23490@www.outflux.net>
References: <20160108232727.GA23490@www.outflux.net>
Date: Sun, 10 Jan 2016 18:48:32 +0300
Message-ID: <CALYGNiOUL7ewU3+5Zoi_9qofYWwF0vpqMy=A0wS=jUFZ11haCg@mail.gmail.com>
Subject: Re: [PATCH v6] fs: clear file privilege bits when mmap writing
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-arch@vger.kernel.org, Linux API <linux-api@vger.kern>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, Jan 9, 2016 at 2:27 AM, Kees Cook <keescook@chromium.org> wrote:
> Normally, when a user can modify a file that has setuid or setgid bits,
> those bits are cleared when they are not the file owner or a member
> of the group. This is enforced when using write and truncate but not
> when writing to a shared mmap on the file. This could allow the file
> writer to gain privileges by changing a binary without losing the
> setuid/setgid/caps bits.
>
> Changing the bits requires holding inode->i_mutex, so it cannot be done
> during the page fault (due to mmap_sem being held during the fault). We
> could do this during vm_mmap_pgoff, but that would need coverage in
> mprotect as well, but to check for MAP_SHARED, we'd need to hold mmap_sem
> again. We could clear at open() time, but it's possible things are
> accidentally opening with O_RDWR and only reading. Better to clear on
> close and error failures (i.e. an improvement over now, which is not
> clearing at all).

I think this should be done in mmap/mprotect. Code in sys_mmap is trivial.

In sys_mprotect you can check file_needs_remove_privs() and VM_SHARED
under mmap_sem, then if needed grab reference to struct file from vma and
clear suid after unlocking mmap_sem.

I haven't seen previous iterations, probably this approach has known flaws.

>
> Instead, detect the need to clear the bits during the page fault, and
> actually remove the bits during final fput. Since the file was open for
> writing, it wouldn't have been possible to execute it yet (ETXTBSY).
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> v6:
> - clarify ETXTBSY situation in comments, luto
> v5:
> - add to f_flags instead, viro
> - add i_mutex during __fput, jack
> v4:
> - delay removal instead of still needing mmap_sem for mprotect, yalin
> v3:
> - move outside of mmap_sem for real now, fengguang
> - check return code of file_remove_privs, akpm
> v2:
> - move to mmap from fault handler, jack
> ---
>  fs/file_table.c                  | 15 +++++++++++++++
>  fs/open.c                        |  2 +-
>  include/uapi/asm-generic/fcntl.h |  4 ++++
>  mm/memory.c                      |  5 +++++
>  4 files changed, 25 insertions(+), 1 deletion(-)
>
> diff --git a/fs/file_table.c b/fs/file_table.c
> index ad17e05ebf95..ca11b86613cf 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -191,6 +191,21 @@ static void __fput(struct file *file)
>
>         might_sleep();
>
> +       /*
> +        * XXX: This is a delayed removal of privs (we've already been
> +        * written to), since we must avoid mmap_sem. But a race shouldn't
> +        * be possible since when open for writing, execve() will fail
> +        * with ETXTBSY (via deny_write_access()). A remaining problem
> +        * is that since we've already been written to, we must ignore the
> +        * return value of file_remove_privs(), since we can't reject the
> +        * writes of the past.
> +        */
> +       if (unlikely(file->f_flags & O_REMOVEPRIV)) {
> +               mutex_lock(&inode->i_mutex);
> +               file_remove_privs(file);
> +               mutex_unlock(&inode->i_mutex);
> +       }
> +
>         fsnotify_close(file);
>         /*
>          * The function eventpoll_release() should be the first called
> diff --git a/fs/open.c b/fs/open.c
> index b6f1e96a7c0b..89069d16ca80 100644
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -895,7 +895,7 @@ static inline int build_open_flags(int flags, umode_t mode, struct open_flags *o
>                 op->mode = 0;
>
>         /* Must never be set by userspace */
> -       flags &= ~FMODE_NONOTIFY & ~O_CLOEXEC;
> +       flags &= ~FMODE_NONOTIFY & ~O_CLOEXEC & ~O_REMOVEPRIV;
>
>         /*
>          * O_SYNC is implemented as __O_SYNC|O_DSYNC.  As many places only
> diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
> index e063effe0cc1..096c4b3afe6a 100644
> --- a/include/uapi/asm-generic/fcntl.h
> +++ b/include/uapi/asm-generic/fcntl.h
> @@ -88,6 +88,10 @@
>  #define __O_TMPFILE    020000000
>  #endif
>
> +#ifndef O_REMOVEPRIV
> +#define O_REMOVEPRIV   040000000
> +#endif
> +
>  /* a horrid kludge trying to make sure that this will fail on old kernels */
>  #define O_TMPFILE (__O_TMPFILE | O_DIRECTORY)
>  #define O_TMPFILE_MASK (__O_TMPFILE | O_DIRECTORY | O_CREAT)
> diff --git a/mm/memory.c b/mm/memory.c
> index c387430f06c3..ad4188a8f279 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2036,6 +2036,11 @@ static inline int wp_page_reuse(struct mm_struct *mm,
>
>                 if (!page_mkwrite)
>                         file_update_time(vma->vm_file);
> +               if (unlikely((vma->vm_file->f_flags & O_REMOVEPRIV) == 0)) {
> +                       spin_lock(&vma->vm_file->f_lock);
> +                       vma->vm_file->f_flags |= O_REMOVEPRIV;
> +                       spin_unlock(&vma->vm_file->f_lock);
> +               }
>         }
>
>         return VM_FAULT_WRITE;
> --
> 2.6.3
>
>
> --
> Kees Cook
> Chrome OS & Brillo Security
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
