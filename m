Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D762B6B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 00:59:31 -0500 (EST)
Date: Fri, 16 Jan 2009 06:59:27 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] Remove needless flush_dcache_page call
Message-ID: <20090116055927.GA22810@wotan.suse.de>
References: <20090116052804.GA18737@barrios-desktop> <20090116053338.GC31013@parisc-linux.org> <20090116055119.GA6515@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090116055119.GA6515@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 16, 2009 at 02:51:19PM +0900, MinChan Kim wrote:
> On Thu, Jan 15, 2009 at 10:33:38PM -0700, Matthew Wilcox wrote:
> > On Fri, Jan 16, 2009 at 02:28:04PM +0900, MinChan Kim wrote:
> > > Now, Anyone don't maintain cramfs.
> > > I don't know who is maintain romfs. so I send this patch to linux-mm, 
> > > lkml, linux-dev. 
> > > 
> > > I am not sure my thought is right. 
> > > 
> > > When readpage is called, page with argument in readpage is just new 
> > > allocated because kernel can't find that page in page cache. 
> > > 
> > > At this time, any user process can't map the page to their address space. 
> > > so, I think D-cache aliasing probelm never occur. 
> > > 
> > > It make sense ?
> > 
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

I think if the page is populated via IO, then it is responsibility of the
IO layers (eg dma API) to ensure caches are consistent. Presumably this
would include calling flush_dcache_page if we CPU is being used for
the copies (eg. see drivers/block/brd.c).

But there are quite possibly holes around here because not as much testing
is done on CPUs with these kinds of caches. Eg. brd probably should be
doing a flush_dcache_page in the rw == WRITE direction AFAIKS, so it picks
up user aliases here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
