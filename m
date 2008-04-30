Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3UJYIZJ025404
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:34:18 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3UJYIg5248200
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:34:18 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3UJYHib026397
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:34:17 -0400
Date: Wed, 30 Apr 2008 12:34:16 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080430193416.GE8597@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015431.462123000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:19 +1000], npiggin@suse.de wrote:
> Add an hugepagesz=... option similar to IA64, PPC etc. to x86-64.
> 
> This finally allows to select GB pages for hugetlbfs in x86 now
> that all the infrastructure is in place.

So, this patch sort of indicates how archs will need to be modified to
take advantage of the new infrastructure?

> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  Documentation/kernel-parameters.txt |   11 +++++++++--
>  arch/x86/mm/hugetlbpage.c           |   17 +++++++++++++++++
>  include/asm-x86/page.h              |    2 ++
>  3 files changed, 28 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/arch/x86/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
> +++ linux-2.6/arch/x86/mm/hugetlbpage.c
> @@ -424,3 +424,20 @@ hugetlb_get_unmapped_area(struct file *f
> 
>  #endif /*HAVE_ARCH_HUGETLB_UNMAPPED_AREA*/
> 
> +#ifdef CONFIG_X86_64
> +static __init int setup_hugepagesz(char *opt)
> +{
> +	unsigned long ps = memparse(opt, &opt);
> +	if (ps == PMD_SIZE) {
> +		huge_add_hstate(PMD_SHIFT - PAGE_SHIFT);
> +	} else if (ps == PUD_SIZE && cpu_has_gbpages) {
> +		huge_add_hstate(PUD_SHIFT - PAGE_SHIFT);
> +	} else {
> +		printk(KERN_ERR "hugepagesz: Unsupported page size %lu M\n",
> +			ps >> 20);
> +		return 0;
> +	}
> +	return 1;
> +}
> +__setup("hugepagesz=", setup_hugepagesz);
> +#endif

Did we decide if what hugepages are available would depend on the kernel
command-line or not?

I would prefer not; that is, the architecture specifies via an init-time
call what hstates it can support (through calls back into generic code
via huge_add_hstate()) and then generic code just supports/iterates over
those pagesizes. It doesn't depend on the administrator specifying
hugepagesz= at all, except if they want to preallocate a certain size
hugepage at boot-time (only strictly necessary for 1G/16G).

Now, this does mean that, for instance, a powerpc kernel may have
HUGE_MAX_HSTATE set to 3 (statically), but not actually be able to
support 3 huge page sizes (if the basepage size is 64k). So either we
need to make HUGE_MAX_HSTATE depend on the CONFIG options, which might
be ok, or we need to make for_each_hstate() also test that the hstate
entry in the array is !NULL?

> Index: linux-2.6/include/asm-x86/page.h
> ===================================================================
> --- linux-2.6.orig/include/asm-x86/page.h
> +++ linux-2.6/include/asm-x86/page.h
> @@ -21,6 +21,8 @@
>  #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
>  #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
> 
> +#define HUGE_MAX_HSTATE 2
> +

power would presumably make this 3, to support 64K,16M,16G (and 2, if
basepage size is 64K).

Another issue for power, though, is that there are local variables in
arch/powerpc/hugetlbpage.c that depend on the hugepage size in use (and
since there is only one, they're global). We really want those variables
to be per-hstate, though, right? The three I see are mmu_huge_psize,
HPAGE_SHIFT and hugepte_shift. For HPAGE_SHIFT, I think we could just
switch them over to huge_page_shift(h) given an hstate, but we would
need to make sure an hstate is available/obtainable at each point? Jon,
do you have any insight here? I want to make sure struct hstate is
future-proofed for other architectures than x86_64...

We probably want to see how converting powerpc looks, then get IA64,
sparc64 and sh on-board?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
