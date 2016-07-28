Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2166B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 20:17:07 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d65so33381464ith.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 17:17:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h194si9516106ioh.38.2016.07.27.17.17.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 17:17:06 -0700 (PDT)
Date: Thu, 28 Jul 2016 03:17:00 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 repost 6/7] mm: add the related functions to get free
 page info
Message-ID: <20160728031629-mutt-send-email-mst@kernel.org>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-7-git-send-email-liang.z.li@intel.com>
 <5798E418.7080608@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E04213C27@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E04213C27@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On Thu, Jul 28, 2016 at 12:10:16AM +0000, Li, Liang Z wrote:
> > Subject: Re: [PATCH v2 repost 6/7] mm: add the related functions to get free
> > page info
> > 
> > On 07/26/2016 06:23 PM, Liang Li wrote:
> > > +	for_each_migratetype_order(order, t) {
> > > +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> > > +			pfn = page_to_pfn(list_entry(curr, struct page, lru));
> > > +			if (pfn >= start_pfn && pfn <= end_pfn) {
> > > +				page_num = 1UL << order;
> > > +				if (pfn + page_num > end_pfn)
> > > +					page_num = end_pfn - pfn;
> > > +				bitmap_set(bitmap, pfn - start_pfn,
> > page_num);
> > > +			}
> > > +		}
> > > +	}
> > 
> > Nit:  The 'page_num' nomenclature really confused me here.  It is the
> > number of bits being set in the bitmap.  Seems like calling it nr_pages or
> > num_pages would be more appropriate.
> > 
> 
> You are right,  will change.
> 
> > Isn't this bitmap out of date by the time it's send up to the hypervisor?  Is
> > there something that makes the inaccuracy OK here?
> 
> Yes. The dirty page logging will be used to correct the inaccuracy.
> The dirty page logging should be started before getting the free page bitmap, then if some of the free pages become no free for writing, these pages will be tracked by the dirty page logging mechanism.
> 
> Thanks!
> Liang

Right but this should be clear from code and naming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
