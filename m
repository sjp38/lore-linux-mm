Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 295D66B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 17:30:58 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id f51so3737441qge.26
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 14:30:57 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id g62si2459236qgg.146.2014.04.10.14.30.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 14:30:57 -0700 (PDT)
Message-ID: <53470E26.2030306@cybernetics.com>
Date: Thu, 10 Apr 2014 17:33:26 -0400
From: Tony Battersby <tonyb@cybernetics.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] shm: add sealing API
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org

(reposted from my comments at http://lwn.net/Articles/593918/)

I may have thought of a way to subvert SEAL_WRITE using O_DIRECT and
asynchronous I/O.  I am not sure if this is a real problem or not, but
better to ask, right?

The exploit would go like this:

1) mmap() the shared memory
2) open some *other* file with O_DIRECT
3) prepare a read-type iocb for the *other* file pointing to the
mmap()ed memory
4) io_submit(), but don't wait for it to complete
5) munmap() the shared memory
6) SEAL_WRITE the shared memory
7) the "sealed" memory is overwritten by DMA from the disk drive at some
point in the future when the I/O completes

So this exploit effectively changes the contents of the supposedly
write-protected memory after SEAL_WRITE is granted.

For O_DIRECT the kernel pins the submitted pages in memory for DMA by
incrementing the page reference counts when the I/O is submitted,
allowing the pages to be modified by DMA even if they are no longer
mapped in the address space of the process.  This is different from a
regular read(), which uses the CPU to copy the data and will fail if the
pages are not mapped.

I am sure there are also other direct I/O mechanisms in the kernel that
can be used to setup a DMA transfer to change the contents of unmapped
memory; the SCSI generic driver comes to mind.

I suppose SEAL_WRITE could iterate over all the pages in the file and
check to make sure no page refcount is greater than the "expected"
value, and return an error instead of granting the seal if a page is
found with an unexpected extra reference that might have been added by
e.g. get_user_pages() for direct I/O. But looking over shmem_set_seals()
in patch 2/6, it doesn't seem to do that.

Tony Battersby
Cybernetics

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
