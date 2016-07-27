Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDFE6B0260
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 18:16:59 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so16516516pad.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 15:16:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id k70si8500235pfk.85.2016.07.27.15.16.58
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 15:16:58 -0700 (PDT)
Subject: Re: [PATCH v2 repost 6/7] mm: add the related functions to get free
 page info
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
 <5798E418.7080608@intel.com> <20160728010030-mutt-send-email-mst@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <579932D9.6000106@intel.com>
Date: Wed, 27 Jul 2016 15:16:57 -0700
MIME-Version: 1.0
In-Reply-To: <20160728010030-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Liang Li <liang.z.li@intel.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On 07/27/2016 03:05 PM, Michael S. Tsirkin wrote:
> On Wed, Jul 27, 2016 at 09:40:56AM -0700, Dave Hansen wrote:
>> On 07/26/2016 06:23 PM, Liang Li wrote:
>>> +	for_each_migratetype_order(order, t) {
>>> +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
>>> +			pfn = page_to_pfn(list_entry(curr, struct page, lru));
>>> +			if (pfn >= start_pfn && pfn <= end_pfn) {
>>> +				page_num = 1UL << order;
>>> +				if (pfn + page_num > end_pfn)
>>> +					page_num = end_pfn - pfn;
>>> +				bitmap_set(bitmap, pfn - start_pfn, page_num);
>>> +			}
>>> +		}
>>> +	}
>>
>> Nit:  The 'page_num' nomenclature really confused me here.  It is the
>> number of bits being set in the bitmap.  Seems like calling it nr_pages
>> or num_pages would be more appropriate.
>>
>> Isn't this bitmap out of date by the time it's send up to the
>> hypervisor?  Is there something that makes the inaccuracy OK here?
> 
> Yes. Calling these free pages is unfortunate. It's likely to confuse
> people thinking they can just discard these pages.
> 
> Hypervisor sends a request. We respond with this list of pages, and
> the guarantee hypervisor needs is that these were free sometime between request
> and response, so they are safe to free if they are unmodified
> since the request. hypervisor can detect modifications so
> it can detect modifications itself and does not need guest help.

Ahh, that makes sense.

So the hypervisor is trying to figure out: "Which pages do I move?".  It
wants to know which pages the guest thinks have good data and need to
move.  But, the list of free pages is (likely) smaller than the list of
pages with good data, so it asks for that instead.

A write to a page means that it has valuable data, regardless of whether
it was in the free list or not.

The hypervisor only skips moving pages that were free *and* were never
written to.  So we never lose data, even if this "get free page info"
stuff is totally out of date.

The patch description and code comments are, um, a _bit_ light for this
level of subtlety. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
