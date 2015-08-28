Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA5D6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 16:22:19 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so73010388pab.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:22:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ow9si11693803pdb.117.2015.08.28.13.22.17
        for <linux-mm@kvack.org>;
        Fri, 28 Aug 2015 13:22:18 -0700 (PDT)
Date: Fri, 28 Aug 2015 14:22:11 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 5/9] x86, pmem: push fallback handling to arch code
Message-ID: <20150828202211.GA21699@linux.intel.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20150826012751.8851.78564.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20150826124124.GA7613@lst.de>
 <1440624859.31365.17.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440624859.31365.17.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "hch@lst.de" <hch@lst.de>, "toshi.kani@hp.com" <toshi.kani@hp.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "hpa@zytor.com" <hpa@zytor.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "mingo@redhat.com" <mingo@redhat.com>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "boaz@plexistor.com" <boaz@plexistor.com>, "david@fromorbit.com" <david@fromorbit.com>

On Wed, Aug 26, 2015 at 09:34:20PM +0000, Williams, Dan J wrote:
> On Wed, 2015-08-26 at 14:41 +0200, Christoph Hellwig wrote:
> > I like the intent behind this, but not the implementation.
> > 
> > I think the right approach is to keep the defaults in linux/pmem.h
> > and simply not set CONFIG_ARCH_HAS_PMEM_API for x86-32.
> 
> Yes, that makes things much cleaner.  Revised patch and changelog below:
> 
> 8<----
> Subject: x86, pmem: clarify that ARCH_HAS_PMEM_API implies PMEM mapped WB
> 
> From: Dan Williams <dan.j.williams@intel.com>
> 
> Given that a write-back (WB) mapping plus non-temporal stores is
> expected to be the most efficient way to access PMEM, update the
> definition of ARCH_HAS_PMEM_API to imply arch support for
> WB-mapped-PMEM.  This is needed as a pre-requisite for adding PMEM to
> the direct map and mapping it with struct page.
> 
> The above clarification for X86_64 means that memcpy_to_pmem() is
> permitted to use the non-temporal arch_memcpy_to_pmem() rather than
> needlessly fall back to default_memcpy_to_pmem() when the pcommit
> instruction is not available.  When arch_memcpy_to_pmem() is not
> guaranteed to flush writes out of cache, i.e. on older X86_32
> implementations where non-temporal stores may just dirty cache,
> ARCH_HAS_PMEM_API is simply disabled.
> 
> The default fall back for persistent memory handling remains.  Namely,
> map it with the WT (write-through) cache-type and hope for the best.
> 
> arch_has_pmem_api() is updated to only indicate whether the arch
> provides the proper helpers to meet the minimum "writes are visible
> outside the cache hierarchy after memcpy_to_pmem() + wmb_pmem()".  Code
> that cares whether wmb_pmem() actually flushes writes to pmem must now
> call arch_has_wmb_pmem() directly.
> 
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Toshi Kani <toshi.kani@hp.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Christoph Hellwig <hch@lst.de>
> [hch: set ARCH_HAS_PMEM_API=n on X86_32]
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Yep, this seems like a good change.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
