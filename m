Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 864786B0098
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 05:36:07 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so770111pde.1
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 02:36:07 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id yl4si795393pbc.83.2014.04.08.02.36.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 08 Apr 2014 02:36:06 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N3P005MMHC17090@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 08 Apr 2014 10:36:01 +0100 (BST)
Message-id: <5343C301.3020702@samsung.com>
Date: Tue, 08 Apr 2014 11:36:01 +0200
From: Tomasz Stanislawski <t.stanislaws@samsung.com>
MIME-version: 1.0
Subject: [RFC] Faster mechanism for memory sharing with memfd
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dh.herrmann@gmail.com, linux-mm@kvack.org
Cc: "l.stelmach@samsung.com" <l.stelmach@samsung.com>

Hi everyone,
I came up with an idea for speeding up memory sharing with memfd.

The memfd introduced a idea of memory sealing. The memory is sealed
when only one mapping is allowed to exist. This forces peers
to repeat a costly mmap()/munmap() dance. Such an overhead
makes memfd mechanism beneficial only for transfer larder than 512 kB.

My idea is to avoid calling mmap()/munmap() at all by modifying
only 1st-lvel of process page tables (PT). This allows to use
page fault mechanism to prevent accessing the buffer without
destroying/recreating page tables.

_INTERNALS_

The new semantics consists of two operations LOCK and UNLOCK.
The reader/writer functions is recognized by access flags passed
to mmap() or to open().

* - means a comment

LOCK()
  - if owner is not NULL return -EPERM
  - set ownership of a buffer to the current process
    * protection from multiple writers
  FOR READER
  - invalidate cache
    * avoid reading no longer valid data from reader's L1 cache
  FOR WRITER
  - restore entry in 1st level PT (if any)
    * accessing the memory will no longer cause page faults

UNLOCK()
  - set buffer owner to NULL
    * allow other writers/readers to access a buffer
  FOR WRITER
  - store pointer to 2nd level page table (PT) in fd's private data
    * allow to restore writer's PT without recreating it
  - flush data cache for the buffer
    * make sure that updated data reached L2 and data is visible for other processes
  - set the entry in 1st level PT to PTE_NONE
    * force a page fault on an access to the buffer without owning it
  - invalidate TLB for the buffer region in VM
    * prevent avoiding a page fault if the page table entry is cached in TLB


Accessing a buffer by a writer outside LOCK() / UNLOCK() session
will cause a page fault. The virtually indexed L1 cache is flushed,
so CPU must use TLB to translate virtual-to-physical address.
There is no such an entry after flushing TLB in UNLOCK() so
CPU must do a page table walk. The walk will fail because
the entry in 1st level PT is empty. This will cause a page fault.

The page fault handler must check if a process has owenership
of the process it tries to access to. If ownership is NULL or
some other process then the page fault is "upgraded" to SEGFAULT,
effectively killing the process that had broken the memfd protocol.


_USE CASE_

The simple use case for new semantics is described below.
There are two processes called reader and writer.
The writer mmap() a buffer with read/write access rights.
The reader uses read-only permission.

The writer fills the buffer and passes it to reader in following.

1. open memfd descriptor and setup its size
2. Pass fd to the reader using sockets
3. mmap() the buffer
   - reserve a region in virtual address space that refers to
     single entry in 1st level page tables (1-4 MiB depending on architecture).
4. LOCK(buffer) (details below).
5. Fill the buffer with data
   - populate the page table on write faults
6. UNLOCK(buffer)
7. Ping the reader using other API (like eventfd/sockets/signals)

The reader process the buffer in following steps:

Pre. Assume that fd is already shared with writer and mmaped with RDONLY flags.
1. LOCK(buffer)
2. Read a buffer
3. UNLOCK (buffer)
4. Ping the writer that the buffer was processed.


_SUMMARY_

The benefits.

Basically it speeds up sharing on the writer's side.
There is no need for destruction of writer's page tables sealing a buffer.
Moreover, the page tables are cached in private data so there is no
need to recreate PT after retrieving buffer's ownership.

It is possible to modify LOCK/UNLOCK semantics to disallowing
concurrent reads. This might be useful for deciphering buffer content in place
on server's side.

The Problems.

The main disadvantage is difficult portability of presented solution.
The size of 2nd level page tables may greatly differ from platform to
platform. Moreover, the mechanism reserves the huge region in
virtual space for usage a single buffer. This might be a great waste
for a valuable resource on 32-bit machines. A possible workaround
might be using 3rd level entries for smaller buffers.

I understand that implementing such a change might require very good
understanding of MM's 'infernals'.

It should be investigated what is the actual bottleneck of the current
mechanism for memfd sharing. If the slowdown is caused by update of PTs
then the new mechanism will be very beneficial.
If performance loss is caused by cache flushes and TLB flushing then
the gain might be negligible. More profiling data are needed.

Regards,
Tomasz Stanislawski

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
