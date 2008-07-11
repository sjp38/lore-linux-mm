Date: Fri, 11 Jul 2008 23:19:23 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 4/5] kmemtrace: SLUB hooks.
Message-ID: <20080711231923.0f827113@linux360.ro>
In-Reply-To: <84144f020807110145g3467d77md54e3d734ecba2c6@mail.gmail.com>
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
	<1215712946-23572-2-git-send-email-eduard.munteanu@linux360.ro>
	<1215712946-23572-3-git-send-email-eduard.munteanu@linux360.ro>
	<1215712946-23572-4-git-send-email-eduard.munteanu@linux360.ro>
	<20080710210617.70975aed@linux360.ro>
	<84144f020807110145g3467d77md54e3d734ecba2c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jul 2008 11:45:59 +0300
"Pekka Enberg" <penberg@cs.helsinki.fi> wrote:

> Hi Eduard-Gabriel,
> 
> On Thu, Jul 10, 2008 at 9:06 PM, Eduard - Gabriel Munteanu
> <eduard.munteanu@linux360.ro> wrote:
> > This adds hooks for the SLUB allocator, to allow tracing with
> > kmemtrace.
> >
> > Signed-off-by: Eduard - Gabriel Munteanu
> > <eduard.munteanu@linux360.ro>
> 
> > @@ -205,7 +206,13 @@ void *__kmalloc(size_t size, gfp_t flags);
> >
> >  static __always_inline void *kmalloc_large(size_t size, gfp_t
> > flags) {
> > -       return (void *)__get_free_pages(flags | __GFP_COMP,
> > get_order(size));
> > +       unsigned int order = get_order(size);
> > +       void *ret = (void *) __get_free_pages(flags, order);
> > +
> > +       kmemtrace_mark_alloc(KMEMTRACE_KIND_KERNEL, _THIS_IP_, ret,
> > +                            size, PAGE_SIZE << order, flags);
> 
> Oh, I missed this on the first review. Here we have, like in SLOB,
> page allocator pass-through, so wouldn't KIND_PAGES be more
> appropriate?

The rationale was to be able to trace how kmalloc()s perform, no matter
what the allocator does behind the scenes. Presumably, the developer
would know what kmalloc() really does with an allocation request.

Does this sound okay?


	Eduard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
