Subject: Re: [RFC PATCH 5/5] kmemtrace: SLOB hooks.
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <84144f020807110144t359ef9d3q36a0ca7caa36841f@mail.gmail.com>
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-2-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-3-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-4-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-5-git-send-email-eduard.munteanu@linux360.ro>
	 <20080710210623.1cad3c3c@linux360.ro>
	 <84144f020807110144t359ef9d3q36a0ca7caa36841f@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 11 Jul 2008 10:36:37 -0500
Message-Id: <1215790597.4800.2.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-11 at 11:44 +0300, Pekka Enberg wrote:
> Hi,
> 
> Matt, can you take a look at this? I know you don't want *debugging*
> code in SLOB but this is for instrumentation.

I presume this code all disappears in a default SLOB build?

> On Thu, Jul 10, 2008 at 9:06 PM, Eduard - Gabriel Munteanu
> <eduard.munteanu@linux360.ro> wrote:
> > This adds hooks for the SLOB allocator, to allow tracing with kmemtrace.
> >
> > Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> > ---
> >  mm/slob.c |   37 +++++++++++++++++++++++++++++++------
> >  1 files changed, 31 insertions(+), 6 deletions(-)
> >
> > diff --git a/mm/slob.c b/mm/slob.c
> > index a3ad667..44f395a 100644
> > --- a/mm/slob.c
> > +++ b/mm/slob.c
> > @@ -65,6 +65,7 @@
> >  #include <linux/module.h>
> >  #include <linux/rcupdate.h>
> >  #include <linux/list.h>
> > +#include <linux/kmemtrace.h>
> >  #include <asm/atomic.h>
> >
> >  /*
> > @@ -463,27 +464,38 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
> >  {
> >        unsigned int *m;
> >        int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
> > +       void *ret;

There's tons of tab damage in this patch. Or perhaps it's just been
mangled by someone's mailer?

> >        if (size < PAGE_SIZE - align) {
> >                if (!size)
> >                        return ZERO_SIZE_PTR;
> >
> >                m = slob_alloc(size + align, gfp, align, node);
> > +
> >                if (!m)
> >                        return NULL;
> >                *m = size;
> > -               return (void *)m + align;
> > +               ret = (void *)m + align;
> > +
> > +               kmemtrace_mark_alloc_node(KMEMTRACE_KIND_KERNEL,
> > +                                         _RET_IP_, ret,
> > +                                         size, size + align, gfp, node);
> >        } else {
> > -               void *ret;
> > +               unsigned int order = get_order(size);
> >
> > -               ret = slob_new_page(gfp | __GFP_COMP, get_order(size), node);
> > +               ret = slob_new_page(gfp | __GFP_COMP, order, node);
> >                if (ret) {
> >                        struct page *page;
> >                        page = virt_to_page(ret);
> >                        page->private = size;
> >                }
> > -               return ret;
> > +
> > +               kmemtrace_mark_alloc_node(KMEMTRACE_KIND_KERNEL,
> 
> The latter case is actually page allocator pass-through so I wonder if
> we want to use KIND_PAGES here instead?
> 
> > +                                         _RET_IP_, ret,
> > +                                         size, PAGE_SIZE << order, gfp, node);
> >        }
> > +
> > +       return ret;
> >  }
> >  EXPORT_SYMBOL(__kmalloc_node);
> >
> > @@ -501,6 +513,8 @@ void kfree(const void *block)
> >                slob_free(m, *m + align);
> >        } else
> >                put_page(&sp->page);
> > +
> > +       kmemtrace_mark_free(KMEMTRACE_KIND_KERNEL, _RET_IP_, block);
> 
> Same comment here.
> 
> >  }
> >  EXPORT_SYMBOL(kfree);
> >
> > @@ -569,10 +583,19 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
> >  {
> >        void *b;
> >
> > -       if (c->size < PAGE_SIZE)
> > +       if (c->size < PAGE_SIZE) {
> >                b = slob_alloc(c->size, flags, c->align, node);
> > -       else
> > +               kmemtrace_mark_alloc_node(KMEMTRACE_KIND_CACHE,
> > +                                         _RET_IP_, b, c->size,
> > +                                         SLOB_UNITS(c->size) * SLOB_UNIT,
> > +                                         flags, node);
> > +       } else {
> >                b = slob_new_page(flags, get_order(c->size), node);
> > +               kmemtrace_mark_alloc_node(KMEMTRACE_KIND_CACHE,
> > +                                         _RET_IP_, b, c->size,
> > +                                         PAGE_SIZE << get_order(c->size),
> > +                                         flags, node);
> > +       }
> >
> >        if (c->ctor)
> >                c->ctor(c, b);
> > @@ -608,6 +631,8 @@ void kmem_cache_free(struct kmem_cache *c, void *b)
> >        } else {
> >                __kmem_cache_free(b, c->size);
> >        }
> > +
> > +       kmemtrace_mark_free(KMEMTRACE_KIND_CACHE, _RET_IP_, b);
> >  }
> >  EXPORT_SYMBOL(kmem_cache_free);
> >
> > --
> > 1.5.6.1
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
