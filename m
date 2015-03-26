Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 351F46B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 03:49:34 -0400 (EDT)
Received: by wixm2 with SMTP id m2so5319093wix.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 00:49:33 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id gi11si26826014wic.70.2015.03.26.00.49.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 00:49:32 -0700 (PDT)
Received: by wiaa2 with SMTP id a2so10183754wia.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 00:49:32 -0700 (PDT)
Message-ID: <5513BA09.3020303@plexistor.com>
Date: Thu, 26 Mar 2015 09:49:29 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: New pfn_mkwrite same as page_mkwrite for VM_PFNMAP
References: <5512B961.8070409@plexistor.com> <5512BA5D.8070609@plexistor.com> <20150325143448.GA11906@node.dhcp.inet.fi>
In-Reply-To: <20150325143448.GA11906@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On 03/25/2015 04:34 PM, Kirill A. Shutemov wrote:
> On Wed, Mar 25, 2015 at 03:38:37PM +0200, Boaz Harrosh wrote:
>> From: Yigal Korman <yigal@plexistor.com>
>>
>> This will allow FS that uses VM_PFNMAP | VM_MIXEDMAP (no page structs)
>> to get notified when access is a write to a read-only PFN.
>>
>> This can happen if we mmap() a file then first mmap-read from it
>> to page-in a read-only PFN, than we mmap-write to the same page.
>>
>> We need this functionality to fix a DAX bug, where in the scenario
>> above we fail to set ctime/mtime though we modified the file.
>> An xfstest is attached to this patchset that shows the failure
>> and the fix. (A DAX patch will follow)
>>
>> This functionality is extra important for us, because upon
>> dirtying of a pmem page we also want to RDMA the page to a
>> remote cluster node.
>>
>> We define a new pfn_mkwrite and do not reuse page_mkwrite because
>>   1 - The name ;-)
>>   2 - But mainly because it would take a very long and tedious
>>       audit of all page_mkwrite functions of VM_MIXEDMAP/VM_PFNMAP
>>       users. To make sure they do not now CRASH. For example current
>>       DAX code (which this is for) would crash.
>>       If we would want to reuse page_mkwrite, We will need to first
>>       patch all users, so to not-crash-on-no-page. Then enable this
>>       patch. But even if I did that I would not sleep so well at night.
>>       Adding a new vector is the safest thing to do, and is not that
>>       expensive. an extra pointer at a static function vector per driver.
>>       Also the new vector is better for performance, because else we
>>       Will call all current Kernel vectors, so to:
>> 	check-ha-no-page-do-nothing and return.
>>
>> No need to call it from do_shared_fault because do_wp_page is called to
>> change pte permissions anyway.
>>
>> CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
>> CC: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> CC: Jan Kara <jack@suse.cz>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: Hugh Dickins <hughd@google.com>
>> CC: Mel Gorman <mgorman@suse.de>
>> CC: linux-mm@kvack.org
>>
>> Signed-off-by: Yigal Korman <yigal@plexistor.com>
>> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> 
> This is not going to apply to -mm. do_wp_page() is reworked there.
> BTW, shouldn't we rename it to do_wp_fault() or something?
> 

Wowhoo you were not kidding ;-)

I'll redo this patch based on linux-next/akpm branch. I will
need an hard up testing. Current patch I had for 6 month and
I'm confident about it. I'll need to stare at this real hard.

>> ---
>>  include/linux/mm.h |  2 ++
>>  mm/memory.c        | 28 +++++++++++++++++++++++++++-
> 
> Documentation/filesystems/Locking ?
> 
>>  2 files changed, 29 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 47a9392..1cd820c 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -250,6 +250,8 @@ struct vm_operations_struct {
>>  	/* notification that a previously read-only page is about to become
>>  	 * writable, if an error is returned it will cause a SIGBUS */
>>  	int (*page_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
>> +	/* same as page_mkwrite when using VM_PFNMAP|VM_MIXEDMAP */
> 
> New line before the comment?
> 
>> +	int (*pfn_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
>>  
>>  	/* called by access_process_vm when get_user_pages() fails, typically
>>  	 * for use by special VMAs that can switch between memory and hardware
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 8068893..8d640d1 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1982,6 +1982,23 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
>>  	return ret;
>>  }
>>  
>> +static int do_pfn_mkwrite(struct vm_area_struct *vma, unsigned long address)
>> +{
>> +	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
>> +		struct vm_fault vmf = {
>> +			.page = 0,
> 
> .page = NULL,
> 
>> +			.pgoff = (((address & PAGE_MASK) - vma->vm_start)
>> +						>> PAGE_SHIFT) + vma->vm_pgoff,
> 
> .pgoff = linear_page_index(vma, address),
> 
>> +			.virtual_address = (void __user *)(address & PAGE_MASK),
>> +			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
>> +		};
>> +
>> +		return vma->vm_ops->pfn_mkwrite(vma, &vmf);
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>>  /*
>>   * This routine handles present pages, when users try to write
>>   * to a shared page. It is done by copying the page to a new address
>> @@ -2025,8 +2042,17 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>  		 * accounting on raw pfn maps.
>>  		 */
>>  		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
>> -				     (VM_WRITE|VM_SHARED))
>> +				     (VM_WRITE|VM_SHARED)) {
>> +			pte_unmap_unlock(page_table, ptl);
> 
> It would be nice to avoid ptl drop if ->pfn_mkwrite is not defined for the
> vma.

OK Yes, I will move the if (vma->vm_ops && vma->vm_ops->pfn_mkwrite)
to out here surrounding the unlock/lock

> 
>> +			ret = do_pfn_mkwrite(vma, address);
>> +			if (ret & VM_FAULT_ERROR)
>> +				return ret;
>> +			page_table = pte_offset_map_lock(mm, pmd, address,
>> +							 &ptl);
>> +			if (!pte_same(*page_table, orig_pte))
>> +				goto unlock;
>>  			goto reuse;
>> +		}
>>  		goto gotten;
>>  	}
>>  

Thank you Kirill, very much. I was hopping you'll have a look at this
see all the fine implications.

I will fix and send, after some hard testing.

Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
