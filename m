Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 18E956B000D
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 05:33:39 -0500 (EST)
Message-ID: <1359023612.2394.17.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [PATCH 1/8] mm: use vm_unmapped_area() on parisc architecture
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 24 Jan 2013 10:33:32 +0000
In-Reply-To: <1358990991-21316-2-git-send-email-walken@google.com>
References: <1358990991-21316-1-git-send-email-walken@google.com>
	 <1358990991-21316-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 2013-01-23 at 17:29 -0800, Michel Lespinasse wrote:
> Update the parisc arch_get_unmapped_area function to make use of
> vm_unmapped_area() instead of implementing a brute force search.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> 
> ---
>  arch/parisc/kernel/sys_parisc.c |   46 ++++++++++++++------------------------
>  1 files changed, 17 insertions(+), 29 deletions(-)
> 
> diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
> index f76c10863c62..6ab138088076 100644
> --- a/arch/parisc/kernel/sys_parisc.c
> +++ b/arch/parisc/kernel/sys_parisc.c
> @@ -35,18 +35,15 @@
>  
>  static unsigned long get_unshared_area(unsigned long addr, unsigned long len)
>  {
> -	struct vm_area_struct *vma;
> +	struct vm_unmapped_area_info info;
>  
> -	addr = PAGE_ALIGN(addr);
> -
> -	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
> -		/* At this point:  (!vma || addr < vma->vm_end). */
> -		if (TASK_SIZE - len < addr)
> -			return -ENOMEM;
> -		if (!vma || addr + len <= vma->vm_start)
> -			return addr;
> -		addr = vma->vm_end;
> -	}
> +	info.flags = 0;
> +	info.length = len;
> +	info.low_limit = PAGE_ALIGN(addr);
> +	info.high_limit = TASK_SIZE;
> +	info.align_mask = 0;
> +	info.align_offset = 0;
> +	return vm_unmapped_area(&info);
>  }
>  
>  #define DCACHE_ALIGN(addr) (((addr) + (SHMLBA - 1)) &~ (SHMLBA - 1))

This macro is now redundant and can be removed.

> @@ -63,30 +60,21 @@ static unsigned long get_unshared_area(unsigned long addr, unsigned long len)
>   */
>  static int get_offset(struct address_space *mapping)
>  {
> -	int offset = (unsigned long) mapping << (PAGE_SHIFT - 8);
> -	return offset & 0x3FF000;
> +	return (unsigned long) mapping >> 8;

I'm not sure I agree with this shift (but I think the original was wrong
as well so the comment probably needs updating.)  Trying to derive
entropy from the mapping address is always nasty.  Mostly they're
embedded in the inode, so the right shift should be something like
log2(sizeof(inode)) + 1 and since the inode size is usually somewhere
between 512 and 1024 bytes, that comes out to 10 I think.

>  }
>  
>  static unsigned long get_shared_area(struct address_space *mapping,
>  		unsigned long addr, unsigned long len, unsigned long pgoff)
>  {
> -	struct vm_area_struct *vma;
> -	int offset = mapping ? get_offset(mapping) : 0;
> -
> -	offset = (offset + (pgoff << PAGE_SHIFT)) & 0x3FF000;
> +	struct vm_unmapped_area_info info;
>  
> -	addr = DCACHE_ALIGN(addr - offset) + offset;
> -
> -	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
> -		/* At this point:  (!vma || addr < vma->vm_end). */
> -		if (TASK_SIZE - len < addr)
> -			return -ENOMEM;
> -		if (!vma || addr + len <= vma->vm_start)
> -			return addr;
> -		addr = DCACHE_ALIGN(vma->vm_end - offset) + offset;
> -		if (addr < vma->vm_end) /* handle wraparound */
> -			return -ENOMEM;
> -	}
> +	info.flags = 0;
> +	info.length = len;
> +	info.low_limit = PAGE_ALIGN(addr);
> +	info.high_limit = TASK_SIZE;
> +	info.align_mask = PAGE_MASK & (SHMLBA - 1);
> +	info.align_offset = (get_offset(mapping) + pgoff) << PAGE_SHIFT;
> +	return vm_unmapped_area(&info);
>  }
>  
>  unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,

Other than that, I think this will work, but I'd like to test it.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
