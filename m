Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2BD6B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 00:57:49 -0500 (EST)
Date: Thu, 15 Jan 2009 22:57:30 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] Remove needless flush_dcache_page call
Message-ID: <20090116055729.GF31013@parisc-linux.org>
References: <20090116052804.GA18737@barrios-desktop> <20090116053338.GC31013@parisc-linux.org> <20090116055119.GA6515@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090116055119.GA6515@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 16, 2009 at 02:51:19PM +0900, MinChan Kim wrote:
> On Thu, Jan 15, 2009 at 10:33:38PM -0700, Matthew Wilcox wrote:
> > Sorry, no.  You have to call fluch_dcache_page() in two situations --
> > when the kernel is going to read some data that userspace wrote, *and*
> > when userspace is going to read some data that the kernel wrote.  From a
> > quick look at the patch, this seems to be the second case.  The kernel
> > wrote data to a pagecache page, and userspace should be able to read it.
> > 
> > To understand why this is necessary, consider a processor which is
> > virtually indexed and has a writeback cache.  The kernel writes to a
> > page, then a user process reads from the same page through a different
> > address.  The cache doesn't find the data the kernel wrote because it
> > has a different virtual index, so userspace reads stale data.
> 
> I see. :)
> 
> Thanks for quick reponse and good explaination.
> Hmm,.. one more question. 
> 
> I can't find flush_dcache_page call in mpage_readpage which is 
> generic read function. In case of ext fs, it use mpage_readpage 
> with readpage.
> 
> who and where call flush_dcache_page in mpage_readpage call path?

Most I/O devices will do DMA to the page in question and thus the kernel
hasn't written to it and the CPU won't have the data in cache.  For the
few devices which can't do DMA, it's the responsibility of the device
driver to call flush_dcache_page() (or some other flushing primitive).
See the gdth driver for an example:

            address = kmap_atomic(sg_page(sl), KM_BIO_SRC_IRQ) + sl->offset;
            memcpy(address, buffer, cpnow);
            flush_dcache_page(sg_page(sl));
            kunmap_atomic(address, KM_BIO_SRC_IRQ);

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
