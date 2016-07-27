Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFF7D6B0261
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 19:05:12 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id i199so23703659ioi.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 16:05:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c62si9298952ioa.60.2016.07.27.16.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 16:05:12 -0700 (PDT)
Date: Thu, 28 Jul 2016 02:05:04 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 repost 6/7] mm: add the related functions to get free
 page info
Message-ID: <20160728015205-mutt-send-email-mst@kernel.org>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
 <5798E418.7080608@intel.com>
 <20160728010030-mutt-send-email-mst@kernel.org>
 <579932D9.6000106@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <579932D9.6000106@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Liang Li <liang.z.li@intel.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On Wed, Jul 27, 2016 at 03:16:57PM -0700, Dave Hansen wrote:
> On 07/27/2016 03:05 PM, Michael S. Tsirkin wrote:
> > On Wed, Jul 27, 2016 at 09:40:56AM -0700, Dave Hansen wrote:
> >> On 07/26/2016 06:23 PM, Liang Li wrote:
> >>> +	for_each_migratetype_order(order, t) {
> >>> +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> >>> +			pfn = page_to_pfn(list_entry(curr, struct page, lru));
> >>> +			if (pfn >= start_pfn && pfn <= end_pfn) {
> >>> +				page_num = 1UL << order;
> >>> +				if (pfn + page_num > end_pfn)
> >>> +					page_num = end_pfn - pfn;
> >>> +				bitmap_set(bitmap, pfn - start_pfn, page_num);
> >>> +			}
> >>> +		}
> >>> +	}
> >>
> >> Nit:  The 'page_num' nomenclature really confused me here.  It is the
> >> number of bits being set in the bitmap.  Seems like calling it nr_pages
> >> or num_pages would be more appropriate.
> >>
> >> Isn't this bitmap out of date by the time it's send up to the
> >> hypervisor?  Is there something that makes the inaccuracy OK here?
> > 
> > Yes. Calling these free pages is unfortunate. It's likely to confuse
> > people thinking they can just discard these pages.
> > 
> > Hypervisor sends a request. We respond with this list of pages, and
> > the guarantee hypervisor needs is that these were free sometime between request
> > and response, so they are safe to free if they are unmodified
> > since the request. hypervisor can detect modifications so
> > it can detect modifications itself and does not need guest help.
> 
> Ahh, that makes sense.
> 
> So the hypervisor is trying to figure out: "Which pages do I move?".  It
> wants to know which pages the guest thinks have good data and need to
> move.  But, the list of free pages is (likely) smaller than the list of
> pages with good data, so it asks for that instead.
> 
> A write to a page means that it has valuable data, regardless of whether
> it was in the free list or not.
> 
> The hypervisor only skips moving pages that were free *and* were never
> written to.

Right - except never is a long time, so we just need it "since the request
was received".

> So we never lose data, even if this "get free page info"
> stuff is totally out of date.

So if you include pages that were written to before the request
then yes data will be lost. This is why we do this scan
after we get the request and not e.g. on boot :)

> The patch description and code comments are, um, a _bit_ light for this
> level of subtlety. :)

Add to that, for any page it is safe to skip and not add it to list.
So the requirement is for when page must *not* be on this list:
it must not be there if it is needed by guest but was not
modified since the request.

Calling it "free" will just keep confusing people.  Either use the
verbose "free or modified" or invent a new word like "discardable" and
add a comment explaining that page is always discardable unless it's
content is needed by Linux but was not modified since the request.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
