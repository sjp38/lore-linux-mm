Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E790B6B006E
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:20:48 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so316326pac.14
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:20:48 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id x3si486419pdm.53.2014.10.17.00.20.47
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:20:48 -0700 (PDT)
Date: Thu, 16 Oct 2014 17:22:34 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 08/21] dax,ext2: Replace ext2_clear_xip_target with
 dax_clear_blocks
Message-ID: <20141016212234.GF11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-9-git-send-email-matthew.r.wilcox@intel.com>
 <20141016100525.GF19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016100525.GF19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 16, 2014 at 12:05:25PM +0200, Mathieu Desnoyers wrote:
> > +int dax_clear_blocks(struct inode *inode, sector_t block, long size)
> > +{
> > +	struct block_device *bdev = inode->i_sb->s_bdev;
> > +	sector_t sector = block << (inode->i_blkbits - 9);
> 
> Is there a define e.g. SECTOR_SHIFT rather than using this hardcoded "9"
> value ?

Yeah ... in half a dozen drivers, so introducing them globally spews
warnings about redefining macros.  The '9' and '512' are sprinkled all
over the storage parts of the kernel, it's a complete flustercluck that
I wasn't about to try to unscrew.

> > +		while (count > 0) {
> > +			unsigned pgsz = PAGE_SIZE - offset_in_page(addr);
> 
> unsigned -> unsigned int

Any particular reason?  Omitting it in some places helps stay within
the 80-column limit without sacrificing readability.

> > +		}
> > +	} while (size);
> 
> Just to stay on the safe side, can we do while (size > 0) ? Just in case
> an unforeseen issue makes size negative, and gets us in a very long loop.

If size < 0, we should BUG, because that means we've zeroed more than
we were asked to do, which is data corruption.

There's probably some other hardening we should do for this loop.
For example, if 'count' is < 512, it can go into an infinite loop.

        do {
                void *addr;
                unsigned long pfn;
                long count;

                count = bdev_direct_access(bdev, sector, &addr, &pfn, size);
                if (count < 0)
                        return count;
                while (count > 0) {
                        unsigned pgsz = PAGE_SIZE - offset_in_page(addr);
                        if (pgsz > count)
                                pgsz = count;
                        if (pgsz < PAGE_SIZE)
                                memset(addr, 0, pgsz);
                        else
                                clear_page(addr);
                        addr += pgsz;
                        size -= pgsz;
                        count -= pgsz;
			BUG_ON(pgsz & 511);
                        sector += pgsz / 512;
                        cond_resched();
                }
		BUG_ON(size < 0);
        } while (size);

I think that should do the job ... ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
