Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC73C6B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 09:51:39 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j67so8640039oih.3
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 06:51:39 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0107.outbound.protection.outlook.com. [104.47.2.107])
        by mx.google.com with ESMTPS id s185si1616546oia.133.2016.08.11.06.51.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 06:51:38 -0700 (PDT)
From: Evgeny Yakovlev <eyakovlev@virtuozzo.com>
Subject: userfaultfd: unexpected behavior with MODE_MISSING | MODE_WP regions
Message-ID: <ef90a2b0-eff4-2269-4a93-35f23ec8b1af@virtuozzo.com>
Date: Thu, 11 Aug 2016 16:51:30 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: aarcange@redhat.com

We're experimenting with userfaultfd write protect implementation on 
Andrea's tree and it looks like there is a problem if we combine 
MODE_MISSING and MODE_WP in one region.

You can find a test case below together with detailed problem 
description. Please take a look, maybe we're doing something wrong?

Will be happy to provide any additional info if needed.

/*
  * This testcase reproduces a problem with userfaultfd writeprotect 
feature on
  * http://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git, HEAD 
a22d71c
  * gcc ufdtest.c -std=gnu99 -lpthread -o ufdtest
  *
  * 1. Allocate a private RW region and register it with MODE_MISSING | 
MODE_WP.
  * 2. Fork a UFD thread and begin writing to memory from main thread.
  *
  * Expected behavior:
  * Recv pagefaults with UFFD_PAGEFAULT_FLAG_WRITE set, handle them with 
zeropage
  *
  * Actual behavior:
  * We recv to pagefaults for each page:
  *
  * 1. First fault is expected UFFD_PAGEFAULT_FLAG_WRITE set which we 
resolve
  * with zeropage
  *
  * 2. Second fault immediately follows the first one with the same address
  * and has UFFD_PAGEFAULT_FLAG_WRITE | UFFD_PAGEFAULT_FLAG_WP set.
  * If we ignore this second fault then main thread never wakes up
  * If we try to resolve it with !WP then main thread received SIGBUS.
  *
  * If we register that region only with MODE_MISSING _or_ MODE_WP then 
we get
  * no problems, i.e. only missing faults or WP faults are seen.
  */

#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <errno.h>
#include <assert.h>

#define _GNU_SOURCE
#include <fcntl.h>
#include <poll.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/user.h>
#include <sys/syscall.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <asm/types.h>
#include <sys/eventfd.h>
#include <linux/userfaultfd.h>
#include <pthread.h>

#if !(defined(__linux__) && defined(__NR_userfaultfd))
#   error Need userfaultfd
#endif

#define DIE(fmt, ...) do { \
     fprintf(stderr, fmt, ##__VA_ARGS__); \
     fprintf(stderr, "\n"); \
     assert(0); \
} while(0);

#define DPRINTF(fmt, ...) do { \
     printf("%s: " fmt, __func__, ##__VA_ARGS__); \
     printf("\n"); \
} while(0);

static int g_ufd = -1;

static bool ufd_version_check(void)
{
     struct uffdio_api api_struct;
     uint64_t ioctl_mask;

     api_struct.api = UFFD_API;
     api_struct.features = 0;
     if (ioctl(g_ufd, UFFDIO_API, &api_struct)) {
         DIE("UFFDIO_API failed: %s", strerror(errno));
     }

     ioctl_mask = (__u64)1 << _UFFDIO_REGISTER |
                  (__u64)1 << _UFFDIO_UNREGISTER;
     if ((api_struct.ioctls & ioctl_mask) != ioctl_mask) {
         DIE("Missing features: %llx", ~api_struct.ioctls & ioctl_mask);
     }

     return true;
}

static void ufd_zeropage(__u64 page)
{
     struct uffdio_zeropage zero_struct;
     zero_struct.range.start = page;
     zero_struct.range.len = getpagesize();
     zero_struct.mode = 0;

     if (ioctl(g_ufd, UFFDIO_ZEROPAGE, &zero_struct)) {
         DIE("zeropage ioctl failed");
     }
}

