Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 294A344084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:49:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so24404980wrc.2
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 06:49:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 68si6767445wmq.33.2017.07.10.06.49.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 06:49:19 -0700 (PDT)
Date: Mon, 10 Jul 2017 15:49:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
Message-ID: <20170710134917.GB19645@dhcp22.suse.cz>
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Mon 10-07-17 16:40:59, Anshuman Khandual wrote:
> As 'delta' is an unsigned long, 'end' (vma->vm_end + delta) cannot
> be less than 'vma->vm_end'.

This just doesn't make any sense. This is exactly what the overflow
check is for. Maybe vm_end + delta can never overflow because of
(old_len == vma->vm_end - addr) and guarantee old_len < new_len
in mremap but I haven't checked that too deeply.

> Checking for availability of virtual
> address range at the end of the VMA for the incremental size is
> also reduntant at this point. Hence drop them both.

OK, this seems to be the case due the above (comment says "old_len
exactly to the end of the area..").

But I am wondering what led you to the patch because you do not say so
here. This is hardly something that would save many cycles in a
relatively cold path.

> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
> 
> The following test program achieves fatser execution time with
> this change.
> 
> #include <stdio.h>
> #include <string.h>
> #include <unistd.h>
> #include <errno.h>
> #include <sys/mman.h>
> #include <sys/time.h>
> 
> #define ALLOC_SIZE 0x10000UL
> #define MAX_COUNT 1024 * 1024
> 
> int main(int argc, char *argv[])
> {
>         unsigned long count;
>         char *ptr;
> 
>         ptr = mmap(NULL, ALLOC_SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE| MAP_ANONYMOUS, -1, 0);
>         if (ptr == MAP_FAILED) {
>                 perror("map() failed");
>                 return -1;
>         }
>         memset(ptr, 0, ALLOC_SIZE);
> 
>         for (count = 1; count <= MAX_COUNT; count++) {
>                 ptr =  (char *) mremap(ptr, ALLOC_SIZE * count, ALLOC_SIZE * (count + 1), 1);
>                 if (ptr == MAP_FAILED) {
>                         perror("mremap() failed");
>                         printf("At %lu size", ALLOC_SIZE * (count + 1));
>                         return -1;
>                 }
>                 /*
>                 memset(ptr, 0, ALLOC_SIZE * (count + 1));
>                 */
>         }
> 
> 
>         for (count = MAX_COUNT; count > 1; count--) {
>                 ptr =  (char *) mremap(ptr, ALLOC_SIZE * count, ALLOC_SIZE * (count - 1), 1);
>                 if (ptr == MAP_FAILED) {
>                         perror("mremap() failed");
>                         printf("At %lu size", ALLOC_SIZE * (count - 1));
>                         return -1;
>                 }
>                 /*
>                 memset(ptr, 0, ALLOC_SIZE * (count - 1));
>                 */
>         }
>         return 0;
> }
> 
> 
>  mm/mremap.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index cd8a1b1..b937c28 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -487,12 +487,9 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
>  static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
>  {
>  	unsigned long end = vma->vm_end + delta;
> -	if (end < vma->vm_end) /* overflow */
> -		return 0;
> -	if (vma->vm_next && vma->vm_next->vm_start < end) /* intersection */
> -		return 0;
> -	if (get_unmapped_area(NULL, vma->vm_start, end - vma->vm_start,
> -			      0, MAP_FIXED) & ~PAGE_MASK)
> +
> +	/* Intersection with next VMA */
> +	if (vma->vm_next && vma->vm_next->vm_start < end)
>  		return 0;
>  	return 1;
>  }
> -- 
> 1.8.5.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
