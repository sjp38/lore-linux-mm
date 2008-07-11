Date: Fri, 11 Jul 2008 23:02:51 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 1/5] kmemtrace: Core implementation.
Message-ID: <20080711230251.59b204ea@linux360.ro>
In-Reply-To: <84144f020807110141r7e54e20drea8d04a0a327850c@mail.gmail.com>
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
	<20080710210557.5777979c@linux360.ro>
	<84144f020807110141r7e54e20drea8d04a0a327850c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jul 2008 11:41:20 +0300
"Pekka Enberg" <penberg@cs.helsinki.fi> wrote:

> Hi Eduard-Gabriel,
> 
> On Thu, Jul 10, 2008 at 9:05 PM, Eduard - Gabriel Munteanu
> <eduard.munteanu@linux360.ro> wrote:
> > kmemtrace provides tracing for slab allocator functions, such as
> > kmalloc, kfree, kmem_cache_alloc, kmem_cache_free etc.. Collected
> > data is then fed to the userspace application in order to analyse
> > allocation hotspots, internal fragmentation and so on, making it
> > possible to see how well an allocator performs, as well as debug
> > and profile kernel code.
> >
> > Signed-off-by: Eduard - Gabriel Munteanu
> > <eduard.munteanu@linux360.ro>
> 
> > new file mode 100644
> > index 0000000..11cd8e2
> > --- /dev/null
> > +++ b/include/linux/kmemtrace.h
> > @@ -0,0 +1,110 @@
> > +/*
> > + * Copyright (C) 2008 Eduard - Gabriel Munteanu
> > + *
> > + * This file is released under GPL version 2.
> > + */
> > +
> > +#ifndef _LINUX_KMEMTRACE_H
> > +#define _LINUX_KMEMTRACE_H
> > +
> > +#include <linux/types.h>
> > +
> > +/* ABI definition starts here. */
> > +
> > +#define KMEMTRACE_ABI_VERSION          1
> > +
> > +enum kmemtrace_event_id {
> > +       KMEMTRACE_EVENT_NULL = 0,       /* Erroneous event. */
> > +       KMEMTRACE_EVENT_ALLOC,
> > +       KMEMTRACE_EVENT_FREE,
> > +};
> > +
> > +enum kmemtrace_kind_id {
> > +       KMEMTRACE_KIND_KERNEL = 0,      /* kmalloc() / kfree(). */
> > +       KMEMTRACE_KIND_CACHE,           /* kmem_cache_*(). */
> > +       KMEMTRACE_KIND_PAGES,           /* __get_free_pages() and
> > friends. */ +};
> 
> Can we do s/kind/type/, please? Also, the names "kernel" and "cache"
> are confusing. Can we just call them "kmalloc" and "kmem_cache"
> instead?

Sure. I thought "type" would be too confusing.

Regarding the use of "kmalloc" and "kmem_cache", I'd have a few objections:
1. "kmalloc" is ambiguous and may mislead some people into thinking
that such a type is inappropriate for kfree().
2. "kmem_cache" seemed way too long. The tracing function calls are
already kinda long.

> > +
> > +struct kmemtrace_event {
> > +       __u16           event_id;       /* Allocate or free? */
> > +       __u16           kind_id;        /* Kind of allocation/free.
> > */
> > +       __s32           node;           /* Target CPU. */
> > +       __u64           call_site;      /* Caller address. */
> > +       __u64           ptr;            /* Pointer to allocation. */
> > +       __u64           bytes_req;      /* Number of bytes
> > requested. */
> > +       __u64           bytes_alloc;    /* Number of bytes
> > allocated. */
> > +       __u64           gfp_flags;      /* Requested flags. */
> > +       __s64           timestamp;      /* When the operation
> > occured in ns. */ +} __attribute__ ((__packed__));
> 
> Why do you need to use the __packed__ attribute here? Looks like the
> struct is already laid out properly.

__packed__ doesn't hurt and will keep us from getting fried when doing
cross-platform tracing (e.g. trace on ARM, analyze on x86) in case the
ABI changes. It's also a reminder that it's best to keep the structure
packed tight and avoid alignment.

> > +
> > +/* End of ABI definition. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
