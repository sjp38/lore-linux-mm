Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA096B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 05:22:47 -0400 (EDT)
Received: by wiun10 with SMTP id n10so10708405wiu.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 02:22:46 -0700 (PDT)
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id ib9si11685006wjb.198.2015.04.07.02.22.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 02:22:45 -0700 (PDT)
Received: by wgbdm7 with SMTP id dm7so49485583wgb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 02:22:45 -0700 (PDT)
Message-ID: <5523A1E2.6080704@plexistor.com>
Date: Tue, 07 Apr 2015 12:22:42 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm(v4.1): New pfn_mkwrite same as page_mkwrite for
 VM_PFNMAP
References: <55239645.9000507@plexistor.com> <552397E6.5030506@plexistor.com> <20150407090335.GA12664@node.dhcp.inet.fi>
In-Reply-To: <20150407090335.GA12664@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>, Stable Tree <stable@vger.kernel.org>

On 04/07/2015 12:03 PM, Kirill A. Shutemov wrote:
> On Tue, Apr 07, 2015 at 11:40:06AM +0300, Boaz Harrosh wrote:
>>
>> [v2]
>> Based on linux-next/akpm [3dc4623]. For v4.1 merge window
>> Incorporated comments from Andrew And Kirill
> 
> Not really. You've ignored most of them. See below.
> 

Yes sorry about that I sent the wrong version.

<>
>> ---
>>  include/linux/mm.h |  3 +++
>>  mm/memory.c        | 35 +++++++++++++++++++++++++++++++----
> 
> Please, document it in Documentation/filesystems/Locking.
> 

Ha, I missed this one. Ok will try to put something coherent.

<>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 59f6268..6e8f3f6 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1982,6 +1982,19 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
>>  	return ret;
>>  }
>>  
>> +static int do_pfn_mkwrite(struct vm_area_struct *vma, unsigned long address)
>> +{
>> +	struct vm_fault vmf = {
>> +		.page = 0,
> 
> .page = NULL,
> 
>> +		.pgoff = (((address & PAGE_MASK) - vma->vm_start)
>> +					>> PAGE_SHIFT) + vma->vm_pgoff,
> 
> .pgoff = linear_page_index(vma, address),
> 

Yes I had fixes for these two

>> +		.virtual_address = (void __user *)(address & PAGE_MASK),
>> +		.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
>> +	};
>> +
>> +	return vma->vm_ops->pfn_mkwrite(vma, &vmf);
>> +}
>> +
>>  /*
>>   * Handle write page faults for pages that can be reused in the current vma
>>   *
>> @@ -2259,14 +2272,28 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>  		 * VM_PFNMAP VMA.
>>  		 *
>>  		 * We should not cow pages in a shared writeable mapping.
>> -		 * Just mark the pages writable as we can't do any dirty
>> -		 * accounting on raw pfn maps.
>> +		 * Just mark the pages writable and/or call ops->pfn_mkwrite.
>>  		 */
>>  		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
>> -				     (VM_WRITE|VM_SHARED))
>> +				     (VM_WRITE|VM_SHARED)) {
> 
> Let's move this case in separate function -- wp_pfn_shared(). As we do for
> wp_page_shared().
> 

Ha, OK I will try that. I will need to re-run tests to make sure I did
not mess up

Thanks will fix, makes sense
Boaz

>> +			if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
>> +				int ret;
>> +
>> +				pte_unmap_unlock(page_table, ptl);
>> +				ret = do_pfn_mkwrite(vma, address);
>> +				if (ret & VM_FAULT_ERROR)
>> +					return ret;
>> +				page_table = pte_offset_map_lock(mm, pmd,
>> +								 address, &ptl);
>> +				/* Did pfn_mkwrite already fixed up the pte */
>> +				if (!pte_same(*page_table, orig_pte)) {
>> +					pte_unmap_unlock(page_table, ptl);
>> +					return ret;
>> +				}
>> +			}
>>  			return wp_page_reuse(mm, vma, address, page_table, ptl,
>>  					     orig_pte, old_page, 0, 0);
>> -
>> +		}
>>  		pte_unmap_unlock(page_table, ptl);
>>  		return wp_page_copy(mm, vma, address, page_table, pmd,
>>  				    orig_pte, old_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
