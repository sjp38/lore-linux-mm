Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 282476B0033
	for <linux-mm@kvack.org>; Mon, 13 May 2013 11:06:46 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 13 May 2013 20:32:59 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id DC694394004F
	for <linux-mm@kvack.org>; Mon, 13 May 2013 20:36:40 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DF6YXS56623194
	for <linux-mm@kvack.org>; Mon, 13 May 2013 20:36:35 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DF6dF1031051
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:06:39 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/THP: Use pmd_populate to update the pmd with pgtable_t pointer
In-Reply-To: <87y5bj3pnc.fsf@linux.vnet.ibm.com>
References: <1368347715-24597-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <871u9b56t2.fsf@linux.vnet.ibm.com> <20130513141357.GL27980@redhat.com> <87y5bj3pnc.fsf@linux.vnet.ibm.com>
Date: Mon, 13 May 2013 20:36:38 +0530
Message-ID: <87txm6537l.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Andrea Arcangeli <aarcange@redhat.com> writes:
>
>> Hi Aneesh,
>>
>> On Mon, May 13, 2013 at 07:18:57PM +0530, Aneesh Kumar K.V wrote:
>>> 
>>> updated one fixing a compile warning.
>>> 
>>> From f721c77eb0d6aaf75758e8e93991a05207680ac8 Mon Sep 17 00:00:00 2001
>>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>> Date: Sun, 12 May 2013 01:59:00 +0530
>>> Subject: [PATCH] mm/THP: Use pmd_populate to update the pmd with pgtable_t
>>>  pointer
>>> 
>>> We should not use set_pmd_at to update pmd_t with pgtable_t pointer. set_pmd_at
>>> is used to set pmd with huge pte entries and architectures like ppc64, clear
>>> few flags from the pte when saving a new entry. Without this change we observe
>>> bad pte errors like below on ppc64 with THP enabled.
>>> 
>>> BUG: Bad page map in process ld mm=0xc000001ee39f4780 pte:7fc3f37848000001 pmd:c000001ec0000000
>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>>> ---
>>>  mm/huge_memory.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>> 
>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>> index 03a89a2..f0bad1f 100644
>>> --- a/mm/huge_memory.c
>>> +++ b/mm/huge_memory.c
>>> @@ -2325,7 +2325,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>>>  		pte_unmap(pte);
>>>  		spin_lock(&mm->page_table_lock);
>>>  		BUG_ON(!pmd_none(*pmd));
>>> -		set_pmd_at(mm, address, pmd, _pmd);
>>> +		pmd_populate(mm, pmd, (pgtable_t)_pmd);
>>>  		spin_unlock(&mm->page_table_lock);
>>>  		anon_vma_unlock_write(vma->anon_vma);
>>>  		goto out;
>>
>> Great, looks like you found the ppc problem with gcc builds and that
>> explains also why it cannot happen on x86.
>
> yes. That was the reason for the failure. 
>

The compiler crash was due to the fact that we didn't do hardware hash
pte flush on pmdp_clear_flush. That means we had previous translations
available while we did a hugepage copy on collapse. Once we fixed that we started
hitting the above Bad page map error. The interesting part for THP on
ppc64 is that we have 

static inline void flush_tlb_range(struct vm_area_struct *vma,
				   unsigned long start, unsigned long end)
{
}

That means we don't really wait for those page table walks with local irq
disabled to finish in both split page and collapse huge page. I handled
that by looking at _PAGE_SPLITTING before we mark the pte _PAGE_BUSY. 

Details are captured here
https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-May/106406.html

https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-May/106410.html

It would be nice if you could review the patches.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
