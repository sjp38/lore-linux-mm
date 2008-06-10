Date: Tue, 10 Jun 2008 15:14:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC:PATCH 02/06] mm: Allow architectures to define additional
 protection bits
Message-Id: <20080610151423.a6e68632.akpm@linux-foundation.org>
In-Reply-To: <20080610220106.10257.69841.sendpatchset@norville.austin.ibm.com>
References: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
	<20080610220106.10257.69841.sendpatchset@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: Linuxppc-dev@ozlabs.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 18:01:07 -0400
Dave Kleikamp <shaggy@linux.vnet.ibm.com> wrote:

> mm: Allow architectures to define additional protection bits
> 
> This patch allows architectures to define functions to deal with
> additional protections bits for mmap() and mprotect().
> 
> arch_calc_vm_prot_bits() maps additonal protection bits to vm_flags
> arch_vm_get_page_prot() maps additional vm_flags to the vma's vm_page_prot
> arch_validate_prot() checks for valid values of the protection bits
> 
> Note: vm_get_page_prot() is now pretty ugly.  Suggestions?

It didn't get any better, no ;)

I wonder if we can do the ORing after doing the protection_map[]
lookup.  I guess that's illogical even if it happens to work.

> Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
> ---
> 
>  include/linux/mman.h |   23 ++++++++++++++++++++++-
>  mm/mmap.c            |    5 +++--
>  mm/mprotect.c        |    2 +-
>  3 files changed, 26 insertions(+), 4 deletions(-)
> 
> diff -Nurp linux001/include/linux/mman.h linux002/include/linux/mman.h
> --- linux001/include/linux/mman.h	2008-06-05 10:08:01.000000000 -0500
> +++ linux002/include/linux/mman.h	2008-06-10 16:48:59.000000000 -0500
> @@ -34,6 +34,26 @@ static inline void vm_unacct_memory(long
>  }
>  
>  /*
> + * Allow architectures to handle additional protection bits
> + */
> +
> +#ifndef HAVE_ARCH_PROT_BITS
> +#define arch_calc_vm_prot_bits(prot) 0
> +#define arch_vm_get_page_prot(vm_flags) __pgprot(0)
> +
> +/*
> + * This is called from mprotect().  PROT_GROWSDOWN and PROT_GROWSUP have
> + * already been masked out.
> + *
> + * Returns true if the prot flags are valid
> + */
> +static inline int arch_validate_prot(unsigned long prot)
> +{
> +	return (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM)) == 0;
> +}
> +#endif /* HAVE_ARCH_PROT_BITS */

argh, another HAVE_ARCH_foo.

A good (but verbose) way of doing this is to nuke the ifdefs and just
go and define these three things for each architecture.  That can be
done via copy-n-paste into include/asm-*/mman.h or #include
<asm-generic/arch-mman.h>(?) within each asm/mman.h.

Another way would be

#ifndef arch_calc_vm_prot_bits
#define arch_calc_vm_prot_bits(prot) ...


> +/*
>   * Optimisation macro.  It is equivalent to:
>   *      (x & bit1) ? bit2 : 0
>   * but this version is faster.
> @@ -51,7 +71,8 @@ calc_vm_prot_bits(unsigned long prot)
>  {
>  	return _calc_vm_trans(prot, PROT_READ,  VM_READ ) |
>  	       _calc_vm_trans(prot, PROT_WRITE, VM_WRITE) |
> -	       _calc_vm_trans(prot, PROT_EXEC,  VM_EXEC );
> +	       _calc_vm_trans(prot, PROT_EXEC,  VM_EXEC) |
> +	       arch_calc_vm_prot_bits(prot);
>  }
>  
>  /*
> diff -Nurp linux001/mm/mmap.c linux002/mm/mmap.c
> --- linux001/mm/mmap.c	2008-06-05 10:08:03.000000000 -0500
> +++ linux002/mm/mmap.c	2008-06-10 16:48:59.000000000 -0500
> @@ -72,8 +72,9 @@ pgprot_t protection_map[16] = {
>  
>  pgprot_t vm_get_page_prot(unsigned long vm_flags)
>  {
> -	return protection_map[vm_flags &
> -				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
> +	return __pgprot(pgprot_val(protection_map[vm_flags &
> +				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
> +			pgprot_val(arch_vm_get_page_prot(vm_flags)));
>  }
>  EXPORT_SYMBOL(vm_get_page_prot);
>  
> diff -Nurp linux001/mm/mprotect.c linux002/mm/mprotect.c
> --- linux001/mm/mprotect.c	2008-06-05 10:08:03.000000000 -0500
> +++ linux002/mm/mprotect.c	2008-06-10 16:48:59.000000000 -0500
> @@ -239,7 +239,7 @@ sys_mprotect(unsigned long start, size_t
>  	end = start + len;
>  	if (end <= start)
>  		return -ENOMEM;
> -	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM))
> +	if (!arch_validate_prot(prot))
>  		return -EINVAL;
>  
>  	reqprot = prot;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
