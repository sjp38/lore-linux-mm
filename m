Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id CB2436B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 13:05:51 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so21451396igb.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:05:51 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id v97si21630860iov.33.2015.12.10.10.05.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 10:05:51 -0800 (PST)
Received: by iouu10 with SMTP id u10so102864346iou.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:05:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151210070635.GC31922@1wt.eu>
References: <20151209225148.GA14794@www.outflux.net>
	<20151210070635.GC31922@1wt.eu>
Date: Thu, 10 Dec 2015 10:05:50 -0800
Message-ID: <CAGXu5jLZ8Ldv4vCjN6+QOa8v=GuUDU9t8sJsTNaQJGYtpdCayA@mail.gmail.com>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 9, 2015 at 11:06 PM, Willy Tarreau <w@1wt.eu> wrote:
> Hi Kees,
>
> Why not add a new file flag instead ?
>
> Something like this (editing your patch by hand to illustrate) :
>
> diff --git a/fs/file_table.c b/fs/file_table.c
> index ad17e05ebf95..3a7eee76ea90 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -191,6 +191,17 @@ static void __fput(struct file *file)
>
>         might_sleep();
>
> +       /*
> +        * XXX: While avoiding mmap_sem, we've already been written to.
> +        * We must ignore the return value, since we can't reject the
> +        * write.
> +        */
> +       if (unlikely(file->f_flags & FL_DROP_PRIVS)) {
> +               mutex_lock(&inode->i_mutex);
> +               file_remove_privs(file);
> +               mutex_unlock(&inode->i_mutex);
> +       }
> +
>         fsnotify_close(file);
>         /*
>          * The function eventpoll_release() should be the first called
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 3aa514254161..409bd7047e7e 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -913,3 +913,4 @@
>  #define FL_OFDLCK       1024    /* lock is "owned" by struct file */
>  #define FL_LAYOUT       2048    /* outstanding pNFS layout */
> +#define FL_DROP_PRIVS   4096    /* lest something weird decides that 2 is OK */
>
> diff --git a/mm/memory.c b/mm/memory.c
> index c387430f06c3..08a77e0cf65f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2036,6 +2036,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
>
>                 if (!page_mkwrite)
>                         file_update_time(vma->vm_file);
> +               vma->vm_file->f_flags |= FL_DROP_PRIVS;
>         }
>
>         return VM_FAULT_WRITE;
>
> Willy
>

Is f_flags safe to write like this without holding a lock?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
