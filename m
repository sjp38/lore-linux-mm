Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE1D6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 10:01:24 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id t20so5474682wju.5
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:01:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xw10si89427816wjb.253.2017.01.06.07.01.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 07:01:22 -0800 (PST)
Date: Fri, 6 Jan 2017 16:01:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: hugetlb: reservation race leading to under provisioning
Message-ID: <20170106150121.GP5556@dhcp22.suse.cz>
References: <20170105151540.GT21618@dhcp22.suse.cz>
 <a46ad76e-2d73-1138-b871-fc110cc9d596@oracle.com>
 <20170106085808.GE5556@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106085808.GE5556@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Paul Cassella <cassella@cray.com>

I have only now realized I haven't attached the promissed program to
replicate the issue.

$ cat badmmap.c
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <hugetlbfs.h>
#include <sys/mman.h>
int main(int argc, const char **argv) {
  const size_t len = 224 * 1024 * 1024;
  int count = (argc > 1) ? atoi(argv[1]) : 1000;
  int i;
  for (i = 0; i < count; ++i) {
    int fd = hugetlbfs_unlinked_fd();
    void *ptr = mmap(0, len, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
      fprintf(stderr, "mmap() failed on iteration %d (%s)\n", i, strerror(errno));
      return 1;
    }
    close(fd);
    if (munmap(ptr, len) < 0) {
      fprintf(stderr, "munmap() failed on iteration %d (%s)\n", i, strerror(errno));
      return 1;
    }
  }
  printf("PASSED %d iters\n", count);
  return 0;
}

$ cc -o badmmap badmmap.c -lhugetlbfs

Run 8 or so instances in parallel to reproduce.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
