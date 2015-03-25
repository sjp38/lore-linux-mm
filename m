Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5A02D6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:25:28 -0400 (EDT)
Received: by wgs2 with SMTP id 2so27394591wgs.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:25:27 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id bi1si22077015wib.106.2015.03.25.06.25.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 06:25:26 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 25 Mar 2015 13:25:25 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5BB851B0805F
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:25:47 +0000 (GMT)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2PDPLKt65601784
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:25:21 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2PDPI7B004627
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 07:25:20 -0600
Message-ID: <5512B73C.5050509@linux.vnet.ibm.com>
Date: Wed, 25 Mar 2015 14:25:16 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] powerpc/mm: Tracking vDSO remap
References: <20150323085209.GA28965@gmail.com> <cover.1427280806.git.ldufour@linux.vnet.ibm.com> <25152b76585716dc635945c3455ab9b49e645f6d.1427280806.git.ldufour@linux.vnet.ibm.com> <20150325121118.GA2542@gmail.com>
In-Reply-To: <20150325121118.GA2542@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org

On 25/03/2015 13:11, Ingo Molnar wrote:
> 
> * Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
> 
>> Some processes (CRIU) are moving the vDSO area using the mremap system
>> call. As a consequence the kernel reference to the vDSO base address is
>> no more valid and the signal return frame built once the vDSO has been
>> moved is not pointing to the new sigreturn address.
>>
>> This patch handles vDSO remapping and unmapping.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/include/asm/mmu_context.h | 36 +++++++++++++++++++++++++++++++++-
>>  1 file changed, 35 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
>> index 73382eba02dc..be5dca3f7826 100644
>> --- a/arch/powerpc/include/asm/mmu_context.h
>> +++ b/arch/powerpc/include/asm/mmu_context.h
>> @@ -8,7 +8,6 @@
>>  #include <linux/spinlock.h>
>>  #include <asm/mmu.h>	
>>  #include <asm/cputable.h>
>> -#include <asm-generic/mm_hooks.h>
>>  #include <asm/cputhreads.h>
>>  
>>  /*
>> @@ -109,5 +108,40 @@ static inline void enter_lazy_tlb(struct mm_struct *mm,
>>  #endif
>>  }
>>  
>> +static inline void arch_dup_mmap(struct mm_struct *oldmm,
>> +				 struct mm_struct *mm)
>> +{
>> +}
>> +
>> +static inline void arch_exit_mmap(struct mm_struct *mm)
>> +{
>> +}
>> +
>> +static inline void arch_unmap(struct mm_struct *mm,
>> +			struct vm_area_struct *vma,
>> +			unsigned long start, unsigned long end)
>> +{
>> +	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
>> +		mm->context.vdso_base = 0;
>> +}
>> +
>> +static inline void arch_bprm_mm_init(struct mm_struct *mm,
>> +				     struct vm_area_struct *vma)
>> +{
>> +}
>> +
>> +#define __HAVE_ARCH_REMAP
>> +static inline void arch_remap(struct mm_struct *mm,
>> +			      unsigned long old_start, unsigned long old_end,
>> +			      unsigned long new_start, unsigned long new_end)
>> +{
>> +	/*
>> +	 * mremap don't allow moving multiple vma so we can limit the check
>> +	 * to old_start == vdso_base.
> 
> s/mremap don't allow moving multiple vma
>   mremap() doesn't allow moving multiple vmas
> 
> right?

Sure you're right.

I'll provide a v3 fixing that comment.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
