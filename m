Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D2D0D440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 03:45:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 76so49593950pgh.11
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 00:45:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 7si3684129pfk.227.2017.07.13.00.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 00:45:12 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6D7hmCN010400
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 03:45:12 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bnt3pcda9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 03:45:10 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 13 Jul 2017 03:45:09 -0400
Date: Thu, 13 Jul 2017 00:45:00 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 14/38] powerpc: initial plumbing for key management
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-15-git-send-email-linuxram@us.ibm.com>
 <20170712132825.2a37e2e9@firefly.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170712132825.2a37e2e9@firefly.ozlabs.ibm.com>
Message-Id: <20170713074500.GF5525@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Wed, Jul 12, 2017 at 01:28:25PM +1000, Balbir Singh wrote:
> On Wed,  5 Jul 2017 14:21:51 -0700
> Ram Pai <linuxram@us.ibm.com> wrote:
> 
> > Initial plumbing to manage all the keys supported by the
> > hardware.
> > 
> > Total 32 keys are supported on powerpc. However pkey 0,1
> > and 31 are reserved. So effectively we have 29 pkeys.
> > 
> > This patch keeps track of reserved keys, allocated  keys
> > and keys that are currently free.
> 
> It looks like this patch will only work in guest mode?
> Is that an assumption we've made? What happens if I use
> keys when running in hypervisor mode?

It works in supervisor mode, as a guest aswell as a bare-metal
kernel. Whatever needs to be done in hypervisor mode
is already there in power-kvm.

> 
> > 
> > Also it  adds  skeletal  functions  and macros, that the
> > architecture-independent code expects to be available.
> > 
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > ---
> >  arch/powerpc/Kconfig                     |   16 +++++
> >  arch/powerpc/include/asm/book3s/64/mmu.h |    9 +++
> >  arch/powerpc/include/asm/pkeys.h         |  106 ++++++++++++++++++++++++++++++
> >  arch/powerpc/mm/mmu_context_book3s64.c   |    5 ++
> >  4 files changed, 136 insertions(+), 0 deletions(-)
> >  create mode 100644 arch/powerpc/include/asm/pkeys.h
> > 
> > diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> > index f7c8f99..a2480b6 100644
> > --- a/arch/powerpc/Kconfig
> > +++ b/arch/powerpc/Kconfig
> > @@ -871,6 +871,22 @@ config SECCOMP
> >  
> >  	  If unsure, say Y. Only embedded should say N here.
> >  
> > +config PPC64_MEMORY_PROTECTION_KEYS
> > +	prompt "PowerPC Memory Protection Keys"
> > +	def_bool y
> > +	# Note: only available in 64-bit mode
> > +	depends on PPC64 && PPC_64K_PAGES
> > +	select ARCH_USES_HIGH_VMA_FLAGS
> > +	select ARCH_HAS_PKEYS
> > +	---help---
> > +	  Memory Protection Keys provides a mechanism for enforcing
> > +	  page-based protections, but without requiring modification of the
> > +	  page tables when an application changes protection domains.
> > +
> > +	  For details, see Documentation/powerpc/protection-keys.txt
> > +
> > +	  If unsure, say y.
> > +
> >  endmenu
> >  
> >  config ISA_DMA_API
> > diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h b/arch/powerpc/include/asm/book3s/64/mmu.h
> > index 77529a3..104ad72 100644
> > --- a/arch/powerpc/include/asm/book3s/64/mmu.h
> > +++ b/arch/powerpc/include/asm/book3s/64/mmu.h
> > @@ -108,6 +108,15 @@ struct patb_entry {
> >  #ifdef CONFIG_SPAPR_TCE_IOMMU
> >  	struct list_head iommu_group_mem_list;
> >  #endif
> > +
> > +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> > +	/*
> > +	 * Each bit represents one protection key.
> > +	 * bit set   -> key allocated
> > +	 * bit unset -> key available for allocation
> > +	 */
> > +	u32 pkey_allocation_map;
> > +#endif
> >  } mm_context_t;
> >  
> >  /*
> > diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> > new file mode 100644
> > index 0000000..9345767
> > --- /dev/null
> > +++ b/arch/powerpc/include/asm/pkeys.h
> > @@ -0,0 +1,106 @@
> > +#ifndef _ASM_PPC64_PKEYS_H
> > +#define _ASM_PPC64_PKEYS_H
> > +
> > +#define arch_max_pkey()  32
> > +#define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
> > +				VM_PKEY_BIT3 | VM_PKEY_BIT4)
> > +/*
> > + * Bits are in BE format.
> > + * NOTE: key 31, 1, 0 are not used.
> > + * key 0 is used by default. It give read/write/execute permission.
> > + * key 31 is reserved by the hypervisor.
> > + * key 1 is recommended to be not used.
> > + * PowerISA(3.0) page 1015, programming note.
> > + */
> > +#define PKEY_INITIAL_ALLOCAION  0xc0000001
> 
> Shouldn't this be exchanged via CAS for guests? Have you seen
> ibm,processor-storage-keys?

