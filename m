Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A94F8E003A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 20:36:12 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j5-v6so225731oiw.13
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 17:36:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 97-v6sor10012059ota.202.2018.09.17.17.36.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Sep 2018 17:36:10 -0700 (PDT)
MIME-Version: 1.0
References: <CAG48ez17Of=dnymzm8GAN_CNG1okMg1KTeMtBQhXGP2dyB5uJw@mail.gmail.com>
 <alpine.LSU.2.11.1809171628190.2225@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1809171628190.2225@eggly.anvils>
From: Jann Horn <jannh@google.com>
Date: Tue, 18 Sep 2018 02:35:43 +0200
Message-ID: <CAG48ez1hk5evqQpyvticPzLFOcESfo2NoWnqrLZk6N4PXwdsOw@mail.gmail.com>
Subject: Re: [BUG] mm: direct I/O (using GUP) can write to COW anonymous pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, sqazi@google.com, "Michael S. Tsirkin" <mst@redhat.com>, jack@suse.cz, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Sep 18, 2018 at 2:05 AM Hugh Dickins <hughd@google.com> wrote:
>
> Hi Jann,
>
> On Mon, 17 Sep 2018, Jann Horn wrote:
>
> > [I'm not sure who the best people to ask about this are, I hope the
> > recipient list resembles something reasonable...]
> >
> > I have noticed that the dup_mmap() logic on fork() doesn't handle
> > pages with active direct I/O properly: dup_mmap() seems to assume that
> > making the PTE referencing a page readonly will always prevent future
> > writes to the page, but if the kernel has acquired a direct reference
> > to the page before (e.g. via get_user_pages_fast()), writes can still
> > happen that way.
> >
> > The worst-case effect of this - as far as I can tell - is that when a
> > multithreaded process forks while one thread is in the middle of
> > sys_read() on a file that uses direct I/O with get_user_pages_fast(),
> > the read data can become visible in the child while the parent's
> > buffer stays uninitialized if the parent writes to a relevant page
> > post-fork before either the I/O completes or the child writes to it.
>
> Yes: you're understandably more worried by the one seeing the other's
> data;

Actually, I was mostly just trying to find a scenario in which the
parent doesn't get the data it's asking for, and this is the simplest
I could come up with. :)

I was also vaguely worried about whether some other part of the mm
subsystem might assume that COW pages are immutable, but I haven't
found anything like that so far, so that might've been unwarranted
paranoia.

> we've tended in the past to be more worried about the one getting
> corruption, and the other not seeing the data it asked for (and usually
> in the context of RDMA, rather than filesystem direct I/O).
>
> I've added some Cc's: I might be misremembering, but I think both
> Andrea and Konstantin have offered approaches to this in the past,
> and I believe Salman is taking a look at it currently.
>
> But my own interest ended when Michael added MADV_DONTFORK: beyond
> that, we've rated it a "Patient: It hurts when I do this. Doctor:
> Don't do that then" - more complexity and overhead to solve, than
> we have had appetite to get into.

Makes sense, I guess.

I wonder whether there's a concise way to express this in the fork.2
manpage, or something like that. Maybe I'll take a stab at writing
something. The biggest issue I see with documenting this edgecase is
that, as an application developer, if you don't know whether some file
might be coming from a FUSE filesystem that has opted out of using the
disk cache, the "don't do that" essentially becomes "don't read() into
heap buffers while fork()ing in another thread", since with FUSE,
direct I/O can happen even if you don't open files as O_DIRECT as long
as the filesystem requests direct I/O, and get_user_pages_fast() will
AFAIU be used for non-page-aligned buffers, meaning that an adjacent
heap memory access could trigger CoW page duplication. But then, FUSE
filesystems that opt out of the disk cache are probably so rare that
it's not a concern in practice...

