Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 74CC36B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 22:16:31 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8G2GYSn019801
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Sep 2009 11:16:34 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AFA0A45DE57
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:16:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7245C45DE51
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:16:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5657A1DB8044
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:16:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CD5871DB803B
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:16:32 +0900 (JST)
Date: Wed, 16 Sep 2009 11:14:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] devmem: change vread()/vwrite() prototype to return
 success or error code
Message-Id: <20090916111425.967fd1ff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090916014958.722014998@intel.com>
References: <20090916013939.656308742@intel.com>
	<20090916014958.722014998@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009 09:39:40 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Silently ignore all vmalloc area holes in vread()/vwrite(),
> and report success (or error code in future) to the caller.
> 
> The original intention is to fix a vwrite() related bug, where
> it could return 0 which cannot be handled correctly by its caller
> write_kmem(). Then KAMEZAWA recommends to change the prototype
> to make the semantics clear.
> 
> CC: Andi Kleen <andi@firstfloor.org>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: Ingo Molnar <mingo@elte.hu>
> CC: Tejun Heo <tj@kernel.org>
> CC: Nick Piggin <npiggin@suse.de>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  drivers/char/mem.c      |   24 ++++++++--------
>  fs/proc/kcore.c         |    5 ++-
>  include/linux/vmalloc.h |    6 ++--
>  mm/nommu.c              |    8 ++---
>  mm/vmalloc.c            |   55 +++++++++++---------------------------
>  5 files changed, 40 insertions(+), 58 deletions(-)
> 
> --- linux-mm.orig/mm/vmalloc.c	2009-09-16 08:52:12.000000000 +0800
> +++ linux-mm/mm/vmalloc.c	2009-09-16 09:24:11.000000000 +0800
> @@ -1655,7 +1655,6 @@ EXPORT_SYMBOL(vmalloc_32_user);
>  static int aligned_vread(char *buf, char *addr, unsigned long count)
>  {
>  	struct page *p;
> -	int copied = 0;
>  
>  	while (count) {
>  		unsigned long offset, length;
> @@ -1685,16 +1684,14 @@ static int aligned_vread(char *buf, char
>  
>  		addr += length;
>  		buf += length;
> -		copied += length;
>  		count -= length;
>  	}
> -	return copied;
> +	return 0;
>  }
>  
>  static int aligned_vwrite(char *buf, char *addr, unsigned long count)
>  {
>  	struct page *p;
> -	int copied = 0;
>  
>  	while (count) {
>  		unsigned long offset, length;
> @@ -1722,10 +1719,9 @@ static int aligned_vwrite(char *buf, cha
>  		}
>  		addr += length;
>  		buf += length;
> -		copied += length;
>  		count -= length;
>  	}
> -	return copied;
> +	return 0;
>  }
>  
>  /**
> @@ -1734,9 +1730,7 @@ static int aligned_vwrite(char *buf, cha
>   *	@addr:		vm address.
>   *	@count:		number of bytes to be read.
>   *
> - *	Returns # of bytes which addr and buf should be increased.
> - *	(same number to @count). Returns 0 if [addr...addr+count) doesn't
> - *	includes any intersect with alive vmalloc area.
> + *	Returns 0 on success.

Seems to return 0 _always_. My version retunrs false if it's out-of-range.
plz return false if out-of-vmalloc-range.
Now, use vmalloc area is exported via /proc/vmallocinfo. Then, it's easy
to know "valid" vmalloc area. But users cannot know memory holes in
"valid" vmalloc area. So, vread() returns success even if it founds holes.

Another thought:
Should we purge vread/vwrite and just use copy_to/from_user ?
To do that, /proc/kcore should be revisited...
It has to copy pages one by one in aligned manner.

Anyway, it's merge window and not good season for this semantic changes of
a function.

>   *
>   *	This function checks that addr is a valid vmalloc'ed area, and
>   *	copy data from that area to a given buffer. If the given memory range
> @@ -1744,23 +1738,21 @@ static int aligned_vwrite(char *buf, cha
>   *	proper area of @buf. If there are memory holes, they'll be zero-filled.
>   *	IOREMAP area is treated as memory hole and no copy is done.
>   *
> - *	If [addr...addr+count) doesn't includes any intersects with alive
> - *	vm_struct area, returns 0.
>   *	@buf should be kernel's buffer. Because	this function uses KM_USER0,
>   *	the caller should guarantee KM_USER0 is not used.
>   *
>   *	Note: In usual ops, vread() is never necessary because the caller
>   *	should know vmalloc() area is valid and can use memcpy().
>   *	This is for routines which have to access vmalloc area without
> - *	any informaion, as /dev/kmem.
> + *	any information, as /dev/kmem and /dev/kcore.
>   *
>   */
>  
> -long vread(char *buf, char *addr, unsigned long count)
> +int vread(char *buf, char *addr, unsigned long count)
>  {
>  	struct vm_struct *tmp;
> -	char *vaddr, *buf_start = buf;
> -	unsigned long buflen = count;
> +	char *vaddr;
> +	char *buf_end = buf + count;
>  	unsigned long n;
>  
>  	/* Don't allow overflow */
> @@ -1794,13 +1786,11 @@ long vread(char *buf, char *addr, unsign
>  finished:
>  	read_unlock(&vmlist_lock);
>  
> -	if (buf == buf_start)
> -		return 0;
>  	/* zero-fill memory holes */
> -	if (buf != buf_start + buflen)
> -		memset(buf, 0, buflen - (buf - buf_start));
> +	if (buf != buf_end)
> +		memset(buf, 0, buf_end - buf);
>  
> -	return buflen;
> +	return 0;
>  }
>  
>  /**
> @@ -1809,10 +1799,7 @@ finished:
>   *	@addr:		vm address.
>   *	@count:		number of bytes to be read.
>   *
> - *	Returns # of bytes which addr and buf should be incresed.
> - *	(same number to @count).
> - *	If [addr...addr+count) doesn't includes any intersect with valid
> - *	vmalloc area, returns 0.
> + *	Returns 0 on success.
>   *
>   *	This function checks that addr is a valid vmalloc'ed area, and
>   *	copy data from a buffer to the given addr. If specified range of
> @@ -1820,30 +1807,24 @@ finished:
>   *	proper area of @buf. If there are memory holes, no copy to hole.
>   *	IOREMAP area is treated as memory hole and no copy is done.
>   *
> - *	If [addr...addr+count) doesn't includes any intersects with alive
> - *	vm_struct area, returns 0.
>   *	@buf should be kernel's buffer. Because	this function uses KM_USER0,
>   *	the caller should guarantee KM_USER0 is not used.
>   *
>   *	Note: In usual ops, vwrite() is never necessary because the caller
>   *	should know vmalloc() area is valid and can use memcpy().
>   *	This is for routines which have to access vmalloc area without
> - *	any informaion, as /dev/kmem.
> - *
> - *	The caller should guarantee KM_USER1 is not used.
> + *	any information, as /dev/kmem.
>   */
>  
> -long vwrite(char *buf, char *addr, unsigned long count)
> +int vwrite(char *buf, char *addr, unsigned long count)
>  {
>  	struct vm_struct *tmp;
>  	char *vaddr;
> -	unsigned long n, buflen;
> -	int copied = 0;
> +	unsigned long n;
>  
>  	/* Don't allow overflow */
>  	if ((unsigned long) addr + count < count)
>  		count = -(unsigned long) addr;
> -	buflen = count;
>  
>  	read_lock(&vmlist_lock);
>  	for (tmp = vmlist; count && tmp; tmp = tmp->next) {
> @@ -1860,19 +1841,15 @@ long vwrite(char *buf, char *addr, unsig
>  		n = vaddr + tmp->size - PAGE_SIZE - addr;
>  		if (n > count)
>  			n = count;
> -		if (!(tmp->flags & VM_IOREMAP)) {
> +		if (!(tmp->flags & VM_IOREMAP))
>  			aligned_vwrite(buf, addr, n);
> -			copied++;
> -		}
>  		buf += n;
>  		addr += n;
>  		count -= n;
>  	}
>  finished:
>  	read_unlock(&vmlist_lock);
> -	if (!copied)
> -		return 0;
> -	return buflen;
> +	return 0;
>  }
>  
>  /**
> --- linux-mm.orig/include/linux/vmalloc.h	2009-09-16 08:52:12.000000000 +0800
> +++ linux-mm/include/linux/vmalloc.h	2009-09-16 08:52:17.000000000 +0800
> @@ -104,9 +104,9 @@ extern void unmap_kernel_range(unsigned 
>  extern struct vm_struct *alloc_vm_area(size_t size);
>  extern void free_vm_area(struct vm_struct *area);
>  
> -/* for /dev/kmem */
> -extern long vread(char *buf, char *addr, unsigned long count);
> -extern long vwrite(char *buf, char *addr, unsigned long count);
> +/* for /dev/kmem and /dev/kcore */
> +extern int vread(char *buf, char *addr, unsigned long count);
> +extern int vwrite(char *buf, char *addr, unsigned long count);
>  
>  /*
>   *	Internals.  Dont't use..
> --- linux-mm.orig/drivers/char/mem.c	2009-09-16 08:52:12.000000000 +0800
> +++ linux-mm/drivers/char/mem.c	2009-09-16 09:23:00.000000000 +0800
> @@ -396,6 +396,7 @@ static ssize_t read_kmem(struct file *fi
>  	unsigned long p = *ppos;
>  	ssize_t low_count, read, sz;
>  	char * kbuf; /* k-addr because vread() takes vmlist_lock rwlock */
> +	int err = 0;
>  
>  	read = 0;
>  	if (p < (unsigned long) high_memory) {
> @@ -442,12 +443,12 @@ static ssize_t read_kmem(struct file *fi
>  			return -ENOMEM;
>  		while (count > 0) {
>  			sz = size_inside_page(p, count);
> -			sz = vread(kbuf, (char *)p, sz);
> -			if (!sz)
> +			err = vread(kbuf, (char *)p, sz);
> +			if (err)
>  				break;
>  			if (copy_to_user(buf, kbuf, sz)) {
> -				free_page((unsigned long)kbuf);
> -				return -EFAULT;
> +				err = -EFAULT;
> +				break;
>  			}
>  			count -= sz;
>  			buf += sz;
> @@ -457,7 +458,7 @@ static ssize_t read_kmem(struct file *fi
>  		free_page((unsigned long)kbuf);
>  	}
>   	*ppos = p;
> - 	return read;
> +	return read ? read : err;
>  }
>  
>  
> @@ -521,6 +522,7 @@ static ssize_t write_kmem(struct file * 
>  	ssize_t wrote = 0;
>  	ssize_t virtr = 0;
>  	char * kbuf; /* k-addr because vwrite() takes vmlist_lock rwlock */
> +	int err = 0;
>  
>  	if (p < (unsigned long) high_memory) {
>  		unsigned long to_write = min_t(unsigned long, count,
> @@ -543,12 +545,12 @@ static ssize_t write_kmem(struct file * 
>  
>  			n = copy_from_user(kbuf, buf, sz);
>  			if (n) {
> -				if (wrote + virtr)
> -					break;
> -				free_page((unsigned long)kbuf);
> -				return -EFAULT;
> +				err = -EFAULT;
> +				break;
>  			}
> -			sz = vwrite(kbuf, (char *)p, sz);
> +			err = vwrite(kbuf, (char *)p, sz);
> +			if (err)
> +				break;
>  			count -= sz;
>  			buf += sz;
>  			virtr += sz;
> @@ -558,7 +560,7 @@ static ssize_t write_kmem(struct file * 
>  	}
>  
>   	*ppos = p;
> - 	return virtr + wrote;
> +	return virtr + wrote ? : err;
>  }
>  #endif
>  
> --- linux-mm.orig/fs/proc/kcore.c	2009-09-16 08:52:12.000000000 +0800
> +++ linux-mm/fs/proc/kcore.c	2009-09-16 08:52:17.000000000 +0800
> @@ -492,11 +492,14 @@ read_kcore(struct file *file, char __use
>  				return -EFAULT;
>  		} else if (is_vmalloc_or_module_addr((void *)start)) {
>  			char * elf_buf;
> +			int err;
>  
>  			elf_buf = kzalloc(tsz, GFP_KERNEL);
>  			if (!elf_buf)
>  				return -ENOMEM;
> -			vread(elf_buf, (char *)start, tsz);
> +			err = vread(elf_buf, (char *)start, tsz);
> +			if (err)
> +				return err;

This is wrong.

/proc/kcore provides "coredump" image of kernel and it never faults.
Then, it doesn't check error code intentionally and just return
zero-filled buffer of reuqested length.

Thanks,
-Kame


>  			/* we have to zero-fill user buffer even if no read */
>  			if (copy_to_user(buffer, elf_buf, tsz)) {
>  				kfree(elf_buf);
> --- linux-mm.orig/mm/nommu.c	2009-09-16 09:01:36.000000000 +0800
> +++ linux-mm/mm/nommu.c	2009-09-16 09:02:02.000000000 +0800
> @@ -263,20 +263,20 @@ unsigned long vmalloc_to_pfn(const void 
>  }
>  EXPORT_SYMBOL(vmalloc_to_pfn);
>  
> -long vread(char *buf, char *addr, unsigned long count)
> +int vread(char *buf, char *addr, unsigned long count)
>  {
>  	memcpy(buf, addr, count);
> -	return count;
> +	return 0;
>  }
>  
> -long vwrite(char *buf, char *addr, unsigned long count)
> +int vwrite(char *buf, char *addr, unsigned long count)
>  {
>  	/* Don't allow overflow */
>  	if ((unsigned long) addr + count < count)
>  		count = -(unsigned long) addr;
>  
>  	memcpy(addr, buf, count);
> -	return(count);
> +	return 0;
>  }
>  
>  /*
> 
> -- 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
