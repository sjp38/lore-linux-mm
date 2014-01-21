Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f53.google.com (mail-vb0-f53.google.com [209.85.212.53])
	by kanga.kvack.org (Postfix) with ESMTP id 40AFA6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 19:59:46 -0500 (EST)
Received: by mail-vb0-f53.google.com with SMTP id p17so3111994vbe.40
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 16:59:45 -0800 (PST)
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
        by mx.google.com with ESMTPS id tj7si1010788vdc.46.2014.01.20.16.59.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 16:59:45 -0800 (PST)
Received: by mail-vc0-f169.google.com with SMTP id hq11so3181137vcb.14
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 16:59:44 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 20 Jan 2014 16:59:23 -0800
Message-ID: <CALCETrVT29DULWg16_oKpGgSSBwZh-yWtygV1oYjH5iQH5jGyg@mail.gmail.com>
Subject: Dirty deleted files cause pointless I/O storms (unless truncated first)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

The code below runs quickly for a few iterations, and then it slows
down and the whole system becomes laggy for far too long.

Removing the sync_file_range call results in no I/O being performed at
all (which means that the kernel isn't totally screwing this up), and
changing "4096" to SIZE causes lots of I/O but without
the going-out-to-lunch bit (unsurprisingly).

Surprisingly, uncommenting the ftruncate call seems to fix the
problem.  This suggests that all the necessary infrastructure to avoid
wasting time writing to deleted files is there but that it's not
getting used.


#define _GNU_SOURCE
#include <sys/mman.h>
#include <err.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#define SIZE (16 * 1048576)

static void hammer(const char *name)
{
  int fd = open(name, O_RDWR | O_CREAT | O_EXCL, 0600);
  if (fd == -1)
    err(1, "open");

  fallocate(fd, 0, 0, SIZE);

  void *addr = mmap(NULL, SIZE, PROT_WRITE, MAP_SHARED, fd, 0);
  if (addr == MAP_FAILED)
    err(1, "mmap");

  memset(addr, 0, SIZE);

  if (munmap(addr, SIZE) != 0)
    err(1, "munmap");

  if (sync_file_range(fd, 0, 4096,
              SYNC_FILE_RANGE_WAIT_BEFORE | SYNC_FILE_RANGE_WRITE |
              SYNC_FILE_RANGE_WAIT_AFTER) != 0)
    err(1, "sync_file_range");

  if (unlink(name) != 0)
    err(1, "unlink");

  //  if (ftruncate(fd, 0) != 0)
  //    err(1, "ftruncate");

  close(fd);
}

int main(int argc, char **argv)
{
  if (argc != 2) {
    printf("Usage: hammer_and_delete FILENAME\n");
    return 1;
  }

  while (true) {
    hammer(argv[1]);
    write(1, ".", 1);
  }
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
