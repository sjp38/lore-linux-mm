Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA2D6B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 09:37:12 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so56393343wgb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 06:37:12 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id ef4si12851666wib.120.2015.04.07.06.37.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 06:37:11 -0700 (PDT)
Received: by wiax7 with SMTP id x7so10990712wia.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 06:37:10 -0700 (PDT)
Message-ID: <5523DD83.4050609@plexistor.com>
Date: Tue, 07 Apr 2015 16:37:07 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3 v6] mm(v4.1): New pfn_mkwrite same as page_mkwrite
 for VM_PFNMAP
References: <55239645.9000507@plexistor.com> <552397E6.5030506@plexistor.com> <5523D43C.1060708@plexistor.com> <20150407131700.GA13946@node.dhcp.inet.fi> <20150407132601.GA14252@node.dhcp.inet.fi>
In-Reply-To: <20150407132601.GA14252@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>, Stable Tree <stable@vger.kernel.org>

On 04/07/2015 04:26 PM, Kirill A. Shutemov wrote:
> On Tue, Apr 07, 2015 at 04:17:00PM +0300, Kirill A. Shutemov wrote:
>> On Tue, Apr 07, 2015 at 03:57:32PM +0300, Boaz Harrosh wrote:
>>> +/*
>>> + * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
>>> + * mapping
>>> + */
>>> +static int wp_pfn_shared(struct mm_struct *mm,
>>> +			struct vm_area_struct *vma, unsigned long address,
>>> +			pte_t *page_table, spinlock_t *ptl, pte_t orig_pte,
>>> +			pmd_t *pmd)
>>> +{
>>> +	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
>>> +		struct vm_fault vmf = {
>>> +			.page = NULL,
>>> +			.pgoff = linear_page_index(vma, address),
>>> +			.virtual_address = (void __user *)(address & PAGE_MASK),
>>> +			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
>>> +		};
>>> +		int ret;
>>> +
>>> +		pte_unmap_unlock(page_table, ptl);
>>> +		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf);
>>> +		if (ret & VM_FAULT_ERROR)
>>> +			return ret;
>>> +		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
>>> +		/* Did pfn_mkwrite already fixed up the pte */
> 
> Oh. I guess you've missunderstood why we need pte_same() check below.
> It's not about ->pfn_mkwrite() changing the pte (generatlly, it should
> not). It's requited to address race with parallel page fault to the pte.
> 
>>> +		if (!pte_same(*page_table, orig_pte)) {
>>> +			pte_unmap_unlock(page_table, ptl);
>>> +			return ret;
>>
>> This should be "return 0;", shouldn't it?
>>
>> VM_FAULT_NOPAGE would imply you've installed new pte, but you did not.

Changing this to "return 0" would be very scary for me. Because I'm running
with this code for 1/2 a year now. And it is stable. You see since the original
code it was always doing just that pte_unmap_unlock && return ret. (See the patch
based on 4.0)

I did not understand if you want that I keep it "return ret".

I gather that you would like the comment changed, about the changed pte.
Both here and at Documentation/.../locking.

I'll send a new patch just tell me if you want the reurn thing

Thank you
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
