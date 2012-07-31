Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id D68596B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:09:57 -0400 (EDT)
Date: Tue, 31 Jul 2012 09:09:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Any reason to use put_page in slub.c?
In-Reply-To: <5017968C.6050301@parallels.com>
Message-ID: <alpine.DEB.2.00.1207310906350.32295@router.home>
References: <1343391586-18837-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1207271054230.18371@router.home> <50163D94.5050607@parallels.com> <alpine.DEB.2.00.1207301421150.27584@router.home> <5017968C.6050301@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 31 Jul 2012, Glauber Costa wrote:

> >> Or am I missing something ?
> >
> > Yes the refcounting is done at the page level by the page allocator. It is
> > safe. The slab allocator can free a page removing all references from its
> > internal structure while the subsystem page reference will hold off the
> > page allocator from actually freeing the page until the subsystem itself
> > drops the page count.
> >
>
> pages, yes. But when you do kfree, you don't free a page. You free an
> object. The allocator is totally free to keep the page around and pass
> it on to someone else.

That is understood. Typically these object where page sized though and
various assumptions (pretty dangerous ones as you are finding out) are
made regarding object reuse. The fallback of SLUB for higher order allocs
to the page allocator avoids these problems for higher order pages.

It would be better and cleaner if all callers would not use slab
allocators but the page allocators directly for any page that requires an
increased refcount for DMA operations.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
