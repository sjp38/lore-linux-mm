Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA3F6B000D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 13:27:18 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id a206-v6so4003211oib.7
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 10:27:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c72-v6sor11355418oig.141.2018.10.10.10.27.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 10:27:17 -0700 (PDT)
MIME-Version: 1.0
References: <20181010152736.99475-1-jannh@google.com> <20181010171944.GJ5873@dhcp22.suse.cz>
In-Reply-To: <20181010171944.GJ5873@dhcp22.suse.cz>
From: Jann Horn <jannh@google.com>
Date: Wed, 10 Oct 2018 19:26:50 +0200
Message-ID: <CAG48ez04KK62doMwsTVN4nN8y_wmv7hn+4my2jk5VXKL0wP7Lg@mail.gmail.com>
Subject: Re: [PATCH] mm: don't clobber partially overlapping VMA with MAP_FIXED_NOREPLACE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, abdhalee@linux.vnet.ibm.com, joel@jms.id.au, Kees Cook <keescook@chromium.org>, jasone@google.com, davidtgoldblatt@gmail.com, trasz@freebsd.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Daniel Micay <danielmicay@gmail.com>, kernel list <linux-kernel@vger.kernel.org>

On Wed, Oct 10, 2018 at 7:19 PM Michal Hocko <mhocko@suse.com> wrote:
> On Wed 10-10-18 17:27:36, Jann Horn wrote:
> > Daniel Micay reports that attempting to use MAP_FIXED_NOREPLACE in an
> > application causes that application to randomly crash. The existing check
> > for handling MAP_FIXED_NOREPLACE looks up the first VMA that either
> > overlaps or follows the requested region, and then bails out if that VMA
> > overlaps *the start* of the requested region. It does not bail out if the
> > VMA only overlaps another part of the requested region.
>
> I do not understand. Could you give me an example?

Sure.

=======
user@debian:~$ cat mmap_fixed_simple.c
#include <sys/mman.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#ifndef MAP_FIXED_NOREPLACE
#define MAP_FIXED_NOREPLACE 0x100000
#endif

int main(void) {
  char *p;

  errno = 0;
  p = mmap((void*)0x10001000, 0x4000, PROT_NONE,
MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED_NOREPLACE, -1, 0);
  printf("p1=%p err=%m\n", p);

  errno = 0;
  p = mmap((void*)0x10000000, 0x2000, PROT_READ,
MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED_NOREPLACE, -1, 0);
  printf("p2=%p err=%m\n", p);

  char cmd[100];
  sprintf(cmd, "cat /proc/%d/maps", getpid());
  system(cmd);

  return 0;
}
user@debian:~$ gcc -o mmap_fixed_simple mmap_fixed_simple.c
user@debian:~$ ./mmap_fixed_simple
p1=0x10001000 err=Success
p2=0x10000000 err=Success
10000000-10002000 r--p 00000000 00:00 0
10002000-10005000 ---p 00000000 00:00 0
564a9a06f000-564a9a070000 r-xp 00000000 fe:01 264004
  /home/user/mmap_fixed_simple
564a9a26f000-564a9a270000 r--p 00000000 fe:01 264004
  /home/user/mmap_fixed_simple
564a9a270000-564a9a271000 rw-p 00001000 fe:01 264004
  /home/user/mmap_fixed_simple
564a9a54a000-564a9a56b000 rw-p 00000000 00:00 0                          [heap]
7f8eba447000-7f8eba5dc000 r-xp 00000000 fe:01 405885
  /lib/x86_64-linux-gnu/libc-2.24.so
7f8eba5dc000-7f8eba7dc000 ---p 00195000 fe:01 405885
  /lib/x86_64-linux-gnu/libc-2.24.so
7f8eba7dc000-7f8eba7e0000 r--p 00195000 fe:01 405885
  /lib/x86_64-linux-gnu/libc-2.24.so
7f8eba7e0000-7f8eba7e2000 rw-p 00199000 fe:01 405885
  /lib/x86_64-linux-gnu/libc-2.24.so
7f8eba7e2000-7f8eba7e6000 rw-p 00000000 00:00 0
7f8eba7e6000-7f8eba809000 r-xp 00000000 fe:01 405876
  /lib/x86_64-linux-gnu/ld-2.24.so
7f8eba9e9000-7f8eba9eb000 rw-p 00000000 00:00 0
7f8ebaa06000-7f8ebaa09000 rw-p 00000000 00:00 0
7f8ebaa09000-7f8ebaa0a000 r--p 00023000 fe:01 405876
  /lib/x86_64-linux-gnu/ld-2.24.so
7f8ebaa0a000-7f8ebaa0b000 rw-p 00024000 fe:01 405876
  /lib/x86_64-linux-gnu/ld-2.24.so
7f8ebaa0b000-7f8ebaa0c000 rw-p 00000000 00:00 0
7ffcc99fa000-7ffcc9a1b000 rw-p 00000000 00:00 0                          [stack]
7ffcc9b44000-7ffcc9b47000 r--p 00000000 00:00 0                          [vvar]
7ffcc9b47000-7ffcc9b49000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0
  [vsyscall]
user@debian:~$ uname -a
Linux debian 4.19.0-rc6+ #181 SMP Wed Oct 3 23:43:42 CEST 2018 x86_64 GNU/Linux
user@debian:~$
=======

As you can see, the first page of the mapping at 0x10001000 was clobbered.

> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 5f2b2b184c60..f7cd9cb966c0 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -1410,7 +1410,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
> >       if (flags & MAP_FIXED_NOREPLACE) {
> >               struct vm_area_struct *vma = find_vma(mm, addr);
> >
> > -             if (vma && vma->vm_start <= addr)
> > +             if (vma && vma->vm_start < addr + len)
>
> find_vma is documented to - Look up the first VMA which satisfies addr <
> vm_end, NULL if none.
> This means that the above check guanratees that
>         vm_start <= addr < vm_end
> so an overlap is guanrateed. Why should we care how much we overlap?

"an overlap is guaranteed"? I have no idea what you're trying to say.
