Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 99B6B6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:52:43 -0400 (EDT)
Date: Tue, 20 Jul 2010 14:52:38 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Message-ID: <20100720145238.29111716@bike.lwn.net>
In-Reply-To: <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
	<d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
	<adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jul 2010 17:51:25 +0200
Michal Nazarewicz <m.nazarewicz@samsung.com> wrote:

> The Contiguous Memory Allocator framework is a set of APIs for
> allocating physically contiguous chunks of memory.
> 
> Various chips require contiguous blocks of memory to operate.  Those
> chips include devices such as cameras, hardware video decoders and
> encoders, etc.

Certainly this is something that many of us have run into; a general
solution would make life easier. I do wonder if this implementation
isn't a bit more complex than is really needed, though.

> diff --git a/Documentation/cma.txt b/Documentation/cma.txt

"cma.txt" is not a name that will say much to people browsing the
directory, especially since you didn't add a 00-INDEX entry for it.  Maybe
something like contiguous-memory.txt would be better?

[...]

> +    For instance, let say that there are two memory banks and for
> +    performance reasons a device uses buffers in both of them.  In
> +    such case, the device driver would define two kinds and use it for
> +    different buffers.  Command line arguments could look as follows:
> +
> +            cma=a=32M@0,b=32M@512M cma_map=foo/a=a;foo/b=b

About the time I get here I really have to wonder if we *really* need all
of this.  A rather large portion of the entire patch is parsing code.  Are
there real-world use cases for this kind of functionality?

> +    And whenever the driver allocated the memory it would specify the
> +    kind of memory:
> +
> +            buffer1 = cma_alloc(dev, 1 << 20, 0, "a");
> +            buffer2 = cma_alloc(dev, 1 << 20, 0, "b");

This example, above, is not consistent with:

> +
> +    There are four calls provided by the CMA framework to devices.  To
> +    allocate a chunk of memory cma_alloc() function needs to be used:
> +
> +            unsigned long cma_alloc(const struct device *dev,
> +                                    const char *kind,
> +                                    unsigned long size,
> +                                    unsigned long alignment);

It looks like the API changed and the example didn't get updated?

> +
> +    If required, device may specify alignment that the chunk need to
> +    satisfy.  It have to be a power of two or zero.  The chunks are
> +    always aligned at least to a page.

So is the alignment specified in bytes or pages?

> +    Allocated chunk is freed via a cma_put() function:
> +
> +            int cma_put(unsigned long addr);
> +
> +    It takes physical address of the chunk as an argument and
> +    decreases it's reference counter.  If the counter reaches zero the
> +    chunk is freed.  Most of the time users do not need to think about
> +    reference counter and simply use the cma_put() as a free call.

A return value from a put() function is mildly different; when would that
value be useful?

> +    If one, however, were to share a chunk with others built in
> +    reference counter may turn out to be handy.  To increment it, one
> +    needs to use cma_get() function:
> +
> +            int cma_put(unsigned long addr);

Somebody's been cut-n-pasting a little too quickly...:)

> +    Creating an allocator for CMA needs four functions to be
> +    implemented.
> +
> +
> +    The first two are used to initialise an allocator far given driver
> +    and clean up afterwards:
> +
> +            int  cma_foo_init(struct cma_region *reg);
> +            void cma_foo_done(struct cma_region *reg);
> +
> +    The first is called during platform initialisation.  The
> +    cma_region structure has saved starting address of the region as
> +    well as its size.  It has also alloc_params field with optional
> +    parameters passed via command line (allocator is free to interpret
> +    those in any way it pleases).  Any data that allocate associated
> +    with the region can be saved in private_data field.
> +
> +    The second call cleans up and frees all resources the allocator
> +    has allocated for the region.  The function can assume that all
> +    chunks allocated form this region have been freed thus the whole
> +    region is free.
> +
> +
> +    The two other calls are used for allocating and freeing chunks.
> +    They are:
> +
> +            struct cma_chunk *cma_foo_alloc(struct cma_region *reg,
> +                                            unsigned long size,
> +                                            unsigned long alignment);
> +            void cma_foo_free(struct cma_chunk *chunk);
> +
> +    As names imply the first allocates a chunk and the other frees
> +    a chunk of memory.  It also manages a cma_chunk object
> +    representing the chunk in physical memory.
> +
> +    Either of those function can assume that they are the only thread
> +    accessing the region.  Therefore, allocator does not need to worry
> +    about concurrency.
> +
> +
> +    When allocator is ready, all that is left is register it by adding
> +    a line to "mm/cma-allocators.h" file:
> +
> +            CMA_ALLOCATOR("foo", foo)
> +
> +    The first "foo" is a named that will be available to use with
> +    command line argument.  The second is the part used in function
> +    names.

