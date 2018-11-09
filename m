Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id F23836B074A
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 19:28:54 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id u5so1603262ota.1
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 16:28:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4-v6sor4844649oia.159.2018.11.09.16.28.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 16:28:53 -0800 (PST)
MIME-Version: 1.0
References: <20181108041537.39694-1-joel@joelfernandes.org>
 <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com> <A7EC46BC-441A-4A06-9E2F-A26DA88B5320@amacapital.net>
In-Reply-To: <A7EC46BC-441A-4A06-9E2F-A26DA88B5320@amacapital.net>
From: Michael Tirado <mtirado418@gmail.com>
Date: Fri, 9 Nov 2018 20:02:14 +0000
Message-ID: <CAMkWEXOLJ=ymbVjQfA2MD8XA7Y9Lu3ByJYUY-JvpnYKJ5gkY1w@mail.gmail.com>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Jann Horn <jannh@google.com>, joel@joelfernandes.org, LKML <linux-kernel@vger.kernel.org>, jreck@google.com, john.stultz@linaro.org, tkjos@google.com, gregkh@linuxfoundation.org, hch@infradead.org, viro@zeniv.linux.org.uk, Andrew Morton <akpm@linux-foundation.org>, dancol@google.com, bfields@fieldses.org, jlayton@kernel.org, khalid.aziz@oracle.com, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, marcandre.lureau@redhat.com, mike.kravetz@oracle.com, minchan@kernel.org, shuah@kernel.org, valdis.kletnieks@vt.edu, hughd@google.com, linux-api@vger.kernel.org

On Fri, Nov 9, 2018 at 9:41 PM Andy Lutomirski <luto@amacapital.net> wrote:
>
>
>
> > On Nov 9, 2018, at 1:06 PM, Jann Horn <jannh@google.com> wrote:
> >
> > +linux-api for API addition
> > +hughd as FYI since this is somewhat related to mm/shmem
> >
> > On Fri, Nov 9, 2018 at 9:46 PM Joel Fernandes (Google)
> > <joel@joelfernandes.org> wrote:
> >> Android uses ashmem for sharing memory regions. We are looking forward
> >> to migrating all usecases of ashmem to memfd so that we can possibly
> >> remove the ashmem driver in the future from staging while also
> >> benefiting from using memfd and contributing to it. Note staging drivers
> >> are also not ABI and generally can be removed at anytime.
> >>
> >> One of the main usecases Android has is the ability to create a region
> >> and mmap it as writeable, then add protection against making any
> >> "future" writes while keeping the existing already mmap'ed
> >> writeable-region active.  This allows us to implement a usecase where
> >> receivers of the shared memory buffer can get a read-only view, while
> >> the sender continues to write to the buffer.

Oh I remember trying this years ago with a new seal, F_SEAL_WRITE_PEER,
or something like that.

> >
> > So you're fiddling around with the file, but not the inode? How are
> > you preventing code like the following from re-opening the file as
> > writable?
> >
> > $ cat memfd.c
> > #define _GNU_SOURCE
> > #include <unistd.h>
> > #include <sys/syscall.h>
> > #include <printf.h>
> > #include <fcntl.h>
> > #include <err.h>
> > #include <stdio.h>
> >
> > int main(void) {
> >  int fd = syscall(__NR_memfd_create, "testfd", 0);
> >  if (fd == -1) err(1, "memfd");
> >  char path[100];
> >  sprintf(path, "/proc/self/fd/%d", fd);
> >  int fd2 = open(path, O_RDWR);
> >  if (fd2 == -1) err(1, "reopen");
> >  printf("reopen successful: %d\n", fd2);
> > }
> > $ gcc -o memfd memfd.c
> > $ ./memfd
> > reopen successful: 4
> > $
> >

The race condition between memfd_create and applying seals in fcntl?
I think it would be possible to block new write mappings from peer processes if
there is a new memfd_create api that accepts seals. Allowing caller to
set a seal
like the one I proposed years ago, though in a race-free manner. Then
also consider
how to properly handle blocking inherited +W mapping through
clone/fork. Maybe I'm
forgetting some other pitfalls?



> > That aside: I wonder whether a better API would be something that
> > allows you to create a new readonly file descriptor, instead of
> > fiddling with the writability of an existing fd.
>
> Every now and then I try to write a patch to prevent using proc to reopen a file with greater permission than the original open.
>
> I like your idea to have a clean way to reopen a a memfd with reduced permissions. But I would make it a syscall instead and maybe make it only work for memfd at first.  And the proc issue would need to be fixed, too.

IMO the best solution would handle the issue at memfd creation time by
removing the race condition.
