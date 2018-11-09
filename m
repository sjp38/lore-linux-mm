Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCBF6B0720
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 16:07:01 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id c43so1834517otd.20
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 13:07:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c125-v6sor4597505oia.151.2018.11.09.13.06.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 13:06:59 -0800 (PST)
MIME-Version: 1.0
References: <20181108041537.39694-1-joel@joelfernandes.org>
In-Reply-To: <20181108041537.39694-1-joel@joelfernandes.org>
From: Jann Horn <jannh@google.com>
Date: Fri, 9 Nov 2018 22:06:31 +0100
Message-ID: <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: joel@joelfernandes.org
Cc: kernel list <linux-kernel@vger.kernel.org>, jreck@google.com, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Daniel Colascione <dancol@google.com>, Bruce Fields <bfields@fieldses.org>, jlayton@kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, minchan@kernel.org, shuah@kernel.org, valdis.kletnieks@vt.edu, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

+linux-api for API addition
+hughd as FYI since this is somewhat related to mm/shmem

On Fri, Nov 9, 2018 at 9:46 PM Joel Fernandes (Google)
<joel@joelfernandes.org> wrote:
> Android uses ashmem for sharing memory regions. We are looking forward
> to migrating all usecases of ashmem to memfd so that we can possibly
> remove the ashmem driver in the future from staging while also
> benefiting from using memfd and contributing to it. Note staging drivers
> are also not ABI and generally can be removed at anytime.
>
> One of the main usecases Android has is the ability to create a region
> and mmap it as writeable, then add protection against making any
> "future" writes while keeping the existing already mmap'ed
> writeable-region active.  This allows us to implement a usecase where
> receivers of the shared memory buffer can get a read-only view, while
> the sender continues to write to the buffer.
> See CursorWindow documentation in Android for more details:
> https://developer.android.com/reference/android/database/CursorWindow
>
> This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
> To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE seal
> which prevents any future mmap and write syscalls from succeeding while
> keeping the existing mmap active.

Please CC linux-api@ on patches like this. If you had done that, I
might have criticized your v1 patch instead of your v3 patch...

> The following program shows the seal
> working in action:
[...]
> Cc: jreck@google.com
> Cc: john.stultz@linaro.org
> Cc: tkjos@google.com
> Cc: gregkh@linuxfoundation.org
> Cc: hch@infradead.org
> Reviewed-by: John Stultz <john.stultz@linaro.org>
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> ---
[...]
> diff --git a/mm/memfd.c b/mm/memfd.c
> index 2bb5e257080e..5ba9804e9515 100644
> --- a/mm/memfd.c
> +++ b/mm/memfd.c
[...]
> @@ -219,6 +220,25 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
>                 }
>         }
>
> +       if ((seals & F_SEAL_FUTURE_WRITE) &&
> +           !(*file_seals & F_SEAL_FUTURE_WRITE)) {
> +               /*
> +                * The FUTURE_WRITE seal also prevents growing and shrinking
> +                * so we need them to be already set, or requested now.
> +                */
> +               int test_seals = (seals | *file_seals) &
> +                                (F_SEAL_GROW | F_SEAL_SHRINK);
> +
> +               if (test_seals != (F_SEAL_GROW | F_SEAL_SHRINK)) {
> +                       error = -EINVAL;
> +                       goto unlock;
> +               }
> +
> +               spin_lock(&file->f_lock);
> +               file->f_mode &= ~(FMODE_WRITE | FMODE_PWRITE);
> +               spin_unlock(&file->f_lock);
> +       }

So you're fiddling around with the file, but not the inode? How are
you preventing code like the following from re-opening the file as
writable?

$ cat memfd.c
#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>
#include <printf.h>
#include <fcntl.h>
#include <err.h>
#include <stdio.h>

int main(void) {
  int fd = syscall(__NR_memfd_create, "testfd", 0);
  if (fd == -1) err(1, "memfd");
  char path[100];
  sprintf(path, "/proc/self/fd/%d", fd);
  int fd2 = open(path, O_RDWR);
  if (fd2 == -1) err(1, "reopen");
  printf("reopen successful: %d\n", fd2);
}
$ gcc -o memfd memfd.c
$ ./memfd
reopen successful: 4
$

That aside: I wonder whether a better API would be something that
allows you to create a new readonly file descriptor, instead of
fiddling with the writability of an existing fd.