static void ufd_writeprotect(__u64 page, bool readonly)
{
     struct uffdio_writeprotect wp_struct;
     wp_struct.range.start = page;
     wp_struct.range.len = PAGE_SIZE;
     if (readonly) {
         wp_struct.mode = UFFDIO_WRITEPROTECT_MODE_WP;
     } else {
         wp_struct.mode = 0;
     }

     if (ioctl(g_ufd, UFFDIO_WRITEPROTECT, &wp_struct)) {
         DIE("ioctl failed: %s", strerror(errno));
     }
}

static void* ufd_worker(void* arg)
{
     while(1) {
         DPRINTF("Reading from ufd");

         struct uffd_msg msg;
         int ret = read(g_ufd, &msg, sizeof(msg));
         if (ret != sizeof(msg)) {
             if (errno == EAGAIN) {
                 continue;
             }

             if (ret < 0) {
                 DIE("Failed to read full message: %s", strerror(errno));
             } else {
                 DIE("Read %d bytes, expected %zd", ret, sizeof(msg));
             }
         }

         if (msg.event != UFFD_EVENT_PAGEFAULT) {
             DIE("unexpected event 0x%x", msg.event);
         }

         __u64 page = msg.arg.pagefault.address & ~(PAGE_SIZE - 1ull);
         DPRINTF("Pagefault @ 0x%llx, flags 0x%llx",
                 page, msg.arg.pagefault.flags);

         bool is_write_fault =
             (msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WRITE) != 0;
         bool is_wp_fault =
             (msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WP) != 0;

         if (!is_write_fault || (is_write_fault && !is_wp_fault)) {
             ufd_zeropage(page);
             DPRINTF("0x%llx zeropaged", page);
         } else if (is_wp_fault) {
             DPRINTF("unexpected WP fault on 0x%llx", page);

             // If you remove this main thread will sleep forever
             ufd_writeprotect(page, false);
         }
     }

     DIE("Unreachable");
     return NULL;
}

int main(void)
{
     int res = 0;

     g_ufd = syscall(__NR_userfaultfd, O_CLOEXEC);
     if (g_ufd < 0) {
         DIE("userfaultfd not available: %s", strerror(errno));
     }

     if (!ufd_version_check()) {
         DIE("UFFDIO_API not supported");
     }

     size_t len = 1024 * 1024 * 1024;
     void* mem = mmap(NULL, len, PROT_READ | PROT_WRITE,
             MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
     if (mem == MAP_FAILED) {
         DIE("mmap failed: %s", strerror(errno));
     }

     struct uffdio_register reg_struct;
     reg_struct.range.start = (uintptr_t)mem;
     reg_struct.range.len = len;
     reg_struct.mode = UFFDIO_REGISTER_MODE_MISSING | 
UFFDIO_REGISTER_MODE_WP;

     if (ioctl(g_ufd, UFFDIO_REGISTER, &reg_struct)) {
         DIE("userfault register: %s", strerror(errno));
     }

     uint64_t feature_mask = 1ull << _UFFDIO_WAKE |
                             1ull << _UFFDIO_ZEROPAGE |
                             1ull << _UFFDIO_WRITEPROTECT;
     if ((reg_struct.ioctls & feature_mask) != feature_mask) {
         DIE("Missing range features: %llx", ~reg_struct.ioctls & 
feature_mask);
     }

     DPRINTF("Registered range %p:%zu", mem, len);
     DPRINTF("UFD features: 0x%x", reg_struct.ioctls);

     pthread_t worker;
     if (0 != pthread_create(&worker, NULL, ufd_worker, NULL)) {
         DIE("Failed to start ufd worker thread");
     }

     volatile uint8_t* pdata = (uint8_t*)mem;
     for (int i = 0; i < (len / PAGE_SIZE); ++i) {
         pdata[0] = (uint8_t)rand();
     }

     DPRINTF("done!");
     pthread_join(worker, NULL);
     return EXIT_SUCCESS;
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
