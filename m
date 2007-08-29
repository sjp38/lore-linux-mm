Date: Wed, 29 Aug 2007 16:58:01 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: speeding up swapoff
In-Reply-To: <20070829073040.1ec35176@laptopd505.fenrus.org>
Message-ID: <Pine.LNX.4.64.0708291638550.30229@blonde.wat.veritas.com>
References: <1188394172.22156.67.camel@localhost> <20070829073040.1ec35176@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Daniel Drake <ddrake@brontes3d.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Aug 2007, Arjan van de Ven wrote:
> On Wed, 29 Aug 2007 09:29:32 -0400
> Daniel Drake <ddrake@brontes3d.com> wrote:
> 
> > I've spent some time trying to understand why swapoff is such a slow
> > operation.
> > 
> > My experiments show that when there is not much free physical memory,
> > swapoff moves pages out of swap at a rate of approximately 5mb/sec.
> 
> sounds like about disk speed (at random-seek IO pattern)

The present method should be reading sequentially (with gaps),
rather than randomly.  Perhaps we need to check what's happening
in practice.

(I've often dithered over whether we should be doing swap readahead
there or not: at present it does not, preferring to assume buffering
at the hardware level, and last time I checked that worked out a
little better.)

> Another question, if this is during system shutdown, maybe that's a
> valid case for flushing most of the pagecache first (from userspace)
> since most of what's there won't be used again anyway. If that's enough
> to make this go faster...

(I didn't understand your point there, but Daniel has replied that
it's not at shutdown anyway.)

> A third question, have you investigated what happens if a process gets
> killed that has pages in swap; as long as we don't page those in but
> just forget about them, that would solve the shutdown problem nicely
> (since we kill stuff first anyway there)

We definitely don't page those in, it would be a disaster for process
exit if we did: they just get discarded.

As you say, shutdown is rarely a big issue, because almost all the
processes which had stuff in swap have already been killed.  tmpfs
use of swap can be an issue there, but if the distro is wise, it'll
do things in such an order that tmpfs'es are unmounted before swapoff
(but may need two passes: the opposite case is a regular swapfile,
where we need to swapoff before that partition can be unmounted).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
