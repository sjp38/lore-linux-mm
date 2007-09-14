Received: by wa-out-1112.google.com with SMTP id m33so1169070wag
        for <linux-mm@kvack.org>; Fri, 14 Sep 2007 16:47:49 -0700 (PDT)
Message-ID: <a781481a0709141647q3d019423s388c64bf6bed871a@mail.gmail.com>
Date: Sat, 15 Sep 2007 05:17:48 +0530
From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH 1/6] cpuset write dirty map
In-Reply-To: <20070914161536.3ec5c533.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
	 <46E742A2.9040006@google.com>
	 <20070914161536.3ec5c533.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On 9/15/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 11 Sep 2007 18:36:34 -0700
> Ethan Solomita <solo@google.com> wrote:

> > The dirty map may be stored either directly in the mapping (for NUMA
> > systems with less then BITS_PER_LONG nodes) or separately allocated
> > for systems with a large number of nodes (f.e. IA64 with 1024 nodes).

> > --- 0/include/linux/fs.h      2007-09-11 14:35:58.000000000 -0700
> > +++ 1/include/linux/fs.h      2007-09-11 14:36:24.000000000 -0700
> > @@ -516,6 +516,13 @@ struct address_space {
> >       spinlock_t              private_lock;   /* for use by the address_space */
> >       struct list_head        private_list;   /* ditto */
> >       struct address_space    *assoc_mapping; /* ditto */
> > +#ifdef CONFIG_CPUSETS
> > +#if MAX_NUMNODES <= BITS_PER_LONG
> > +     nodemask_t              dirty_nodes;    /* nodes with dirty pages */
> > +#else
> > +     nodemask_t              *dirty_nodes;   /* pointer to map if dirty */
> > +#endif
> > +#endif
>
> afacit there is no code comment and no changelog text which explains the
> above design decision?  There should be, please.

> > +/*
> > + * Special functions for NUMA systems with a large number of nodes.
> > + * The nodemask is pointed to from the address space structures.
> > + * The attachment of the dirty_node mask is protected by the
> > + * tree_lock. The nodemask is freed only when the inode is cleared
> > + * (and therefore unused, thus no locking necessary).
> > + */
>
> hmm, OK, there's a hint as to wghat's going on.
>
> It's unobvious why the break point is at MAX_NUMNODES = BITS_PER_LONG and
> we might want to tweak that in the future.  Yet another argument for
> centralising this comparison.

Looks like just an optimization to me ... Ethan wants to economize and not bloat
struct address_space too much.

So, if sizeof(nodemask_t) == sizeof(long), i.e. when:
MAX_NUMNODES <= BITS_PER_LONG, then we'll be adding only sizeof(long)
extra bytes to the struct (by plonking the object itself into it).

But even when MAX_NUMNODES > BITS_PER_LONG, because we're storing
a pointer, and because sizeof(void *) == sizeof(long), so again the maximum
bloat addition to struct address_space would only be sizeof(long) bytes.

I didn't see the original mail, but if the #ifdeffery for this
conditional is too much
as a result of this optimization, Ethan should probably just do away
with all of it
entirely, and simply put a full nodemask_t object (irrespective of MAX_NUMNODES)
into the struct. After all, struct task_struct does the same unconditionally ...
but admittedly, there are several times more address_space struct's resident in
memory at any given time than there are task_struct's, so this optimization does
make sense too ...


> > +             if (!nodes)
> > +                     return;
> > +
> > +             *nodes = NODE_MASK_NONE;
> > +             mapping->dirty_nodes = nodes;
> > +     }
> > +
> > +     if (!node_isset(node, *nodes))
> > +             node_set(node, *nodes);
> > +}
> > +
> > +void cpuset_clear_dirty_nodes(struct address_space *mapping)
> > +{
> > +     nodemask_t *nodes = mapping->dirty_nodes;
> > +
> > +     if (nodes) {
> > +             mapping->dirty_nodes = NULL;
> > +             kfree(nodes);
> > +     }
> > +}
>
> Can this race with cpuset_update_dirty_nodes()?  And with itself?  If not,
> a comment which describes the locking requirements would be good.
>
> > +/*
> > + * Called without the tree_lock. The nodemask is only freed when the inode
> > + * is cleared and therefore this is safe.
> > + */
> > +int cpuset_intersects_dirty_nodes(struct address_space *mapping,
> > +                     nodemask_t *mask)
> > +{
> > +     nodemask_t *dirty_nodes = mapping->dirty_nodes;
> > +
> > +     if (!mask)
> > +             return 1;
> > +
> > +     if (!dirty_nodes)
> > +             return 0;
> > +
> > +     return nodes_intersects(*dirty_nodes, *mask);
> > +}
> > +#endif
> > +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
