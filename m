Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id E27D46B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 00:14:23 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 22 Feb 2013 15:07:04 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 63EAA3578050
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 16:14:13 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1M5EAHZ328182
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 16:14:11 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1M5ECmW000746
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 16:14:12 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH -V2 05/21] powerpc: Reduce PTE table memory wastage
In-Reply-To: <20130222003235.GJ21011@truffula.fritz.box>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361465248-10867-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130222003235.GJ21011@truffula.fritz.box>
Date: Fri, 22 Feb 2013 10:44:09 +0530
Message-ID: <871uc9vske.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <david@gibson.dropbear.id.au> writes:

> On Thu, Feb 21, 2013 at 10:17:12PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We now have PTE page consuming only 2K of the 64K page.This is in order to
>> facilitate transparent huge page support, which works much better if our PMDs
>> cover 16MB instead of 256MB.
>> 
>> Inorder to reduce the wastage, we now have multiple PTE page fragment
>> from the same PTE page.
>
> This needs a much better description of what you're doing here to
> manage the allocations.  It's certainly not easy to figure out from
> the code.


I will add more detailed description in the commit message.

We allocate one page for the last level of linux page table. With THP and
large page size of 16MB, that would mean we are be wasting large part
of that page. To map 16MB area, we only need a PTE space of 2K with 64K
Page size. This patch reduce the space wastage by sharing the page
allocated for the last level of linux page table with multiple pmd
entries. We call these smaller chunks PTE page fragments and allocated
page, PTE page. We use the page->_mapcount as bitmap to indicate which
PTE fragments are free.


>
>
> [snip]
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +typedef pte_t *pgtable_t;
>> +#else
>>  typedef struct page *pgtable_t;
>> +#endif
>
> This looks really bogus.  A pgtable_t is a pointer to PTEs on 64K, but
> a pointer to a struct page on 4k.
>

We enable all the above only with 64K Pages. 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
