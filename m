Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id E8EF56B02FA
	for <linux-mm@kvack.org>; Fri,  3 May 2013 15:09:24 -0400 (EDT)
Message-ID: <51840B50.6010603@parallels.com>
Date: Fri, 03 May 2013 23:09:04 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm: soft-dirty bits for user memory changes tracking
References: <517FED13.8090806@parallels.com> <517FED64.4020400@parallels.com> <5183A137.4060808@linux.vnet.ibm.com>
In-Reply-To: <5183A137.4060808@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Matt Mackall <mpm@selenic.com>, Marcelo Tosatti <mtosatti@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 05/03/2013 03:36 PM, Xiao Guangrong wrote:
> On 05/01/2013 12:12 AM, Pavel Emelyanov wrote:
> 
>> +static inline void clear_soft_dirty(struct vm_area_struct *vma,
>> +		unsigned long addr, pte_t *pte)
>> +{
>> +#ifdef CONFIG_MEM_SOFT_DIRTY
>> +	/*
>> +	 * The soft-dirty tracker uses #PF-s to catch writes
>> +	 * to pages, so write-protect the pte as well. See the
>> +	 * Documentation/vm/soft-dirty.txt for full description
>> +	 * of how soft-dirty works.
>> +	 */
>> +	pte_t ptent = *pte;
>> +	ptent = pte_wrprotect(ptent);
>> +	ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
>> +	set_pte_at(vma->vm_mm, addr, pte, ptent);
>> +#endif
> 
> It seems that TLBs are not flushed and mmu-notification is not called?

TLBs are flushed by clear_refs_write()->flush_tlb_mm().

As far as MMU notification is concerned -- yes, you're right! I will
prepare the patch for this soon.

> .
> 


Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
