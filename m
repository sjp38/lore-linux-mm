Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E56236B0096
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 20:41:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o071feWC030324
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 10:41:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A24E245DE51
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 10:41:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F9C81EF082
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 10:41:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 47E461DB803F
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 10:41:40 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DDD2A1DB803C
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 10:41:39 +0900 (JST)
Date: Thu, 7 Jan 2010 10:38:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmalloc: simplify vread()/vwrite()
Message-Id: <20100107103825.239ffcf9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100107012458.GA9073@localhost>
References: <20100107012458.GA9073@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 09:24:59 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> vread()/vwrite() is only called from kcore/kmem to access one page at
> a time.  So the logic can be vastly simplified.
> 
I recommend you to rename the function because safety of function is
changed and you can show what callers are influenced.


> The changes are:
> - remove the vmlist walk and rely solely on vmalloc_to_page()
> - replace the VM_IOREMAP check with (page && page_is_ram(pfn))
> 
> The VM_IOREMAP check is introduced in commit d0107eb07320b for per-cpu
> alloc. Kame, would you double check if this change is OK for that
> purpose?
> 
I think VM_IOREMAP is for avoiding access to device configuration area and
unexpected breakage in device. Then, VM_IOREMAP are should be skipped by
the caller. (My patch _just_ moves the avoidance of callers to vread()/vwrite())


> The page_is_ram() check is necessary because kmap_atomic() is not
> designed to work with non-RAM pages.
> 
I think page_is_ram() is not a complete method...on x86, it just check
e820's memory range. checking VM_IOREMAP is better, I think.

> Even for a RAM page, we don't own the page, and cannot assume it's a
> _PAGE_CACHE_WB page. So I wonder whether it's necessary to do another
> patch to call reserve_memtype() before kmap_atomic() to ensure cache
> consistency?
> 
> TODO: update comments accordingly
> 

BTW, f->f_pos problem on 64bit machine still exists and this patch is still
hard to test. I stopped that because anyone doesn't show any interests.

I have no objection to your direction.

but please rewrite the function explanation as
"addr" should be page alinged and bufsize should be multiple of page size."
and change the function names.

Thanks,
-Kame


