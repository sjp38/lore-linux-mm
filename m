Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f42.google.com (mail-vk0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 509416B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 20:46:45 -0400 (EDT)
Received: by vkao123 with SMTP id o123so1973043vka.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:46:45 -0700 (PDT)
Received: from mail-vk0-f49.google.com (mail-vk0-f49.google.com. [209.85.213.49])
        by mx.google.com with ESMTPS id v2si9375554vdv.41.2015.08.17.17.46.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 17:46:44 -0700 (PDT)
Received: by vkm66 with SMTP id 66so2230479vkm.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:46:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150817214554.GA5976@gmail.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150813035005.36913.77364.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150814213714.GA3265@gmail.com>
	<CAPcyv4ib244VMSdhHDWHRnmCvYdteUEzT+ehTzitSY42m2Tt=w@mail.gmail.com>
	<20150814220605.GB3265@gmail.com>
	<CAPcyv4gEPum_qq7PH0oNx3ntiWTP_1fp4EU+CAj8tm1Oeg-E9w@mail.gmail.com>
	<CAPcyv4i-5RWTLK8FQFCBuFKwY0_HShbW7PVTHudSk4sF35xosA@mail.gmail.com>
	<20150817214554.GA5976@gmail.com>
Date: Mon, 17 Aug 2015 17:46:43 -0700
Message-ID: <CAPcyv4jPezPAy9gMMtenBH1U526N3cwQY02823jfqWPyuRMouw@mail.gmail.com>
Subject: Re: [RFC PATCH 1/7] x86, mm: ZONE_DEVICE for "device memory"
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Mon, Aug 17, 2015 at 2:45 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> On Fri, Aug 14, 2015 at 07:11:27PM -0700, Dan Williams wrote:
>> Although it does not offer perfect protection if device memory is at a
>> physically lower address than RAM, skipping the update of these
>> variables does seem to be what we want.  For example /dev/mem would
>> fail to allow write access to persistent memory if it fails a
>> valid_phys_addr_range() check.  Since /dev/mem does not know how to
>> write to PMEM in a reliably persistent way, it should not treat a
>> PMEM-pfn like RAM.
>
> So i attach is a patch that should keep ZONE_DEVICE out of consideration
> for the buddy allocator. You might also want to keep page reserved and not
> free inside the zone, you could replace the generic_online_page() using
> set_online_page_callback() while hotpluging device memory.
>

Hmm, are we already protected by the fact that ZONE_DEVICE is not
represented in the GFP_ZONEMASK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