Yes. Was one of my TODOs to initilize this using the device-tree
interface.  A brief look at that did not show the reserved keys
properly enumerated. But I may be wrong.

> 
> > +
> > +#define pkeybit_mask(pkey) (0x1 << (arch_max_pkey() - pkey - 1))
> > +
> > +#define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
> > +
> > +#define mm_set_pkey_allocated(mm, pkey) {	\
> > +	mm_pkey_allocation_map(mm) |= pkeybit_mask(pkey); \
> > +}
> > +
> > +#define mm_set_pkey_free(mm, pkey) {	\
> > +	mm_pkey_allocation_map(mm) &= ~pkeybit_mask(pkey);	\
> > +}
> > +
> > +#define mm_set_pkey_is_allocated(mm, pkey)	\
> > +	(mm_pkey_allocation_map(mm) & pkeybit_mask(pkey))
> > +
> > +#define mm_set_pkey_is_reserved(mm, pkey) (PKEY_INITIAL_ALLOCAION & \
> > +					pkeybit_mask(pkey))
> > +
> > +static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
> > +{
> > +	/* a reserved key is never considered as 'explicitly allocated' */
> > +	return (!mm_set_pkey_is_reserved(mm, pkey) &&
> > +		mm_set_pkey_is_allocated(mm, pkey));
> > +}
> > +
> > +/*
> > + * Returns a positive, 5-bit key on success, or -1 on failure.
> > + */
> > +static inline int mm_pkey_alloc(struct mm_struct *mm)
> > +{
> > +	/*
> > +	 * Note: this is the one and only place we make sure
> > +	 * that the pkey is valid as far as the hardware is
> > +	 * concerned.  The rest of the kernel trusts that
> > +	 * only good, valid pkeys come out of here.
> > +	 */
> > +	u32 all_pkeys_mask = (u32)(~(0x0));
> > +	int ret;
> > +
> > +	/*
> > +	 * Are we out of pkeys?  We must handle this specially
> > +	 * because ffz() behavior is undefined if there are no
> > +	 * zeros.
> > +	 */
> > +	if (mm_pkey_allocation_map(mm) == all_pkeys_mask)
> > +		return -1;
> > +
> > +	ret = arch_max_pkey() -
> > +		ffz((u32)mm_pkey_allocation_map(mm))
> > +		- 1;
> > +	mm_set_pkey_allocated(mm, ret);
> > +	return ret;
> > +}
> 
> So the locking is provided by the caller for the function above?

yes.

> 
> > +
> > +static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
> > +{
> > +	if (!mm_pkey_is_allocated(mm, pkey))
> > +		return -EINVAL;
> > +
> > +	mm_set_pkey_free(mm, pkey);
> > +
> > +	return 0;
> > +}
> > +
> > +/*
> > + * Try to dedicate one of the protection keys to be used as an
> > + * execute-only protection key.
> > + */
> > +static inline int execute_only_pkey(struct mm_struct *mm)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
> > +		int prot, int pkey)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> > +		unsigned long init_val)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline void pkey_mm_init(struct mm_struct *mm)
> > +{
> > +	mm_pkey_allocation_map(mm) = PKEY_INITIAL_ALLOCAION;
> > +}
> > +#endif /*_ASM_PPC64_PKEYS_H */
> > diff --git a/arch/powerpc/mm/mmu_context_book3s64.c b/arch/powerpc/mm/mmu_context_book3s64.c
> > index c6dca2a..2da9931 100644
> > --- a/arch/powerpc/mm/mmu_context_book3s64.c
> > +++ b/arch/powerpc/mm/mmu_context_book3s64.c
> > @@ -16,6 +16,7 @@
> >  #include <linux/string.h>
> >  #include <linux/types.h>
> >  #include <linux/mm.h>
> > +#include <linux/pkeys.h>
> >  #include <linux/spinlock.h>
> >  #include <linux/idr.h>
> >  #include <linux/export.h>
> > @@ -120,6 +121,10 @@ static int hash__init_new_context(struct mm_struct *mm)
> >  
> >  	subpage_prot_init_new_context(mm);
> >  
> > +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> > +	pkey_mm_init(mm);
> 
> Can we have two variants of pkey_mm_init() and avoid #ifdefs around the code?

ok.

> 
> > +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> > +
> >  	return index;
> >  }
> >  
> 
> Balbir Singh.

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
