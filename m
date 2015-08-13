Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB67C6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 14:15:43 -0400 (EDT)
Received: by labd1 with SMTP id d1so30959288lab.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:15:43 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id w9si5408267wja.73.2015.08.13.11.15.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 11:15:41 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so269032351wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:15:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150813173552.GA9645@linux.intel.com>
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150813173552.GA9645@linux.intel.com>
Date: Thu, 13 Aug 2015 11:15:40 -0700
Message-ID: <CAPcyv4i8kz0UNiT05JSEp12QCMu6bKKGuMnVofSnWSg0cZF88A@mail.gmail.com>
Subject: Re: [PATCH v5 2/5] allow mapping page-less memremaped areas into KVA
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Thu, Aug 13, 2015 at 10:35 AM, Matthew Wilcox <willy@linux.intel.com> wrote:
> On Wed, Aug 12, 2015 at 11:01:09PM -0400, Dan Williams wrote:
>> +static inline __pfn_t page_to_pfn_t(struct page *page)
>> +{
>> +     __pfn_t pfn = { .val = page_to_pfn(page) << PAGE_SHIFT, };
>> +
>> +     return pfn;
>> +}
>
> static inline __pfn_t page_to_pfn_t(struct page *page)
> {
>         __pfn_t __pfn;
>         unsigned long pfn = page_to_pfn(page);
>         BUG_ON(pfn > (-1UL >> PFN_SHIFT))
>         __pfn.val = pfn << PFN_SHIFT;
>
>         return __pfn;
> }
>
> I have a problem wih PFN_SHIFT being equal to PAGE_SHIFT.  Consider a
> 32-bit kernel; you're asserting that no memory represented by a struct
> page can have a physical address above 4GB.
>
> You only need three bits for flags so far ... how about making PFN_SHIFT
> be 6?  That supports physical addresses up to 2^38 (256GB).  That should
> be enough, but hardware designers have done some strange things in the
> past (I know that HP made PA-RISC hardware that can run 32-bit kernels
> with memory between 64GB and 68GB, and they can't be the only strange
> hardware people out there).

Sounds good, especially given we only use 4-bits today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
