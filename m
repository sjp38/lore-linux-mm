Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E438E6B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 00:33:58 -0500 (EST)
Date: Thu, 15 Jan 2009 22:33:38 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] Remove needless flush_dcache_page call
Message-ID: <20090116053338.GC31013@parisc-linux.org>
References: <20090116052804.GA18737@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090116052804.GA18737@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 16, 2009 at 02:28:04PM +0900, MinChan Kim wrote:
> Now, Anyone don't maintain cramfs.
> I don't know who is maintain romfs. so I send this patch to linux-mm, 
> lkml, linux-dev. 
> 
> I am not sure my thought is right. 
> 
> When readpage is called, page with argument in readpage is just new 
> allocated because kernel can't find that page in page cache. 
> 
> At this time, any user process can't map the page to their address space. 
> so, I think D-cache aliasing probelm never occur. 
> 
> It make sense ?

Sorry, no.  You have to call fluch_dcache_page() in two situations --
when the kernel is going to read some data that userspace wrote, *and*
when userspace is going to read some data that the kernel wrote.  From a
quick look at the patch, this seems to be the second case.  The kernel
wrote data to a pagecache page, and userspace should be able to read it.

To understand why this is necessary, consider a processor which is
virtually indexed and has a writeback cache.  The kernel writes to a
page, then a user process reads from the same page through a different
address.  The cache doesn't find the data the kernel wrote because it
has a different virtual index, so userspace reads stale data.

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
