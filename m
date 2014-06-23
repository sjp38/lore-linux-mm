Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 010EC6B005A
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 09:31:28 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so4333794wib.0
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 06:31:26 -0700 (PDT)
Received: from demumfd002.nsn-inter.net (demumfd002.nsn-inter.net. [93.183.12.31])
        by mx.google.com with ESMTPS id xm12si16743687wib.10.2014.06.23.06.31.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 06:31:24 -0700 (PDT)
Date: Mon, 23 Jun 2014 15:35:37 +0200
From: Adam Endrodi <adam.endrodi@nsn.com>
Subject: mmap()ing a size-extended file on a 100% full tmpfs
Message-ID: <20140623133537.GD12012@timmy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org


Hello,


If you try to run the following program with /dev/shm being 100% full, it will
be terminated by a SIGBUS in memset():

"""
#define _GNU_SOURCE
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>

int main(void)
{
	int fd = shm_open("segg", O_CREAT|O_RDWR, 0666);
	printf("fd: %d\n", fd);
	printf("truncate: %d\n", ftruncate(fd, 1024*1024));
//	errno = posix_fallocate(fd, 0, 1024*1024);
//	printf("falloc: %s\n", strerror(errno));
	void *ptr = mmap(NULL, 1024*1024, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	printf("ptr: %p\n", ptr);

	memset(ptr, 0, 1024*1024);

	return 0;
}
"""

On a similarly full ext2 file system memset() completes successfully (though
I'm not sure whether it made through it by mere chance).

So the probelm is that the program may not know at all what the underlying
file system is, and in case of tmpfs it may be terminated for a completely
unexpected reason.

A portable solution could be to [posix_]fallocate() the file before trying to
mmap() it.  That works (except that perhaps tmpfs can deallocate memory if
it's under pressure).

Alternatively I could imagine such an ftruncate() implementation for tmpfs,
which would incorporate fallocate()ion.

In combination with this mmap() could refuse the operation if insufficient
backing store is available.  Ie. it would return MAP_FAILED if the programmer
didn't call ftruncate() which would include fallocate().

The wayland developers faced the same problem last year:
http://lists.freedesktop.org/archives/wayland-devel/2013-October/011501.html

My opinion is that either ftruncate() or mmap() should return an error.
What do you think?

-- 
adam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
