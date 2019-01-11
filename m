Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 214A58E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:43:26 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so8629299pgb.7
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:43:26 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id c3si71845524pgi.370.2019.01.11.07.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 07:43:24 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH v11 00/26] Speculative page faults
Message-ID: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org>
Date: Fri, 11 Jan 2019 21:13:20 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ldufour@linux.vnet.ibm.com
Cc: Linux-MM <linux-mm@kvack.org>, charante@codeaurora.org

Hi Laurent,

We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).

Steps:

1) Run the program

2) The 2 threads will try lock/unlock and prints messages, and main thread does fork. In around 1 minute time, lock/unlock threads will hang on pthread_mutex_lock.


Initially the issue was reported when ptrace was tried on apps. Later it was discovered that the write protect done by fork is causing the issue and the below test code was created.


Observations:

1) We have tried disabling SPF and the issue disappears.

2) Adding this piece of code in __handle_speculative_fault also fixes the problem.

if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))

    return VM_FAULT_RETRY;

3) As an experiment we tried encapsulating handle_speculative_fault with down_read(mmap_sem) and that too fixes the problem.

4) It is observed that while in wp_page_copy, the contents of the old_page changes which should not ideally happen as the pte is !pte_write.

5) To prove that it is a race, we tried affining the threads to single core, and the issue disappears.

Let us know if you want us to try out any experiments.

Thanks,
Vinayak

/**test.c***/

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#define UNUSED(expr) do { (void)(expr); } while(0)
#define print printf

pthread_mutex_t m;
pthread_cond_t c;

static void* cond_do(void* arg)
{
  UNUSED(arg);
  do {
    print("%s:%d state=%u addr: %lx\n", __func__, __LINE__, *(uint32_t*)(&m), (unsigned long)&m);
    pthread_mutex_lock(&m);
 
    print("%s:%d state=%u addr: %lx\n", __func__, __LINE__, *(uint32_t*)(&m), (unsigned long)&m);
    pthread_mutex_unlock(&m);
    print("%s:%d state=%u addr: %lx\n", __func__, __LINE__, *(uint32_t*)(&m), (unsigned long)&m);
  } while (true);

  return NULL;
}

static void* sig_do(void* arg)
{
  UNUSED(arg);
  do {
    print("%s:%d state=%u addr: %lx\n", __func__, __LINE__, *(uint32_t*)(&m), (unsigned long)&m);
    pthread_mutex_lock(&m);

    print("%s:%d state=%u addr: %lx\n", __func__, __LINE__, *(uint32_t*)(&m), (unsigned long)&m);
    pthread_mutex_unlock(&m);
    print("%s:%d state=%u addr: %lx\n", __func__, __LINE__, *(uint32_t*)(&m), (unsigned long)&m);
  } while (true);
  return NULL;
}

int main()
{
  pthread_t sig;
  pthread_t cond;
  pthread_mutex_init(&m, NULL);
 
  pthread_create(&cond, NULL, cond_do, NULL);
  pthread_create(&sig, NULL, sig_do, NULL);

  while(1) {
      if (!fork()) {
          usleep(500);
          abort();
      }
      usleep(550);
  }

  pthread_join(sig, NULL);
  pthread_join(cond, NULL);

  return 0;
}
