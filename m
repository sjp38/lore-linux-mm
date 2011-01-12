Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39DAE6B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 21:15:38 -0500 (EST)
Message-ID: <4D2D0EBE.7040406@goop.org>
Date: Wed, 12 Jan 2011 13:15:26 +1100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/9] mm: add apply_to_page_range_batch()
References: <cover.1292450600.git.jeremy.fitzhardinge@citrix.com> <8c28c76840fcc7b76c7c8ce4dc28a57241243df7.1292450600.git.jeremy.fitzhardinge@citrix.com> <20110110212628.GC15016@dumpdata.com>
In-Reply-To: <20110110212628.GC15016@dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Haavard Skinnemoen <hskinnemoen@atmel.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>, Xen-devel <xen-devel@lists.xensource.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
List-ID: <linux-mm.kvack.org>

On 01/11/2011 08:26 AM, Konrad Rzeszutek Wilk wrote:
> . snip..
>>  static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>>  				     unsigned long addr, unsigned long end,
>> -				     pte_fn_t fn, void *data)
>> +				     pte_batch_fn_t fn, void *data)
>>  {
>>  	pte_t *pte;
>>  	int err;
>> -	pgtable_t token;
>>  	spinlock_t *uninitialized_var(ptl);
>>  
>>  	pte = (mm == &init_mm) ?
>> @@ -1940,25 +1939,17 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>>  	BUG_ON(pmd_huge(*pmd));
>>  
>>  	arch_enter_lazy_mmu_mode();
>> -
>> -	token = pmd_pgtable(*pmd);
>> -
>> -	do {
>> -		err = fn(pte++, addr, data);
>> -		if (err)
>> -			break;
>> -	} while (addr += PAGE_SIZE, addr != end);
>> -
>> +	err = fn(pte, (end - addr) / PAGE_SIZE, addr, data);
>>  	arch_leave_lazy_mmu_mode();
>>  
>>  	if (mm != &init_mm)
>> -		pte_unmap_unlock(pte-1, ptl);
>> +		pte_unmap_unlock(pte, ptl);
> That looks like a bug fix as well? Did this hit us before the change or was
> it masked by the fact that the code never go to here?

No, it isn't.  In the original code, "pte" would end up pointing into
the next page as the end state of the loop; the "-1" points it back to
the correct page.  With the new version, pte remains unchanged.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
