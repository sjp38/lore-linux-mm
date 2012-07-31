Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 1D0A56B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:17:26 -0400 (EDT)
Date: Tue, 31 Jul 2012 09:17:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Any reason to use put_page in slub.c?
In-Reply-To: <5017E72D.2060303@parallels.com>
Message-ID: <alpine.DEB.2.00.1207310915150.32295@router.home>
References: <1343391586-18837-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1207271054230.18371@router.home> <50163D94.5050607@parallels.com> <alpine.DEB.2.00.1207301421150.27584@router.home> <5017968C.6050301@parallels.com>
 <alpine.DEB.2.00.1207310906350.32295@router.home> <5017E72D.2060303@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 31 Jul 2012, Glauber Costa wrote:

> On 07/31/2012 06:09 PM, Christoph Lameter wrote:
> > That is understood. Typically these object where page sized though and
> > various assumptions (pretty dangerous ones as you are finding out) are
> > made regarding object reuse. The fallback of SLUB for higher order allocs
> > to the page allocator avoids these problems for higher order pages.
> omg...

I would be very thankful if you would go through the tree and check for
any remaining use cases like that. Would take care of your problem.

> I am curious how slab handles this, since it doesn't seem to refcount in
> the same way slub does?

Slabs are not refcounting in general. With slab larger sized free pages
may be queued for awhile on the freelist. I guess this has taken care of
these issues in the past.

> Now, I am still left with the original problem:
> __free_pages() here would be a superior solution, and the right thing to
> do. Should we just convert it - and then fix whoever we find to be
> abusing it (it doesn't mean anything, but I am running it on my systems
> since then - 0 problems), or should I just create a hacky
> put_accounted_page()?
>
> I really, really dislike the later.

So do I. If you can verify that this no longer occurs then your patch wil
be fine and we can get rid of the put_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
