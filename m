Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3D8D6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:15:22 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 190so28150412pgh.16
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 22:15:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r59sor7518936plb.9.2017.11.26.22.15.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 Nov 2017 22:15:21 -0800 (PST)
Date: Sun, 26 Nov 2017 22:15:17 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: KASAN: use-after-free Read in handle_userfault
Message-ID: <20171127061517.GA26341@zzz.localdomain>
References: <001a114c9224e34a49055c842032@google.com>
 <CACT4Y+ZrYTNHDN71ZO1-vhFuCE=sRhfXeLbLom=9XodT7TJtog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZrYTNHDN71ZO1-vhFuCE=sRhfXeLbLom=9XodT7TJtog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <bot+998c483ca801a50e3ce5b63a845216588ada5e2a@syzkaller.appspotmail.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, syzkaller-bugs@googlegroups.com, Al Viro <viro@zeniv.linux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org

+Cc aarcange@redhat.com, xemul@parallels.com, linux-mm@kvack.org

On Fri, Oct 27, 2017 at 11:46:13AM +0200, Dmitry Vyukov wrote:
> On Fri, Oct 27, 2017 at 11:44 AM, syzbot
> <bot+998c483ca801a50e3ce5b63a845216588ada5e2a@syzkaller.appspotmail.com>
> wrote:
> > Hello,
> >
> > syzkaller hit the following crash on
> > a31cc455c512f3f1dd5f79cac8e29a7c8a617af8
> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> > compiler: gcc (GCC) 7.1.1 20170620
> > .config is attached
> > Raw console output is attached.
> > C reproducer is attached
> > syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> > for information about syzkaller reproducers
> 

Andrea or Pavel, can one of you please fix this?  It's another use-after-free
related to userfaultfd "fork events", and it can easily be triggered by an
unprivileged user.  It was reported a month ago already; the original report is
here: https://groups.google.com/forum/#!topic/syzkaller-bugs/sS99S-Z-9No.
(Please consider adding yourself and/or linux-mm to the MAINTAINERS file for
fs/userfaultfd.c, so that you are Cc'ed on userfaultfd bug reports.)  In
userfaultfd_event_wait_completion(), called from dup_fctx(), the kernel is
freeing the the new userfaultfd_ctx because the old one had all its fd's closed,
but actually the new one is still in use by the new mm_struct.

Also, I've simplified the C reproducer:

#include <linux/sched.h>
#include <linux/userfaultfd.h>
#include <pthread.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <unistd.h>

static int userfaultfd;
static void *page;

static void *close_fd_proc(void *arg)
{
        usleep(1000);
        close(userfaultfd);
        return NULL;
}

int main()
{
        pthread_t t;
        struct uffdio_api api = { 0 };
        struct uffdio_register reg = { 0 };

        page = mmap(NULL, 4096, PROT_READ|PROT_WRITE,
                    MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);

        userfaultfd = syscall(__NR_userfaultfd, 0);

        api.api = UFFDIO;
        api.features = UFFD_FEATURE_EVENT_FORK;
        ioctl(userfaultfd, UFFDIO_API, &api);

        reg.range.start = (__u64)page;
        reg.range.len = 4096;
        reg.mode = UFFDIO_REGISTER_MODE_MISSING;
        ioctl(userfaultfd, UFFDIO_REGISTER, &reg);

        pthread_create(&t, NULL, close_fd_proc, NULL);

        syscall(__NR_clone, CLONE_FILES, page, NULL, NULL, NULL);

        return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
