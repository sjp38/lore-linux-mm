Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 2BA836B0034
	for <linux-mm@kvack.org>; Mon, 13 May 2013 10:45:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 14 May 2013 00:32:29 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 0B5402CE804A
	for <linux-mm@kvack.org>; Tue, 14 May 2013 00:45:06 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DEUxmo22675704
	for <linux-mm@kvack.org>; Tue, 14 May 2013 00:30:59 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DEj5wp006257
	for <linux-mm@kvack.org>; Tue, 14 May 2013 00:45:05 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/THP: Use pmd_populate to update the pmd with pgtable_t pointer
In-Reply-To: <20130513141357.GL27980@redhat.com>
References: <1368347715-24597-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <871u9b56t2.fsf@linux.vnet.ibm.com> <20130513141357.GL27980@redhat.com>
Date: Mon, 13 May 2013 20:14:55 +0530
Message-ID: <87y5bj3pnc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

Andrea Arcangeli <aarcange@redhat.com> writes:

> Hi Aneesh,
>
> On Mon, May 13, 2013 at 07:18:57PM +0530, Aneesh Kumar K.V wrote:
>> 
>> updated one fixing a compile warning.
>> 
>> From f721c77eb0d6aaf75758e8e93991a05207680ac8 Mon Sep 17 00:00:00 2001
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> Date: Sun, 12 May 2013 01:59:00 +0530
>> Subject: [PATCH] mm/THP: Use pmd_populate to update the pmd with pgtable_t
>>  pointer
>> 
>> We should not use set_pmd_at to update pmd_t with pgtable_t pointer. set_pmd_at
>> is used to set pmd with huge pte entries and architectures like ppc64, clear
>> few flags from the pte when saving a new entry. Without this change we observe
>> bad pte errors like below on ppc64 with THP enabled.
>> 
>> BUG: Bad page map in process ld mm=0xc000001ee39f4780 pte:7fc3f37848000001 pmd:c000001ec0000000
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  mm/huge_memory.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 03a89a2..f0bad1f 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2325,7 +2325,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>>  		pte_unmap(pte);
>>  		spin_lock(&mm->page_table_lock);
>>  		BUG_ON(!pmd_none(*pmd));
>> -		set_pmd_at(mm, address, pmd, _pmd);
>> +		pmd_populate(mm, pmd, (pgtable_t)_pmd);
>>  		spin_unlock(&mm->page_table_lock);
>>  		anon_vma_unlock_write(vma->anon_vma);
>>  		goto out;
>
> Great, looks like you found the ppc problem with gcc builds and that
> explains also why it cannot happen on x86.

yes. That was the reason for the failure. 

>
> But about the fix, did you test it? The above should be:
> pmd_populate(mm, pmd, pmd_pgtable(_pmd)) instead.
>

Yes and it worked in powerpc because we have for ppc64 

static inline pgtable_t pmd_pgtable(pmd_t pmd)
{
	return (pgtable_t)(pmd_val(pmd) & ~PMD_MASKED_BITS);
}

That is because we share the PTE page with multiple pmds

> _pmd is not a pointer to a page struct and the cast seems to be hiding
> a bug. _pmd if something is a physical address potentially with some
> high bit set not making it a good physical address either.
>
> So you can only use set_pmd_at when establishing hugepmds, and never
> for establishing regular pmds that points to regular pagetables. I
> guess a comment would be good to add too.
>

I will send an updated patch.


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
