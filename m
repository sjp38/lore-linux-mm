Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A21D66B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 08:44:50 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c52so14260576qte.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 05:44:50 -0700 (PDT)
Received: from mail-ua0-x241.google.com (mail-ua0-x241.google.com. [2607:f8b0:400c:c08::241])
        by mx.google.com with ESMTPS id q69si80434uaq.19.2016.07.26.05.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 05:44:49 -0700 (PDT)
Received: by mail-ua0-x241.google.com with SMTP id m60so123186uam.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 05:44:49 -0700 (PDT)
MIME-Version: 1.0
From: =?UTF-8?Q?Marcin_=C5=9Alusarz?= <marcin.slusarz@gmail.com>
Date: Tue, 26 Jul 2016 14:44:48 +0200
Message-ID: <CA+GA0_uRjKznAB+d-3bDqdNRDYBA+YQbYSUcB9=rDTLk1NJEmg@mail.gmail.com>
Subject: Is reading from /proc/self/smaps thread-safe?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hey

I have a simple program that mmaps 8MB of anonymous memory, spawns 16
threads, reads /proc/self/smaps in each thread and looks up whether
mapped address can be found in smaps. From time to time it's not there.

Is this supposed to work reliably?

My guess is that libc functions allocate memory internally using mmap
and modify process' address space while other thread is iterating over
vmas.

I see that reading from smaps takes mmap_sem in read mode. I'm guessing
vm modifications are done under mmap_sem in write mode.

Documentation/filesystem/proc.txt says reading from smaps is "slow but
very precise" (although in context of RSS).

Example program below.

smaps_test.c:
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#define N 16
#define SZ (8 * 1024 * 1024)

void *addr;
char addrstr[20];
pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;

static void *worker(void *arg)
{
    char tmp[100000];
    int ret;
    int off = 0;

    int fd = open("/proc/self/smaps", O_RDONLY);
    if (fd < 0)
        abort();

    do {
        ret = read(fd, tmp + off, sizeof(tmp) - off);
        if (ret < 0)
            abort();
        off += ret;
        if (off == sizeof(tmp))
            abort();
    } while (ret != 0);

    char *found = strstr(tmp, addrstr);

    /* lock to prevent multiple threads from
       writing to stdout at the same time */
    pthread_mutex_lock(&mtx);
    printf("%d\n", found ? 1 : 0);
    if (!found) {
        printf("%s\n", tmp);
        printf("address %p not found in smaps\n", addr);
        fflush(stdout);
        abort();
    }
    pthread_mutex_unlock(&mtx);

    close(fd);
    return NULL;
}

int main()
{
    pthread_t t[N];

    addr = mmap(NULL, SZ, PROT_READ|PROT_WRITE,
MAP_SHARED|MAP_ANONYMOUS, -1, 0);
    if (addr == MAP_FAILED)
        abort();

    sprintf(addrstr, "%lx-", (uintptr_t)addr);

    for (int i = 0; i < N; ++i)
        if (pthread_create(&t[i], NULL, worker, NULL))
            abort();
    for (int i = 0; i < N; ++i)
        if (pthread_join(t[i], NULL))
            abort();

    munmap(addr, SZ);

    return 0;
}

Makefile:
LDFLAGS=-pthread

smaps_test: smaps_test.c

run: smaps_test
    while ./smaps_test; do echo; done | grep -v ': '


Failing run:
$ make run
while ./smaps_test; do echo; done | grep -v ': '
1
1
1
1
1
1
1
1
1
1
1
1
1
1
0
00400000-00401000 r-xp 00000000 08:02 19006749
  /home/mslusarz/smaps_test/smaps_test
00601000-00602000 rw-p 00001000 08:02 19006749
  /home/mslusarz/smaps_test/smaps_test
