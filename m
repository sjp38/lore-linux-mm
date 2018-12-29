Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1E08E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 15:53:20 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q63so26126316pfi.19
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 12:53:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a8si10947444pgw.380.2018.12.29.12.53.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Dec 2018 12:53:18 -0800 (PST)
Date: Sat, 29 Dec 2018 12:53:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 202089] New: transparent hugepage not compatable with
 madvise(MADV_DONTNEED)
Message-Id: <20181229125316.27f7f1fedacfe4c1a5551a2d@linux-foundation.org>
In-Reply-To: <bug-202089-27@https.bugzilla.kernel.org/>
References: <bug-202089-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, jianpanlanyue@163.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 29 Dec 2018 09:00:22 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=202089
> 
>             Bug ID: 202089
>            Summary: transparent hugepage not compatable with
>                     madvise(MADV_DONTNEED)
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.4.0-117
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: jianpanlanyue@163.com
>         Regression: No
> 
> environment:  
>   1.kernel 4.4.0 on x86_64
>   2.echo always > /sys/kernel/mm/transparent_hugepage/enable
>     echo always > /sys/kernel/mm/transparent_hugepage/defrag
>     echo 2000000 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
> ( faster defrag pages to reproduce problem)
> 
> problem: 
>   1. use mmap() to allocate 4096 bytes for 1024*512 times (4096*1024*512=2G).
>   2. use madvise(MADV_DONTNEED) to free most of the above pages, but reserve a
> few pages(by if（i%33==0) continue;), then process's physical memory firstly
> come down, but after a few seconds, it rise back to 2G again, and can't come
> down forever.
>   3. if i delete this condition(if（i%33==0) continue;) or disable
> transparent_hugepage by setting 'enable' and 'defrag' to never, all go well and
> the physical memory can come down expectly.
> 
>   It seems like transparent_hugepage has problems with non-contiguous
> madvise(MADV_DONTEED).
> 
> 
> Belows is the test code:
> 
> #include <stdio.h>
> #include <memory.h>
> #include <stdlib.h>
> #include <sys/mman.h>
> #include <errno.h>
> #include <assert.h>
> 
> #define PAGE_SIZE 4096
> #define PAGE_COUNT 1024*512
> int main()
> {
>   void** table = (void**)malloc(sizeof(void*) * PAGE_COUNT);
>   printf("begin mmap...\n");
> 
>   for (int i=0; i<PAGE_COUNT; i++) {
>     table[i] = mmap(NULL, PAGE_SIZE, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_ANONYMOUS, -1 ,0);
>     assert(table[i] != MAP_FAILED);
>     memset(table[i], 1, PAGE_SIZE);
>   }
> 
>   printf("mmap ok, press enter to free most of them\n");
>   getchar();
> 
>   //it behaves not expectly: after most pages freed, thp make it rise to 2G
> again
>   for(int i=0; i<PAGE_COUNT; i++) {
>     if (i%33==0) continue;
>     if (madvise(table[i], PAGE_SIZE, MADV_DONTNEED) != 0)
>       printf("madvise error, errno:%d\n", errno);
>   }
> 
>   printf("munmap finish\n");
>   free(table);
>   getchar();
>   getchar();
> }
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
