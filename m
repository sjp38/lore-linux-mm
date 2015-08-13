Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D297D6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 13:35:55 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so41536194pac.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 10:35:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id kg9si1540934pab.42.2015.08.13.10.35.54
        for <linux-mm@kvack.org>;
        Thu, 13 Aug 2015 10:35:55 -0700 (PDT)
Date: Thu, 13 Aug 2015 13:35:52 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v5 2/5] allow mapping page-less memremaped areas into KVA
Message-ID: <20150813173552.GA9645@linux.intel.com>
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
 <20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org, hch@lst.de

On Wed, Aug 12, 2015 at 11:01:09PM -0400, Dan Williams wrote:
> +static inline __pfn_t page_to_pfn_t(struct page *page)
> +{
> +	__pfn_t pfn = { .val = page_to_pfn(page) << PAGE_SHIFT, };
> +
> +	return pfn;
> +}

static inline __pfn_t page_to_pfn_t(struct page *page)
{
	__pfn_t __pfn;
	unsigned long pfn = page_to_pfn(page);
	BUG_ON(pfn > (-1UL >> PFN_SHIFT))
	__pfn.val = pfn << PFN_SHIFT;

	return __pfn;
}

I have a problem wih PFN_SHIFT being equal to PAGE_SHIFT.  Consider a
32-bit kernel; you're asserting that no memory represented by a struct
page can have a physical address above 4GB.

You only need three bits for flags so far ... how about making PFN_SHIFT
be 6?  That supports physical addresses up to 2^38 (256GB).  That should
be enough, but hardware designers have done some strange things in the
past (I know that HP made PA-RISC hardware that can run 32-bit kernels
with memory between 64GB and 68GB, and they can't be the only strange
hardware people out there).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
