Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D0F1A6B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 01:44:21 -0400 (EDT)
From: Neil Brown <neilb@suse.de>
Date: Fri, 2 Oct 2009 15:52:16 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <19141.38160.888705.175222@notabene.brown>
Subject: Re: [PATCH 00/31] Swap over NFS -v20
In-Reply-To: message from Christoph Hellwig on Thursday October 1
References: <1254405858-15651-1-git-send-email-sjayaraman@suse.de>
	<20091001174201.GA30068@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thursday October 1, hch@infradead.org wrote:
> 
> The other really big one is adding a proper method for safe, page-backed
> kernelspace I/O on files.  That is not something like the grotty
> swap-tied address_space operations in this patch, but more something in
> the direction of the kernel direct I/O patches from Jenx Axboe he did
> for using in the loop driver.  But even those aren't complete as they
> don't touch the locking issue yet.

Do you have a problem with the proposed address_space operations apart
from their names including the word "swap"?  Would something like:
  direct_on, direct_off, direct_read, direct_write
be better.
Semantics being that the read and write:
  - bypass the page cache (invalidation is up to caller)
  - must not make a blocking non-emergency memory allocation
direct_on does any pre-allocation and pre-reading to ensure those
semantics and be provided.

I have wondered if an extra flag along the lines of "I don't care
about this data after a crash" would be useful.
It would be set for swap, but not set for other users.  Thus
e.g. RAID1 could easily avoid resyncing an area that was used only for
swap.

The only thing of Jens' that I could find used bmap - is there
something more recent I should look for?

> 
> Especially the latter is an absolutely essential step to make any
> progress here, and an excellent patch series of it's own as there are
> multiple users for this, like making swap safe on btrfs files, making
> the MD bitmap code actually safe or improving the loop driver.

100% agree.

Thanks,
NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
