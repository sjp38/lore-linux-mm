Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 193056B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 13:06:16 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id hl10so1137498igb.2
        for <linux-mm@kvack.org>; Fri, 23 May 2014 10:06:15 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id ad4si4042584igd.13.2014.05.23.10.06.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 10:06:15 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id tp5so5345070ieb.11
        for <linux-mm@kvack.org>; Fri, 23 May 2014 10:06:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1405191920160.2970@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
	<1397587118-1214-4-git-send-email-dh.herrmann@gmail.com>
	<alpine.LSU.2.11.1405191920160.2970@eggly.anvils>
Date: Fri, 23 May 2014 19:06:14 +0200
Message-ID: <CANq1E4T9b4m0ByoBJBtx3KFNotVGsZzQn79_ApcDOnBy1F5yGg@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] selftests: add memfd_create() + sealing tests
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirsky <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

Hi

On Tue, May 20, 2014 at 4:22 AM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 15 Apr 2014, David Herrmann wrote:
>
>> Some basic tests to verify sealing on memfds works as expected and
>> guarantees the advertised semantics.
>
> Thanks for providing these.
>
> A few remarks below, and I should note one oddity.
>
> Curious about leaks (probably none, I was merely curious), I tried to
> run memfd_test 4096 times in succession, and never succeeded.  After
> many iterations, the 32-bit one tends to hang somewhere just before
> reaching the DONE, and the 64-bit one gave me some kind of assert
> error from a library.
>
> I expect there's some threading race around join_idle_thread():
> which I think you will sort out infinitely sooner than I would.
> No need to fix it right now: the test works well enough.

Ugh, I will look into that. Didn't see anything obvious so far.

