Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AAA86B0033
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 12:48:06 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id c3so7488496itc.19
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 09:48:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n3si726455qkb.460.2017.10.09.09.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 09:48:04 -0700 (PDT)
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
References: <3ba05809-63a2-2969-e54f-fd0202fe336b@gmx.de>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <7403af16-ca37-fe4d-e6fc-b4a3cd78471f@oracle.com>
Date: Mon, 9 Oct 2017 09:47:56 -0700
MIME-Version: 1.0
In-Reply-To: <3ba05809-63a2-2969-e54f-fd0202fe336b@gmx.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>, linux-mm@kvack.org

On 10/06/2017 06:58 PM, C.Wehrmeyer wrote:
> This is my very first time reporting a Linux kernel problem. Despite my best efforts of doing homework I'm not yet used to the process.
> 

Thanks you for taking the effort to write to the list.

> Creating a private, anonymous mapping via mmap(2) which is supposed to use hugepages (test machine: x64 with 2-MiB pages) and later resizing that mapping via mremap(2) causes the kernel to return EINVAL. If the flags that create the hugepages mapping are omitted and thus allocating pages with the normal page size, mremap(2)succeeds.
> 
> The check to stop processing hugepages is in mm/mremap.c, function vma_to_resize:
> 
> if (is_vm_hugetlb_page(vma))
>         return ERR_PTR(-EINVAL);

You are correct.  That check in function vma_to_resize() will prevent
mremap from growing or relocating hugetlb backed mappings.  This check
existed in the 2.6.0 linux kernel, so this restriction has existed for
a very long time.  I'm guessing that growing or relocating a hugetlb
mapping was never allowed.  Perhaps the mremap man page should list this
restriction.

Is there a specific use case where the ability to grow hugetlb mappings
is desired?  Adding this functionality would involve more than simply
removing the above if statement.  One area of concern would be hugetlb
huge page reservations.  If there is a compelling use case, adding the
functionality may be worth consideration.  If not, I suggest we just
document the limitation.

-- 
Mike Kravetz


> 
> Furthermore, the code makes no further attempt to map page shifts and page sizes if a hugepage mapping has been detected. I have too little experience with programming in kernelland to provide a proper patch - a cobbler should stick to his last.
> 
> The problem was first encountered on a 4.8.10 kernel, but can still be encountered in the latest git snapshot from 3:30 AM, 2017-10-07 CEST.
> 
> Steps to reproduce: Enable at least two 2-MiB hugepages:
> # echo 2 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
> # cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
> 
> Note that due to memory fragmentation the kernel might have problems allocating a big enough amount of memory. The second statement should print "2".
> 
> Then compile and run the following program:
> 
> #define USE_HUGEPAGES
> #define _GNU_SOURCE
> 
> #include <errno.h> /*errno*/
> #include <stdio.h> /*fprintf*/
> 
> #include <sys/mman.h> /*mmap*/
> #include <asm/mman.h> /*hugepages flags*/
> 
> #define ALLOC_SIZE_1 (2 * 1024 * 1024)
> #define ALLOC_SIZE_2 (2 * ALLOC_SIZE_1)
> 
> int main(void)
> {
>         int errno_tmp = 0;
>         int prot  = PROT_READ | PROT_WRITE;
> 
>         const int flags_huge =
> #ifdef USE_HUGEPAGES
>         MAP_HUGETLB | MAP_HUGE_2MB
> #else
>         0
> #endif
>         ;
>         const int flags = MAP_PRIVATE | MAP_ANONYMOUS | flags_huge;
> 
>         void *buf1;
>         void *buf2;
>         /*****/
>         buf1 = mmap (
>                 NULL,
>                 ALLOC_SIZE_1,
>                 prot,
>                 flags,
>                 -1,
>                 0
>         );
> 
>         if (MAP_FAILED == buf1) {
>                 errno_tmp = errno;
>                 fprintf(stderr,"mmap: %u\n",errno_tmp);
>                 goto out;
>         }
>         /*****/
>         buf2 = mremap (
>                 buf1,
>                 ALLOC_SIZE_1,
>                 ALLOC_SIZE_2,
>                 MREMAP_MAYMOVE
>         );
> 
>         if (MAP_FAILED == buf2) {
>                 errno_tmp = errno;
>                 fprintf(stderr,"mremap: %u\n",errno_tmp);
>                 munmap(buf1,ALLOC_SIZE_1);
>                 goto out;
>         }
> 
>         fputs("mremap succeeded!\n",stdout);
>         munmap(buf2,ALLOC_SIZE_2);
> out:
>         return errno_tmp;
> }
> 
> Note that by commenting out USE_HUGEPAGES you can omit the flags that cause mremap to fail.
> 
> Using hugetlbfs is not a fix, but at most a workaround for this problem, seeing as the problem occurs with memory mappings. File systems shouldn't have anything to say when it comes to (simple) memory allocations.
> 
> Thank you very much.
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
