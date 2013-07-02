Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 976E76B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 12:28:55 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 3 Jul 2013 02:21:31 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 375E8357804E
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 02:28:50 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r62GDpcH62259294
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 02:13:52 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r62GSnrI002042
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 02:28:49 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 3/4] powerpc/kvm: Contiguous memory allocator based RMA allocation
In-Reply-To: <51D2F278.3050002@suse.de>
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1372743918-12293-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <51D2EEF7.8000607@suse.de> <87zju5yo7g.fsf@linux.vnet.ibm.com> <51D2F278.3050002@suse.de>
Date: Tue, 02 Jul 2013 21:58:45 +0530
Message-ID: <87r4fhylhe.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: kvm@vger.kernel.org, mina86@mina86.com, linux-mm@kvack.org, paulus@samba.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, m.szyprowski@samsung.com

Alexander Graf <agraf@suse.de> writes:

> On 07/02/2013 05:29 PM, Aneesh Kumar K.V wrote:
>> Alexander Graf<agraf@suse.de>  writes:
>>
>>> On 07/02/2013 07:45 AM, Aneesh Kumar K.V wrote:
>>>> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
>>>>
>>>> Older version of power architecture use Real Mode Offset register and Real Mode Limit
>>>> Selector for mapping guest Real Mode Area. The guest RMA should be physically
>>>> contigous since we use the range when address translation is not enabled.
>>>>
>>>> This patch switch RMA allocation code to use contigous memory allocator. The patch
>>>> also remove the the linear allocator which not used any more
>>>>
>>>> Acked-by: Paul Mackerras<paulus@samba.org>
>>>> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
>>>> ---
>> .... snip ....
>>
>>>> diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
>>>> index 550f592..55c8519 100644
>>>> --- a/arch/powerpc/kvm/book3s_hv.c
>>>> +++ b/arch/powerpc/kvm/book3s_hv.c
>>>> @@ -1511,10 +1511,10 @@ static inline int lpcr_rmls(unsigned long rma_size)
>>>>
>>>>    static int kvm_rma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>>>>    {
>>>> -	struct kvmppc_linear_info *ri = vma->vm_file->private_data;
>>>>    	struct page *page;
>>>> +	struct kvm_rma_info *ri = vma->vm_file->private_data;
>>>>
>>>> -	if (vmf->pgoff>= ri->npages)
>>>> +	if (vmf->pgoff>= kvm_rma_pages)
>>>>    		return VM_FAULT_SIGBUS;
>>>>
>>>>    	page = pfn_to_page(ri->base_pfn + vmf->pgoff);
>>>> @@ -1536,7 +1536,7 @@ static int kvm_rma_mmap(struct file *file, struct vm_area_struct *vma)
>>>>
>>>>    static int kvm_rma_release(struct inode *inode, struct file *filp)
>>>>    {
>>>> -	struct kvmppc_linear_info *ri = filp->private_data;
>>>> +	struct kvm_rma_info *ri = filp->private_data;
>>>>
>>>>    	kvm_release_rma(ri);
>>>>    	return 0;
>>>> @@ -1549,8 +1549,17 @@ static const struct file_operations kvm_rma_fops = {
>>>>
>>>>    long kvm_vm_ioctl_allocate_rma(struct kvm *kvm, struct kvm_allocate_rma *ret)
>>>>    {
>>>> -	struct kvmppc_linear_info *ri;
>>>>    	long fd;
>>>> +	struct kvm_rma_info *ri;
>>>> +	/*
>>>> +	 * Only do this on PPC970 in HV mode
>>>> +	 */
>>>> +	if (!cpu_has_feature(CPU_FTR_HVMODE) ||
>>>> +	    !cpu_has_feature(CPU_FTR_ARCH_201))
>>>> +		return -EINVAL;
>>> Is this really what we want? User space may want to use an RMA on POWER7
>>> systems, no?
>> IIUC they will use virtual real mode area (VRMA) and not RMA
>
> Then I suppose we should at least update the comment a bit further down 
> the patch that indicates that on POWER7 systems we do support a real 
> RMA. I can't really think of any reason why user space would want to use 
> RMA over VRMA.
>

where ? We have comments like

/* On POWER7, use VRMA; on PPC970, give up */

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
