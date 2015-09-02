Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 23B786B0038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 13:47:55 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so18362575pac.3
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 10:47:54 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id l11si15219124pbq.216.2015.09.02.10.47.53
        for <linux-mm@kvack.org>;
        Wed, 02 Sep 2015 10:47:54 -0700 (PDT)
Date: Wed, 2 Sep 2015 11:47:52 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150902174752.GA26189@linux.intel.com>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <55E5A44A.1050206@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55E5A44A.1050206@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, x86@kernel.org, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 01, 2015 at 04:12:42PM +0300, Boaz Harrosh wrote:
> On 08/31/2015 09:59 PM, Ross Zwisler wrote:
> > @@ -753,3 +755,18 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
> >  	return dax_zero_page_range(inode, from, length, get_block);
> >  }
> >  EXPORT_SYMBOL_GPL(dax_truncate_page);
> > +
> > +void dax_sync_range(unsigned long addr, size_t len)
> > +{
> > +	while (len) {
> > +		size_t chunk_len = min_t(size_t, SZ_1G, len);
> > +
> 
> Where does the  SZ_1G come from is it because you want to do cond_resched()
> every 1G bytes so not to get stuck for a long time?
> 
> It took me a while to catch, At first I thought it might be do to wb_cache_pmem()
> limitations. Would you put a comment in the next iteration?

Yep, the SZ_1G is just to make sure we cond_reshced() every once in a while.
Is there a documented guideline somewhere as to how long a kernel thread is
allowed to spin before calling cond_resched()?   So far I haven' been able to
find anything solid on this - it seems like each developer has their own
preferences, and that those preferences vary pretty widely.

In any case, assuming we continue to separate the msync() and fsync()
implementations for DAX (which right now I'm doubting, to be honest), I'll add
in a comment to explain this logic.

> > diff --git a/include/linux/pmem.h b/include/linux/pmem.h
> > index 85f810b3..aa29ebb 100644
> > --- a/include/linux/pmem.h
> > +++ b/include/linux/pmem.h
> > @@ -53,12 +53,18 @@ static inline void arch_clear_pmem(void __pmem *addr, size_t size)
> >  {
> >  	BUG();
> 
> See below
> 
> >  }
> > +
> > +static inline void arch_wb_cache_pmem(void __pmem *addr, size_t size)
> > +{
> > +	BUG();
> 
> There is a clflush_cache_range() defined for generic use. On ADR systems (even without pcommit)
> this works perfectly and is persistent. why not use that in the generic case?

Nope, we really do need to use wb_cache_pmem() because clflush_cache_range()
isn't an architecture neutral API.  wb_cache_pmem() also has the advantage
that on x86 it will take advantage of the new CLWB instruction if it is
available on the platform, and it doesn't introduce any unnecessary memory
fencing.  This works on both PCOMMIT-aware systems and on ADR boxes without
PCOMMIT.
 
> One usage of pmem is overlooked by all this API. The use of DRAM as pmem, across a VM
> or cross reboot. you have a piece of memory exposed as pmem to the subsytem which survives
> past the boot of that system. The CPU cache still needs flushing in this case.
> (People are already using this for logs and crash dumps)

I'm confused about this "DRAM as pmem" use case - are the requirements
essentially the same as the ADR case?  You need to make sure that pre-reboot
the dirty cache lines have been flushed from the processor cache, but if they
are in platform buffers (the "safe zone" for ADR) you're fine?

If so, we're good to go, I think.  Dan's most recent patch series made it so
we correctly handle systems that have the PMEM API but not PCOMMIT:

https://lists.01.org/pipermail/linux-nvdimm/2015-August/002005.html

If the "DRAM as pmem across reboots" case isn't okay with your dirty data
being in the ADR safe zone, I think you're toast.  Without PCOMMIT the kernel
cannot guarantee that the data has ever made it durably to the DIMMs,
regardless what clflush/clflushopt/clwb magic you do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
