Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 225B46B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:46:08 -0400 (EDT)
Received: by qgeg42 with SMTP id g42so104804626qge.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 14:46:07 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id 127si25927876qhd.45.2015.08.17.14.46.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 14:46:07 -0700 (PDT)
Received: by qgj62 with SMTP id 62so104320155qgj.2
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 14:46:05 -0700 (PDT)
Date: Mon, 17 Aug 2015 17:45:56 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC PATCH 1/7] x86, mm: ZONE_DEVICE for "device memory"
Message-ID: <20150817214554.GA5976@gmail.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
 <20150813035005.36913.77364.stgit@otcpl-skl-sds-2.jf.intel.com>
 <20150814213714.GA3265@gmail.com>
 <CAPcyv4ib244VMSdhHDWHRnmCvYdteUEzT+ehTzitSY42m2Tt=w@mail.gmail.com>
 <20150814220605.GB3265@gmail.com>
 <CAPcyv4gEPum_qq7PH0oNx3ntiWTP_1fp4EU+CAj8tm1Oeg-E9w@mail.gmail.com>
 <CAPcyv4i-5RWTLK8FQFCBuFKwY0_HShbW7PVTHudSk4sF35xosA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4i-5RWTLK8FQFCBuFKwY0_HShbW7PVTHudSk4sF35xosA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Fri, Aug 14, 2015 at 07:11:27PM -0700, Dan Williams wrote:
> On Fri, Aug 14, 2015 at 3:33 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> > On Fri, Aug 14, 2015 at 3:06 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >> On Fri, Aug 14, 2015 at 02:52:15PM -0700, Dan Williams wrote:
> >>> On Fri, Aug 14, 2015 at 2:37 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >>> > On Wed, Aug 12, 2015 at 11:50:05PM -0400, Dan Williams wrote:
> > [..]
> >>> > What is the rational for not updating max_pfn, max_low_pfn, ... ?
> >>> >
> >>>
> >>> The idea is that this memory is not meant to be available to the page
> >>> allocator and should not count as new memory capacity.  We're only
> >>> hotplugging it to get struct page coverage.
> >>
> >> But this sounds bogus to me to rely on max_pfn to stay smaller than
> >> first_dev_pfn.  For instance you might plug a device that register
> >> dev memory and then some regular memory might be hotplug, effectively
> >> updating max_pfn to a value bigger than first_dev_pfn.
> >>
> >
> > True.
> >
> >> Also i do not think that the buddy allocator use max_pfn or max_low_pfn
> >> to consider page/zone for allocation or not.
> >
> > Yes, I took it out with no effects.  I'll investigate further whether
> > we should be touching those variables or not for this new usage.
> 
> Although it does not offer perfect protection if device memory is at a
> physically lower address than RAM, skipping the update of these
> variables does seem to be what we want.  For example /dev/mem would
> fail to allow write access to persistent memory if it fails a
> valid_phys_addr_range() check.  Since /dev/mem does not know how to
> write to PMEM in a reliably persistent way, it should not treat a
> PMEM-pfn like RAM.

So i attach is a patch that should keep ZONE_DEVICE out of consideration
for the buddy allocator. You might also want to keep page reserved and not
free inside the zone, you could replace the generic_online_page() using
set_online_page_callback() while hotpluging device memory.

Regarding /dev/mem i would not worry about highmem, as /dev/mem is already
broken in respect to memory hole that might exist (at least that is my
understanding). Alternatively if you really care about /dev/mem you could
add an arch valid_phys_addr_range() that could check valid zone.

Cheers,
Jerome

--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="0001-mm-ZONE_DEVICE-Keep-ZONE_DEVICE-out-of-allocation-zo.patch"
Content-Transfer-Encoding: 8bit


--17pEHd4RhPHOinZp--
