Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2555D6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 12:23:40 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so53591811pfy.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 09:23:40 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f15si27013531pap.212.2016.11.07.09.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 09:23:39 -0800 (PST)
Subject: Re: [PATCH kernel v4 7/7] virtio-balloon: tell host vm's unused page
 info
References: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
 <1478067447-24654-8-git-send-email-liang.z.li@intel.com>
 <b25eac6e-3744-3874-93a8-02f814549adf@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A106DAA@shsmsx102.ccr.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <281acd8d-fd94-6318-35e5-9eb130303dc6@intel.com>
Date: Mon, 7 Nov 2016 09:23:38 -0800
MIME-Version: 1.0
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A106DAA@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "pbonzini@redhat.com" <pbonzini@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>

On 11/06/2016 07:37 PM, Li, Liang Z wrote:
>> Let's say we do a 32k bitmap that can hold ~1M pages.  That's 4GB of RAM.
>> On a 1TB system, that's 256 passes through the top-level loop.
>> The bottom-level lists have tens of thousands of pages in them, even on my
>> laptop.  Only 1/256 of these pages will get consumed in a given pass.
>>
> Your description is not exactly.
> A 32k bitmap is used only when there is few free memory left in the system and when 
> the extend_page_bitmap() failed to allocate more memory for the bitmap. Or dozens of 
> 32k split bitmap will be used, this version limit the bitmap count to 32, it means we can use
> at most 32*32 kB for the bitmap, which can cover 128GB for RAM. We can increase the bitmap
> count limit to a larger value if 32 is not big enough.

OK, so it tries to allocate a large bitmap.  But, if it fails, it will
try to work with a smaller bitmap.  Correct?

So, what's the _worst_ case?  It sounds like it is even worse than I was
positing.

>> That's an awfully inefficient way of doing it.  This patch essentially changed
>> the data structure without changing the algorithm to populate it.
>>
>> Please change the *algorithm* to use the new data structure efficiently.
>>  Such a change would only do a single pass through each freelist, and would
>> choose whether to use the extent-based (pfn -> range) or bitmap-based
>> approach based on the contents of the free lists.
> 
> Save the free page info to a raw bitmap first and then process the raw bitmap to
> get the proper ' extent-based ' and  'bitmap-based' is the most efficient way I can 
> come up with to save the virtio data transmission.  Do you have some better idea?

That's kinda my point.  This patch *does* processing to try to pack the
bitmaps full of pages from the various pfn ranges.  It's a form of
processing that gets *REALLY*, *REALLY* bad in some (admittedly obscure)
cases.

Let's not pretend that making an essentially unlimited number of passes
over the free lists is not processing.

1. Allocate as large of a bitmap as you can. (what you already do)
2. Iterate from the largest freelist order.  Store those pages in the
   bitmap.
3. If you can no longer fit pages in the bitmap, return the list that
   you have.
4. Make an approximation about where the bitmap does not make any more,
   and fall back to listing individual PFNs.  This would make sens, for
   instance in a large zone with very few free order-0 pages left.
			

> It seems the benefit we get for this feature is not as big as that in fast balloon inflating/deflating.
>>
>> You should not be using get_max_pfn().  Any patch set that continues to use
>> it is not likely to be using a proper algorithm.
> 
> Do you have any suggestion about how to avoid it?

Yes: get the pfns from the page free lists alone.  Don't derive them
from the pfn limits of the system or zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
