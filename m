Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 4DA986B0034
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 11:32:12 -0400 (EDT)
Message-ID: <51D2F278.3050002@suse.de>
Date: Tue, 02 Jul 2013 17:32:08 +0200
From: Alexander Graf <agraf@suse.de>
MIME-Version: 1.0
Subject: Re: [PATCH -V3 3/4] powerpc/kvm: Contiguous memory allocator based
 RMA allocation
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1372743918-12293-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <51D2EEF7.8000607@suse.de> <87zju5yo7g.fsf@linux.vnet.ibm.com>
In-Reply-To: <87zju5yo7g.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, m.szyprowski@samsung.com, mina86@mina86.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org

On 07/02/2013 05:29 PM, Aneesh Kumar K.V wrote:
> Alexander Graf<agraf@suse.de>  writes:
>
>> On 07/02/2013 07:45 AM, Aneesh Kumar K.V wrote:
>>> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
>>>
>>> Older version of power architecture use Real Mode Offset register and Real Mode Limit
>>> Selector for mapping guest Real Mode Area. The guest RMA should be physically
>>> contigous since we use the range when address translation is not enabled.
>>>
>>> This patch switch RMA allocation code to use contigous memory allocator. The patch
>>> also remove the the linear allocator which not used any more
>>>
>>> Acked-by: Paul Mackerras<paulus@samba.org>
>>> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
>>> ---
> .... snip ....
>
>>> diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
>>> index 550f592..55c8519 100644
>>> --- a/arch/powerpc/kvm/book3s_hv.c
>>> +++ b/arch/powerpc/kvm/book3s_hv.c
>>> @@ -1511,10 +1511,10 @@ static inline int lpcr_rmls(unsigned long rma_size)
>>>
>>>    static int kvm_rma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>>>    {
>>> -	struct kvmppc_linear_info *ri = vma->vm_file->private_data;
>>>    	struct page *page;
>>> +	struct kvm_rma_info *ri = vma->vm_file->private_data;
>>>
>>> -	if (vmf->pgoff>= ri->npages)
>>> +	if (vmf->pgoff>= kvm_rma_pages)
>>>    		return VM_FAULT_SIGBUS;
>>>
>>>    	page = pfn_to_page(ri->base_pfn + vmf->pgoff);
>>> @@ -1536,7 +1536,7 @@ static int kvm_rma_mmap(struct file *file, struct vm_area_struct *vma)
>>>
>>>    static int kvm_rma_release(struct inode *inode, struct file *filp)
>>>    {
>>> -	struct kvmppc_linear_info *ri = filp->private_data;
>>> +	struct kvm_rma_info *ri = filp->private_data;
>>>
>>>    	kvm_release_rma(ri);
>>>    	return 0;
>>> @@ -1549,8 +1549,17 @@ static const struct file_operations kvm_rma_fops = {
>>>
>>>    long kvm_vm_ioctl_allocate_rma(struct kvm *kvm, struct kvm_allocate_rma *ret)
>>>    {
>>> -	struct kvmppc_linear_info *ri;
>>>    	long fd;
>>> +	struct kvm_rma_info *ri;
>>> +	/*
>>> +	 * Only do this on PPC970 in HV mode
>>> +	 */
>>> +	if (!cpu_has_feature(CPU_FTR_HVMODE) ||
>>> +	    !cpu_has_feature(CPU_FTR_ARCH_201))
>>> +		return -EINVAL;
>> Is this really what we want? User space may want to use an RMA on POWER7
>> systems, no?
> IIUC they will use virtual real mode area (VRMA) and not RMA

Then I suppose we should at least update the comment a bit further down 
the patch that indicates that on POWER7 systems we do support a real 
RMA. I can't really think of any reason why user space would want to use 
RMA over VRMA.

>
>>> +
>>> +	if (!kvm_rma_pages)
>>> +		return -EINVAL;
>>>
>>>    	ri = kvm_alloc_rma();
>>>    	if (!ri)
>>> @@ -1560,7 +1569,7 @@ long kvm_vm_ioctl_allocate_rma(struct kvm *kvm, struct kvm_allocate_rma *ret)
>>>    	if (fd<   0)
>>>    		kvm_release_rma(ri);
>>>
>>> -	ret->rma_size = ri->npages<<   PAGE_SHIFT;
>>> +	ret->rma_size = kvm_rma_pages<<   PAGE_SHIFT;
>>>    	return fd;
>>>    }
>>>
>>> @@ -1725,7 +1734,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
>>>    {
>>>    	int err = 0;
>>>    	struct kvm *kvm = vcpu->kvm;
>>> -	struct kvmppc_linear_info *ri = NULL;
>>> +	struct kvm_rma_info *ri = NULL;
>>>    	unsigned long hva;
>>>    	struct kvm_memory_slot *memslot;
>>>    	struct vm_area_struct *vma;
>>> @@ -1803,7 +1812,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
>>>
>>>    	} else {
>>>    		/* Set up to use an RMO region */
>>> -		rma_size = ri->npages;
>>> +		rma_size = kvm_rma_pages;
>>>    		if (rma_size>   memslot->npages)
>>>    			rma_size = memslot->npages;
>>>    		rma_size<<= PAGE_SHIFT;
>>> @@ -1831,14 +1840,14 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
>>>    			/* POWER7 */
>>>    			lpcr&= ~(LPCR_VPM0 | LPCR_VRMA_L);
>>>    			lpcr |= rmls<<   LPCR_RMLS_SH;
>>> -			kvm->arch.rmor = kvm->arch.rma->base_pfn<<   PAGE_SHIFT;
>>> +			kvm->arch.rmor = ri->base_pfn<<   PAGE_SHIFT;
>>>    		}
>>>    		kvm->arch.lpcr = lpcr;
>>>    		pr_info("KVM: Using RMO at %lx size %lx (LPCR = %lx)\n",
>>>    			ri->base_pfn<<   PAGE_SHIFT, rma_size, lpcr);
>>>
>>>    		/* Initialize phys addrs of pages in RMO */
>>> -		npages = ri->npages;
>>> +		npages = kvm_rma_pages;
>>>    		porder = __ilog2(npages);
>>>    		physp = memslot->arch.slot_phys;
>>>    		if (physp) {
>>> diff --git a/arch/powerpc/kvm/book3s_hv_builtin.c b/arch/powerpc/kvm/book3s_hv_builtin.c
>>> index 4b865c5..8cd0dae 100644
>>> --- a/arch/powerpc/kvm/book3s_hv_builtin.c
>>> +++ b/arch/powerpc/kvm/book3s_hv_builtin.c
>>> @@ -21,13 +21,6 @@
>>>    #include<asm/kvm_book3s.h>
>>>
>>>    #include "book3s_hv_cma.h"
>>> -
>>> -#define KVM_LINEAR_RMA		0
>>> -#define KVM_LINEAR_HPT		1
>>> -
>>> -static void __init kvm_linear_init_one(ulong size, int count, int type);
>>> -static struct kvmppc_linear_info *kvm_alloc_linear(int type);
>>> -static void kvm_release_linear(struct kvmppc_linear_info *ri);
>>>    /*
>>>     * Hash page table alignment on newer cpus(CPU_FTR_ARCH_206)
>>>     * should be power of 2.
>>> @@ -37,19 +30,17 @@ static void kvm_release_linear(struct kvmppc_linear_info *ri);
>>>     * By default we reserve 5% of memory for hash pagetable allocation.
>>>     */
>>>    static unsigned long kvm_cma_resv_ratio = 5;
>>> -
>>> -/*************** RMA *************/
>>> -
>>>    /*
>>> - * This maintains a list of RMAs (real mode areas) for KVM guests to use.
>>> + * We allocate RMAs (real mode areas) for KVM guests from the KVM CMA area.
>>>     * Each RMA has to be physically contiguous and of a size that the
>>>     * hardware supports.  PPC970 and POWER7 support 64MB, 128MB and 256MB,
>>>     * and other larger sizes.  Since we are unlikely to be allocate that
>>>     * much physically contiguous memory after the system is up and running,
>>> - * we preallocate a set of RMAs in early boot for KVM to use.
>>> + * we preallocate a set of RMAs in early boot using CMA.
>>> + * should be power of 2.
>>>     */
>>> -static unsigned long kvm_rma_size = 64<<   20;	/* 64MB */
>>> -static unsigned long kvm_rma_count;
>>> +unsigned long kvm_rma_pages = (1<<   27)>>   PAGE_SHIFT;	/* 128MB */
>>> +EXPORT_SYMBOL_GPL(kvm_rma_pages);
>>>
>>>    /* Work out RMLS (real mode limit selector) field value for a given RMA size.
>>>       Assumes POWER7 or PPC970. */
>>> @@ -79,35 +70,50 @@ static inline int lpcr_rmls(unsigned long rma_size)
>>>
>>>    static int __init early_parse_rma_size(char *p)
>>>    {
>>> -	if (!p)
>>> -		return 1;
>>> +	unsigned long kvm_rma_size;
>>>
>>> +	pr_debug("%s(%s)\n", __func__, p);
>>> +	if (!p)
>>> +		return -EINVAL;
>>>    	kvm_rma_size = memparse(p,&p);
>>> -
>>> +	/*
>>> +	 * Check that the requested size is one supported in hardware
>>> +	 */
>>> +	if (lpcr_rmls(kvm_rma_size)<   0) {
>>> +		pr_err("RMA size of 0x%lx not supported\n", kvm_rma_size);
>>> +		return -EINVAL;
>>> +	}
>>> +	kvm_rma_pages = kvm_rma_size>>   PAGE_SHIFT;
>>>    	return 0;
>>>    }
>>>    early_param("kvm_rma_size", early_parse_rma_size);
>>>
>>> -static int __init early_parse_rma_count(char *p)
>>> +struct kvm_rma_info *kvm_alloc_rma()
>>>    {
>>> -	if (!p)
>>> -		return 1;
>>> -
>>> -	kvm_rma_count = simple_strtoul(p, NULL, 0);
>>> -
>>> -	return 0;
>>> -}
>>> -early_param("kvm_rma_count", early_parse_rma_count);
>>> -
>>> -struct kvmppc_linear_info *kvm_alloc_rma(void)
>>> -{
>>> -	return kvm_alloc_linear(KVM_LINEAR_RMA);
>>> +	struct page *page;
>>> +	struct kvm_rma_info *ri;
>>> +
>>> +	ri = kmalloc(sizeof(struct kvm_rma_info), GFP_KERNEL);
>>> +	if (!ri)
>>> +		return NULL;
>>> +	page = kvm_alloc_cma(kvm_rma_pages, kvm_rma_pages);
>>> +	if (!page)
>>> +		goto err_out;
>>> +	atomic_set(&ri->use_count, 1);
>>> +	ri->base_pfn = page_to_pfn(page);
>>> +	return ri;
>>> +err_out:
>>> +	kfree(ri);
>>> +	return NULL;
>>>    }
>>>    EXPORT_SYMBOL_GPL(kvm_alloc_rma);
>>>
>>> -void kvm_release_rma(struct kvmppc_linear_info *ri)
>>> +void kvm_release_rma(struct kvm_rma_info *ri)
>>>    {
>>> -	kvm_release_linear(ri);
>>> +	if (atomic_dec_and_test(&ri->use_count)) {
>>> +		kvm_release_cma(pfn_to_page(ri->base_pfn), kvm_rma_pages);
>>> +		kfree(ri);
>>> +	}
>>>    }
>>>    EXPORT_SYMBOL_GPL(kvm_release_rma);
>>>
>>> @@ -137,101 +143,6 @@ void kvm_release_hpt(struct page *page, unsigned long nr_pages)
>>>    }
>>>    EXPORT_SYMBOL_GPL(kvm_release_hpt);
>>>
>>> -/*************** generic *************/
>>> -
>>> -static LIST_HEAD(free_linears);
>>> -static DEFINE_SPINLOCK(linear_lock);
>>> -
>>> -static void __init kvm_linear_init_one(ulong size, int count, int type)
>> Please split the linar removal bits out into a separate patch :).
>>
>>
> That was the way I had in the earlier patchset. That will cause a bisect
> build break, because we consider warnings as error and we hit warning
> of unused function.
>
> I also realized that linear alloc functions are nearby and mostly fall
> in the same hunk. Hence folded it back.

Fair enough :)


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