This is a bit of an awkward way to register new allocators.  Why not just
have new allocators fill in an operations structure can call something like
cma_allocator_register() at initialization time?  That would let people
write allocators as modules and would eliminate the need to add allocators
to a central include file.  It would also get rid of some ugly and (IMHO)
unnecessary preprocessor hackery.

[...]

> +** Future work
> +
> +    In the future, implementation of mechanisms that would allow the
> +    free space inside the regions to be used as page cache, filesystem
> +    buffers or swap devices is planned.  With such mechanisms, the
> +    memory would not be wasted when not used.

Ouch.  You'd need to be able to evacuate that space again when it's needed,
or the whole point of CMA has been lost.  Once again, is it worth the
complexity?


[...]
> diff --git a/include/linux/cma-int.h b/include/linux/cma-int.h
> new file mode 100644
> index 0000000..b588e9b
> --- /dev/null
> +++ b/include/linux/cma-int.h

> +struct cma_region {
> +	const char *name;
> +	unsigned long start;
> +	unsigned long size, free_space;
> +	unsigned long alignment;
> +
> +	struct cma_allocator *alloc;
> +	const char *alloc_name;
> +	const char *alloc_params;
> +	void *private_data;
> +
> +	unsigned users;
> +	/*
> +	 * Protects the "users" and "free_space" fields and any calls
> +	 * to allocator on this region thus guarantees only one call
> +	 * to allocator will operate on this region..
> +	 */
> +	struct mutex mutex;
> +};

The use of mutexes means that allocation/free functions cannot be called
from atomic context.  Perhaps that will never be a problem, but it might
also be possible to use spinlocks instead?

[...]

> diff --git a/mm/cma-allocators.h b/mm/cma-allocators.h
> new file mode 100644
> index 0000000..564f705
> --- /dev/null
> +++ b/mm/cma-allocators.h
> @@ -0,0 +1,42 @@
> +#ifdef __CMA_ALLOCATORS_H
> +
> +/* List all existing allocators here using CMA_ALLOCATOR macro. */
> +
> +#ifdef CONFIG_CMA_BEST_FIT
> +CMA_ALLOCATOR("bf", bf)
> +#endif

This is the kind of thing I think it would be nice to avoid; is there any
real reason why allocators need to be put into this central file?

This is some weird ifdef stuff as well; it processes the CMA_ALLOCATOR()
invocations if it's included twice?

> +
> +#  undef CMA_ALLOCATOR
> +#else
> +#  define __CMA_ALLOCATORS_H
> +
> +/* Function prototypes */
> +#  ifndef __LINUX_CMA_ALLOCATORS_H
> +#    define __LINUX_CMA_ALLOCATORS_H
> +#    define CMA_ALLOCATOR(name, infix)				\
> +	extern int cma_ ## infix ## _init(struct cma_region *);		\
> +	extern void cma_ ## infix ## _cleanup(struct cma_region *);	\
> +	extern struct cma_chunk *					\
> +	cma_ ## infix ## _alloc(struct cma_region *,			\
> +			      unsigned long, unsigned long);		\
> +	extern void cma_ ## infix ## _free(struct cma_chunk *);
> +#    include "cma-allocators.h"
> +#  endif
> +
> +/* The cma_allocators array */
> +#  ifdef CMA_ALLOCATORS_LIST
> +#    define CMA_ALLOCATOR(_name, infix) {		\
> +		.name    = _name,			\
> +		.init    = cma_ ## infix ## _init,	\
> +		.cleanup = cma_ ## infix ## _cleanup,	\
> +		.alloc   = cma_ ## infix ## _alloc,	\
> +		.free    = cma_ ## infix ## _free,	\
> +	},

Different implementations of the macro in different places in the same
kernel can cause confusion.  To what end?  As I said before, a simple
registration function called by the allocators would eliminate the need for
this kind of stuff.

> diff --git a/mm/cma-best-fit.c b/mm/cma-best-fit.c

[...]

