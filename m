Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5F10D6B0074
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:11:30 -0400 (EDT)
Received: by wibg7 with SMTP id g7so41448256wib.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 02:11:29 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id h3si10711017wix.93.2015.03.23.02.11.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Mar 2015 02:11:28 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 23 Mar 2015 09:11:27 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2934717D805F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 09:11:53 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2N9BQck53805080
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 09:11:26 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2N9BMHJ011313
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 03:11:25 -0600
Message-ID: <550FD8B6.305@linux.vnet.ibm.com>
Date: Mon, 23 Mar 2015 10:11:18 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: Introducing arch_remap hook
References: <cover.1426866405.git.ldufour@linux.vnet.ibm.com> <503499aae380db1c4673f146bcba6ad095021257.1426866405.git.ldufour@linux.vnet.ibm.com> <20150323085209.GA28965@gmail.com>
In-Reply-To: <20150323085209.GA28965@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org

On 23/03/2015 09:52, Ingo Molnar wrote:
> 
> * Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
> 
>> Some architecture would like to be triggered when a memory area is moved
>> through the mremap system call.
>>
>> This patch is introducing a new arch_remap mm hook which is placed in the
>> path of mremap, and is called before the old area is unmapped (and the
>> arch_unmap hook is called).
>>
>> To no break the build, this patch adds the empty hook definition to the
>> architectures that were not using the generic hook's definition.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  arch/s390/include/asm/mmu_context.h      | 6 ++++++
>>  arch/um/include/asm/mmu_context.h        | 5 +++++
>>  arch/unicore32/include/asm/mmu_context.h | 6 ++++++
>>  arch/x86/include/asm/mmu_context.h       | 6 ++++++
>>  include/asm-generic/mm_hooks.h           | 6 ++++++
>>  mm/mremap.c                              | 9 +++++++--
>>  6 files changed, 36 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/s390/include/asm/mmu_context.h b/arch/s390/include/asm/mmu_context.h
>> index 8fb3802f8fad..ddd861a490ba 100644
>> --- a/arch/s390/include/asm/mmu_context.h
>> +++ b/arch/s390/include/asm/mmu_context.h
>> @@ -131,4 +131,10 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
>>  {
>>  }
>>  
>> +static inline void arch_remap(struct mm_struct *mm,
>> +			      unsigned long old_start, unsigned long old_end,
>> +			      unsigned long new_start, unsigned long new_end)
>> +{
>> +}
>> +
>>  #endif /* __S390_MMU_CONTEXT_H */
>> diff --git a/arch/um/include/asm/mmu_context.h b/arch/um/include/asm/mmu_context.h
>> index 941527e507f7..f499b017c1f9 100644
>> --- a/arch/um/include/asm/mmu_context.h
>> +++ b/arch/um/include/asm/mmu_context.h
>> @@ -27,6 +27,11 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
>>  				     struct vm_area_struct *vma)
>>  {
>>  }
>> +static inline void arch_remap(struct mm_struct *mm,
>> +			      unsigned long old_start, unsigned long old_end,
>> +			      unsigned long new_start, unsigned long new_end)
>> +{
>> +}
>>  /*
>>   * end asm-generic/mm_hooks.h functions
>>   */
>> diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
>> index 1cb5220afaf9..39a0a553172e 100644
>> --- a/arch/unicore32/include/asm/mmu_context.h
>> +++ b/arch/unicore32/include/asm/mmu_context.h
>> @@ -97,4 +97,10 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
>>  {
>>  }
>>  
>> +static inline void arch_remap(struct mm_struct *mm,
>> +			      unsigned long old_start, unsigned long old_end,
>> +			      unsigned long new_start, unsigned long new_end)
>> +{
>> +}
>> +
>>  #endif
>> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
>> index 883f6b933fa4..75cb71f4be1e 100644
>> --- a/arch/x86/include/asm/mmu_context.h
>> +++ b/arch/x86/include/asm/mmu_context.h
>> @@ -172,4 +172,10 @@ static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
>>  		mpx_notify_unmap(mm, vma, start, end);
>>  }
>>  
>> +static inline void arch_remap(struct mm_struct *mm,
>> +			      unsigned long old_start, unsigned long old_end,
>> +			      unsigned long new_start, unsigned long new_end)
>> +{
>> +}
>> +
>>  #endif /* _ASM_X86_MMU_CONTEXT_H */
> 
> So instead of spreading these empty prototypes around mmu_context.h 
> files, why not add something like this to the PPC definition:
> 
>  #define __HAVE_ARCH_REMAP
> 
> and define the empty prototype for everyone else? It's a bit like how 
> the __HAVE_ARCH_PTEP_* namespace works.
> 
> That should shrink this patch considerably.

My idea was to mimic the MMU hook's definition. This new hook is in the
continuity of what have been done for arch_dup_mmap, arch_exit_mmap,
arch_unmap and arch_bprm_mm_init.

Do you think that there is a need to make this one in another way ?

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
