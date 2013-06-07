Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id E71E76B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 23:55:39 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 7 Jun 2013 13:49:46 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id BB7B42BB0051
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 13:55:30 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r573erw466191382
	for <linux-mm@kvack.org>; Fri, 7 Jun 2013 13:40:54 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r573tSoq024759
	for <linux-mm@kvack.org>; Fri, 7 Jun 2013 13:55:29 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 09/18] powerpc: Switch 16GB and 16MB explicit hugepages to a different page table format
In-Reply-To: <1370558559.32518.4@snotra>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1367177859-7893-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1370558559.32518.4@snotra>
Date: Fri, 07 Jun 2013 09:25:22 +0530
Message-ID: <87zjv2wp5h.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Scott Wood <scottwood@freescale.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Scott Wood <scottwood@freescale.com> writes:

> On 04/28/2013 02:37:30 PM, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We will be switching PMD_SHIFT to 24 bits to facilitate THP  
>> impmenetation.
>> With PMD_SHIFT set to 24, we now have 16MB huge pages allocated at  
>> PGD level.
>> That means with 32 bit process we cannot allocate normal pages at
>> all, because we cover the entire address space with one pgd entry.  
>> Fix this
>> by switching to a new page table format for hugepages. With the new  
>> page table
>> format for 16GB and 16MB hugepages we won't allocate hugepage  
>> directory. Instead
>> we encode the PTE information directly at the directory level. This  
>> forces 16MB
>> hugepage at PMD level. This will also make the page take walk much  
>> simpler later
>> when we add the THP support.
>> 
>> With the new table format we have 4 cases for pgds and pmds:
>> (1) invalid (all zeroes)
>> (2) pointer to next table, as normal; bottom 6 bits == 0
>> (3) leaf pte for huge page, bottom two bits != 00
>> (4) hugepd pointer, bottom two bits == 00, next 4 bits indicate size  
>> of table
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/include/asm/page.h    |   2 +
>>  arch/powerpc/include/asm/pgtable.h |   2 +
>>  arch/powerpc/mm/gup.c              |  18 +++-
>>  arch/powerpc/mm/hugetlbpage.c      | 176  
>> +++++++++++++++++++++++++++++++------
>>  4 files changed, 168 insertions(+), 30 deletions(-)
>
> After this patch, on 64-bit book3e (e5500, and thus 4K pages), I see  
> messages like this after exiting a program that uses hugepages  
> (specifically, qemu):
>
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc221516.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc221516.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc2214d6.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc2214d6.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc221916.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc221916.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc2218d6.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc2218d6.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc221496.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc221496.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc221856.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc221856.
> /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd  
> 40000001fc221816.

hmm that implies some of the code paths are not properly #ifdef.
The goal was to limit the new format CONFIG_PPC_BOOK3S_64 as seen in the
definition of huge_pte_alloc. Can you send me the .config ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
