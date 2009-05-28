Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D2EF16B005D
	for <linux-mm@kvack.org>; Thu, 28 May 2009 06:43:46 -0400 (EDT)
Date: Thu, 28 May 2009 12:51:03 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090528105103.GG1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528101111.GE1065@one.firstfloor.org> <20090528103300.GA15133@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528103300.GA15133@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 06:33:00PM +0800, Wu Fengguang wrote:
> > > > You haven't waited on writeback here AFAIKS, and have you
> > > > *really* verified it is safe to call delete_from_swap_cache?
> > > 
> > > Good catch. I'll soon submit patches for handling the under
> > > read/write IO pages. In this patchset they are simply ignored.
> > 
> > Yes, we assume the IO device does something sensible with the poisoned
> > cache lines and aborts. Later we can likely abort IO requests in a early
> > stage on the Linux, but that's more advanced.
> > 
> > The question is if we need to wait on writeback for correctness? 
> 
> Not necessary. Because I'm going to add a me_writeback() handler.

Ok but without it. Let's assume me_writeback() is in the future.

I'm mainly interested in correctness (as in not crashing) of this
version now.

Also writeback seems to be only used by nfs/afs/nilfs2, not in
the normal case, unless I'm misreading the code. 

The nilfs2 case seems weird, I haven't completely read that.

> Then the writeback pages simply won't reach here. And it won't
> magically go into writeback state, since the page has been locked.

But since we take the page lock they should not be in writeback anyways,
no?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
