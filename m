Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0FF6B0032
	for <linux-mm@kvack.org>; Sun, 21 Jun 2015 21:37:54 -0400 (EDT)
Received: by qkfe185 with SMTP id e185so93313942qkf.3
        for <linux-mm@kvack.org>; Sun, 21 Jun 2015 18:37:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 81si17716781qgx.77.2015.06.21.18.37.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jun 2015 18:37:53 -0700 (PDT)
Message-ID: <558766E4.5020801@redhat.com>
Date: Sun, 21 Jun 2015 21:37:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 3/3] mm: make swapin readahead to improve thp collapse
 rate
References: <1434799686-7929-1-git-send-email-ebru.akagunduz@gmail.com> <1434799686-7929-4-git-send-email-ebru.akagunduz@gmail.com> <20150621181131.GA6710@node.dhcp.inet.fi>
In-Reply-To: <20150621181131.GA6710@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 06/21/2015 02:11 PM, Kirill A. Shutemov wrote:
> On Sat, Jun 20, 2015 at 02:28:06PM +0300, Ebru Akagunduz wrote:

>> +static void __collapse_huge_page_swapin(struct mm_struct *mm,
>> +					struct vm_area_struct *vma,
>> +					unsigned long address, pmd_t *pmd,
>> +					pte_t *pte)
>> +{
>> +	unsigned long _address;
>> +	pte_t pteval = *pte;
>> +	int swap_pte = 0;
>> +
>> +	pte = pte_offset_map(pmd, address);
>> +	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
>> +	     pte++, _address += PAGE_SIZE) {
>> +		pteval = *pte;
>> +		if (is_swap_pte(pteval)) {
>> +			swap_pte++;
>> +			do_swap_page(mm, vma, _address, pte, pmd,
>> +				     FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
>> +				     pteval);
> 
> Hm. I guess this lacking error handling.
> We really should abort early at least for VM_FAULT_HWPOISON and VM_FAULT_OOM.

Good catch.

>> +			/* pte is unmapped now, we need to map it */
>> +			pte = pte_offset_map(pmd, _address);
> 
> No, it's within the same pte page table. It should be mapped with
> pte_offset_map() above.

It would be, except do_swap_page() unmaps the pte page table.

>> @@ -2551,6 +2586,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>>  	if (!pmd)
>>  		goto out;
>>  
>> +	__collapse_huge_page_swapin(mm, vma, address, pmd, pte);
>> +
> 
> And now the pages we swapped in are not isolated, right?
> What prevents them from being swapped out again or whatever?

Nothing, but __collapse_huge_page_isolate is run with the
appropriate locks to ensure that once we actually collapse
the THP, things are present.

The way do_swap_page is called, khugepaged does not even
wait for pages to be brought in from swap. It just maps
in pages that are in the swap cache, and which can be
immediately locked (without waiting).

It will also start IO on pages that are not in memory
yet, and will hopefully get those next round.


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
