Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E865682F7D
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 19:00:12 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 78so40816740pfw.2
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 16:00:12 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rx5si6433447pab.151.2015.12.22.16.00.11
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 16:00:12 -0800 (PST)
Date: Tue, 22 Dec 2015 17:00:10 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 1/7] pmem: add wb_cache_pmem() to the PMEM API
Message-ID: <20151223000010.GB24124@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450502540-8744-2-git-send-email-ross.zwisler@linux.intel.com>
 <20151222144440.1ad9e076464f4751f3de6a1f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151222144440.1ad9e076464f4751f3de6a1f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org, xfs@oss.sgi.com, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, Dec 22, 2015 at 02:44:40PM -0800, Andrew Morton wrote:
> On Fri, 18 Dec 2015 22:22:14 -0700 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:
> 
> > The function __arch_wb_cache_pmem() was already an internal implementation
> > detail of the x86 PMEM API, but this functionality needs to be exported as
> > part of the general PMEM API to handle the fsync/msync case for DAX mmaps.
> > 
> > One thing worth noting is that we really do want this to be part of the
> > PMEM API as opposed to a stand-alone function like clflush_cache_range()
> > because of ordering restrictions.  By having wb_cache_pmem() as part of the
> > PMEM API we can leave it unordered, call it multiple times to write back
> > large amounts of memory, and then order the multiple calls with a single
> > wmb_pmem().
> > 
> > @@ -138,7 +139,7 @@ static inline void arch_clear_pmem(void __pmem *addr, size_t size)
> >  	else
> >  		memset(vaddr, 0, size);
> >  
> > -	__arch_wb_cache_pmem(vaddr, size);
> > +	arch_wb_cache_pmem(addr, size);
> >  }
> >  
> 
> reject.  I made this
> 
> 	arch_wb_cache_pmem(vaddr, size);
> 
> due to Dan's
> http://www.ozlabs.org/~akpm/mmots/broken-out/pmem-dax-clean-up-clear_pmem.patch

The first argument seems wrong to me - in arch_clear_pmem() 'addr' and 'vaddr'
are the same address, with the only difference being 'addr' has the __pmem
annotation.

As of this patch arch_wb_cache_pmem() follows the lead of the rest of the
exported PMEM API functions and takes an argument that has the __pmem
annotation, so I believe it should be:

arch_wb_cache_pmem(addr, size);

Without this I think you'll get a sparse warning.

This will be fixed up in the next version of my series which build upon Dan's
patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
