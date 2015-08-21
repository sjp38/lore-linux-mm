Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id C0EF96B0038
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 11:15:17 -0400 (EDT)
Received: by ykfw73 with SMTP id w73so73291583ykf.3
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 08:15:17 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id j93si13233120qge.113.2015.08.21.08.15.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 08:15:16 -0700 (PDT)
Received: by qkfh127 with SMTP id h127so33263447qkf.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 08:15:15 -0700 (PDT)
Date: Fri, 21 Aug 2015 11:15:12 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC PATCH 1/7] x86, mm: ZONE_DEVICE for "device memory"
Message-ID: <20150821151511.GB3244@gmail.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
 <20150813035005.36913.77364.stgit@otcpl-skl-sds-2.jf.intel.com>
 <20150814213714.GA3265@gmail.com>
 <CAPcyv4ib244VMSdhHDWHRnmCvYdteUEzT+ehTzitSY42m2Tt=w@mail.gmail.com>
 <20150815085954.GC21033@lst.de>
 <CAPcyv4jiXqcy_kUrArw7cpbySDoaQe+UF5JcvihxyGyxjsWKZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4jiXqcy_kUrArw7cpbySDoaQe+UF5JcvihxyGyxjsWKZw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, David Woodhouse <dwmw2@infradead.org>

On Fri, Aug 21, 2015 at 08:02:51AM -0700, Dan Williams wrote:
> [ Adding David Woodhouse ]
> 
> On Sat, Aug 15, 2015 at 1:59 AM, Christoph Hellwig <hch@lst.de> wrote:
> > On Fri, Aug 14, 2015 at 02:52:15PM -0700, Dan Williams wrote:
> >> The idea is that this memory is not meant to be available to the page
> >> allocator and should not count as new memory capacity.  We're only
> >> hotplugging it to get struct page coverage.
> >
> > This might need a bigger audit of the max_pfn usages.  I remember
> > architectures using it as a decisions for using IOMMUs or similar.
> 
> We chatted about this at LPC yesterday.  The takeaway was that the
> max_pfn checks that the IOMMU code does is for checking whether a
> device needs an io-virtual mapping to reach addresses above its DMA
> limit (if it can't do 64-bit DMA).  Given the capacities of persistent
> memory it's likely that a device with this limitation already can't
> address all of RAM let alone PMEM.   So it seems to me that updating
> max_pfn for PMEM hotplug does not buy us anything except a few more
> opportunities to confuse PMEM as typical RAM.

I think it is wrong do not update max_pfn for 3 reasons :
  - In some case your PMEM memory will end up below current max_pfn
    value so device doing DMA can confuse your PMEM for regular RAM.
  - Given the above, not updating PMEM means you are not consistant,
    ie on some computer PMEM will be DMA addressable by device and
    on other computer it would not. Because different RAM and PMEM
    configuration, different bios, ... that cause max_pfn to be below
    range where PMEM get hotpluged.
  - Last why would we want to block device to access PMEM directly ?
    Wouldn't it make sense for some device like say network to read
    PMEM directly and stream it over the network ? All this happening
    through IOMMU (i am assuming PCIE network card using IOMMU). Which
    imply having the IOMMU consider this like regular mapping (ignoring
    Will Davis recent patchset here that might affect the IOMMU max_pfn
    test).

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
