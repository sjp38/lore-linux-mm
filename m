Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2DE6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:47:59 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so45379898pdn.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:47:59 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id c1si5926420pdc.50.2015.03.25.17.47.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 17:47:55 -0700 (PDT)
Received: by pdnc3 with SMTP id c3so45378266pdn.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:47:54 -0700 (PDT)
Date: Wed, 25 Mar 2015 17:47:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB
 aligned
In-Reply-To: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3>
Message-ID: <alpine.LSU.2.11.1503251708530.5592@eggly.anvils>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 22 Oct 2014, Davide Libenzi wrote:

> [Resending with proper CC list suggested by Andrew]

I have recently been reminded of this languishing in my inbox ;)
(along with many others that I won't get to answer so quickly).

And in turn it reminds me of an older from Joern, who was annoyed
that he couldn't mmap a hugetlbfs file with MAP_HUGETLB.

Cc'ing more people, including Eric, the father of MAP_HUGETLB.

> 
> Calling munmap on a MAP_HUGETLB area, and a size which is not 2MB aligned, 
> causes munmap to fail.  Tested on 3.13.x but tracking back to 3.2.x.

When you say "tracking back to 3.2.x", I think you mean you've tried as
far back as 3.2.x and found the same behaviour, but not tried further?

>From the source, it looks like this is unchanged since MAP_HUGETLB was
introduced in 2.6.32.  And is the same behaviour as you've been given
with hugetlbfs since it arrived in 2.5.46.

> In do_munmap() we forcibly want a 4KB default page, and we wrongly 
> calculate the end of the map.  Since the calculated end is within the end 
> address of the target vma, we try to do a split with an address right in 
> the middle of a huge page, which would fail with EINVAL.
> 
> Tentative (untested) patch and test case attached (be sure you have a few 
> huge pages available via /proc/sys/vm/nr_hugepages tinkering).
> 
> 
> Signed-Off-By: Davide Libenzi <davidel@xmailserver.org>

The patch looks to me as if it will do what you want, and I agree
that it's displeasing that you can mmap a size, and then fail to
munmap that same size.

But I tend to think that's simply typical of the clunkiness we offer
you with hugetlbfs and MAP_HUGETLB: that it would have been better to
make a different choice all those years ago, but wrong to change the
user interface now.

Perhaps others will disagree.  And if I'm wrong, and the behaviour
got somehow changed in 3.2, then that's a different story and we
should fix it back.

Hugh

> 
> 
> - Davide
> 
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7f85520..6dba257 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2528,10 +2528,6 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
>  	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
>  		return -EINVAL;
>  
> -	len = PAGE_ALIGN(len);
> -	if (len == 0)
> -		return -EINVAL;
> -
>  	/* Find the first overlapping VMA */
>  	vma = find_vma(mm, start);
>  	if (!vma)
> @@ -2539,6 +2535,16 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
>  	prev = vma->vm_prev;
>  	/* we have  start < vma->vm_end  */
>  
> +	if (likely(!is_vm_hugetlb_page(vma)))
> +		len = PAGE_ALIGN(len);
> +	else {
> +		unsigned long hpage_size = huge_page_size(hstate_vma(vma));
> +
> +		len = ALIGN(len, hpage_size);
> +	}
> +	if (unlikely(len == 0))
> +		return -EINVAL;
> +
>  	/* if it doesn't overlap, we have nothing.. */
>  	end = start + len;
>  	if (vma->vm_start >= end)
> 
> 
> 
> 
> [hugebug.c]
> 
> #include <sys/mman.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <errno.h>
> 
> static void test(int flags, size_t size)
> {
>     void* addr = mmap(NULL, size, PROT_READ | PROT_WRITE,
>                       flags | MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
> 
>     if (addr == MAP_FAILED)
>     {
>         perror("mmap");
>         exit(1);
>     }
>     *(char*) addr = 17;
> 
>     if (munmap(addr, size) != 0)
>     {
>         perror("munmap");
>         exit(1);
>     }
> }
> 
> int main(int ac, const char** av)
> {
>     static const size_t hugepage_size = 2 * 1024 * 1024;
> 
>     printf("Testing normal pages with 2MB size ...\n");
>     test(0, hugepage_size);
>     printf("OK\n");
> 
>     printf("Testing huge pages with 2MB size ...\n");
>     test(MAP_HUGETLB, hugepage_size);
>     printf("OK\n");
> 
> 
>     printf("Testing normal pages with 4KB byte size ...\n");
>     test(0, 4096);
>     printf("OK\n");
> 
>     printf("Testing huge pages with 4KB byte size ...\n");
>     test(MAP_HUGETLB, 4096);
>     printf("OK\n");
> 
> 
>     printf("Testing normal pages with 1 byte size ...\n");
>     test(0, 1);
>     printf("OK\n");
> 
>     printf("Testing huge pages with 1 byte size ...\n");
>     test(MAP_HUGETLB, 1);
>     printf("OK\n");
> 
>     return 0;
> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
