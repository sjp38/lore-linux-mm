Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B4E986B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:53:46 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so141281904pad.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 03:53:46 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id xl5si22563184pab.188.2015.09.14.03.53.45
        for <linux-mm@kvack.org>;
        Mon, 14 Sep 2015 03:53:46 -0700 (PDT)
Date: Mon, 14 Sep 2015 11:53:46 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: LTP regressions due to 6dc296e7df4c ("mm: make sure all file VMAs
 have ->vm_ops set")
Message-ID: <20150914105346.GB23878@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: oleg@redhat.com, hpa@zytor.com, luto@amacapital.net, dave.hansen@linux.intel.com, mingo@elte.hu, minchan@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kirill,

Your patch 6dc296e7df4c ("mm: make sure all file VMAs have ->vm_ops set")
causes some mmap regressions in LTP, which appears to use a MAP_PRIVATE
mmap of /dev/zero as a way to get anonymous pages in some of its tests
(specifically mmap10 [1]).

Dead simple reproducer below. Is this change in behaviour intentional?

Will

[1]
http://sourceforge.net/p/ltp/git/ci/1eb440c2b5fe43a3e5023015a16aa5d7d3385b1e/tree/testcases/kernel/syscalls/mmap/mmap10.c

--->8

#include <sys/mman.h>
#include <sys/stat.h>

#include <fcntl.h>
#include <stdio.h>

#define MAP_SZ	5*1024*1024

int main(void)
{
	char *foo;
	int fd;

	fd = open("/dev/zero", O_RDWR, 0666);
	if (fd < 0) {
		perror(NULL);
		return fd;
	}

	foo = mmap(NULL, MAP_SZ, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
	if (foo == MAP_FAILED) {
		perror(NULL);
		return -1;
	}

	foo[MAP_SZ >> 1] = 0; // Generates SIGBUS with 4.3-rc1
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
