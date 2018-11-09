Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2D196B072B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 17:20:25 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id t136so654068vsc.12
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 14:20:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p12sor5004063vsb.53.2018.11.09.14.20.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 14:20:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
References: <20181108041537.39694-1-joel@joelfernandes.org> <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 9 Nov 2018 14:20:18 -0800
Message-ID: <CAKOZuesw1wG-YynWL7bVb+4BWtYp0Ei62vweWF+mqF1Ln-_2Tg@mail.gmail.com>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Joel Fernandes <joel@joelfernandes.org>, kernel list <linux-kernel@vger.kernel.org>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, valdis.kletnieks@vt.edu, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Nov 9, 2018 at 1:06 PM, Jann Horn <jannh@google.com> wrote:
>
> +linux-api for API addition
> +hughd as FYI since this is somewhat related to mm/shmem
>
> On Fri, Nov 9, 2018 at 9:46 PM Joel Fernandes (Google)
> <joel@joelfernandes.org> wrote:
> > Android uses ashmem for sharing memory regions. We are looking forward
> > to migrating all usecases of ashmem to memfd so that we can possibly
> > remove the ashmem driver in the future from staging while also
> > benefiting from using memfd and contributing to it. Note staging drivers
> > are also not ABI and generally can be removed at anytime.
> >
> > One of the main usecases Android has is the ability to create a region
> > and mmap it as writeable, then add protection against making any
> > "future" writes while keeping the existing already mmap'ed
> > writeable-region active.  This allows us to implement a usecase where
> > receivers of the shared memory buffer can get a read-only view, while
> > the sender continues to write to the buffer.
> > See CursorWindow documentation in Android for more details:
> > https://developer.android.com/reference/android/database/CursorWindow
> >
> > This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
> > To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE seal
> > which prevents any future mmap and write syscalls from succeeding while
> > keeping the existing mmap active.
>
> Please CC linux-api@ on patches like this. If you had done that, I
> might have criticized your v1 patch instead of your v3 patch...
>
> > The following program shows the seal
> > working in action:
> [...]
> > Cc: jreck@google.com
> > Cc: john.stultz@linaro.org
> > Cc: tkjos@google.com
> > Cc: gregkh@linuxfoundation.org
> > Cc: hch@infradead.org
> > Reviewed-by: John Stultz <john.stultz@linaro.org>
> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > ---
> [...]
> > diff --git a/mm/memfd.c b/mm/memfd.c
> > index 2bb5e257080e..5ba9804e9515 100644
> > --- a/mm/memfd.c
> > +++ b/mm/memfd.c
> [...]
> > @@ -219,6 +220,25 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
> >                 }
> >         }
> >
> > +       if ((seals & F_SEAL_FUTURE_WRITE) &&
> > +           !(*file_seals & F_SEAL_FUTURE_WRITE)) {
> > +               /*
> > +                * The FUTURE_WRITE seal also prevents growing and shrinking
> > +                * so we need them to be already set, or requested now.
> > +                */
> > +               int test_seals = (seals | *file_seals) &
> > +                                (F_SEAL_GROW | F_SEAL_SHRINK);
> > +
> > +               if (test_seals != (F_SEAL_GROW | F_SEAL_SHRINK)) {
> > +                       error = -EINVAL;
> > +                       goto unlock;
> > +               }
> > +
> > +               spin_lock(&file->f_lock);
> > +               file->f_mode &= ~(FMODE_WRITE | FMODE_PWRITE);
> > +               spin_unlock(&file->f_lock);
> > +       }
>
> So you're fiddling around with the file, but not the inode? How are
> you preventing code like the following from re-opening the file as
> writable?

Good catch. That's fixable too though, isn't it, just by fiddling with
the inode, right?

Another, more general fix might be to prevent /proc/pid/fd/N opens
from "upgrading" access modes. But that'd be a bigger ABI break.

> That aside: I wonder whether a better API would be something that
> allows you to create a new readonly file descriptor, instead of
> fiddling with the writability of an existing fd.

That doesn't work, unfortunately. The ashmem API we're replacing with
memfd requires file descriptor continuity. I also looked into opening
a new FD and dup2(2)ing atop the old one, but this approach doesn't
work in the case that the old FD has already leaked to some other
context (e.g., another dup, SCM_RIGHTS). See
https://developer.android.com/ndk/reference/group/memory. We can't
break ASharedMemory_setProt.