> But not a shiningly satisfactory
> situation, I'll agree.
>
> Hugh
>
> >
> > Reproducer code:
> >
> > =3D=3D=3D=3D=3D=3D START hello.c =3D=3D=3D=3D=3D=3D
> > #define FUSE_USE_VERSION 26
> >
> > #include <fuse.h>
> > #include <stdio.h>
> > #include <string.h>
> > #include <errno.h>
> > #include <fcntl.h>
> > #include <unistd.h>
> > #include <err.h>
> > #include <sys/uio.h>
> >
> > static const char *hello_path =3D "/hello";
> >
> > static int hello_getattr(const char *path, struct stat *stbuf)
> > {
> >         int res =3D 0;
> >         memset(stbuf, 0, sizeof(struct stat));
> >         if (strcmp(path, "/") =3D=3D 0) {
> >                 stbuf->st_mode =3D S_IFDIR | 0755;
> >                 stbuf->st_nlink =3D 2;
> >         } else if (strcmp(path, hello_path) =3D=3D 0) {
> >                 stbuf->st_mode =3D S_IFREG | 0666;
> >                 stbuf->st_nlink =3D 1;
> >                 stbuf->st_size =3D 0x1000;
> >                 stbuf->st_blocks =3D 0;
> >         } else
> >                 res =3D -ENOENT;
> >         return res;
> > }
> >
> > static int hello_readdir(const char *path, void *buf, fuse_fill_dir_t
> > filler, off_t offset, struct fuse_file_info *fi) {
> >         filler(buf, ".", NULL, 0);
> >         filler(buf, "..", NULL, 0);
> >         filler(buf, hello_path + 1, NULL, 0);
> >         return 0;
> > }
> >
> > static int hello_open(const char *path, struct fuse_file_info *fi) {
> >         return 0;
> > }
> >
> > static int hello_read(const char *path, char *buf, size_t size, off_t
> > offset, struct fuse_file_info *fi) {
> >         sleep(3);
> >         size_t len =3D 0x1000;
> >         if (offset < len) {
> >                 if (offset + size > len)
> >                         size =3D len - offset;
> >                 memset(buf, 0, size);
> >         } else
> >                 size =3D 0;
> >         return size;
> > }
> >
> > static int hello_write(const char *path, const char *buf, size_t size,
> > off_t offset, struct fuse_file_info *fi) {
> >         while(1) pause();
> > }
> >
> > static struct fuse_operations hello_oper =3D {
> >         .getattr        =3D hello_getattr,
> >         .readdir        =3D hello_readdir,
> >         .open           =3D hello_open,
> >         .read           =3D hello_read,
> >         .write          =3D hello_write,
> > };
> >
> > int main(int argc, char *argv[]) {
> >         return fuse_main(argc, argv, &hello_oper, NULL);
> > }
> > =3D=3D=3D=3D=3D=3D END hello.c =3D=3D=3D=3D=3D=3D
> >
> > =3D=3D=3D=3D=3D=3D START simple_mmap.c =3D=3D=3D=3D=3D=3D
> > #define _GNU_SOURCE
> > #include <pthread.h>
> > #include <sys/mman.h>
> > #include <err.h>
> > #include <unistd.h>
> > #include <fcntl.h>
> > #include <stdio.h>
> > #include <signal.h>
> > #include <sys/prctl.h>
> > #include <sys/wait.h>
> >
> > __attribute__((aligned(0x1000))) char data_buffer_[0x10000];
> > #define data_buffer (data_buffer_ + 0x8000)
> >
> > void *fuse_thread(void *dummy) {
> >         /* step 2: start direct I/O on data_buffer */
> >         int fuse_fd =3D open("mount/hello", O_RDWR);
> >         if (fuse_fd =3D=3D -1)
> >                 err(1, "unable to open FUSE fd");
> >         printf("char in parent (before): %hhd\n", data_buffer[0]);
> >         int res =3D read(fuse_fd, data_buffer, 0x1000);
> >         /* step 6: read completes, show post-read state */
> >         printf("fuse read result: %d\n", res);
> >         printf("char in parent (after): %hhd\n", data_buffer[0]);
> > }
> >
> > int main(void) {
> >         /* step 1: make data_buffer dirty */
> >         data_buffer[0] =3D 1;
> >
> >         pthread_t thread;
> >         if (pthread_create(&thread, NULL, fuse_thread, NULL))
> >                 errx(1, "pthread_create");
> >
> >         sleep(1);
> >         /* step 3: fork a child */
> >         pid_t child =3D fork();
> >         if (child =3D=3D -1)
> >                 err(1, "fork");
> >         if (child =3D=3D 0) {
> >                 prctl(PR_SET_PDEATHSIG, SIGKILL);
> >                 sleep(1);
> >
> >                 /* step 5: show pre-read state in the child */
> >                 printf("char in child (before): %hhd\n", data_buffer[0]=
);
> >                 sleep(3);
> >                 /* step 7: read is complete, show post-read state in ch=
ild */
> >                 printf("char in child (after): %hhd\n", data_buffer[0])=
;
> >                 return 0;
> >         }
> >
> >         /* step 4: de-CoW data_buffer in the parent */
> >         data_buffer[0x800] =3D 2;
> >
> >         int status;
> >         if (wait(&status) !=3D child)
> >                 err(1, "wait");
> > }
> > =3D=3D=3D=3D=3D=3D END simple_mmap.c =3D=3D=3D=3D=3D=3D
> >
> > Repro steps:
> >
> > In one terminal:
> > $ mkdir mount
> > $ gcc -o hello hello.c -Wall -std=3Dgnu99 `pkg-config fuse --cflags --l=
ibs`
> > hello.c: In function =E2=80=98hello_write=E2=80=99:
> > hello.c:67:1: warning: no return statement in function returning
> > non-void [-Wreturn-type]
> >  }
> >  ^
> > $ ./hello -d -o direct_io mount
> > FUSE library version: 2.9.7
> > [...]
> >
> > In a second terminal:
> > $ gcc -pthread -o simple_mmap simple_mmap.c
> > $ ./simple_mmap
> > char in parent (before): 1
> > char in child (before): 1
> > fuse read result: 4096
> > char in parent (after): 1
> > char in child (after): 0
> >
> > I have tested that this still works on 4.19.0-rc3+.
> >
> > As far as I can tell, the fix would be to immediately copy pages with
> > `refcount - mapcount > N` in dup_mmap(), or something like that?
> >
