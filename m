Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5E74A6B0038
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 19:43:24 -0400 (EDT)
Received: by obbop1 with SMTP id op1so36828383obb.2
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 16:43:24 -0700 (PDT)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id o24si18437167oik.62.2015.06.24.16.43.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jun 2015 16:43:23 -0700 (PDT)
Received: by obpn3 with SMTP id n3so36905789obp.0
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 16:43:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150624152518.d3a5408f2bde405df1e6e5c4@linux-foundation.org>
References: <CAA25o9SCnDYZ6vXWQWEWGDiwpV9rf+S_3Np8nJrWqHJ1x6-kMg@mail.gmail.com>
	<20150624152518.d3a5408f2bde405df1e6e5c4@linux-foundation.org>
Date: Wed, 24 Jun 2015 16:43:23 -0700
Message-ID: <CAA25o9RNLr4Gk_4m56bAf7_RBsObrccFWPtd-9jwuHg1NLdRTA@mail.gmail.com>
Subject: Re: extremely long blockages when doing random writes to SSD
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

Kernel version is 3.8.

I am not using a file system, I am writing directly into a partition.

Here's the little test app.  I call it "random-write" but you're
welcome to call it whatever you wish.

My apologies for the copyright notice.

/* Copyright 2015 The Chromium OS Authors. All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#define _FILE_OFFSET_BITS 64
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>

#define PAGE_SIZE 4096
#define GIGA (1024 * 1024 * 1024)

typedef u_int8_t u8;
typedef u_int64_t u64;

typedef char bool;
const bool true = 1;
const bool false = 0;


void permute_randomly(u64 *offsets, int offset_count) {
  int i;
  for (i = 0; i < offset_count; i++) {
    int r = random() % (offset_count - i) + i;
    u64 t = offsets[r];
    offsets[r] = offsets[i];
    offsets[i] = t;
  }
}

u8 page[4096];
off_t offsets[2 * (GIGA / PAGE_SIZE)];

int main(int ac, char **av) {
  u64 i;
  int out;

  /* Make "page" slightly non-empty, why not. */
  page[4] = 1;
  page[34] = 1;
  page[234] = 1;
  page[1234] = 1;

  for (i = 0; i < sizeof(offsets) / sizeof(offsets[0]); i++) {
    offsets[i] = i * PAGE_SIZE;
  }

  permute_randomly(offsets, sizeof(offsets) / sizeof(offsets[0]));

  if (ac < 2) {
    fprintf(stderr, "usage: %s <device>\n", av[0]);
    exit(1);
  }

  out = open(av[1], O_WRONLY);
  if (out < 0) {
    perror(av[1]);
    exit(1);
  }

  for (i = 0; i < sizeof(offsets) / sizeof(offsets[0]); i++) {
    int rc;
    if (lseek(out, offsets[i], SEEK_SET) < 0) {
      perror("lseek");
      exit(1);
    }
    rc = write(out, page, sizeof(page));
    if (rc < 0) {
      perror("write");
      exit(1);
    } else if (rc != sizeof(page)) {
      fprintf(stderr, "wrote %d bytes, expected %d\n", rc, sizeof(page));
      exit(1);
    }
  }
}

On Wed, Jun 24, 2015 at 3:25 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 24 Jun 2015 14:54:09 -0700 Luigi Semenzato <semenzato@google.com> wrote:
>
>> Greetings,
>>
>> we have an app that writes 4k blocks to an SSD partition with more or
>> less random seeks.  (For the curious: it's called "update engine" and
>> it's used to install a new Chrome OS version in the background.)  The
>> total size of the writes can be a few hundred megabytes.  During this
>> time, we see that other apps, such as the browser, block for seconds,
>> or tens of seconds.
>>
>> I have reproduced this behavior with a small program that writes 2GB
>> worth of 4k blocks randomly to the SSD partition.  I can get apps to
>> block for over 2 minutes, at which point our hang detector triggers
>> and panics the kernel.
>>
>> CPU: Intel Haswell i7
>> RAM: 4GB
>> SSD: 16GB SanDisk
>> kernel: 3.8
>>
>> >From /proc/meminfo I see that the "Buffers:" entry easily gets over
>> 1GB.  The problem goes away completely, as expected, if I use O_SYNC
>> when doing the random writes, but then the average size of the I/O
>> requests goes down a lot, also as expected.
>>
>> First of all, it seems that there may be some kind of resource
>> management bug.  Maybe it has been fixed in later kernels?  But, if
>> not, is there any way of encouraging some in-between behavior?  That
>> is, limit the allocation of I/O buffers to a smaller amount, which
>> still give the system a chance to do some coalescing, but perhaps
>> avoid the extreme badness that we are seeing?
>>
>
> What kernel version?
>
> Are you able to share that little test app with us?
>
> Which filesystem is being used and with what mount options etc?
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