> +int cma_bf_init(struct cma_region *reg)
> +{
> +	struct cma_bf_private *prv;
> +	struct cma_bf_item *item;
> +
> +	prv = kzalloc(sizeof *prv, GFP_NOWAIT);
> +	if (unlikely(!prv))
> +		return -ENOMEM;

I'll say this once, but the comment applies all over this code: I hate it
when people go nuts with likely/unlikely().  This is an initialization
function, we don't actually care if the branch prediction gets it wrong.
Classic premature optimization.  The truth of the matter is that
*programmers* often get this wrong.  Have you profiled all these
ocurrences?  Maybe it would be better to take them out?

[...]

> +struct cma_chunk *cma_bf_alloc(struct cma_region *reg,
> +			       unsigned long size, unsigned long alignment)
> +{
> +	struct cma_bf_private *prv = reg->private_data;
> +	struct rb_node *node = prv->by_size_root.rb_node;
> +	struct cma_bf_item *item = NULL;
> +	unsigned long start, end;
> +
> +	/* First first item that is large enough */
> +	while (node) {
> +		struct cma_bf_item *i =
> +			rb_entry(node, struct cma_bf_item, by_size);

This is about where I start to wonder about locking.  I take it that the
allocator code is relying upon locking at the CMA level to prevent
concurrent calls?  If so, it would be good to document what guarantees the
CMA level provides.

> +/************************* Basic Tree Manipulation *************************/
> +
> +#define __CMA_BF_HOLE_INSERT(root, node, field) ({			\
> +	bool equal = false;						\
> +	struct rb_node **link = &(root).rb_node, *parent = NULL;	\
> +	const unsigned long value = item->field;			\
> +	while (*link) {							\
> +		struct cma_bf_item *i;					\
> +		parent = *link;						\
> +		i = rb_entry(parent, struct cma_bf_item, node);		\
> +		link = value <= i->field				\
> +			? &parent->rb_left				\
> +			: &parent->rb_right;				\
> +		equal = equal || value == i->field;			\
> +	}								\
> +	rb_link_node(&item->node, parent, link);			\
> +	rb_insert_color(&item->node, &root);				\
> +	equal;								\
> +})

Is there a reason why this is a macro?  The code might be more readable if
you just wrote out the two versions that you need.

[...]

> diff --git a/mm/cma.c b/mm/cma.c
> new file mode 100644
> index 0000000..6a0942f
> --- /dev/null
> +++ b/mm/cma.c

[...]

> +static const char *__must_check
> +__cma_where_from(const struct device *dev, const char *kind)
> +{
> +	/*
> +	 * This function matches the pattern given at command line
> +	 * parameter agains given device name and kind.  Kind may be
> +	 * of course NULL or an emtpy string.
> +	 */
> +
> +	const char **spec, *name;
> +	int name_matched = 0;
> +
> +	/* Make sure dev was given and has name */
> +	if (unlikely(!dev))
> +		return ERR_PTR(-EINVAL);
> +
> +	name = dev_name(dev);
> +	if (WARN_ON(!name || !*name))
> +		return ERR_PTR(-EINVAL);
> +
> +	/* kind == NULL is just like an empty kind */
> +	if (!kind)
> +		kind = "";
> +
> +	/*
> +	 * Now we go throught the cma_map array.  It is an array of
> +	 * pointers to chars (ie. array of strings) so in each
> +	 * iteration we take each of the string.  The strings is
> +	 * basically what user provided at the command line separated
> +	 * by semicolons.
> +	 */
> +	for (spec = cma_map; *spec; ++spec) {
> +		/*
> +		 * This macro tries to match pattern pointed by s to
> +		 * @what.  If, while reading the spec, we ecnounter
> +		 * comma it means that the pattern does not match and
> +		 * we need to start over with another spec.  If there
> +		 * is a character that does not match, we neet to try
> +		 * again looking if there is another spec.
> +		 */
> +#define TRY_MATCH(what) do {				\
> +		const char *c = what;			\
> +		for (; *s != '*' && *c; ++c, ++s)	\
> +			if (*s == ',')			\
> +				goto again;		\
> +			else if (*s != '?' && *c != *s)	\
> +				goto again_maybe;	\
> +		if (*s == '*')				\
> +			++s;				\
> +	} while (0)

This kind of thing rarely contributes to the readability or maintainability
of the code.  Is it really necessary?  Or (as asked before) is all this
functionality really necessary?

[...]

One other comment: it might be nice if drivers could provide allocation
regions of their own.  The viafb driver, for example, really needs an
allocator to hand out chunks of framebuffer memory - including large chunks
for things like video frames.  If that driver could hand responsibility
for that over to CMA, it could eliminate the need for yet another
driver-quality memory manager.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
