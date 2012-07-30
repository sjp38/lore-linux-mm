Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 9F5106B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:23:55 -0400 (EDT)
Date: Mon, 30 Jul 2012 14:23:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Any reason to use put_page in slub.c?
In-Reply-To: <50163D94.5050607@parallels.com>
Message-ID: <alpine.DEB.2.00.1207301421150.27584@router.home>
References: <1343391586-18837-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1207271054230.18371@router.home> <50163D94.5050607@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 30 Jul 2012, Glauber Costa wrote:

> On 07/27/2012 07:55 PM, Christoph Lameter wrote:
> > On Fri, 27 Jul 2012, Glauber Costa wrote:
> >
> >> But I am still wondering if there is anything I am overlooking.
> >
> > put_page() is necessary because other subsystems may still be holding a
> > refcount on the page (if f.e. there is DMA still pending to that page).
> >
>
> Humm, this seems to be extremely unsafe in my read.

I do not like it either. Hopefully these usecases have been removed in the
meantime but that used to be an issue.

> If you do kmalloc, the API - AFAIK - does not provide us with any
> guarantee that the object (it's not even a page, in the strict sense!)
> allocated is reference counted internally. So relying on kfree to do it
> doesn't bode well. For one thing, slab doesn't go to the page allocator
> for high order allocations, and this code would crash miserably if
> running with the slab.
>
> Or am I missing something ?

Yes the refcounting is done at the page level by the page allocator. It is
safe. The slab allocator can free a page removing all references from its
internal structure while the subsystem page reference will hold off the
page allocator from actually freeing the page until the subsystem itself
drops the page count.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
