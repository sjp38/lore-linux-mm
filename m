Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id E585C6B0005
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 11:38:17 -0500 (EST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 24 Feb 2013 02:32:32 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 25F6E2CE804A
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 03:38:13 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1NGPeqQ10617192
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 03:25:40 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1NGcCcN004822
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 03:38:12 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH -V2 05/21] powerpc: Reduce PTE table memory wastage
In-Reply-To: <20130222052351.GE6139@drongo>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361465248-10867-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130222052351.GE6139@drongo>
Date: Sat, 23 Feb 2013 22:08:10 +0530
Message-ID: <8738wnc7f1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

> On Thu, Feb 21, 2013 at 10:17:12PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We now have PTE page consuming only 2K of the 64K page.This is in order to
>
> In fact the PTE page together with the hash table indexes occupies 4k,
> doesn't it?  The comments in the code are similarly confusing since
> they talk about 2k but actually allocate 4k.
>
>> facilitate transparent huge page support, which works much better if our PMDs
>> cover 16MB instead of 256MB.
>> 
>> Inorder to reduce the wastage, we now have multiple PTE page fragment
>   ^ In order (two words)
>
>> from the same PTE page.
>
> A patch like this needs a more complete description and explanation
> than you have given.  For instance, you could mention that the code
> that you're adding for the 32-bit and non-64k cases are just copies of
> the previously generic code from pgalloc.h (actually, this movement
> might be something that could be split out as a separate patch).
> Also, you should describe in outline how you keep a list of pages that
> aren't fully allocated and have a bitmap of which 4k sections are in
> use, and also how your scheme interacts with RCU.

will do

>
> [snip]
>
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +/*
>> + * we support 15 fragments per PTE page. This is limited by how many
>
> Why only 15?  Don't we get 16 fragments per page?
>

That was one of the details I wanted to come back and closely look at
before posting. But missed that in the excitement of getting this
all working :). ._mapcount is a signed value and hence I was not sure
whether setting the top bit have any impact on how we deal with the page
in other part of VM. 


>> + * bits we can pack in page->_mapcount. We use the first half for
>> + * tracking the usage for rcu page table free.
>
> What does "first" mean?  The high half or the low half?
>

high half.

>> +unsigned long *page_table_alloc(struct mm_struct *mm, unsigned long vmaddr)
>> +{
>> +	struct page *page;
>> +	unsigned int mask, bit;
>> +	unsigned long *table;
>> +
>> +	/* Allocate fragments of a 4K page as 1K/2K page table */
>
> A 4k page?  Do you mean a 64k page?  And what is 1K to do with
> anything?
>

That should be completely dropped, Cut-paste from s390 code :)

>> +#ifdef CONFIG_SMP
>> +static void __page_table_free_rcu(void *table)
>> +{
>> +	unsigned int bit;
>> +	struct page *page;
>> +	/*
>> +	 * this is a PTE page free 2K page table
>> +	 * fragment of a 64K page.
>> +	 */
>> +	page = virt_to_page(table);
>> +	bit = 1 << ((__pa(table) & ~PAGE_MASK) / PTE_FRAG_SIZE);
>> +	bit <<= FRAG_MASK_BITS;
>> +	/*
>> +	 * clear the higher half and if nobody used the page in
>> +	 * between, even lower half would be zero.
>> +	 */
>> +	if (atomic_xor_bits(&page->_mapcount, bit) == 0) {
>> +		pgtable_page_dtor(page);
>> +		atomic_set(&page->_mapcount, -1);
>> +		__free_page(page);
>> +	}
>> +}
>> +
>> +static void page_table_free_rcu(struct mmu_gather *tlb, unsigned long *table)
>> +{
>> +	struct page *page;
>> +	struct mm_struct *mm;
>> +	unsigned int bit, mask;
>> +
>> +	mm = tlb->mm;
>> +	/* Free 2K page table fragment of a 64K page */
>> +	page = virt_to_page(table);
>> +	bit = 1 << ((__pa(table) & ~PAGE_MASK) / PTE_FRAG_SIZE);
>> +	spin_lock(&mm->page_table_lock);
>> +	/*
>> +	 * stash the actual mask in higher half, and clear the lower half
>> +	 * and selectively, add remove from pgtable list
>> +	 */
>> +	mask = atomic_xor_bits(&page->_mapcount, bit | (bit << FRAG_MASK_BITS));
>> +	if (!(mask & FRAG_MASK))
>> +		list_del(&page->lru);
>> +	else {
>> +		/*
>> +		 * Add the page table page to pgtable_list so that
>> +		 * the free fragment can be used by the next alloc
>> +		 */
>> +		list_del_init(&page->lru);
>> +		list_add_tail(&page->lru, &mm->context.pgtable_list);
>> +	}
>> +	spin_unlock(&mm->page_table_lock);
>> +	tlb_remove_table(tlb, table);
>> +}

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
