Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 53F106B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 19:25:53 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so6417637pab.20
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 16:25:52 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ob5si23823056pbb.102.2014.06.23.16.25.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 16:25:52 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so6419037pab.18
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 16:25:52 -0700 (PDT)
Date: Mon, 23 Jun 2014 16:23:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mmap()ing a size-extended file on a 100% full tmpfs
In-Reply-To: <20140623133537.GD12012@timmy>
Message-ID: <alpine.LSU.2.11.1406231551230.2083@eggly.anvils>
References: <20140623133537.GD12012@timmy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adam Endrodi <adam.endrodi@nsn.com>
Cc: linux-mm@kvack.org

On Mon, 23 Jun 2014, Adam Endrodi wrote:
> 
> Hello,
> 
> 
> If you try to run the following program with /dev/shm being 100% full, it will
> be terminated by a SIGBUS in memset():

Yes.

> 
> """
> #define _GNU_SOURCE
> #include <unistd.h>
> #include <errno.h>
> #include <string.h>
> #include <stdio.h>
> #include <fcntl.h>
> #include <sys/mman.h>
> 
> int main(void)
> {
> 	int fd = shm_open("segg", O_CREAT|O_RDWR, 0666);
> 	printf("fd: %d\n", fd);
> 	printf("truncate: %d\n", ftruncate(fd, 1024*1024));
> //	errno = posix_fallocate(fd, 0, 1024*1024);
> //	printf("falloc: %s\n", strerror(errno));
> 	void *ptr = mmap(NULL, 1024*1024, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
> 	printf("ptr: %p\n", ptr);
> 
> 	memset(ptr, 0, 1024*1024);
> 
> 	return 0;
> }
> """
> 
> On a similarly full ext2 file system memset() completes successfully (though
> I'm not sure whether it made through it by mere chance).

Well, I changed your "shm_open" above to "open", and ran from a full ext2
root, and from a full ext4 root: in each case got the same SIGBUS myself.

I wonder if you freed the space in your /dev/shm, and then ran the program
from a full ext2 root, but forgot that you were using shm_open(), which
was creating the file over in /dev/shm again.

> 
> So the probelm is that the program may not know at all what the underlying
> file system is, and in case of tmpfs it may be terminated for a completely
> unexpected reason.

It is normal to SIGBUS on an mmap'ed region when the filesystem cannot
provide backing store - usually because it has run out of space.

> 
> A portable solution could be to [posix_]fallocate() the file before trying to
> mmap() it.  That works (except that perhaps tmpfs can deallocate memory if
> it's under pressure).

Yes, please do use fallocate (or posix_fallocate) for that:
tmpfs will not deallocate what has been allocated.

> 
> Alternatively I could imagine such an ftruncate() implementation for tmpfs,
> which would incorporate fallocate()ion.

No, ftruncate and fallocate have different semantics: fallocate is
the right one to use if you want to allocate the space in advance.

> 
> In combination with this mmap() could refuse the operation if insufficient
> backing store is available.  Ie. it would return MAP_FAILED if the programmer
> didn't call ftruncate() which would include fallocate().

That would be a non-standard change in behaviour for mmap,
and would make some accepted uses of sparse (holey) files impossible.

> 
> The wayland developers faced the same problem last year:
> http://lists.freedesktop.org/archives/wayland-devel/2013-October/011501.html

Thanks for the link: which concludes that a fallocate is what's needed.

> 
> My opinion is that either ftruncate() or mmap() should return an error.
> What do you think?

I agree that SIGBUS can often be an unwelcome surprise, but disagree
that we should give ftruncate or mmap different behaviour on tmpfs.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
