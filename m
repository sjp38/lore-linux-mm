Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 5255F6B00D9
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 06:20:06 -0500 (EST)
Date: Mon, 12 Dec 2011 12:20:00 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mempolicy: refix mbind_range() vma issue
Message-ID: <20111212112000.GB18789@cmpxchg.org>
References: <1323449709-25923-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323449709-25923-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Caspar Zhang <caspar@casparzhang.com>

On Fri, Dec 09, 2011 at 11:55:09AM -0500, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> commit 8aacc9f550 (mm/mempolicy.c: fix pgoff in mbind vma merge) is
> slightly incorrect fix. It doesn't handle vma merge case 4 (see
> mmap.c#vma_merge() source comment).
> 
> This patch fixes it.
> 
> testcase:  mbind_vma_test.c
> =====================================================
>  #include <numaif.h>
>  #include <numa.h>
>  #include <sys/mman.h>
>  #include <stdio.h>
>  #include <unistd.h>
>  #include <stdlib.h>
>  #include <string.h>
> 
> static unsigned long pagesize;
> void* mmap_addr;
> struct bitmask *nmask;
> char buf[1024];
> FILE *file;
> char retbuf[10240] = "";
> 
> char *rubysrc = "ruby -e '\
>   pid = %d; \
>   vstart = 0x%llx; \
>   vend = 0x%llx; \
>   s = `pmap -q #{pid}`; \
>   rary = []; \
>   s.each_line {|line|; \
>     ary=line.split(\" \"); \
>     addr = ary[0].to_i(16); \
>     if(vstart <= addr && addr < vend) then \
>       rary.push(ary[1].to_i()/4); \
>     end; \
>   }; \
>   print rary.join(\",\"); \
> '";

;-)

But thanks for going through the test cases so meticulously!

That being said, would you mind including the output before and after
this patch in the changelog?

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

for the fix itself, but I think the changelog needs a bit more
information:

> @@ -636,6 +636,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
>  	struct vm_area_struct *prev;
>  	struct vm_area_struct *vma;
>  	int err = 0;
> +	pgoff_t pgoff;
>  	unsigned long vmstart;
>  	unsigned long vmend;
>  
> @@ -643,13 +644,17 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
>  	if (!vma || vma->vm_start > start)
>  		return -EFAULT;
>  
> +	if (start > vma->vm_start)
> +		prev = vma;
> +
>  	for (; vma && vma->vm_start < end; prev = vma, vma = next) {
>  		next = vma->vm_next;
>  		vmstart = max(start, vma->vm_start);
>  		vmend   = min(end, vma->vm_end);
>  
> +		pgoff = vma->vm_pgoff + ((vmstart - vma->vm_start) >> PAGE_SHIFT);
>  		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
> -				  vma->anon_vma, vma->vm_file, vma->vm_pgoff,
> +				  vma->anon_vma, vma->vm_file, pgoff,
>  				  new_pol);
>  		if (prev) {
>  			vma = prev;

This is essentially a revert of the aforementioned commit.

What you added instead is the fixing of @prev: only when mbind is
vma-aligned can the new area be potentially merged into the preceding
one.  Otherwise that original vma is the one we need to check for
compatibility with the mbind range and leave the original prev alone:

	[prev         ][vma            ]
	                    |start

	[prev         ][vma][mbind vma ]

This should NOT attempt to merge mbind vma with prev (and forget about
and leak vma, iirc), but check if vma and the mbind vma are compatible
or should be separate areas.

Could you please add something to that extent to the changelog?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