020f8000-02119000 rw-p 00000000 00:00 0                                  [heap]
7f0dfdffc000-7f0dfe7fd000 rw-p 00000000 00:00 0
7f0dfe7fd000-7f0dfe7fe000 ---p 00000000 00:00 0
7f0dfe7fe000-7f0dfeffe000 rw-p 00000000 00:00 0
7f0dfeffe000-7f0dfefff000 ---p 00000000 00:00 0
7f0dfefff000-7f0dff7ff000 rw-p 00000000 00:00 0
7f0dff7ff000-7f0dff800000 ---p 00000000 00:00 0
7f0dff800000-7f0e00000000 rw-p 00000000 00:00 0
7f0e00000000-7f0e00022000 rw-p 00000000 00:00 0
7f0e00022000-7f0e04000000 ---p 00000000 00:00 0
7f0e04595000-7f0e04596000 ---p 00000000 00:00 0
7f0e04596000-7f0e04d96000 rw-p 00000000 00:00 0
7f0e04d96000-7f0e04d97000 ---p 00000000 00:00 0
7f0e04d97000-7f0e05597000 rw-p 00000000 00:00 0
7f0e05597000-7f0e05598000 ---p 00000000 00:00 0
7f0e05598000-7f0e05d98000 rw-p 00000000 00:00 0
7f0e05d98000-7f0e05d99000 ---p 00000000 00:00 0
7f0e05d99000-7f0e06599000 rw-p 00000000 00:00 0
7f0e06599000-7f0e0659a000 ---p 00000000 00:00 0
7f0e0659a000-7f0e06d9a000 rw-p 00000000 00:00 0
7f0e06d9a000-7f0e06d9b000 ---p 00000000 00:00 0
7f0e06d9b000-7f0e0759b000 rw-p 00000000 00:00 0
7f0e0759b000-7f0e0759c000 ---p 00000000 00:00 0
7f0e0759c000-7f0e07d9c000 rw-p 00000000 00:00 0
7f0e07d9c000-7f0e07d9d000 ---p 00000000 00:00 0
7f0e07d9d000-7f0e0859d000 rw-p 00000000 00:00 0
7f0e0859d000-7f0e0859e000 ---p 00000000 00:00 0
7f0e0859e000-7f0e08d9e000 rw-p 00000000 00:00 0
7f0e08d9e000-7f0e08d9f000 ---p 00000000 00:00 0
7f0e08d9f000-7f0e0959f000 rw-p 00000000 00:00 0
7f0e0959f000-7f0e095a0000 ---p 00000000 00:00 0
7f0e095a0000-7f0e09da0000 rw-p 00000000 00:00 0
7f0e09da0000-7f0e09da1000 ---p 00000000 00:00 0
(should be here)
7f0e0ada1000-7f0e0af38000 r-xp 00000000 08:02 9699508
  /lib/x86_64-linux-gnu/libc-2.23.so
7f0e0af38000-7f0e0b138000 ---p 00197000 08:02 9699508
  /lib/x86_64-linux-gnu/libc-2.23.so
7f0e0b138000-7f0e0b13c000 r--p 00197000 08:02 9699508
  /lib/x86_64-linux-gnu/libc-2.23.so
7f0e0b13c000-7f0e0b13e000 rw-p 0019b000 08:02 9699508
  /lib/x86_64-linux-gnu/libc-2.23.so
7f0e0b13e000-7f0e0b142000 rw-p 00000000 00:00 0
7f0e0b142000-7f0e0b15a000 r-xp 00000000 08:02 9699869
  /lib/x86_64-linux-gnu/libpthread-2.23.so
7f0e0b15a000-7f0e0b359000 ---p 00018000 08:02 9699869
  /lib/x86_64-linux-gnu/libpthread-2.23.so
7f0e0b359000-7f0e0b35a000 r--p 00017000 08:02 9699869
  /lib/x86_64-linux-gnu/libpthread-2.23.so
7f0e0b35a000-7f0e0b35b000 rw-p 00018000 08:02 9699869
  /lib/x86_64-linux-gnu/libpthread-2.23.so
7f0e0b35b000-7f0e0b35f000 rw-p 00000000 00:00 0
7f0e0b35f000-7f0e0b383000 r-xp 00000000 08:02 9699378
  /lib/x86_64-linux-gnu/ld-2.23.so
7f0e0b557000-7f0e0b55a000 rw-p 00000000 00:00 0
7f0e0b580000-7f0e0b582000 rw-p 00000000 00:00 0
7f0e0b582000-7f0e0b583000 r--p 00023000 08:02 9699378
  /lib/x86_64-linux-gnu/ld-2.23.so
7f0e0b583000-7f0e0b584000 rw-p 00024000 08:02 9699378
  /lib/x86_64-linux-gnu/ld-2.23.so
7f0e0b584000-7f0e0b585000 rw-p 00000000 00:00 0
7fff48fe4000-7fff49005000 rw-p 00000000 00:00 0                          [stack]
7fff4908e000-7fff49090000 r--p 00000000 00:00 0                          [vvar]
7fff49090000-7fff49092000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0
  [vsyscall]

address 0x7f0e0a5a1000 not found in smaps
Aborted

Cheers,
Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
