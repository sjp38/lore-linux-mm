Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 879F06B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 04:52:40 -0400 (EDT)
Received: by mail-qe0-f52.google.com with SMTP id jy17so2668864qeb.25
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 01:52:39 -0700 (PDT)
Message-ID: <5152B34B.6090406@gmail.com>
Date: Wed, 27 Mar 2013 16:52:27 +0800
From: wenchaolinux <wenchaolinux@gmail.com>
MIME-Version: 1.0
Subject: [RFC] provide an API to userspace doing memory snapshot
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: walken@google.com, riel@redhat.com, viro@zeniv.linux.org.uk, mingo@kernel.org, linux-mm@kvack.org

Hi,
  I'd like to add/export an system call which allow userspace program
to take snapshot for a region of memory. Since it is not implemented yet
I will describe it as C APIs, it is quite simple now and if it is worthy
I'll improve the interface later:

Simple prototype:
C API in userspace:
/*
 *   This function will mark a section of memory as COW, and return
 * a new virtual address of it. User space program can dump out the
 * content as a snapshot while other thread continue modify the content
 * in the region.
 *   @addr: the virtual address to be snapshotted.
 *   @length: the length of it.
 *   This function returns a new virtual address which can be used as
 * snapshot. Return NULL on fail.
 */
void *memory_snapshot_create(void *addr, uint64_t length);

/*
 *   This function will free the memory snapshot.
 *   @addr: the virtual snapshot addr to be freed, it should be the
 * returned one in memory_snapshot_create().
 */
void memory_snapshot_delete(void *addr);

In kernel space:
  The pages in those virtual address will be marked as COW. Take a
page with physical addr P0 as example, it will have two virtual addr:
old A0 and new A1. When modified, kernel should create a new page P1
with same contents, and mapping A1 to P1. When NUMA is used, P1 can
be a slower page.
  It is quite like fork(), but only COW part of pages.

Background:
  To provide a good snapshot for KVM, disk and RAM both need to be
snapshotted. A good way to do it is tagging the contents as COW,
which erase unnecessary I/O. Block device have this support, but
RAM is missing, so I'd like to add it. It can be done by fork(),
but it brings many unnecessary troubles and can't benefit when
NUMA is used, the core I need is COW the pages. Although the
requirement comes from virtualization but it do not use virtualization
tech and serve more than virtualization, any APP have some
un-interceptable changing pages, can use it, so I wonder whether can
add it as common memory API.

  That's my plan, hope to get your opinion for it.

Best Regards
Wenchao Xia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