>>
>> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
>> ---
>>  tools/testing/selftests/Makefile           |   1 +
>>  tools/testing/selftests/memfd/.gitignore   |   2 +
>>  tools/testing/selftests/memfd/Makefile     |  29 +
>>  tools/testing/selftests/memfd/memfd_test.c | 944 +++++++++++++++++++++++++++++
>>  4 files changed, 976 insertions(+)
>>  create mode 100644 tools/testing/selftests/memfd/.gitignore
>>  create mode 100644 tools/testing/selftests/memfd/Makefile
>>  create mode 100644 tools/testing/selftests/memfd/memfd_test.c
>>
>> diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
>> index 32487ed..c57325a 100644
>> --- a/tools/testing/selftests/Makefile
>> +++ b/tools/testing/selftests/Makefile
>> @@ -2,6 +2,7 @@ TARGETS = breakpoints
>>  TARGETS += cpu-hotplug
>>  TARGETS += efivarfs
>>  TARGETS += kcmp
>> +TARGETS += memfd
>>  TARGETS += memory-hotplug
>>  TARGETS += mqueue
>>  TARGETS += net
>> diff --git a/tools/testing/selftests/memfd/.gitignore b/tools/testing/selftests/memfd/.gitignore
>> new file mode 100644
>> index 0000000..bcc8ee2
>> --- /dev/null
>> +++ b/tools/testing/selftests/memfd/.gitignore
>> @@ -0,0 +1,2 @@
>> +memfd_test
>> +memfd-test-file
>> diff --git a/tools/testing/selftests/memfd/Makefile b/tools/testing/selftests/memfd/Makefile
>> new file mode 100644
>> index 0000000..36653b9
>> --- /dev/null
>> +++ b/tools/testing/selftests/memfd/Makefile
>> @@ -0,0 +1,29 @@
>> +uname_M := $(shell uname -m 2>/dev/null || echo not)
>> +ARCH ?= $(shell echo $(uname_M) | sed -e s/i.86/i386/)
>> +ifeq ($(ARCH),i386)
>> +     ARCH := X86
>> +endif
>> +ifeq ($(ARCH),x86_64)
>> +     ARCH := X86
>> +endif
>> +
>> +CFLAGS += -I../../../../arch/x86/include/generated/uapi/
>> +CFLAGS += -I../../../../arch/x86/include/uapi/
>> +CFLAGS += -I../../../../include/uapi/
>> +CFLAGS += -I../../../../include/
>> +
>> +all:
>> +ifeq ($(ARCH),X86)
>> +     gcc $(CFLAGS) memfd_test.c -o memfd_test
>> +else
>> +     echo "Not an x86 target, can't build memfd selftest"
>> +endif
>> +
>> +run_tests: all
>> +ifeq ($(ARCH),X86)
>> +     gcc $(CFLAGS) memfd_test.c -o memfd_test
>> +endif
>> +     @./memfd_test || echo "memfd_test: [FAIL]"
>> +
>> +clean:
>> +     $(RM) memfd_test
>> diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
>> new file mode 100644
>> index 0000000..3e105ea
>> --- /dev/null
>> +++ b/tools/testing/selftests/memfd/memfd_test.c
>> @@ -0,0 +1,944 @@
>> +#define _GNU_SOURCE
>> +#define __EXPORTED_HEADERS__
>> +
>> +#include <errno.h>
>> +#include <inttypes.h>
>> +#include <limits.h>
>> +#include <linux/falloc.h>
>> +#include <linux/fcntl.h>
>> +#include <linux/memfd.h>
>> +#include <sched.h>
>> +#include <stdio.h>
>> +#include <stdlib.h>
>> +#include <signal.h>
>> +#include <string.h>
>> +#include <sys/mman.h>
>> +#include <sys/stat.h>
>> +#include <sys/syscall.h>
>> +#include <unistd.h>
>> +
>> +#define MFD_DEF_SIZE 8192
>> +#define STACK_SIZE 65535
>> +
>> +static int sys_memfd_create(const char *name,
>> +                         __u64 size,
>> +                         __u64 flags)
>> +{
>> +     return syscall(__NR_memfd_create, name, size, flags);
>> +}
>> +
>> +static int mfd_assert_new(const char *name, __u64 sz, __u64 flags)
>> +{
>> +     int r;
>> +
>> +     r = sys_memfd_create(name, sz, flags);
>> +     if (r < 0) {
>> +             printf("memfd_create(\"%s\", %llu, %llu) failed: %m\n",
>> +                    name,
>> +                    (unsigned long long)sz,
>> +                    (unsigned long long)flags);
>> +             abort();
>> +     }
>> +
>> +     return r;
>> +}
>> +
>> +static void mfd_fail_new(const char *name, __u64 size, __u64 flags)
>> +{
>> +     int r;
>> +
>> +     r = sys_memfd_create(name, size, flags);
>> +     if (r >= 0) {
>> +             printf("memfd_create(\"%s\", %llu, %llu) succeeded, but failure expected\n",
>
> scripts/checkpatch.pl complains about line-length: please ignore it on this.
>
>> +                    name,
>> +                    (unsigned long long)size,
>> +                    (unsigned long long)flags);
>> +             close(r);
>> +             abort();
>> +     }
>> +}
>> +
>> +static __u64 mfd_assert_get_seals(int fd)
>> +{
>> +     long r;
>> +
>> +     r = fcntl(fd, F_GET_SEALS);
>> +     if (r < 0) {
>> +             printf("GET_SEALS(%d) failed: %m\n", fd);
>> +             abort();
>> +     }
>> +
>> +     return r;
>> +}
>> +
>> +static void mfd_fail_get_seals(int fd)
>> +{
>> +     long r;
>> +
>> +     r = fcntl(fd, F_GET_SEALS);
>> +     if (r >= 0) {
>> +             printf("GET_SEALS(%d) succeeded, but failure expected\n");
>> +             abort();
>> +     }
>> +}
>> +
>> +static void mfd_assert_has_seals(int fd, __u64 seals)
>> +{
>> +     __u64 s;
>> +
>> +     s = mfd_assert_get_seals(fd);
>> +     if (s != seals) {
>> +             printf("%llu != %llu = GET_SEALS(%d)\n",
>> +                    (unsigned long long)seals, (unsigned long long)s, fd);
>> +             abort();
>> +     }
>> +}
>> +
>> +static void mfd_assert_add_seals(int fd, __u64 seals)
>> +{
>> +     long r;
>> +     __u64 s;
>> +
>> +     s = mfd_assert_get_seals(fd);
>> +     r = fcntl(fd, F_ADD_SEALS, seals);
>> +     if (r < 0) {
>> +             printf("ADD_SEALS(%d, %llu -> %llu) failed: %m\n",
>> +                    fd, (unsigned long long)s, (unsigned long long)seals);
>> +             abort();
>> +     }
>> +}
>> +
>> +static void mfd_fail_add_seals(int fd, __u64 seals)
>> +{
>> +     long r;
>> +     __u64 s;
>> +
>> +     r = fcntl(fd, F_GET_SEALS);
>> +     if (r < 0)
>> +             s = 0;
>> +     else
>> +             s = r;
>> +
>> +     r = fcntl(fd, F_ADD_SEALS, seals);
>> +     if (r >= 0) {
>> +             printf("ADD_SEALS(%d, %llu -> %llu) didn't fail as expected\n",
>> +                    fd, (unsigned long long)s, (unsigned long long)seals);
>> +             abort();
>> +     }
>> +}
>> +
>> +static void mfd_assert_size(int fd, size_t size)
>> +{
>> +     struct stat st;
>> +     int r;
>> +
>> +     r = fstat(fd, &st);
>> +     if (r < 0) {
>> +             printf("fstat(%d) failed: %m\n", fd);
>> +             abort();
>> +     } else if (st.st_size != size) {
>> +             printf("wrong file size %lld, but expected %lld\n",
>> +                    (long long)st.st_size, (long long)size);
>> +             abort();
>> +     }
>> +}
>> +
>> +static int mfd_assert_dup(int fd)
>> +{
>> +     int r;
>> +
>> +     r = dup(fd);
>> +     if (r < 0) {
>> +             printf("dup(%d) failed: %m\n", fd);
>> +             abort();
>> +     }
>> +
>> +     return r;
>> +}
>> +
>> +static void *mfd_assert_mmap_shared(int fd)
>> +{
>> +     void *p;
>> +
>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_READ | PROT_WRITE,
>> +              MAP_SHARED,
>> +              fd,
>> +              0);
>> +     if (p == MAP_FAILED) {
>> +             printf("mmap() failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     return p;
>> +}
>> +
>> +static void *mfd_assert_mmap_private(int fd)
>> +{
>> +     void *p;
>> +
>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_READ,
>> +              MAP_PRIVATE,
>> +              fd,
>> +              0);
>> +     if (p == MAP_FAILED) {
>> +             printf("mmap() failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     return p;
>> +}
>> +
>> +static int mfd_assert_open(int fd, int flags, mode_t mode)
>> +{
>> +     char buf[512];
>> +     int r;
>> +
>> +     sprintf(buf, "/proc/self/fd/%d", fd);
>> +     r = open(buf, flags, mode);
>> +     if (r < 0) {
>> +             printf("open(%s) failed: %m\n", buf);
>> +             abort();
>> +     }
>> +
>> +     return r;
>> +}
>> +
>> +static void mfd_fail_open(int fd, int flags, mode_t mode)
>> +{
>> +     char buf[512];
>> +     int r;
>> +
>> +     sprintf(buf, "/proc/self/fd/%d", fd);
>> +     r = open(buf, flags, mode);
>> +     if (r >= 0) {
>> +             printf("open(%s) didn't fail as expected\n");
>> +             abort();
>> +     }
>> +}
>> +
>> +static void mfd_assert_read(int fd)
>> +{
>> +     char buf[16];
>> +     void *p;
>> +     ssize_t l;
>> +
>> +     l = read(fd, buf, sizeof(buf));
>> +     if (l != sizeof(buf)) {
>> +             printf("read() failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     /* verify PROT_READ *is* allowed */
>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_READ,
>> +              MAP_PRIVATE,
>> +              fd,
>> +              0);
>> +     if (p == MAP_FAILED) {
>> +             printf("mmap() failed: %m\n");
>> +             abort();
>> +     }
>> +     munmap(p, MFD_DEF_SIZE);
>> +
>> +     /* verify MAP_PRIVATE is *always* allowed (even writable) */
>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_READ | PROT_WRITE,
>> +              MAP_PRIVATE,
>> +              fd,
>> +              0);
>> +     if (p == MAP_FAILED) {
>> +             printf("mmap() failed: %m\n");
>> +             abort();
>> +     }
>> +     munmap(p, MFD_DEF_SIZE);
>> +}
>> +
>> +static void mfd_assert_write(int fd)
>> +{
>> +     ssize_t l;
>> +     void *p;
>> +     int r;
>> +
>> +     /* verify write() succeeds */
>> +     l = write(fd, "\0\0\0\0", 4);
>> +     if (l != 4) {
>> +             printf("write() failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     /* verify PROT_READ | PROT_WRITE is allowed */
>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_READ | PROT_WRITE,
>> +              MAP_SHARED,
>> +              fd,
>> +              0);
>> +     if (p == MAP_FAILED) {
>> +             printf("mmap() failed: %m\n");
>> +             abort();
>> +     }
>> +     *(char*)p = 0;
>
> scripts/checkpatch.pl complains about (char*): better calm it with (char *).
> Same on two other lines below.
>
>> +     munmap(p, MFD_DEF_SIZE);
>> +
>> +     /* verify PROT_WRITE is allowed */
>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_WRITE,
>> +              MAP_SHARED,
>> +              fd,
>> +              0);
>> +     if (p == MAP_FAILED) {
>> +             printf("mmap() failed: %m\n");
>> +             abort();
>> +     }
>> +     *(char*)p = 0;
>> +     munmap(p, MFD_DEF_SIZE);
>> +
>> +     /* verify PROT_READ with MAP_SHARED is allowed and a following
>> +      * mprotect(PROT_WRITE) allows writing */
>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_READ,
>> +              MAP_SHARED,
>> +              fd,
>> +              0);
>> +     if (p == MAP_FAILED) {
>> +             printf("mmap() failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     r = mprotect(p, MFD_DEF_SIZE, PROT_READ | PROT_WRITE);
>> +     if (r < 0) {
>> +             printf("mprotect() failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     *(char*)p = 0;
>> +     munmap(p, MFD_DEF_SIZE);
>> +
>> +     /* verify PUNCH_HOLE works */
>> +     r = fallocate(fd,
>> +                   FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
>> +                   0,
>> +                   MFD_DEF_SIZE);
>> +     if (r < 0) {
>> +             printf("fallocate(PUNCH_HOLE) failed: %m\n");
>> +             abort();
>> +     }
>> +}
>> +
>> +static void mfd_fail_write(int fd)
>> +{
>> +     ssize_t l;
>> +     void *p;
>> +     int r;
>> +
>> +     /* verify write() fails */
>> +     l = write(fd, "data", 4);
>> +     if (l != -EPERM) {
>> +             printf("expected EPERM on write(), but got %d: %m\n", (int)l);
>> +             abort();
>> +     }
>> +
>> +     /* verify PROT_READ | PROT_WRITE is not allowed */
>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_READ | PROT_WRITE,
>> +              MAP_SHARED,
>> +              fd,
>> +              0);
>> +     if (p != MAP_FAILED) {
>> +             printf("mmap() didn't fail as expected\n");
>> +             abort();
>> +     }
>> +
>> +     /* verify PROT_WRITE is not allowed */
>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_WRITE,
>> +              MAP_SHARED,
>> +              fd,
>> +              0);
>> +     if (p != MAP_FAILED) {
>> +             printf("mmap() didn't fail as expected\n");
>> +             abort();
>> +     }
>> +
>> +     /* verify PROT_READ with MAP_SHARED is not allowed */
>
> This is a particularly interesting case, checking PROT_READ,MAP_SHARED
> not allowed in mfd_fail_write().  It feels invidious to ask for more
> of a comment, in a test which you have been generous to provide at all.
> But it stopped me short for a while: more comment might help others too.
>
> The reason being (right?) that this fd was opened O_RDWR, so a
> MAP_SHARED mapping would permit a subsequent mprotect(,,PROT_WRITE),
> which sealing the file against writes must prevent.
>
> Your kernel checks rely on VM_SHARED and i_mmap_writable for this
> protection: which is fine, but an implementation detail which could
> be modified in future, if this case were ever to pose a difficulty.

Yes indeed, this is meant to catch VM_MAYWRITE. Currently, every
mmap(MAP_SHARED) on a writable FD allows mprotect(PROT_WRITE) later
on. I thought that's hard-coded ABI so I rely on it here. But I can
definitely add a comment mentioning VM_MAYWRITE.

Given that this test-case fails if I run mfd_fail_write() on a
read-only FD, I might even want to change it to run mmap()+mprotect().
This should clear up all doubts.

Thanks!
David

>> +     p = mmap(NULL,
>> +              MFD_DEF_SIZE,
>> +              PROT_READ,
>> +              MAP_SHARED,
>> +              fd,
>> +              0);
>> +     if (p != MAP_FAILED) {
>> +             printf("mmap() didn't fail as expected\n");
>> +             abort();
>> +     }
>> +
>> +     /* verify PUNCH_HOLE fails */
>> +     r = fallocate(fd,
>> +                   FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
>> +                   0,
>> +                   MFD_DEF_SIZE);
>> +     if (r >= 0) {
>> +             printf("fallocate(PUNCH_HOLE) didn't fail as expected\n");
>> +             abort();
>> +     }
>> +}
>> +
>> +static void mfd_assert_shrink(int fd)
>> +{
>> +     int r, fd2;
>> +
>> +     r = ftruncate(fd, MFD_DEF_SIZE / 2);
>> +     if (r < 0) {
>> +             printf("ftruncate(SHRINK) failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     mfd_assert_size(fd, MFD_DEF_SIZE / 2);
>> +
>> +     fd2 = mfd_assert_open(fd,
>> +                           O_RDWR | O_CREAT | O_TRUNC,
>> +                           S_IRUSR | S_IWUSR);
>> +     close(fd2);
>> +
>> +     mfd_assert_size(fd, 0);
>> +}
>> +
>> +static void mfd_fail_shrink(int fd)
>> +{
>> +     int r;
>> +
>> +     r = ftruncate(fd, MFD_DEF_SIZE / 2);
>> +     if (r >= 0) {
>> +             printf("ftruncate(SHRINK) didn't fail as expected\n");
>> +             abort();
>> +     }
>> +
>> +     mfd_fail_open(fd,
>> +                   O_RDWR | O_CREAT | O_TRUNC,
>> +                   S_IRUSR | S_IWUSR);
>> +}
>> +
>> +static void mfd_assert_grow(int fd)
>> +{
>> +     int r;
>> +
>> +     r = ftruncate(fd, MFD_DEF_SIZE * 2);
>> +     if (r < 0) {
>> +             printf("ftruncate(GROW) failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     mfd_assert_size(fd, MFD_DEF_SIZE * 2);
>> +
>> +     r = fallocate(fd,
>> +                   0,
>> +                   0,
>> +                   MFD_DEF_SIZE * 4);
>> +     if (r < 0) {
>> +             printf("fallocate(ALLOC) failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     mfd_assert_size(fd, MFD_DEF_SIZE * 4);
>> +}
>> +
>> +static void mfd_fail_grow(int fd)
>> +{
>> +     int r;
>> +
>> +     r = ftruncate(fd, MFD_DEF_SIZE * 2);
>> +     if (r >= 0) {
>> +             printf("ftruncate(GROW) didn't fail as expected\n");
>> +             abort();
>> +     }
>> +
>> +     r = fallocate(fd,
>> +                   0,
>> +                   0,
>> +                   MFD_DEF_SIZE * 4);
>> +     if (r >= 0) {
>> +             printf("fallocate(ALLOC) didn't fail as expected\n");
>> +             abort();
>> +     }
>> +}
>> +
>> +static void mfd_assert_grow_write(int fd)
>> +{
>> +     static char buf[MFD_DEF_SIZE * 8];
>> +     ssize_t l;
>> +
>> +     l = pwrite(fd, buf, sizeof(buf), 0);
>> +     if (l != sizeof(buf)) {
>> +             printf("pwrite() failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     mfd_assert_size(fd, MFD_DEF_SIZE * 8);
>> +}
>> +
>> +static void mfd_fail_grow_write(int fd)
>> +{
>> +     static char buf[MFD_DEF_SIZE * 8];
>> +     ssize_t l;
>> +
>> +     l = pwrite(fd, buf, sizeof(buf), 0);
>> +     if (l == sizeof(buf)) {
>> +             printf("pwrite() didn't fail as expected\n");
>> +             abort();
>> +     }
>> +}
>> +
>> +static int idle_thread_fn(void *arg)
>> +{
>> +     sigset_t set;
>> +     int sig;
>> +
>> +     /* dummy waiter; SIGTERM terminates us anyway */
>> +     sigemptyset(&set);
>> +     sigaddset(&set, SIGTERM);
>> +     sigwait(&set, &sig);
>> +
>> +     return 0;
>> +}
>> +
>> +static pid_t spawn_idle_thread(void)
>> +{
>> +     uint8_t *stack;
>> +     pid_t pid;
>> +
>> +     stack = malloc(STACK_SIZE);
>> +     if (!stack) {
>> +             printf("malloc(STACK_SIZE) failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     pid = clone(idle_thread_fn,
>> +                 stack + STACK_SIZE,
>> +                 CLONE_FILES | CLONE_FS | CLONE_VM | SIGCHLD,
>> +                 NULL);
>> +     if (pid < 0) {
>> +             printf("clone() failed: %m\n");
>> +             abort();
>> +     }
>> +
>> +     return pid;
>> +}
>> +
>> +static void join_idle_thread(pid_t pid)
>> +{
>> +     kill(pid, SIGTERM);
>> +     waitpid(pid, NULL, 0);
>> +}
>> +
>> +static pid_t spawn_idle_proc(void)
>> +{
>> +     pid_t pid;
>> +     sigset_t set;
>> +     int sig;
>> +
>> +     pid = fork();
>> +     if (pid < 0) {
>> +             printf("fork() failed: %m\n");
>> +             abort();
>> +     } else if (!pid) {
>> +             /* dummy waiter; SIGTERM terminates us anyway */
>> +             sigemptyset(&set);
>> +             sigaddset(&set, SIGTERM);
>> +             sigwait(&set, &sig);
>> +             exit(0);
>> +     }
>> +
>> +     return pid;
>> +}
>> +
>> +static void join_idle_proc(pid_t pid)
>> +{
>> +     kill(pid, SIGTERM);
>> +     waitpid(pid, NULL, 0);
>> +}
>> +
>> +/*
>> + * Test memfd_create() syscall
>> + * Verify syscall-argument validation, including name checks, flag validation
>> + * and more.
>> + */
>> +static void test_create(void)
>> +{
>> +     char buf[2048];
>> +     int fd;
>> +
>> +     /* test NULL name */
>> +     mfd_fail_new(NULL, 0, 0);
>> +
>> +     /* test over-long name (not zero-terminated) */
>> +     memset(buf, 0xff, sizeof(buf));
>> +     mfd_fail_new(buf, 0, 0);
>> +
>> +     /* test over-long zero-terminated name */
>> +     memset(buf, 0xff, sizeof(buf));
>> +     buf[sizeof(buf) - 1] = 0;
>> +     mfd_fail_new(buf, 0, 0);
>> +
>> +     /* verify "" is a valid name */
>> +     fd = mfd_assert_new("", 0, 0);
>> +     close(fd);
>> +
>> +     /* verify invalid O_* open flags */
>> +     mfd_fail_new("", 0, 0x0100);
>> +     mfd_fail_new("", 0, ~MFD_CLOEXEC);
>> +     mfd_fail_new("", 0, ~MFD_ALLOW_SEALING);
>> +     mfd_fail_new("", 0, ~0);
>> +     mfd_fail_new("", 0, 0x8000000000000000ULL);
>> +
>> +     /* verify MFD_CLOEXEC is allowed */
>> +     fd = mfd_assert_new("", 0, MFD_CLOEXEC);
>> +     close(fd);
>> +
>> +     /* verify MFD_ALLOW_SEALING is allowed */
>> +     fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING);
>> +     close(fd);
>> +
>> +     /* verify MFD_ALLOW_SEALING | MFD_CLOEXEC is allowed */
>> +     fd = mfd_assert_new("", 0, MFD_ALLOW_SEALING | MFD_CLOEXEC);
>> +     close(fd);
>> +}
>> +
>> +/*
>> + * Test basic sealing
>> + * A very basic sealing test to see whether setting/retrieving seals works.
>> + */
>> +static void test_basic(void)
>> +{
>> +     int fd;
>> +
>> +     fd = mfd_assert_new("kern_memfd_basic",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC | MFD_ALLOW_SEALING);
>> +
>> +     /* add basic seals */
>> +     mfd_assert_has_seals(fd, 0);
>> +     mfd_assert_add_seals(fd, F_SEAL_SHRINK |
>> +                              F_SEAL_WRITE);
>> +     mfd_assert_has_seals(fd, F_SEAL_SHRINK |
>> +                              F_SEAL_WRITE);
>> +
>> +     /* add them again */
>> +     mfd_assert_add_seals(fd, F_SEAL_SHRINK |
>> +                              F_SEAL_WRITE);
>> +     mfd_assert_has_seals(fd, F_SEAL_SHRINK |
>> +                              F_SEAL_WRITE);
>> +
>> +     /* add more seals and seal against sealing */
>> +     mfd_assert_add_seals(fd, F_SEAL_GROW | F_SEAL_SEAL);
>> +     mfd_assert_has_seals(fd, F_SEAL_SHRINK |
>> +                              F_SEAL_GROW |
>> +                              F_SEAL_WRITE |
>> +                              F_SEAL_SEAL);
>> +
>> +     /* verify that sealing no longer works */
>> +     mfd_fail_add_seals(fd, F_SEAL_GROW);
>> +     mfd_fail_add_seals(fd, 0);
>> +
>> +     close(fd);
>> +
>> +     /* verify sealing does not work without MFD_ALLOW_SEALING */
>> +     fd = mfd_assert_new("kern_memfd_basic",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC);
>> +     mfd_fail_get_seals(fd);
>> +     mfd_fail_add_seals(fd, F_SEAL_SHRINK |
>> +                            F_SEAL_GROW |
>> +                            F_SEAL_WRITE);
>> +     mfd_fail_get_seals(fd);
>> +     close(fd);
>> +}
>> +
>> +/*
>> + * Test SEAL_WRITE
>> + * Test whether SEAL_WRITE actually prevents modifications.
>> + */
>> +static void test_seal_write(void)
>> +{
>> +     int fd;
>> +
>> +     fd = mfd_assert_new("kern_memfd_seal_write",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC | MFD_ALLOW_SEALING);
>> +     mfd_assert_has_seals(fd, 0);
>> +     mfd_assert_add_seals(fd, F_SEAL_WRITE);
>> +     mfd_assert_has_seals(fd, F_SEAL_WRITE);
>> +
>> +     mfd_assert_read(fd);
>> +     mfd_fail_write(fd);
>> +     mfd_assert_shrink(fd);
>> +     mfd_assert_grow(fd);
>> +     mfd_fail_grow_write(fd);
>> +
>> +     close(fd);
>> +}
>> +
>> +/*
>> + * Test SEAL_SHRINK
>> + * Test whether SEAL_SHRINK actually prevents shrinking
>> + */
>> +static void test_seal_shrink(void)
>> +{
>> +     int fd;
>> +
>> +     fd = mfd_assert_new("kern_memfd_seal_shrink",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC | MFD_ALLOW_SEALING);
>> +     mfd_assert_has_seals(fd, 0);
>> +     mfd_assert_add_seals(fd, F_SEAL_SHRINK);
>> +     mfd_assert_has_seals(fd, F_SEAL_SHRINK);
>> +
>> +     mfd_assert_read(fd);
>> +     mfd_assert_write(fd);
>> +     mfd_fail_shrink(fd);
>> +     mfd_assert_grow(fd);
>> +     mfd_assert_grow_write(fd);
>> +
>> +     close(fd);
>> +}
>> +
>> +/*
>> + * Test SEAL_GROW
>> + * Test whether SEAL_GROW actually prevents growing
>> + */
>> +static void test_seal_grow(void)
>> +{
>> +     int fd;
>> +
>> +     fd = mfd_assert_new("kern_memfd_seal_grow",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC | MFD_ALLOW_SEALING);
>> +     mfd_assert_has_seals(fd, 0);
>> +     mfd_assert_add_seals(fd, F_SEAL_GROW);
>> +     mfd_assert_has_seals(fd, F_SEAL_GROW);
>> +
>> +     mfd_assert_read(fd);
>> +     mfd_assert_write(fd);
>> +     mfd_assert_shrink(fd);
>> +     mfd_fail_grow(fd);
>> +     mfd_fail_grow_write(fd);
>> +
>> +     close(fd);
>> +}
>> +
>> +/*
>> + * Test SEAL_SHRINK | SEAL_GROW
>> + * Test whether SEAL_SHRINK | SEAL_GROW actually prevents resizing
>> + */
>> +static void test_seal_resize(void)
>> +{
>> +     int fd;
>> +
>> +     fd = mfd_assert_new("kern_memfd_seal_resize",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC | MFD_ALLOW_SEALING);
>> +     mfd_assert_has_seals(fd, 0);
>> +     mfd_assert_add_seals(fd, F_SEAL_SHRINK | F_SEAL_GROW);
>> +     mfd_assert_has_seals(fd, F_SEAL_SHRINK | F_SEAL_GROW);
>> +
>> +     mfd_assert_read(fd);
>> +     mfd_assert_write(fd);
>> +     mfd_fail_shrink(fd);
>> +     mfd_fail_grow(fd);
>> +     mfd_fail_grow_write(fd);
>> +
>> +     close(fd);
>> +}
>> +
>> +/*
>> + * Test sharing via dup()
>> + * Test that seals are shared between dupped FDs and they're all equal.
>> + */
>> +static void test_share_dup(void)
>> +{
>> +     int fd, fd2;
>> +
>> +     fd = mfd_assert_new("kern_memfd_share_dup",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC | MFD_ALLOW_SEALING);
>> +     mfd_assert_has_seals(fd, 0);
>> +
>> +     fd2 = mfd_assert_dup(fd);
>> +     mfd_assert_has_seals(fd2, 0);
>> +
>> +     mfd_assert_add_seals(fd, F_SEAL_WRITE);
>> +     mfd_assert_has_seals(fd, F_SEAL_WRITE);
>> +     mfd_assert_has_seals(fd2, F_SEAL_WRITE);
>> +
>> +     mfd_assert_add_seals(fd2, F_SEAL_SHRINK);
>> +     mfd_assert_has_seals(fd, F_SEAL_WRITE | F_SEAL_SHRINK);
>> +     mfd_assert_has_seals(fd2, F_SEAL_WRITE | F_SEAL_SHRINK);
>> +
>> +     mfd_assert_add_seals(fd, F_SEAL_SEAL);
>> +     mfd_assert_has_seals(fd, F_SEAL_WRITE | F_SEAL_SHRINK | F_SEAL_SEAL);
>> +     mfd_assert_has_seals(fd2, F_SEAL_WRITE | F_SEAL_SHRINK | F_SEAL_SEAL);
>> +
>> +     mfd_fail_add_seals(fd, F_SEAL_GROW);
>> +     mfd_fail_add_seals(fd2, F_SEAL_GROW);
>> +     mfd_fail_add_seals(fd, F_SEAL_SEAL);
>> +     mfd_fail_add_seals(fd2, F_SEAL_SEAL);
>> +
>> +     close(fd2);
>> +
>> +     mfd_fail_add_seals(fd, F_SEAL_GROW);
>> +     close(fd);
>> +}
>> +
>> +/*
>> + * Test sealing with active mmap()s
>> + * Modifying seals is only allowed if no other mmap() refs exist.
>> + */
>> +static void test_share_mmap(void)
>> +{
>> +     int fd;
>> +     void *p;
>> +
>> +     fd = mfd_assert_new("kern_memfd_share_mmap",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC | MFD_ALLOW_SEALING);
>> +     mfd_assert_has_seals(fd, 0);
>> +
>> +     /* shared/writable ref prevents sealing */
>> +     p = mfd_assert_mmap_shared(fd);
>> +     mfd_fail_add_seals(fd, F_SEAL_SHRINK);
>> +     mfd_assert_has_seals(fd, 0);
>> +     munmap(p, MFD_DEF_SIZE);
>> +
>> +     /* readable ref allows sealing */
>> +     p = mfd_assert_mmap_private(fd);
>> +     mfd_assert_add_seals(fd, F_SEAL_SHRINK);
>> +     mfd_assert_has_seals(fd, F_SEAL_SHRINK);
>> +     munmap(p, MFD_DEF_SIZE);
>> +
>> +     close(fd);
>> +}
>> +
>> +/*
>> + * Test sealing with open(/proc/self/fd/%d)
>> + * Via /proc we can get access to a separate file-context for the same memfd.
>> + * This is *not* like dup(), but like a real separate open(). Make sure the
>> + * semantics are as expected and we correctly check for RDONLY / WRONLY / RDWR.
>> + */
>> +static void test_share_open(void)
>> +{
>> +     int fd, fd2;
>> +
>> +     fd = mfd_assert_new("kern_memfd_share_open",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC | MFD_ALLOW_SEALING);
>> +     mfd_assert_has_seals(fd, 0);
>> +
>> +     fd2 = mfd_assert_open(fd, O_RDWR, 0);
>> +     mfd_assert_add_seals(fd, F_SEAL_WRITE);
>> +     mfd_assert_has_seals(fd, F_SEAL_WRITE);
>> +     mfd_assert_has_seals(fd2, F_SEAL_WRITE);
>> +
>> +     mfd_assert_add_seals(fd2, F_SEAL_SHRINK);
>> +     mfd_assert_has_seals(fd, F_SEAL_WRITE | F_SEAL_SHRINK);
>> +     mfd_assert_has_seals(fd2, F_SEAL_WRITE | F_SEAL_SHRINK);
>> +
>> +     close(fd);
>> +     fd = mfd_assert_open(fd2, O_RDONLY, 0);
>> +
>> +     mfd_fail_add_seals(fd, F_SEAL_SEAL);
>> +     mfd_assert_has_seals(fd, F_SEAL_WRITE | F_SEAL_SHRINK);
>> +     mfd_assert_has_seals(fd2, F_SEAL_WRITE | F_SEAL_SHRINK);
>> +
>> +     close(fd2);
>> +     fd2 = mfd_assert_open(fd, O_RDWR, 0);
>> +
>> +     mfd_assert_add_seals(fd2, F_SEAL_SEAL);
>> +     mfd_assert_has_seals(fd, F_SEAL_WRITE | F_SEAL_SHRINK | F_SEAL_SEAL);
>> +     mfd_assert_has_seals(fd2, F_SEAL_WRITE | F_SEAL_SHRINK | F_SEAL_SEAL);
>> +
>> +     close(fd2);
>> +     close(fd);
>> +}
>> +
>> +/*
>> + * Test sharing via fork()
>> + * Test whether seal-modifications work as expected with forked childs.
>> + */
>> +static void test_share_fork(void)
>> +{
>> +     int fd;
>> +     pid_t pid;
>> +
>> +     fd = mfd_assert_new("kern_memfd_share_fork",
>> +                         MFD_DEF_SIZE,
>> +                         MFD_CLOEXEC | MFD_ALLOW_SEALING);
>> +     mfd_assert_has_seals(fd, 0);
>> +
>> +     pid = spawn_idle_proc();
>> +     mfd_assert_add_seals(fd, F_SEAL_SEAL);
>> +     mfd_assert_has_seals(fd, F_SEAL_SEAL);
>> +
>> +     mfd_fail_add_seals(fd, F_SEAL_WRITE);
>> +     mfd_assert_has_seals(fd, F_SEAL_SEAL);
>> +
>> +     join_idle_proc(pid);
>> +
>> +     mfd_fail_add_seals(fd, F_SEAL_WRITE);
>> +     mfd_assert_has_seals(fd, F_SEAL_SEAL);
>> +
>> +     close(fd);
>> +}
>> +
>> +int main(int argc, char **argv)
>> +{
>> +     pid_t pid;
>> +
>> +     printf("memfd: CREATE\n");
>> +     test_create();
>> +     printf("memfd: BASIC\n");
>> +     test_basic();
>> +
>> +     printf("memfd: SEAL-WRITE\n");
>> +     test_seal_write();
>> +     printf("memfd: SEAL-SHRINK\n");
>> +     test_seal_shrink();
>> +     printf("memfd: SEAL-GROW\n");
>> +     test_seal_grow();
>> +     printf("memfd: SEAL-RESIZE\n");
>> +     test_seal_resize();
>> +
>> +     printf("memfd: SHARE-DUP\n");
>> +     test_share_dup();
>> +     printf("memfd: SHARE-MMAP\n");
>> +     test_share_mmap();
>> +     printf("memfd: SHARE-OPEN\n");
>> +     test_share_open();
>> +     printf("memfd: SHARE-FORK\n");
>> +     test_share_fork();
>> +
>> +     /* Run test-suite in a multi-threaded environment with a shared
>> +      * file-table. */
>> +     pid = spawn_idle_thread();
>> +     printf("memfd: SHARE-DUP (shared file-table)\n");
>> +     test_share_dup();
>> +     printf("memfd: SHARE-MMAP (shared file-table)\n");
>> +     test_share_mmap();
>> +     printf("memfd: SHARE-OPEN (shared file-table)\n");
>> +     test_share_open();
>> +     printf("memfd: SHARE-FORK (shared file-table)\n");
>> +     test_share_fork();
>> +     join_idle_thread(pid);
>> +
>> +     printf("memfd: DONE\n");
>> +
>> +     return 0;
>> +}
>> --
>> 1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
