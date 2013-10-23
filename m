Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id BB2E06B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 03:39:50 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y13so637337pdi.12
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 00:39:50 -0700 (PDT)
Received: from psmtp.com ([74.125.245.191])
        by mx.google.com with SMTP id hb3si14590062pac.181.2013.10.23.00.39.48
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 00:39:49 -0700 (PDT)
Date: Wed, 23 Oct 2013 16:39:43 +0900
From: Akira Takeuchi <takeuchi.akr@jp.panasonic.com>
Subject: Re: [PATCH] mm: Ensure get_unmapped_area() returns higheraddressthan mmap_min_addr
In-Reply-To: <1382511049-gd4rydjg-mutt-n-horiguchi@ah.jp.nec.com>
References: <20131023145303.B205.38390934@jp.panasonic.com> <1382511049-gd4rydjg-mutt-n-horiguchi@ah.jp.nec.com>
Message-Id: <20131023163943.B209.38390934@jp.panasonic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Wed, 23 Oct 2013 02:50:49 -0400
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> On Wed, Oct 23, 2013 at 02:53:03PM +0900, Akira Takeuchi wrote:
> > Hi,
> > 
> > On Wed, 23 Oct 2013 00:26:05 -0400
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > 
> > > Hi,
> > > 
> > > On Wed, Oct 23, 2013 at 11:46:53AM +0900, Akira Takeuchi wrote:
> > > > This patch fixes the problem that get_unmapped_area() can return illegal
> > > > address and result in failing mmap(2) etc.
> > > > 
> > > > In case that the address higher than PAGE_SIZE is set to
> > > > /proc/sys/vm/mmap_min_addr, the address lower than mmap_min_addr can be
> > > > returned by get_unmapped_area(), even if you do not pass any virtual
> > > > address hint (i.e. the second argument).
> > > > 
> > > > This is because the current get_unmapped_area() code does not take into
> > > > account mmap_min_addr.
> > > > 
> > > > This leads to two actual problems as follows:
> > > > 
> > > > 1. mmap(2) can fail with EPERM on the process without CAP_SYS_RAWIO,
> > > >    although any illegal parameter is not passed.
> > > > 
> > > > 2. The bottom-up search path after the top-down search might not work in
> > > >    arch_get_unmapped_area_topdown().
> > > > 
> > > > [How to reproduce]
> > > > 
> > > > 	--- test.c -------------------------------------------------
> > > > 	#include <stdio.h>
> > > > 	#include <unistd.h>
> > > > 	#include <sys/mman.h>
> > > > 	#include <sys/errno.h>
> > > > 
> > > > 	int main(int argc, char *argv[])
> > > > 	{
> > > > 		void *ret = NULL, *last_map;
> > > > 		size_t pagesize = sysconf(_SC_PAGESIZE);
> > > > 
> > > > 		do {
> > > > 			last_map = ret;
> > > > 			ret = mmap(0, pagesize, PROT_NONE,
> > > > 				MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
> > > > 	//		printf("ret=%p\n", ret);
> > > > 		} while (ret != MAP_FAILED);
> > > > 
> > > > 		if (errno != ENOMEM) {
> > > > 			printf("ERR: unexpected errno: %d (last map=%p)\n",
> > > > 			errno, last_map);
> > > > 		}
> > > > 
> > > > 		return 0;
> > > > 	}
> > > > 	---------------------------------------------------------------
> > > > 
> > > > 	$ gcc -m32 -o test test.c
> > > > 	$ sudo sysctl -w vm.mmap_min_addr=65536
> > > > 	vm.mmap_min_addr = 65536
> > > > 	$ ./test  (run as non-priviledge user)
> > > > 	ERR: unexpected errno: 1 (last map=0x10000)
> > > > 
> > > > Signed-off-by: Akira Takeuchi <takeuchi.akr@jp.panasonic.com>
> > > > Signed-off-by: Kiyoshi Owada <owada.kiyoshi@jp.panasonic.com>
> > > > ---
> > > >  mm/mmap.c |   10 +++++-----
> > > >  1 files changed, 5 insertions(+), 5 deletions(-)
> > > > 
> > > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > > index 9d54851..362e5f1 100644
> > > > --- a/mm/mmap.c
> > > > +++ b/mm/mmap.c
> > > > @@ -1856,7 +1856,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
> > > >  	struct vm_area_struct *vma;
> > > >  	struct vm_unmapped_area_info info;
> > > >  
> > > > -	if (len > TASK_SIZE)
> > > > +	if (len > TASK_SIZE - mmap_min_addr)
> > > >  		return -ENOMEM;
> > > >  
> > > >  	if (flags & MAP_FIXED)
> > > 
> > > I feel that it looks clearer to fix this in round_hint_to_min(),
> > > with doing mmap_min_addr check in hint == NULL case.
> > > Does it work for you?
> > 
> > The current round_hint_to_min() code checks and adjusts just for
> > the hint address, not for "len". Also, it returns no error.
> > 
> > Do you mean adding "len" to the argument of round_hint_to_min()
> > and making round_hint_to_min() return any error ?
> 
> I thought of just removing (hint != NULL) check in round_hint_to_min(),
> but in my rethinking I found that that affects other code and needs
> more changes, so your approach is simpler. I drop my suggestion.
> 
> The above check is to detect too big request, and in your reproducer
> len is small (4096), so I'm a bit confused :)  
> Although it doesn't fix your problem itself, it's correct, 

I'll add a description as a "Note" to my v2 patch to avoid such
confusing. The difference between v1 and v2 patch is only adding
the "Note". Thank you for reviewing !


Regadrs,
Akira Takeuchi


> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Thanks,
> Naoya Horiguchi
> 
> > 
> > Regards,
> > Akira Takeuchi
> > 
> > > Thanks,
> > > Naoya Horiguchi
> > > 
> > > > @@ -1865,7 +1865,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
> > > >  	if (addr) {
> > > >  		addr = PAGE_ALIGN(addr);
> > > >  		vma = find_vma(mm, addr);
> > > > -		if (TASK_SIZE - len >= addr &&
> > > > +		if (TASK_SIZE - len >= addr && addr >= mmap_min_addr &&
> > > >  		    (!vma || addr + len <= vma->vm_start))
> > > >  			return addr;
> > > >  	}
> > > > @@ -1895,7 +1895,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
> > > >  	struct vm_unmapped_area_info info;
> > > >  
> > > >  	/* requested length too big for entire address space */
> > > > -	if (len > TASK_SIZE)
> > > > +	if (len > TASK_SIZE - mmap_min_addr)
> > > >  		return -ENOMEM;
> > > >  
> > > >  	if (flags & MAP_FIXED)
> > > > @@ -1905,14 +1905,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
> > > >  	if (addr) {
> > > >  		addr = PAGE_ALIGN(addr);
> > > >  		vma = find_vma(mm, addr);
> > > > -		if (TASK_SIZE - len >= addr &&
> > > > +		if (TASK_SIZE - len >= addr && addr >= mmap_min_addr &&
> > > >  				(!vma || addr + len <= vma->vm_start))
> > > >  			return addr;
> > > >  	}
> > > >  
> > > >  	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
> > > >  	info.length = len;
> > > > -	info.low_limit = PAGE_SIZE;
> > > > +	info.low_limit = max(PAGE_SIZE, mmap_min_addr);
> > > >  	info.high_limit = mm->mmap_base;
> > > >  	info.align_mask = 0;
> > > >  	addr = vm_unmapped_area(&info);
> > > > -- 
> > > > 1.7.0.4
> > > > 
> > > > 
> > > > -- 
> > > > Akira Takeuchi <takeuchi.akr@jp.panasonic.com>
> > > > 
> > > > --
> > > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > > see: http://www.linux-mm.org/ .
> > > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > > > 
> > 
> > -- 
> > Akira Takeuchi <takeuchi.akr@jp.panasonic.com>
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 

-- 
Akira Takeuchi <takeuchi.akr@jp.panasonic.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
