Date: Sun, 9 Jan 2005 09:35:51 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] per thread page reservation patch
Message-ID: <20050109113551.GB9144@logos.cnet>
References: <1105019521.7074.79.camel@tribesman.namesys.com> <20050107144644.GA9606@infradead.org> <1105118217.3616.171.camel@tribesman.namesys.com> <41DEDF87.8080809@grupopie.com> <m1llb5q7qs.fsf@clusterfs.com> <20050107132459.033adc9f.akpm@osdl.org> <m1d5wgrir7.fsf@clusterfs.com> <20050107150315.3c1714a4.akpm@osdl.org> <m18y74rfqs.fsf@clusterfs.com> <20050107154305.790b8a51.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050107154305.790b8a51.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <nikita@clusterfs.com>, pmarques@grupopie.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 07, 2005 at 03:43:05PM -0800, Andrew Morton wrote:
> Nikita Danilov <nikita@clusterfs.com> wrote:
> >
> > >
> > > Why does the filesystem risk going oom during the rebalance anyway?  Is it
> > > doing atomic allocations?
> > 
> > No, just __alloc_pages(GFP_KERNEL, 0, ...) returns NULL. When this
> > happens, the only thing balancing can do is to panic.
> 
> __alloc_pages(GFP_KERNEL, ...) doesn't return NULL.  It'll either succeed
> or never return ;) That behaviour may change at any time of course, but it
> does make me wonder why we're bothering with this at all.  Maybe it's
> because of the possibility of a GFP_IO failure under your feet or
> something?
> 
> What happens if reiser4 simply doesn't use this code?
> 
> 
> If we introduce this mechanism, people will end up using it all over the
> place.  Probably we could remove radix_tree_preload(), which is the only
> similar code I can I can immediately think of.
> 
> Page reservation is not a bad thing per-se, but it does need serious
> thought.

Whenever scheme comes up I dont think the current check in __alloc_pages() is 
any good:

        if (order == 0) {
                page = perthread_pages_alloc();
                if (page != NULL)
                        return page;
        }

Two things:

- all instances of an allocator from the current thread will eat from the perthread
  reserves, you probably want only a few special allocations to eat from the reserves?
  Thing is its not really a reservation intended for emergency situations,
  rather a "generic per-thread pool" the way things are now.

- its a real fast path, we're adding quite some instructions there which are only
  used by reiserfs now.

I think in a "final" implementation emergency allocations should be explicitly stated 
as such by the callers ?

> How does reiser4 end up deciding how many pages to reserve?  Gross
> overkill?
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
