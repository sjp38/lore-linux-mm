Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 624256B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 21:59:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r202so1864489wmd.17
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 18:59:31 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id y80si2575546wrc.478.2017.10.06.18.59.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 18:59:30 -0700 (PDT)
Received: from [192.168.1.103] ([94.114.72.182]) by mail.gmx.com (mrgmx003
 [212.227.17.190]) with ESMTPSA (Nemesis) id 0MbxJ8-1dkli31JfK-00JKmZ for
 <linux-mm@kvack.org>; Sat, 07 Oct 2017 03:59:29 +0200
From: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Subject: PROBLEM: Remapping hugepages mappings causes kernel to return EINVAL
Message-ID: <3ba05809-63a2-2969-e54f-fd0202fe336b@gmx.de>
Date: Sat, 7 Oct 2017 03:58:28 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This is my very first time reporting a Linux kernel problem. Despite my 
best efforts of doing homework I'm not yet used to the process.

Creating a private, anonymous mapping via mmap(2) which is supposed to 
use hugepages (test machine: x64 with 2-MiB pages) and later resizing 
that mapping via mremap(2) causes the kernel to return EINVAL. If the 
flags that create the hugepages mapping are omitted and thus allocating 
pages with the normal page size, mremap(2)succeeds.

The check to stop processing hugepages is in mm/mremap.c, function 
vma_to_resize:

if (is_vm_hugetlb_page(vma))
         return ERR_PTR(-EINVAL);

Furthermore, the code makes no further attempt to map page shifts and 
page sizes if a hugepage mapping has been detected. I have too little 
experience with programming in kernelland to provide a proper patch - a 
cobbler should stick to his last.

The problem was first encountered on a 4.8.10 kernel, but can still be 
encountered in the latest git snapshot from 3:30 AM, 2017-10-07 CEST.

Steps to reproduce: Enable at least two 2-MiB hugepages:
# echo 2 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
# cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

Note that due to memory fragmentation the kernel might have problems 
allocating a big enough amount of memory. The second statement should 
print "2".

Then compile and run the following program:

#define USE_HUGEPAGES
#define _GNU_SOURCE

#include <errno.h> /*errno*/
#include <stdio.h> /*fprintf*/

#include <sys/mman.h> /*mmap*/
#include <asm/mman.h> /*hugepages flags*/

#define ALLOC_SIZE_1 (2 * 1024 * 1024)
#define ALLOC_SIZE_2 (2 * ALLOC_SIZE_1)

int main(void)
{
         int errno_tmp = 0;
         int prot  = PROT_READ | PROT_WRITE;

         const int flags_huge =
#ifdef USE_HUGEPAGES
         MAP_HUGETLB | MAP_HUGE_2MB
#else
         0
#endif
         ;
         const int flags = MAP_PRIVATE | MAP_ANONYMOUS | flags_huge;

         void *buf1;
         void *buf2;
         /*****/
         buf1 = mmap (
                 NULL,
                 ALLOC_SIZE_1,
                 prot,
                 flags,
                 -1,
                 0
         );

         if (MAP_FAILED == buf1) {
                 errno_tmp = errno;
                 fprintf(stderr,"mmap: %u\n",errno_tmp);
                 goto out;
         }
         /*****/
         buf2 = mremap (
                 buf1,
                 ALLOC_SIZE_1,
                 ALLOC_SIZE_2,
                 MREMAP_MAYMOVE
         );

         if (MAP_FAILED == buf2) {
                 errno_tmp = errno;
                 fprintf(stderr,"mremap: %u\n",errno_tmp);
                 munmap(buf1,ALLOC_SIZE_1);
                 goto out;
         }

         fputs("mremap succeeded!\n",stdout);
         munmap(buf2,ALLOC_SIZE_2);
out:
         return errno_tmp;
}

Note that by commenting out USE_HUGEPAGES you can omit the flags that 
cause mremap to fail.

Using hugetlbfs is not a fix, but at most a workaround for this problem, 
seeing as the problem occurs with memory mappings. File systems 
shouldn't have anything to say when it comes to (simple) memory allocations.

Thank you very much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
