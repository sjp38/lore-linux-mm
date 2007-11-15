In-reply-to: <1195154530.22457.16.camel@lappy> (message from Peter Zijlstra on
	Thu, 15 Nov 2007 20:22:10 +0100)
Subject: Re: [RFC] fuse writable mmap design
References: <E1IshIR-0000fE-00@dorka.pomaz.szeredi.hu> <1195154530.22457.16.camel@lappy>
Message-Id: <E1IskWl-0000oJ-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 15 Nov 2007 20:37:27 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I'm somewhat confused by the complexity. Currently we can already have a
> lot of dirty pages from FUSE (up to the per BDI dirty limit - so
> basically up to the total dirty limit).
> 
> How is having them dirty from mmap'ed writes different?

Nope, fuse never had dirty pages.  It does normal writes
synchronously, just updating the cache.

The dirty accounting and then the per-bdi throttling basically made it
possible _at_all_ to have a chance at a writepage implementation which
is not deadlocky (so thanks for those ;).

But there's still the throttle_vm_writeout() thing, and the other
places where the kernel is waiting for a write to complete, which just
cannot be done within a constrained time if an unprivileged userspace
process is involved.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
