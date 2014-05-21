Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 46E2C6B0035
	for <linux-mm@kvack.org>; Wed, 21 May 2014 06:50:20 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id hn18so1908907igb.12
        for <linux-mm@kvack.org>; Wed, 21 May 2014 03:50:20 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id g20si2481311igf.36.2014.05.21.03.50.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 03:50:19 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id tp5so1758361ieb.39
        for <linux-mm@kvack.org>; Wed, 21 May 2014 03:50:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1397587118-1214-3-git-send-email-dh.herrmann@gmail.com>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
	<1397587118-1214-3-git-send-email-dh.herrmann@gmail.com>
Date: Wed, 21 May 2014 14:50:19 +0400
Message-ID: <CALYGNiM5dVhW9rp8Xpbu=DpENobUtRpRNTteJXbg1s99_STNiw@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] shm: add memfd_create() syscall
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, =?UTF-8?Q?Kristian_H=C3=B8gsberg?= <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

On Tue, Apr 15, 2014 at 10:38 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
> that you can pass to mmap(). It can support sealing and avoids any
> connection to user-visible mount-points. Thus, it's not subject to quotas
> on mounted file-systems, but can be used like malloc()'ed memory, but
> with a file-descriptor to it.
>
> memfd_create() does not create a front-FD, but instead returns the raw
> shmem file, so calls like ftruncate() can be used. Also calls like fstat()
> will return proper information and mark the file as regular file. If you
> want sealing, you can specify MFD_ALLOW_SEALING. Otherwise, sealing is not
> support (like on all other regular files).
>
> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
> subject to quotas and alike.
>
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
> ---

<cut>

> +++ b/include/linux/syscalls.h
> @@ -802,6 +802,7 @@ asmlinkage long sys_timerfd_settime(int ufd, int flags,
>  asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
>  asmlinkage long sys_eventfd(unsigned int count);
>  asmlinkage long sys_eventfd2(unsigned int count, int flags);
> +asmlinkage long sys_memfd_create(const char *uname_ptr, u64 size, u64 flags);

Is it right to use u64 here? I think arguments sould be 'loff_t' and 'int'.

>  asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
>  asmlinkage long sys_old_readdir(unsigned int, struct old_linux_dirent __user *, unsigned int);
>  asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
