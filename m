Received: by fk-out-0910.google.com with SMTP id 22so1887721fkq.6
        for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:16:51 -0700 (PDT)
Message-ID: <ab3f9b940804141716x755787f5h8e0122c394922a83@mail.gmail.com>
Date: Mon, 14 Apr 2008 17:16:50 -0700
From: "Tom May" <tom@tommay.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <20080402154910.9588.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	 <ab3f9b940804011635g2de833d0l44558f78a1cce1e5@mail.gmail.com>
	 <20080402154910.9588.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 2, 2008 at 12:31 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi Tom,
>
>  Thank you very useful comment.
>  that is very interesting.
>
>
>  > I tried it with a real-world program that, among other things, mmaps
>  > anonymous pages and touches them at a reasonable speed until it gets
>  > notified via /dev/mem_notify, releases most of them with
>  > madvise(MADV_DONTNEED), then loops to start the cycle again.
>  >
>  > What tends to happen is that I do indeed get notifications via
>  > /dev/mem_notify when the kernel would like to be swapping, at which
>  > point I free memory.  But the notifications come at a time when the
>  > kernel needs memory, and it gets the memory by discarding some Cached
>  > or Mapped memory (I can see these decreasing in /proc/meminfo with
>  > each notification).  With each mmap/notify/madvise cycle the Cached
>  > and Mapped memory gets smaller, until eventually while I'm touching
>  > pages the kernel can't find enough memory and will either invoke the
>  > OOM killer or return ENOMEM from syscalls.  This is precisely the
>  > situation I'm trying to avoid by using /dev/mem_notify.
>
>  Could you send your test program?
>  I can't reproduce that now, sorry.
>
>
>
>  > The criterion of "notify when the kernel would like to swap" feels
>  > correct, but in addition I seem to need something like "notify when
>  > cached+mapped+free memory is getting low".
>
>  Hmmm,
>  I think this idea is only useful when userland process call
>  madvise(MADV_DONTNEED) periodically.
>
>  but I hope improve my patch and solve your problem.
>  if you don' mind, please help my testing ;)

Here's a test program that allocates memory and frees on notification.
 It takes an argument which is the number of pages to use; use a
number considerably higher than the amount of memory in the system.
I'm running this on a system without swap.  Each time it gets a
notification, it frees memory and writes out the /proc/meminfo
contents.  What I see is that Cached gradually decreases, then Mapped
decreases, and eventually the kernel invokes the oom killer.  It may
be necessary to tune some of the constants that control the allocation
and free rates and latency; these values work for my system.

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <poll.h>
#include <sched.h>
#include <time.h>

#define PAGESIZE 4096

/* How many pages we've mmap'd. */
static int pages;

/* Pointer to mmap'd memory used as a circular buffer.  One thread
   touches pages, another thread releases them on notification. */
static char *p;

/* How many pages to touch each 5ms.  This makes at most 2000
   pages/sec. */
#define TOUCH_CHUNK 10

/* How many pages to free when we're notified.  With a 100ms FREE_DELAY,
   we can free ~9110 pages/sec, or perhaps only 5*911 = 4555 pages/sec if we're
   notified only 5 times/sec. */
#define FREE_CHUNK 911

/* Delay in milliseconds before freeing pages, to simulate latency while finding
   pages to free. */
#define FREE_DELAY 100

static void touch(void);
static int release(void *arg);
static void release_pages(void);
static void show_meminfo(void);

/* Stack for the release thread. */
static char stack[8192];

int
main (int argc, char **argv)
{
    pages = atoi(argv[1]);
    p = mmap(NULL, pages * PAGESIZE, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE, 0, 0);
    if (p == MAP_FAILED) {
        perror("mmap");
        exit(1);
    }

    if (clone(release, stack + sizeof(stack) - 4,
              CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_THREAD,
              NULL) == -1) {
        perror("clone failed");
        exit(1);
    }

    touch();
}

static void
touch (void)
{
    int page = 0;

    while (1) {
        int i;
        struct timespec t;
        for (i = 0; i < TOUCH_CHUNK; i++) {
            p[page * PAGESIZE] = 1;
            if (++page >= pages) {
                page = 0;
            }
        }

        t.tv_sec = 0;
        t.tv_nsec = 5000000;
        if (nanosleep(&t, NULL) == -1) {
            perror("nanosleep");
        }
    }
}

static int
release (void *arg)
{
    int fd = open("/dev/mem_notify", O_RDONLY);
    if (fd == -1) {
        perror("open(/dev/mem_notify)");
        exit(1);
    }

    while (1) {
        struct pollfd pfd;
        int nfds;

        pfd.fd = fd;
        pfd.events = POLLIN;

        nfds = poll(&pfd, 1, -1);
        if (nfds == -1) {
            perror("poll");
            exit(1);
        }
        if (nfds == 1) {
            struct timespec t;
            t.tv_sec = 0;
            t.tv_nsec = FREE_DELAY * 1000000;
            if (nanosleep(&t, NULL) == -1) {
                perror("nanosleep");
            }
            release_pages();
            printf("time: %d\n", time(NULL));
            show_meminfo();
        }
    }
}

static void
release_pages (void)
{
    /* Index of the next page to free. */
    static int page = 0;
    int i;

    /* Release FREE_CHUNK pages. */

    for (i = 0; i < FREE_CHUNK; i++) {
        int r = madvise(p + page*PAGESIZE, PAGESIZE, MADV_DONTNEED);
        if (r == -1) {
            perror("madvise");
            exit(1);
        }
        if (++page >= pages) {
            page = 0;
        }
    }
}

static void
show_meminfo (void)
{
    char buffer[2000];
    int fd;
    ssize_t n;

    fd = open("/proc/meminfo", O_RDONLY);
    if (fd == -1) {
        perror("open(/proc/meminfo)");
        exit(1);
    }

    n = read(fd, buffer, sizeof(buffer));
    if (n == -1) {
        perror("read(/proc/meminfo)");
        exit(1);
    }

    n = write(1, buffer, n);
    if (n == -1) {
        perror("write(stdout)");
        exit(1);
    }

    if (close(fd) == -1) {
        perror("close(/proc/meminfo)");
        exit(1);
    }
}

.tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
