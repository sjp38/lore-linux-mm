Date: Fri, 7 Jan 2005 13:24:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] per thread page reservation patch
Message-Id: <20050107132459.033adc9f.akpm@osdl.org>
In-Reply-To: <m1llb5q7qs.fsf@clusterfs.com>
References: <20050103011113.6f6c8f44.akpm@osdl.org>
	<20050103114854.GA18408@infradead.org>
	<41DC2386.9010701@namesys.com>
	<1105019521.7074.79.camel@tribesman.namesys.com>
	<20050107144644.GA9606@infradead.org>
	<1105118217.3616.171.camel@tribesman.namesys.com>
	<41DEDF87.8080809@grupopie.com>
	<m1llb5q7qs.fsf@clusterfs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: pmarques@grupopie.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> That's the whole idea behind this patch: at the beginning of "atomic"
> operation, some number of pages is reserved. As these pages are
> available through page allocator, _all_ allocations done by atomic
> operation will use reserved pages transparently. For example:
> 
>         perthread_pages_reserve(nr, GFP_KERNEL);
> 
>         foo()->
> 
>             bar()->
> 
>                 page = find_or_create_page(some_mapping, ...);
> 
>         perthread_pages_release(unused_pages);
> 
> find_or_create() pages will use pages reserved for this thread and,
> hence, is guaranteed to succeed (given correct reservation).
> 
> Alternative is to pass some sort of handle all the way down to actual
> calls to allocator, and to modify all generic code to use reservations.

Maybe I'm being thick, but I don't see how you can protect the reservation
of an outer reserver in the above way:

	perthread_pages_reserve(10);
	...				/* current->private_pages_count = 10 */
		perthread_pages_reserve(10)	/* private_pages_count = 20 */
		use 5 pages			/* private_pages_count = 15 */
		perthread_pages_release(5);

But how does the caller come up with the final "5"?

Seems better to me if prethread_pages_reserve() were to return the initial
value of private_pages_count, so the caller can do:

	old = perthread_pages_reserve(10);
		use 5 pages
	perthread_pages_release(old);

or whatever.

That kinda stinks too in a way, because both the outer and the inner
callers need to overallocate pages on behalf of the worst case user in some
deep call stack.

And the whole idea is pretty flaky really - how can one precalculate how
much memory an arbitrary md-on-dm-on-loop-on-md-on-NBD stack will want to
use?  It really would be better if we could drop the whole patch and make
reiser4 behave more sanely when its writepage is called with for_reclaim=1.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
