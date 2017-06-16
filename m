Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE68B83293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:57:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d21so4265902wme.2
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 08:57:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k19si2687473wrd.349.2017.06.16.08.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 08:57:25 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5GFrkWe056954
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:57:24 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b4hqpsp2a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:57:23 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 16 Jun 2017 11:57:23 -0400
Subject: Re: [PATCHv2 3/3] mm: Use updated pmdp_invalidate() inteface to track
 dirty/accessed bits
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-4-kirill.shutemov@linux.intel.com>
 <87bmpob23x.fsf@skywalker.in.ibm.com>
 <20170616132143.cdr4qt5hzvgxsnek@node.shutemov.name>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Fri, 16 Jun 2017 21:27:04 +0530
MIME-Version: 1.0
In-Reply-To: <20170616132143.cdr4qt5hzvgxsnek@node.shutemov.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <f662e44c-4dd9-a301-8b6c-8cee572f6465@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Friday 16 June 2017 06:51 PM, Kirill A. Shutemov wrote:
> On Fri, Jun 16, 2017 at 05:01:30PM +0530, Aneesh Kumar K.V wrote:
>> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
>>
>>> This patch uses modifed pmdp_invalidate(), that return previous value of pmd,
>>> to transfer dirty and accessed bits.
>>>
>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> ---
>>>   fs/proc/task_mmu.c |  8 ++++----
>>>   mm/huge_memory.c   | 29 ++++++++++++-----------------
>>>   2 files changed, 16 insertions(+), 21 deletions(-)
>>>
>>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>>> index f0c8b33d99b1..f2fc1ef5bba2 100644
>>> --- a/fs/proc/task_mmu.c
>>> +++ b/fs/proc/task_mmu.c
>>
>> .....
>>
>>> @@ -1965,7 +1955,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>>>   	page_ref_add(page, HPAGE_PMD_NR - 1);
>>>   	write = pmd_write(*pmd);
>>>   	young = pmd_young(*pmd);
>>> -	dirty = pmd_dirty(*pmd);
>>>   	soft_dirty = pmd_soft_dirty(*pmd);
>>>
>>>   	pmdp_huge_split_prepare(vma, haddr, pmd);
>>> @@ -1995,8 +1984,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>>>   			if (soft_dirty)
>>>   				entry = pte_mksoft_dirty(entry);
>>>   		}
>>> -		if (dirty)
>>> -			SetPageDirty(page + i);
>>>   		pte = pte_offset_map(&_pmd, addr);
>>>   		BUG_ON(!pte_none(*pte));
>>>   		set_pte_at(mm, addr, pte, entry);
>>> @@ -2045,7 +2032,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>>>   	 * and finally we write the non-huge version of the pmd entry with
>>>   	 * pmd_populate.
>>>   	 */
>>> -	pmdp_invalidate(vma, haddr, pmd);
>>> +	old = pmdp_invalidate(vma, haddr, pmd);
>>> +
>>> +	/*
>>> +	 * Transfer dirty bit using value returned by pmd_invalidate() to be
>>> +	 * sure we don't race with CPU that can set the bit under us.
>>> +	 */
>>> +	if (pmd_dirty(old))
>>> +		SetPageDirty(page);
>>> +
>>>   	pmd_populate(mm, pmd, pgtable);
>>>
>>>   	if (freeze) {
>>
>>
>> Can we invalidate the pmd early here ? ie, do pmdp_invalidate instead of
>> pmdp_huge_split_prepare() ?
> 
> I think we can. But it means we would block access to the page for longer
> than it's necessary on most architectures. I guess it's not a bit deal.
> 
> Maybe as separate patch on top of this patchet? Aneesh, would you take
> care of this?
> 

Yes, I cam do that.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
