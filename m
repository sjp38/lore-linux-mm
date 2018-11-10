Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1371A6B0796
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 12:11:03 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id c15-v6so3625842pls.15
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 09:11:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y64sor860975pgd.38.2018.11.10.09.11.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 09:11:01 -0800 (PST)
Date: Sat, 10 Nov 2018 09:10:58 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to
 memfd
Message-ID: <20181110171058.GA242356@google.com>
References: <20181108041537.39694-1-joel@joelfernandes.org>
 <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
 <CAG48ez0kQ4d566bXTFOYANDgii-stL-Qj-oyaBzvfxdV=PU-7g@mail.gmail.com>
 <20181110032005.GA22238@google.com>
 <CAKOZuethC7+YrRyyGciUCfhSSa9cCcAFJ8g_qEw9uh3TBbyOcg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuethC7+YrRyyGciUCfhSSa9cCcAFJ8g_qEw9uh3TBbyOcg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: Jann Horn <jannh@google.com>, kernel list <linux-kernel@vger.kernel.org>, "jreck@google.com" <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, "jlayton@kernel.org" <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, "Lei.Yang@windriver.com" <Lei.Yang@windriver.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "marcandre.lureau@redhat.com" <marcandre.lureau@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, "minchan@kernel.org" <minchan@kernel.org>, "shuah@kernel.org" <shuah@kernel.org>, "valdis.kletnieks@vt.edu" <valdis.kletnieks@vt.edu>, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

On Sat, Nov 10, 2018 at 04:26:46AM -0800, Daniel Colascione wrote:
> On Friday, November 9, 2018, Joel Fernandes <joel@joelfernandes.org> wrote:
> 
> > On Fri, Nov 09, 2018 at 10:19:03PM +0100, Jann Horn wrote:
> > > On Fri, Nov 9, 2018 at 10:06 PM Jann Horn <jannh@google.com> wrote:
> > > > On Fri, Nov 9, 2018 at 9:46 PM Joel Fernandes (Google)
> > > > <joel@joelfernandes.org> wrote:
> > > > > Android uses ashmem for sharing memory regions. We are looking
> > forward
> > > > > to migrating all usecases of ashmem to memfd so that we can possibly
> > > > > remove the ashmem driver in the future from staging while also
> > > > > benefiting from using memfd and contributing to it. Note staging
> > drivers
> > > > > are also not ABI and generally can be removed at anytime.
> > > > >
> > > > > One of the main usecases Android has is the ability to create a
> > region
> > > > > and mmap it as writeable, then add protection against making any
> > > > > "future" writes while keeping the existing already mmap'ed
> > > > > writeable-region active.  This allows us to implement a usecase where
> > > > > receivers of the shared memory buffer can get a read-only view, while
> > > > > the sender continues to write to the buffer.
> > > > > See CursorWindow documentation in Android for more details:
> > > > > https://developer.android.com/reference/android/database/
> > CursorWindow
> > > > >
> > > > > This usecase cannot be implemented with the existing F_SEAL_WRITE
> > seal.
> > > > > To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE
> > seal
> > > > > which prevents any future mmap and write syscalls from succeeding
> > while
> > > > > keeping the existing mmap active.
> > > >
> > > > Please CC linux-api@ on patches like this. If you had done that, I
> > > > might have criticized your v1 patch instead of your v3 patch...
> > > >
> > > > > The following program shows the seal
> > > > > working in action:
> > > > [...]
> > > > > Cc: jreck@google.com
> > > > > Cc: john.stultz@linaro.org
> > > > > Cc: tkjos@google.com
> > > > > Cc: gregkh@linuxfoundation.org
> > > > > Cc: hch@infradead.org
> > > > > Reviewed-by: John Stultz <john.stultz@linaro.org>
> > > > > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > > > > ---
> > > > [...]
> > > > > diff --git a/mm/memfd.c b/mm/memfd.c
> > > > > index 2bb5e257080e..5ba9804e9515 100644
> > > > > --- a/mm/memfd.c
> > > > > +++ b/mm/memfd.c
> > > > [...]
> > > > > @@ -219,6 +220,25 @@ static int memfd_add_seals(struct file *file,
> > unsigned int seals)
> > > > >                 }
> > > > >         }
> > > > >
> > > > > +       if ((seals & F_SEAL_FUTURE_WRITE) &&
> > > > > +           !(*file_seals & F_SEAL_FUTURE_WRITE)) {
> > > > > +               /*
> > > > > +                * The FUTURE_WRITE seal also prevents growing and
> > shrinking
> > > > > +                * so we need them to be already set, or requested
> > now.
> > > > > +                */
> > > > > +               int test_seals = (seals | *file_seals) &
> > > > > +                                (F_SEAL_GROW | F_SEAL_SHRINK);
> > > > > +
> > > > > +               if (test_seals != (F_SEAL_GROW | F_SEAL_SHRINK)) {
> > > > > +                       error = -EINVAL;
> > > > > +                       goto unlock;
> > > > > +               }
> > > > > +
> > > > > +               spin_lock(&file->f_lock);
> > > > > +               file->f_mode &= ~(FMODE_WRITE | FMODE_PWRITE);
> > > > > +               spin_unlock(&file->f_lock);
> > > > > +       }
> > > >
> > > > So you're fiddling around with the file, but not the inode? How are
> > > > you preventing code like the following from re-opening the file as
> > > > writable?
> > > >
> > > > $ cat memfd.c
> > > > #define _GNU_SOURCE
> > > > #include <unistd.h>
> > > > #include <sys/syscall.h>
> > > > #include <printf.h>
> > > > #include <fcntl.h>
> > > > #include <err.h>
> > > > #include <stdio.h>
> > > >
> > > > int main(void) {
> > > >   int fd = syscall(__NR_memfd_create, "testfd", 0);
> > > >   if (fd == -1) err(1, "memfd");
> > > >   char path[100];
> > > >   sprintf(path, "/proc/self/fd/%d", fd);
> > > >   int fd2 = open(path, O_RDWR);
> > > >   if (fd2 == -1) err(1, "reopen");
> > > >   printf("reopen successful: %d\n", fd2);
> > > > }
> > > > $ gcc -o memfd memfd.c
> > > > $ ./memfd
> > > > reopen successful: 4
> > > > $
> > > >
> > > > That aside: I wonder whether a better API would be something that
> > > > allows you to create a new readonly file descriptor, instead of
> > > > fiddling with the writability of an existing fd.
> > >
> > > My favorite approach would be to forbid open() on memfds, hope that
> > > nobody notices the tiny API break, and then add an ioctl for "reopen
> > > this memfd with reduced permissions" - but that's just my personal
> > > opinion.
> >
> > I did something along these lines and it fixes the issue, but I forbid open
> > of memfd only when the F_SEAL_FUTURE_WRITE seal is in place. So then its
> > not
> > an ABI break because this is a brand new seal. That seems the least
> > intrusive
> > solution and it works. Do you mind testing it and I'll add your and
> > Tested-by
> > to the new fix? The patch is based on top of this series.
> >
> 
> Please don't forbid reopens entirely. You're taking a feature that works
> generally (reopens) and breaking it in one specific case (memfd write
> sealed files). The open modes are available in .open in the struct file:
> you can deny *only* opens for write instead of denying reopens generally.

Yes, as we discussed over chat already, I will implement it that way.

Also lets continue to discuss Andy's concerns he raised on the other thread.

thanks,

 - Joel
