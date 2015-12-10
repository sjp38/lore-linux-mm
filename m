Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id E4CEA6B0253
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 13:18:43 -0500 (EST)
Received: by iouu10 with SMTP id u10so103277909iou.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:18:43 -0800 (PST)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id 67si21649623ios.53.2015.12.10.10.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 10:18:43 -0800 (PST)
Received: by ioc74 with SMTP id 74so101101300ioc.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:18:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151210181611.GB32083@1wt.eu>
References: <20151209225148.GA14794@www.outflux.net>
	<20151210070635.GC31922@1wt.eu>
	<CAGXu5jLZ8Ldv4vCjN6+QOa8v=GuUDU9t8sJsTNaQJGYtpdCayA@mail.gmail.com>
	<20151210181611.GB32083@1wt.eu>
Date: Thu, 10 Dec 2015 10:18:42 -0800
Message-ID: <CAGXu5jJW3p2ay7==YhjNOx_pVd3Hmdz+0Ucn4iu6Wgv7eK9CgQ@mail.gmail.com>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 10, 2015 at 10:16 AM, Willy Tarreau <w@1wt.eu> wrote:
> On Thu, Dec 10, 2015 at 10:05:50AM -0800, Kees Cook wrote:
>> On Wed, Dec 9, 2015 at 11:06 PM, Willy Tarreau <w@1wt.eu> wrote:
>> > Hi Kees,
>> >
>> > Why not add a new file flag instead ?
>> >
>> > Something like this (editing your patch by hand to illustrate) :
>> >
>> > diff --git a/fs/file_table.c b/fs/file_table.c
>> > index ad17e05ebf95..3a7eee76ea90 100644
>> > --- a/fs/file_table.c
>> > +++ b/fs/file_table.c
>> > @@ -191,6 +191,17 @@ static void __fput(struct file *file)
>> >
>> >         might_sleep();
>> >
>> > +       /*
>> > +        * XXX: While avoiding mmap_sem, we've already been written to.
>> > +        * We must ignore the return value, since we can't reject the
>> > +        * write.
>> > +        */
>> > +       if (unlikely(file->f_flags & FL_DROP_PRIVS)) {
>> > +               mutex_lock(&inode->i_mutex);
>> > +               file_remove_privs(file);
>> > +               mutex_unlock(&inode->i_mutex);
>> > +       }
>> > +
>> >         fsnotify_close(file);
>> >         /*
>> >          * The function eventpoll_release() should be the first called
>> > diff --git a/include/linux/fs.h b/include/linux/fs.h
>> > index 3aa514254161..409bd7047e7e 100644
>> > --- a/include/linux/fs.h
>> > +++ b/include/linux/fs.h
>> > @@ -913,3 +913,4 @@
>> >  #define FL_OFDLCK       1024    /* lock is "owned" by struct file */
>> >  #define FL_LAYOUT       2048    /* outstanding pNFS layout */
>> > +#define FL_DROP_PRIVS   4096    /* lest something weird decides that 2 is OK */
>> >
>> > diff --git a/mm/memory.c b/mm/memory.c
>> > index c387430f06c3..08a77e0cf65f 100644
>> > --- a/mm/memory.c
>> > +++ b/mm/memory.c
>> > @@ -2036,6 +2036,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
>> >
>> >                 if (!page_mkwrite)
>> >                         file_update_time(vma->vm_file);
>> > +               vma->vm_file->f_flags |= FL_DROP_PRIVS;
>> >         }
>> >
>> >         return VM_FAULT_WRITE;
>> >
>> > Willy
>> >
>>
>> Is f_flags safe to write like this without holding a lock?
>
> Unfortunately I have no idea. I've seen places where it's written without
> taking a lock such as in blkdev_open() and I don't think that this one is
> called with a lock held.
>
> The comment in fs.h says that spinlock f_lock is here to protect f_flags
> (among others) and that it must not be taken from IRQ context. Thus I'd
> think we "just" have to take it to remain safe. That would be just one
> spinlock per first write via mmap() to a file, I don't know if that's
> reasonable or not :-/

Al, what's the best way forward here? I created a separate flag
variable so it could be used effectively write-only, with the read
happening only at final fput.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