> CC: Tejun Heo <tj@kernel.org>
> CC: Ingo Molnar <mingo@elte.hu>
> CC: Nick Piggin <npiggin@suse.de>
> CC: Andi Kleen <andi@firstfloor.org> 
> CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/vmalloc.c |  196 ++++++++++---------------------------------------
>  1 file changed, 40 insertions(+), 156 deletions(-)
> 
> --- linux-mm.orig/mm/vmalloc.c	2010-01-04 10:23:12.000000000 +0800
> +++ linux-mm/mm/vmalloc.c	2010-01-05 12:42:40.000000000 +0800
> @@ -1646,87 +1646,6 @@ void *vmalloc_32_user(unsigned long size
>  }
>  EXPORT_SYMBOL(vmalloc_32_user);
>  
> -/*
> - * small helper routine , copy contents to buf from addr.
> - * If the page is not present, fill zero.
> - */
> -
> -static int aligned_vread(char *buf, char *addr, unsigned long count)
> -{
> -	struct page *p;
> -	int copied = 0;
> -
> -	while (count) {
> -		unsigned long offset, length;
> -
> -		offset = (unsigned long)addr & ~PAGE_MASK;
> -		length = PAGE_SIZE - offset;
> -		if (length > count)
> -			length = count;
> -		p = vmalloc_to_page(addr);
> -		/*
> -		 * To do safe access to this _mapped_ area, we need
> -		 * lock. But adding lock here means that we need to add
> -		 * overhead of vmalloc()/vfree() calles for this _debug_
> -		 * interface, rarely used. Instead of that, we'll use
> -		 * kmap() and get small overhead in this access function.
> -		 */
> -		if (p) {
> -			/*
> -			 * we can expect USER0 is not used (see vread/vwrite's
> -			 * function description)
> -			 */
> -			void *map = kmap_atomic(p, KM_USER0);
> -			memcpy(buf, map + offset, length);
> -			kunmap_atomic(map, KM_USER0);
> -		} else
> -			memset(buf, 0, length);
> -
> -		addr += length;
> -		buf += length;
> -		copied += length;
> -		count -= length;
> -	}
> -	return copied;
> -}
> -
> -static int aligned_vwrite(char *buf, char *addr, unsigned long count)
> -{
> -	struct page *p;
> -	int copied = 0;
> -
> -	while (count) {
> -		unsigned long offset, length;
> -
> -		offset = (unsigned long)addr & ~PAGE_MASK;
> -		length = PAGE_SIZE - offset;
> -		if (length > count)
> -			length = count;
> -		p = vmalloc_to_page(addr);
> -		/*
> -		 * To do safe access to this _mapped_ area, we need
> -		 * lock. But adding lock here means that we need to add
> -		 * overhead of vmalloc()/vfree() calles for this _debug_
> -		 * interface, rarely used. Instead of that, we'll use
> -		 * kmap() and get small overhead in this access function.
> -		 */
> -		if (p) {
> -			/*
> -			 * we can expect USER0 is not used (see vread/vwrite's
> -			 * function description)
> -			 */
> -			void *map = kmap_atomic(p, KM_USER0);
> -			memcpy(map + offset, buf, length);
> -			kunmap_atomic(map, KM_USER0);
> -		}
> -		addr += length;
> -		buf += length;
> -		copied += length;
> -		count -= length;
> -	}
> -	return copied;
> -}
> -
>  /**
>   *	vread() -  read vmalloc area in a safe way.
>   *	@buf:		buffer for reading data
> @@ -1757,49 +1676,34 @@ static int aligned_vwrite(char *buf, cha
>  
>  long vread(char *buf, char *addr, unsigned long count)
>  {
> -	struct vm_struct *tmp;
> -	char *vaddr, *buf_start = buf;
> -	unsigned long buflen = count;
> -	unsigned long n;
> -
> -	/* Don't allow overflow */
> -	if ((unsigned long) addr + count < count)
> -		count = -(unsigned long) addr;
> +	struct page *p;
> +	void *map;
> +	int offset = (unsigned long)addr & (PAGE_SIZE - 1);
>  
> -	read_lock(&vmlist_lock);
> -	for (tmp = vmlist; count && tmp; tmp = tmp->next) {
> -		vaddr = (char *) tmp->addr;
> -		if (addr >= vaddr + tmp->size - PAGE_SIZE)
> -			continue;
> -		while (addr < vaddr) {
> -			if (count == 0)
> -				goto finished;
> -			*buf = '\0';
> -			buf++;
> -			addr++;
> -			count--;
> -		}
> -		n = vaddr + tmp->size - PAGE_SIZE - addr;
> -		if (n > count)
> -			n = count;
> -		if (!(tmp->flags & VM_IOREMAP))
> -			aligned_vread(buf, addr, n);
> -		else /* IOREMAP area is treated as memory hole */
> -			memset(buf, 0, n);
> -		buf += n;
> -		addr += n;
> -		count -= n;
> -	}
> -finished:
> -	read_unlock(&vmlist_lock);
> +	/* Assume subpage access */
> +	BUG_ON(count > PAGE_SIZE - offset);
>  
> -	if (buf == buf_start)
> +	p = vmalloc_to_page(addr);
> +	if (!p || !page_is_ram(page_to_pfn(p))) {
> +		memset(buf, 0, count);
>  		return 0;
> -	/* zero-fill memory holes */
> -	if (buf != buf_start + buflen)
> -		memset(buf, 0, buflen - (buf - buf_start));
> +	}
>  
> -	return buflen;
> +	/*
> +	 * To do safe access to this _mapped_ area, we need
> +	 * lock. But adding lock here means that we need to add
> +	 * overhead of vmalloc()/vfree() calles for this _debug_
> +	 * interface, rarely used. Instead of that, we'll use
> +	 * kmap() and get small overhead in this access function.
> +	 *
> +	 * we can expect USER0 is not used (see vread/vwrite's
> +	 * function description)
> +	 */
> +	map = kmap_atomic(p, KM_USER0);
> +	memcpy(buf, map + offset, count);
> +	kunmap_atomic(map, KM_USER0);
> +
> +	return count;
>  }
>  
>  /**
> @@ -1834,44 +1738,24 @@ finished:
>  
>  long vwrite(char *buf, char *addr, unsigned long count)
>  {
> -	struct vm_struct *tmp;
> -	char *vaddr;
> -	unsigned long n, buflen;
> -	int copied = 0;
> -
> -	/* Don't allow overflow */
> -	if ((unsigned long) addr + count < count)
> -		count = -(unsigned long) addr;
> -	buflen = count;
> +	struct page *p;
> +	void *map;
> +	int offset = (unsigned long)addr & (PAGE_SIZE - 1);
>  
> -	read_lock(&vmlist_lock);
> -	for (tmp = vmlist; count && tmp; tmp = tmp->next) {
> -		vaddr = (char *) tmp->addr;
> -		if (addr >= vaddr + tmp->size - PAGE_SIZE)
> -			continue;
> -		while (addr < vaddr) {
> -			if (count == 0)
> -				goto finished;
> -			buf++;
> -			addr++;
> -			count--;
> -		}
> -		n = vaddr + tmp->size - PAGE_SIZE - addr;
> -		if (n > count)
> -			n = count;
> -		if (!(tmp->flags & VM_IOREMAP)) {
> -			aligned_vwrite(buf, addr, n);
> -			copied++;
> -		}
> -		buf += n;
> -		addr += n;
> -		count -= n;
> -	}
> -finished:
> -	read_unlock(&vmlist_lock);
> -	if (!copied)
> +	/* Assume subpage access */
> +	BUG_ON(count > PAGE_SIZE - offset);
> +
> +	p = vmalloc_to_page(addr);
> +	if (!p)
> +		return 0;
> +	if (!page_is_ram(page_to_pfn(p)))
>  		return 0;
> -	return buflen;
> +
> +	map = kmap_atomic(p, KM_USER0);
> +	memcpy(map + offset, buf, count);
> +	kunmap_atomic(map, KM_USER0);
> +
> +	return count;
>  }
>  
>  /**
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
