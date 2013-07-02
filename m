Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 2A04A6B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 12:37:00 -0400 (EDT)
Message-ID: <51D301A8.50406@suse.de>
Date: Tue, 02 Jul 2013 18:36:56 +0200
From: Alexander Graf <agraf@suse.de>
MIME-Version: 1.0
Subject: Re: [PATCH -V3 3/4] powerpc/kvm: Contiguous memory allocator based
 RMA allocation
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1372743918-12293-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <51D2EEF7.8000607@suse.de> <87zju5yo7g.fsf@linux.vnet.ibm.com> <51D2F278.3050002@suse.de> <87r4fhylhe.fsf@linux.vnet.ibm.com>
In-Reply-To: <87r4fhylhe.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: kvm@vger.kernel.org, mina86@mina86.com, linux-mm@kvack.org, paulus@samba.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, m.szyprowski@samsung.com

On 07/02/2013 06:28 PM, Aneesh Kumar K.V wrote:
> Alexander Graf<agraf@suse.de>  writes:
>
>> On 07/02/2013 05:29 PM, Aneesh Kumar K.V wrote:
>>> Alexander Graf<agraf@suse.de>   writes:
>>>
>>>> On 07/02/2013 07:45 AM, Aneesh Kumar K.V wrote:
>>>>> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
>>>>>
>>>>> Older version of power architecture use Real Mode Offset register and Real Mode Limit
>>>>> Selector for mapping guest Real Mode Area. The guest RMA should be physically
>>>>> contigous since we use the range when address translation is not enabled.
>>>>>
>>>>> This patch switch RMA allocation code to use contigous memory allocator. The patch
>>>>> also remove the the linear allocator which not used any more
>>>>>
>>>>> Acked-by: Paul Mackerras<paulus@samba.org>
>>>>> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
>>>>> ---
>>> .... snip ....
>>>
>>>>> diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
>>>>> index 550f592..55c8519 100644
>>>>> --- a/arch/powerpc/kvm/book3s_hv.c
>>>>> +++ b/arch/powerpc/kvm/book3s_hv.c
>>>>> @@ -1511,10 +1511,10 @@ static inline int lpcr_rmls(unsigned long rma_size)
>>>>>
>>>>>     static int kvm_rma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>>>>>     {
>>>>> -	struct kvmppc_linear_info *ri = vma->vm_file->private_data;
>>>>>     	struct page *page;
>>>>> +	struct kvm_rma_info *ri = vma->vm_file->private_data;
>>>>>
>>>>> -	if (vmf->pgoff>= ri->npages)
>>>>> +	if (vmf->pgoff>= kvm_rma_pages)
>>>>>     		return VM_FAULT_SIGBUS;
>>>>>
>>>>>     	page = pfn_to_page(ri->base_pfn + vmf->pgoff);
>>>>> @@ -1536,7 +1536,7 @@ static int kvm_rma_mmap(struct file *file, struct vm_area_struct *vma)
>>>>>
>>>>>     static int kvm_rma_release(struct inode *inode, struct file *filp)
>>>>>     {
>>>>> -	struct kvmppc_linear_info *ri = filp->private_data;
>>>>> +	struct kvm_rma_info *ri = filp->private_data;
>>>>>
>>>>>     	kvm_release_rma(ri);
>>>>>     	return 0;
>>>>> @@ -1549,8 +1549,17 @@ static const struct file_operations kvm_rma_fops = {
>>>>>
>>>>>     long kvm_vm_ioctl_allocate_rma(struct kvm *kvm, struct kvm_allocate_rma *ret)
>>>>>     {
>>>>> -	struct kvmppc_linear_info *ri;
>>>>>     	long fd;
>>>>> +	struct kvm_rma_info *ri;
>>>>> +	/*
>>>>> +	 * Only do this on PPC970 in HV mode
>>>>> +	 */
>>>>> +	if (!cpu_has_feature(CPU_FTR_HVMODE) ||
>>>>> +	    !cpu_has_feature(CPU_FTR_ARCH_201))
>>>>> +		return -EINVAL;
>>>> Is this really what we want? User space may want to use an RMA on POWER7
>>>> systems, no?
>>> IIUC they will use virtual real mode area (VRMA) and not RMA
>> Then I suppose we should at least update the comment a bit further down
>> the patch that indicates that on POWER7 systems we do support a real
>> RMA. I can't really think of any reason why user space would want to use
>> RMA over VRMA.
>>
> where ? We have comments like
>
> /* On POWER7, use VRMA; on PPC970, give up */

>   /*
> - * This maintains a list of RMAs (real mode areas) for KVM guests to use.
> + * We allocate RMAs (real mode areas) for KVM guests from the KVM CMA area.
>    * Each RMA has to be physically contiguous and of a size that the
>    * hardware supports.  PPC970 and POWER7 support 64MB, 128MB and 256MB,
>    * and other larger sizes.  Since we are unlikely to be allocate that
>    * much physically contiguous memory after the system is up and running,
> - * we preallocate a set of RMAs in early boot for KVM to use.
> + * we preallocate a set of RMAs in early boot using CMA.
> + * should be power of 2.
>    */

This could be falsely interpreted as "POWER7 can use an RMA".


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
