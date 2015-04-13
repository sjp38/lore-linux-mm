Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 95F276B0038
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 08:41:33 -0400 (EDT)
Received: by widdi4 with SMTP id di4so49958615wid.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 05:41:33 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id dj8si590100wib.80.2015.04.13.05.41.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 05:41:32 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 13 Apr 2015 13:41:30 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id C0DEF17D8063
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 13:42:02 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3DCfR8U852308
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 12:41:27 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3DCfOFP013438
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:41:27 -0600
Message-ID: <552BB972.3010704@linux.vnet.ibm.com>
Date: Mon, 13 Apr 2015 14:41:22 +0200
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v3 1/2] mm: Introducing arch_remap hook
References: <cover.1428916945.git.ldufour@linux.vnet.ibm.com> <9d827fc618a718830b2c47aa87e8be546914c897.1428916945.git.ldufour@linux.vnet.ibm.com> <20150413115811.GA12354@node.dhcp.inet.fi>
In-Reply-To: <20150413115811.GA12354@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@kernel.org>, linuxppc-dev@lists.ozlabs.org, cov@codeaurora.org, criu@openvz.org

On 13/04/2015 13:58, Kirill A. Shutemov wrote:
> On Mon, Apr 13, 2015 at 11:56:27AM +0200, Laurent Dufour wrote:
>> Some architecture would like to be triggered when a memory area is moved
>> through the mremap system call.
>>
>> This patch is introducing a new arch_remap mm hook which is placed in the
>> path of mremap, and is called before the old area is unmapped (and the
>> arch_unmap hook is called).
>>
>> The architectures which need to call this hook should define
>> __HAVE_ARCH_REMAP in their asm/mmu_context.h and provide the arch_remap
>> service with the following prototype:
>> void arch_remap(struct mm_struct *mm,
>>                 unsigned long old_start, unsigned long old_end,
>>                 unsigned long new_start, unsigned long new_end);
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> Reviewed-by: Ingo Molnar <mingo@kernel.org>
>> ---
>>  mm/mremap.c | 19 +++++++++++++------
>>  1 file changed, 13 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/mremap.c b/mm/mremap.c
>> index 2dc44b1cb1df..009db5565893 100644
>> --- a/mm/mremap.c
>> +++ b/mm/mremap.c
>> @@ -25,6 +25,7 @@
>>  
>>  #include <asm/cacheflush.h>
>>  #include <asm/tlbflush.h>
>> +#include <asm/mmu_context.h>
>>  
>>  #include "internal.h"
>>  
>> @@ -286,13 +287,19 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>>  		old_len = new_len;
>>  		old_addr = new_addr;
>>  		new_addr = -ENOMEM;
>> -	} else if (vma->vm_file && vma->vm_file->f_op->mremap) {
>> -		err = vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
>> -		if (err < 0) {
>> -			move_page_tables(new_vma, new_addr, vma, old_addr,
>> -					 moved_len, true);
>> -			return err;
>> +	} else {
>> +		if (vma->vm_file && vma->vm_file->f_op->mremap) {
>> +			err = vma->vm_file->f_op->mremap(vma->vm_file, new_vma);
>> +			if (err < 0) {
>> +				move_page_tables(new_vma, new_addr, vma,
>> +						  old_addr, moved_len, true);
>> +				return err;
>> +			}
>>  		}
>> +#ifdef __HAVE_ARCH_REMAP
> 
> It would be cleaner to provide dummy arch_remap() for !__HAVE_ARCH_REMAP
> in some generic header.

The idea was to not impact all the architectures as arch_unmap(),
arch_dup_mmap() or arch_exit_mmap() implies.

I look at the headers where such a dummy arch_remap could be put but I
can't figure out one which will not impact all the architecture.
What about defining a dummy service earlier in mm/remap.c in the case
__HAVE_ARCH_REMAP is not defined ?
Something like :
#ifndef __HAVE_ARCH_REMAP
static inline void void arch_remap(struct mm_struct *mm,
                                   unsigned long old_start,
                                   unsigned long old_end,
                                   unsigned long new_start,
                                   unsigned long new_end)
{
}
#endif

> 
> 
>> +		arch_remap(mm, old_addr, old_addr+old_len,
>> +			   new_addr, new_addr+new_len);
> 
> Spaces around '+'?

Nice catch ;)

Thanks,
Laurent.

> 
>> +#endif
>>  	}
>>  
>>  	/* Conceal VM_ACCOUNT so old reservation is not undone */
>> -- 
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
