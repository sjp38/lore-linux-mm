Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id DF9276B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 20:58:57 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id gg6so5624649lbb.27
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 17:58:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5123BC4D.1010404@linux.vnet.ibm.com>
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1360780731-11708-2-git-send-email-sjenning@linux.vnet.ibm.com>
	<20130219091804.GA13989@lge.com>
	<5123BC4D.1010404@linux.vnet.ibm.com>
Date: Tue, 19 Feb 2013 17:58:55 -0800
Message-ID: <CAPkvG_fgTEGCNEaU7H8vzJpuXTP2yKLo8QM=_zvgHGDivQ8-AA@mail.gmail.com>
Subject: Re: [PATCHv5 1/8] zsmalloc: add to mm/
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: multipart/alternative; boundary=bcaec5524414fb029f04d61e4c20
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Driver Project <devel@driverdev.osuosl.org>

--bcaec5524414fb029f04d61e4c20
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Feb 19, 2013 at 9:54 AM, Seth Jennings
<sjenning@linux.vnet.ibm.com>wrote:

> On 02/19/2013 03:18 AM, Joonsoo Kim wrote:
> > Hello, Seth.
> > I'm not sure that this is right time to review, because I already have
> > seen many effort of various people to promote zxxx series. I don't want
> to
> > be a stopper to promote these. :)
>
> Any time is good review time :)  Thanks for your review!
>
> >
> > But, I read the code, now, and then some comments below.
> >
> > On Wed, Feb 13, 2013 at 12:38:44PM -0600, Seth Jennings wrote:
> >> =========
> >> DO NOT MERGE, FOR REVIEW ONLY
> >> This patch introduces zsmalloc as new code, however, it already
> >> exists in drivers/staging.  In order to build successfully, you
> >> must select EITHER to driver/staging version OR this version.
> >> Once zsmalloc is reviewed in this format (and hopefully accepted),
> >> I will create a new patchset that properly promotes zsmalloc from
> >> staging.
> >> =========
> >>
> >> This patchset introduces a new slab-based memory allocator,
> >> zsmalloc, for storing compressed pages.  It is designed for
> >> low fragmentation and high allocation success rate on
> >> large object, but <= PAGE_SIZE allocations.
> >>
> >> zsmalloc differs from the kernel slab allocator in two primary
> >> ways to achieve these design goals.
> >>
> >> zsmalloc never requires high order page allocations to back
> >> slabs, or "size classes" in zsmalloc terms. Instead it allows
> >> multiple single-order pages to be stitched together into a
> >> "zspage" which backs the slab.  This allows for higher allocation
> >> success rate under memory pressure.
> >>
> >> Also, zsmalloc allows objects to span page boundaries within the
> >> zspage.  This allows for lower fragmentation than could be had
> >> with the kernel slab allocator for objects between PAGE_SIZE/2
> >> and PAGE_SIZE.  With the kernel slab allocator, if a page compresses
> >> to 60% of it original size, the memory savings gained through
> >> compression is lost in fragmentation because another object of
> >> the same size can't be stored in the leftover space.
> >>
> >> This ability to span pages results in zsmalloc allocations not being
> >> directly addressable by the user.  The user is given an
> >> non-dereferencable handle in response to an allocation request.
> >> That handle must be mapped, using zs_map_object(), which returns
> >> a pointer to the mapped region that can be used.  The mapping is
> >> necessary since the object data may reside in two different
> >> noncontigious pages.
> >>
> >> zsmalloc fulfills the allocation needs for zram and zswap.
> >>
> >> Acked-by: Nitin Gupta <ngupta@vflare.org>
> >> Acked-by: Minchan Kim <minchan@kernel.org>
> >> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> >> ---
> >>  include/linux/zsmalloc.h |   49 ++
> >>  mm/Kconfig               |   24 +
> >>  mm/Makefile              |    1 +
> >>  mm/zsmalloc.c            | 1124
> ++++++++++++++++++++++++++++++++++++++++++++++
> >>  4 files changed, 1198 insertions(+)
> >>  create mode 100644 include/linux/zsmalloc.h
> >>  create mode 100644 mm/zsmalloc.c
> >>
> >> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> >> new file mode 100644
> >> index 0000000..eb6efb6
> >> --- /dev/null
> >> +++ b/include/linux/zsmalloc.h
> >> @@ -0,0 +1,49 @@
> >> +/*
> >> + * zsmalloc memory allocator
> >> + *
> >> + * Copyright (C) 2011  Nitin Gupta
> >> + *
> >> + * This code is released using a dual license strategy: BSD/GPL
> >> + * You can choose the license that better fits your requirements.
> >> + *
> >> + * Released under the terms of 3-clause BSD License
> >> + * Released under the terms of GNU General Public License Version 2.0
> >> + */
> >> +
> >> +#ifndef _ZS_MALLOC_H_
> >> +#define _ZS_MALLOC_H_
> >> +
> >> +#include <linux/types.h>
> >> +#include <linux/mm_types.h>
> >> +
> >> +/*
> >> + * zsmalloc mapping modes
> >> + *
> >> + * NOTE: These only make a difference when a mapped object spans pages
> >> +*/
> >> +enum zs_mapmode {
> >> +    ZS_MM_RW, /* normal read-write mapping */
> >> +    ZS_MM_RO, /* read-only (no copy-out at unmap time) */
> >> +    ZS_MM_WO /* write-only (no copy-in at map time) */
> >> +};
> >
> >
> > These makes no difference for PGTABLE_MAPPING.
> > Please add some comment for this.
>
> Yes. Will do.
>
> >
> >> +struct zs_ops {
> >> +    struct page * (*alloc)(gfp_t);
> >> +    void (*free)(struct page *);
> >> +};
> >> +
> >> +struct zs_pool;
> >> +
> >> +struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops);
> >> +void zs_destroy_pool(struct zs_pool *pool);
> >> +
> >> +unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t
> flags);
> >> +void zs_free(struct zs_pool *pool, unsigned long obj);
> >> +
> >> +void *zs_map_object(struct zs_pool *pool, unsigned long handle,
> >> +                    enum zs_mapmode mm);
> >> +void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
> >> +
> >> +u64 zs_get_total_size_bytes(struct zs_pool *pool);
> >> +
> >> +#endif
> >> diff --git a/mm/Kconfig b/mm/Kconfig
> >> index 278e3ab..25b8f38 100644
> >> --- a/mm/Kconfig
> >> +++ b/mm/Kconfig
> >> @@ -446,3 +446,27 @@ config FRONTSWAP
> >>        and swap data is stored as normal on the matching swap device.
> >>
> >>        If unsure, say Y to enable frontswap.
> >> +
> >> +config ZSMALLOC
> >> +    tristate "Memory allocator for compressed pages"
> >> +    default n
> >> +    help
> >> +      zsmalloc is a slab-based memory allocator designed to store
> >> +      compressed RAM pages.  zsmalloc uses virtual memory mapping
> >> +      in order to reduce fragmentation.  However, this results in a
> >> +      non-standard allocator interface where a handle, not a pointer,
> is
> >> +      returned by an alloc().  This handle must be mapped in order to
> >> +      access the allocated space.
> >> +
> >> +config PGTABLE_MAPPING
> >> +    bool "Use page table mapping to access object in zsmalloc"
> >> +    depends on ZSMALLOC
> >> +    help
> >> +      By default, zsmalloc uses a copy-based object mapping method to
> >> +      access allocations that span two pages. However, if a particular
> >> +      architecture (ex, ARM) performs VM mapping faster than copying,
> >> +      then you should select this. This causes zsmalloc to use page
> table
> >> +      mapping rather than copying for object mapping.
> >> +
> >> +      You can check speed with zsmalloc benchmark[1].
> >> +      [1] https://github.com/spartacus06/zsmalloc
> >> diff --git a/mm/Makefile b/mm/Makefile
> >> index 3a46287..0f6ef0a 100644
> >> --- a/mm/Makefile
> >> +++ b/mm/Makefile
> >> @@ -58,3 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
> >>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
> >>  obj-$(CONFIG_CLEANCACHE) += cleancache.o
> >>  obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
> >> +obj-$(CONFIG_ZSMALLOC)      += zsmalloc.o
> >> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> >> new file mode 100644
> >> index 0000000..34378ef
> >> --- /dev/null
> >> +++ b/mm/zsmalloc.c
> >> @@ -0,0 +1,1124 @@
> >> +/*
> >> + * zsmalloc memory allocator
> >> + *
> >> + * Copyright (C) 2011  Nitin Gupta
> >> + *
> >> + * This code is released using a dual license strategy: BSD/GPL
> >> + * You can choose the license that better fits your requirements.
> >> + *
> >> + * Released under the terms of 3-clause BSD License
> >> + * Released under the terms of GNU General Public License Version 2.0
> >> + */
> >> +
> >> +
> >> +/*
> >> + * This allocator is designed for use with zcache and zram. Thus, the
> >> + * allocator is supposed to work well under low memory conditions. In
> >> + * particular, it never attempts higher order page allocation which is
> >> + * very likely to fail under memory pressure. On the other hand, if we
> >> + * just use single (0-order) pages, it would suffer from very high
> >> + * fragmentation -- any object of size PAGE_SIZE/2 or larger would
> occupy
> >> + * an entire page. This was one of the major issues with its
> predecessor
> >> + * (xvmalloc).
> >> + *
> >> + * To overcome these issues, zsmalloc allocates a bunch of 0-order
> pages
> >> + * and links them together using various 'struct page' fields. These
> linked
> >> + * pages act as a single higher-order page i.e. an object can span
> 0-order
> >> + * page boundaries. The code refers to these linked pages as a single
> entity
> >> + * called zspage.
> >> + *
> >> + * For simplicity, zsmalloc can only allocate objects of size up to
> PAGE_SIZE
> >> + * since this satisfies the requirements of all its current users (in
> the
> >> + * worst case, page is incompressible and is thus stored "as-is" i.e.
> in
> >> + * uncompressed form). For allocation requests larger than this size,
> failure
> >> + * is returned (see zs_malloc).
> >> + *
> >> + * Additionally, zs_malloc() does not return a dereferenceable pointer.
> >> + * Instead, it returns an opaque handle (unsigned long) which encodes
> actual
> >> + * location of the allocated object. The reason for this indirection
> is that
> >> + * zsmalloc does not keep zspages permanently mapped since that would
> cause
> >> + * issues on 32-bit systems where the VA region for kernel space
> mappings
> >> + * is very small. So, before using the allocating memory, the object
> has to
> >> + * be mapped using zs_map_object() to get a usable pointer and
> subsequently
> >> + * unmapped using zs_unmap_object().
> >> + *
> >> + * Following is how we use various fields and flags of underlying
> >> + * struct page(s) to form a zspage.
> >> + *
> >> + * Usage of struct page fields:
> >> + *  page->first_page: points to the first component (0-order) page
> >> + *  page->index (union with page->freelist): offset of the first object
> >> + *          starting in this page. For the first page, this is
> >> + *          always 0, so we use this field (aka freelist) to point
> >> + *          to the first free object in zspage.
> >> + *  page->lru: links together all component pages (except the first
> page)
> >> + *          of a zspage
> >> + *
> >> + *  For _first_ page only:
> >> + *
> >> + *  page->private (union with page->first_page): refers to the
> >> + *          component page after the first page
> >> + *  page->freelist: points to the first free object in zspage.
> >> + *          Free objects are linked together using in-place
> >> + *          metadata.
> >> + *  page->objects: maximum number of objects we can store in this
> >> + *          zspage (class->zspage_order * PAGE_SIZE / class->size)
> >
> > How about just embedding maximum number of objects to size_class?
> > For the SLUB, each slab can have difference number of objects.
> > But, for the zsmalloc, it is not possible, so there is no reason
> > to maintain it within metadata of zspage. Just to embed it to size_class
> > is sufficient.
>
> Yes, a little code massaging and this can go away.
>
> However, there might be some value in having variable sized zspages in
> the same size_class.  It could improve allocation success rate at the
> expense of efficiency by not failing in alloc_zspage() if we can't
> allocate the optimal number of pages.  As long as we can allocate the
> first page, then we can proceed.
>


Yes, I remember trying to allow partial failures and thus allow variable
sized zspages within the same size class but I just skipped that since
it seemed like non-trivial to do and the value wasn't clear: if the
system cannot give us 4 (non-contiguous) pages then it's probably
going to fail allocation requests for single pages also in not so far
future. Also, for objects > PAGESIZE/2, failing over to zspage
of just PAGESIZE is not going to help either.


>
>
>
> >
> >> + *  page->lru: links together first pages of various zspages.
> >> + *          Basically forming list of zspages in a fullness group.
> >> + *  page->mapping: class index and fullness group of the zspage
> >> + *
> >> + * Usage of struct page flags:
> >> + *  PG_private: identifies the first component page
> >> + *  PG_private2: identifies the last component page
> >> + *
>
<snip>


> >> + */
>  >> +struct size_class {
> >> +    /*
> >> +     * Size of objects stored in this class. Must be multiple
> >> +     * of ZS_ALIGN.
> >> +     */
> >> +    int size;
> >> +    unsigned int index;
> >> +
> >> +    /* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
> >> +    int pages_per_zspage;
> >> +
> >> +    spinlock_t lock;
> >> +
> >> +    /* stats */
> >> +    u64 pages_allocated;
> >> +
> >> +    struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
> >> +};
> >
> > Instead of simple pointer, how about using list_head?
> > With this, fullness_list management is easily consolidated to
> > set_zspage_mapping() and we can remove remove_zspage(), insert_zspage().
>
>
>

Yes, this looks like a nice cleanup.
Still, I would hold such changes till we get out of staging.


Thanks for your comments, Kim.


Nitin

--bcaec5524414fb029f04d61e4c20
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Tue, Feb 19, 2013 at 9:54 AM, Seth Jennings <span dir=3D"ltr">&l=
t;<a href=3D"mailto:sjenning@linux.vnet.ibm.com" target=3D"_blank">sjenning=
@linux.vnet.ibm.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On 02/19/2013 03:18 AM, Jo=
onsoo Kim wrote:<br>
&gt; Hello, Seth.<br>
&gt; I&#39;m not sure that this is right time to review, because I already =
have<br>
&gt; seen many effort of various people to promote zxxx series. I don&#39;t=
 want to<br>
&gt; be a stopper to promote these. :)<br>
<br>
</div>Any time is good review time :) =A0Thanks for your review!<br>
<div><div class=3D"h5"><br>
&gt;<br>
&gt; But, I read the code, now, and then some comments below.<br>
&gt;<br>
&gt; On Wed, Feb 13, 2013 at 12:38:44PM -0600, Seth Jennings wrote:<br>
&gt;&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt;&gt; DO NOT MERGE, FOR REVIEW ONLY<br>
&gt;&gt; This patch introduces zsmalloc as new code, however, it already<br=
>
&gt;&gt; exists in drivers/staging. =A0In order to build successfully, you<=
br>
&gt;&gt; must select EITHER to driver/staging version OR this version.<br>
&gt;&gt; Once zsmalloc is reviewed in this format (and hopefully accepted),=
<br>
&gt;&gt; I will create a new patchset that properly promotes zsmalloc from<=
br>
&gt;&gt; staging.<br>
&gt;&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt;&gt;<br>
&gt;&gt; This patchset introduces a new slab-based memory allocator,<br>
&gt;&gt; zsmalloc, for storing compressed pages. =A0It is designed for<br>
&gt;&gt; low fragmentation and high allocation success rate on<br>
&gt;&gt; large object, but &lt;=3D PAGE_SIZE allocations.<br>
&gt;&gt;<br>
&gt;&gt; zsmalloc differs from the kernel slab allocator in two primary<br>
&gt;&gt; ways to achieve these design goals.<br>
&gt;&gt;<br>
&gt;&gt; zsmalloc never requires high order page allocations to back<br>
&gt;&gt; slabs, or &quot;size classes&quot; in zsmalloc terms. Instead it a=
llows<br>
&gt;&gt; multiple single-order pages to be stitched together into a<br>
&gt;&gt; &quot;zspage&quot; which backs the slab. =A0This allows for higher=
 allocation<br>
&gt;&gt; success rate under memory pressure.<br>
&gt;&gt;<br>
&gt;&gt; Also, zsmalloc allows objects to span page boundaries within the<b=
r>
&gt;&gt; zspage. =A0This allows for lower fragmentation than could be had<b=
r>
&gt;&gt; with the kernel slab allocator for objects between PAGE_SIZE/2<br>
&gt;&gt; and PAGE_SIZE. =A0With the kernel slab allocator, if a page compre=
sses<br>
&gt;&gt; to 60% of it original size, the memory savings gained through<br>
&gt;&gt; compression is lost in fragmentation because another object of<br>
&gt;&gt; the same size can&#39;t be stored in the leftover space.<br>
&gt;&gt;<br>
&gt;&gt; This ability to span pages results in zsmalloc allocations not bei=
ng<br>
&gt;&gt; directly addressable by the user. =A0The user is given an<br>
&gt;&gt; non-dereferencable handle in response to an allocation request.<br=
>
&gt;&gt; That handle must be mapped, using zs_map_object(), which returns<b=
r>
&gt;&gt; a pointer to the mapped region that can be used. =A0The mapping is=
<br>
&gt;&gt; necessary since the object data may reside in two different<br>
&gt;&gt; noncontigious pages.<br>
&gt;&gt;<br>
&gt;&gt; zsmalloc fulfills the allocation needs for zram and zswap.<br>
&gt;&gt;<br>
&gt;&gt; Acked-by: Nitin Gupta &lt;<a href=3D"mailto:ngupta@vflare.org">ngu=
pta@vflare.org</a>&gt;<br>
&gt;&gt; Acked-by: Minchan Kim &lt;<a href=3D"mailto:minchan@kernel.org">mi=
nchan@kernel.org</a>&gt;<br>
&gt;&gt; Signed-off-by: Seth Jennings &lt;<a href=3D"mailto:sjenning@linux.=
vnet.ibm.com">sjenning@linux.vnet.ibm.com</a>&gt;<br>
&gt;&gt; ---<br>
&gt;&gt; =A0include/linux/zsmalloc.h | =A0 49 ++<br>
&gt;&gt; =A0mm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 24 +<br>
&gt;&gt; =A0mm/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +<br>
&gt;&gt; =A0mm/zsmalloc.c =A0 =A0 =A0 =A0 =A0 =A0| 1124 +++++++++++++++++++=
+++++++++++++++++++++++++++<br>
&gt;&gt; =A04 files changed, 1198 insertions(+)<br>
&gt;&gt; =A0create mode 100644 include/linux/zsmalloc.h<br>
&gt;&gt; =A0create mode 100644 mm/zsmalloc.c<br>
&gt;&gt;<br>
&gt;&gt; diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h<b=
r>
&gt;&gt; new file mode 100644<br>
&gt;&gt; index 0000000..eb6efb6<br>
&gt;&gt; --- /dev/null<br>
&gt;&gt; +++ b/include/linux/zsmalloc.h<br>
&gt;&gt; @@ -0,0 +1,49 @@<br>
&gt;&gt; +/*<br>
&gt;&gt; + * zsmalloc memory allocator<br>
&gt;&gt; + *<br>
&gt;&gt; + * Copyright (C) 2011 =A0Nitin Gupta<br>
&gt;&gt; + *<br>
&gt;&gt; + * This code is released using a dual license strategy: BSD/GPL<b=
r>
&gt;&gt; + * You can choose the license that better fits your requirements.=
<br>
&gt;&gt; + *<br>
&gt;&gt; + * Released under the terms of 3-clause BSD License<br>
&gt;&gt; + * Released under the terms of GNU General Public License Version=
 2.0<br>
&gt;&gt; + */<br>
&gt;&gt; +<br>
&gt;&gt; +#ifndef _ZS_MALLOC_H_<br>
&gt;&gt; +#define _ZS_MALLOC_H_<br>
&gt;&gt; +<br>
&gt;&gt; +#include &lt;linux/types.h&gt;<br>
&gt;&gt; +#include &lt;linux/mm_types.h&gt;<br>
&gt;&gt; +<br>
&gt;&gt; +/*<br>
&gt;&gt; + * zsmalloc mapping modes<br>
&gt;&gt; + *<br>
&gt;&gt; + * NOTE: These only make a difference when a mapped object spans =
pages<br>
&gt;&gt; +*/<br>
&gt;&gt; +enum zs_mapmode {<br>
&gt;&gt; + =A0 =A0ZS_MM_RW, /* normal read-write mapping */<br>
&gt;&gt; + =A0 =A0ZS_MM_RO, /* read-only (no copy-out at unmap time) */<br>
&gt;&gt; + =A0 =A0ZS_MM_WO /* write-only (no copy-in at map time) */<br>
&gt;&gt; +};<br>
&gt;<br>
&gt;<br>
&gt; These makes no difference for PGTABLE_MAPPING.<br>
&gt; Please add some comment for this.<br>
<br>
</div></div>Yes. Will do.<br>
<div><div class=3D"h5"><br>
&gt;<br>
&gt;&gt; +struct zs_ops {<br>
&gt;&gt; + =A0 =A0struct page * (*alloc)(gfp_t);<br>
&gt;&gt; + =A0 =A0void (*free)(struct page *);<br>
&gt;&gt; +};<br>
&gt;&gt; +<br>
&gt;&gt; +struct zs_pool;<br>
&gt;&gt; +<br>
&gt;&gt; +struct zs_pool *zs_create_pool(gfp_t flags, struct zs_ops *ops);<=
br>
&gt;&gt; +void zs_destroy_pool(struct zs_pool *pool);<br>
&gt;&gt; +<br>
&gt;&gt; +unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t =
flags);<br>
&gt;&gt; +void zs_free(struct zs_pool *pool, unsigned long obj);<br>
&gt;&gt; +<br>
&gt;&gt; +void *zs_map_object(struct zs_pool *pool, unsigned long handle,<b=
r>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum zs_mapmode mm);<br>
&gt;&gt; +void zs_unmap_object(struct zs_pool *pool, unsigned long handle);=
<br>
&gt;&gt; +<br>
&gt;&gt; +u64 zs_get_total_size_bytes(struct zs_pool *pool);<br>
&gt;&gt; +<br>
&gt;&gt; +#endif<br>
&gt;&gt; diff --git a/mm/Kconfig b/mm/Kconfig<br>
&gt;&gt; index 278e3ab..25b8f38 100644<br>
&gt;&gt; --- a/mm/Kconfig<br>
&gt;&gt; +++ b/mm/Kconfig<br>
&gt;&gt; @@ -446,3 +446,27 @@ config FRONTSWAP<br>
&gt;&gt; =A0 =A0 =A0 =A0and swap data is stored as normal on the matching s=
wap device.<br>
&gt;&gt;<br>
&gt;&gt; =A0 =A0 =A0 =A0If unsure, say Y to enable frontswap.<br>
&gt;&gt; +<br>
&gt;&gt; +config ZSMALLOC<br>
&gt;&gt; + =A0 =A0tristate &quot;Memory allocator for compressed pages&quot=
;<br>
&gt;&gt; + =A0 =A0default n<br>
&gt;&gt; + =A0 =A0help<br>
&gt;&gt; + =A0 =A0 =A0zsmalloc is a slab-based memory allocator designed to=
 store<br>
&gt;&gt; + =A0 =A0 =A0compressed RAM pages. =A0zsmalloc uses virtual memory=
 mapping<br>
&gt;&gt; + =A0 =A0 =A0in order to reduce fragmentation. =A0However, this re=
sults in a<br>
&gt;&gt; + =A0 =A0 =A0non-standard allocator interface where a handle, not =
a pointer, is<br>
&gt;&gt; + =A0 =A0 =A0returned by an alloc(). =A0This handle must be mapped=
 in order to<br>
&gt;&gt; + =A0 =A0 =A0access the allocated space.<br>
&gt;&gt; +<br>
&gt;&gt; +config PGTABLE_MAPPING<br>
&gt;&gt; + =A0 =A0bool &quot;Use page table mapping to access object in zsm=
alloc&quot;<br>
&gt;&gt; + =A0 =A0depends on ZSMALLOC<br>
&gt;&gt; + =A0 =A0help<br>
&gt;&gt; + =A0 =A0 =A0By default, zsmalloc uses a copy-based object mapping=
 method to<br>
&gt;&gt; + =A0 =A0 =A0access allocations that span two pages. However, if a=
 particular<br>
&gt;&gt; + =A0 =A0 =A0architecture (ex, ARM) performs VM mapping faster tha=
n copying,<br>
&gt;&gt; + =A0 =A0 =A0then you should select this. This causes zsmalloc to =
use page table<br>
&gt;&gt; + =A0 =A0 =A0mapping rather than copying for object mapping.<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0 =A0You can check speed with zsmalloc benchmark[1].<br>
&gt;&gt; + =A0 =A0 =A0[1] <a href=3D"https://github.com/spartacus06/zsmallo=
c" target=3D"_blank">https://github.com/spartacus06/zsmalloc</a><br>
&gt;&gt; diff --git a/mm/Makefile b/mm/Makefile<br>
&gt;&gt; index 3a46287..0f6ef0a 100644<br>
&gt;&gt; --- a/mm/Makefile<br>
&gt;&gt; +++ b/mm/Makefile<br>
&gt;&gt; @@ -58,3 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) +=3D kmemleak.o<br>
&gt;&gt; =A0obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) +=3D kmemleak-test.o<br>
&gt;&gt; =A0obj-$(CONFIG_CLEANCACHE) +=3D cleancache.o<br>
&gt;&gt; =A0obj-$(CONFIG_MEMORY_ISOLATION) +=3D page_isolation.o<br>
&gt;&gt; +obj-$(CONFIG_ZSMALLOC) =A0 =A0 =A0+=3D zsmalloc.o<br>
&gt;&gt; diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c<br>
&gt;&gt; new file mode 100644<br>
&gt;&gt; index 0000000..34378ef<br>
&gt;&gt; --- /dev/null<br>
&gt;&gt; +++ b/mm/zsmalloc.c<br>
&gt;&gt; @@ -0,0 +1,1124 @@<br>
&gt;&gt; +/*<br>
&gt;&gt; + * zsmalloc memory allocator<br>
&gt;&gt; + *<br>
&gt;&gt; + * Copyright (C) 2011 =A0Nitin Gupta<br>
&gt;&gt; + *<br>
&gt;&gt; + * This code is released using a dual license strategy: BSD/GPL<b=
r>
&gt;&gt; + * You can choose the license that better fits your requirements.=
<br>
&gt;&gt; + *<br>
&gt;&gt; + * Released under the terms of 3-clause BSD License<br>
&gt;&gt; + * Released under the terms of GNU General Public License Version=
 2.0<br>
&gt;&gt; + */<br>
&gt;&gt; +<br>
&gt;&gt; +<br>
&gt;&gt; +/*<br>
&gt;&gt; + * This allocator is designed for use with zcache and zram. Thus,=
 the<br>
&gt;&gt; + * allocator is supposed to work well under low memory conditions=
. In<br>
&gt;&gt; + * particular, it never attempts higher order page allocation whi=
ch is<br>
&gt;&gt; + * very likely to fail under memory pressure. On the other hand, =
if we<br>
&gt;&gt; + * just use single (0-order) pages, it would suffer from very hig=
h<br>
&gt;&gt; + * fragmentation -- any object of size PAGE_SIZE/2 or larger woul=
d occupy<br>
&gt;&gt; + * an entire page. This was one of the major issues with its pred=
ecessor<br>
&gt;&gt; + * (xvmalloc).<br>
&gt;&gt; + *<br>
&gt;&gt; + * To overcome these issues, zsmalloc allocates a bunch of 0-orde=
r pages<br>
&gt;&gt; + * and links them together using various &#39;struct page&#39; fi=
elds. These linked<br>
&gt;&gt; + * pages act as a single higher-order page i.e. an object can spa=
n 0-order<br>
&gt;&gt; + * page boundaries. The code refers to these linked pages as a si=
ngle entity<br>
&gt;&gt; + * called zspage.<br>
&gt;&gt; + *<br>
&gt;&gt; + * For simplicity, zsmalloc can only allocate objects of size up =
to PAGE_SIZE<br>
&gt;&gt; + * since this satisfies the requirements of all its current users=
 (in the<br>
&gt;&gt; + * worst case, page is incompressible and is thus stored &quot;as=
-is&quot; i.e. in<br>
&gt;&gt; + * uncompressed form). For allocation requests larger than this s=
ize, failure<br>
&gt;&gt; + * is returned (see zs_malloc).<br>
&gt;&gt; + *<br>
&gt;&gt; + * Additionally, zs_malloc() does not return a dereferenceable po=
inter.<br>
&gt;&gt; + * Instead, it returns an opaque handle (unsigned long) which enc=
odes actual<br>
&gt;&gt; + * location of the allocated object. The reason for this indirect=
ion is that<br>
&gt;&gt; + * zsmalloc does not keep zspages permanently mapped since that w=
ould cause<br>
&gt;&gt; + * issues on 32-bit systems where the VA region for kernel space =
mappings<br>
&gt;&gt; + * is very small. So, before using the allocating memory, the obj=
ect has to<br>
&gt;&gt; + * be mapped using zs_map_object() to get a usable pointer and su=
bsequently<br>
&gt;&gt; + * unmapped using zs_unmap_object().<br>
&gt;&gt; + *<br>
&gt;&gt; + * Following is how we use various fields and flags of underlying=
<br>
&gt;&gt; + * struct page(s) to form a zspage.<br>
&gt;&gt; + *<br>
&gt;&gt; + * Usage of struct page fields:<br>
&gt;&gt; + * =A0page-&gt;first_page: points to the first component (0-order=
) page<br>
&gt;&gt; + * =A0page-&gt;index (union with page-&gt;freelist): offset of th=
e first object<br>
&gt;&gt; + * =A0 =A0 =A0 =A0 =A0starting in this page. For the first page, =
this is<br>
&gt;&gt; + * =A0 =A0 =A0 =A0 =A0always 0, so we use this field (aka freelis=
t) to point<br>
&gt;&gt; + * =A0 =A0 =A0 =A0 =A0to the first free object in zspage.<br>
&gt;&gt; + * =A0page-&gt;lru: links together all component pages (except th=
e first page)<br>
&gt;&gt; + * =A0 =A0 =A0 =A0 =A0of a zspage<br>
&gt;&gt; + *<br>
&gt;&gt; + * =A0For _first_ page only:<br>
&gt;&gt; + *<br>
&gt;&gt; + * =A0page-&gt;private (union with page-&gt;first_page): refers t=
o the<br>
&gt;&gt; + * =A0 =A0 =A0 =A0 =A0component page after the first page<br>
&gt;&gt; + * =A0page-&gt;freelist: points to the first free object in zspag=
e.<br>
&gt;&gt; + * =A0 =A0 =A0 =A0 =A0Free objects are linked together using in-p=
lace<br>
&gt;&gt; + * =A0 =A0 =A0 =A0 =A0metadata.<br>
&gt;&gt; + * =A0page-&gt;objects: maximum number of objects we can store in=
 this<br>
&gt;&gt; + * =A0 =A0 =A0 =A0 =A0zspage (class-&gt;zspage_order * PAGE_SIZE =
/ class-&gt;size)<br>
&gt;<br>
&gt; How about just embedding maximum number of objects to size_class?<br>
&gt; For the SLUB, each slab can have difference number of objects.<br>
&gt; But, for the zsmalloc, it is not possible, so there is no reason<br>
&gt; to maintain it within metadata of zspage. Just to embed it to size_cla=
ss<br>
&gt; is sufficient.<br>
<br>
</div></div>Yes, a little code massaging and this can go away.<br>
<br>
However, there might be some value in having variable sized zspages in<br>
the same size_class. =A0It could improve allocation success rate at the<br>
expense of efficiency by not failing in alloc_zspage() if we can&#39;t<br>
allocate the optimal number of pages. =A0As long as we can allocate the<br>
first page, then we can proceed.<br></blockquote><div><br></div><div style>=
<br></div><div style>Yes, I remember trying to allow partial failures and t=
hus allow variable</div><div style>sized zspages within the same size class=
 but I just skipped that since</div>
<div style>it seemed like non-trivial to do and the value wasn&#39;t clear:=
 if the</div><div style>system cannot give us 4 (non-contiguous) pages then=
 it&#39;s probably</div><div style>going to fail allocation requests for si=
ngle pages also in not so far</div>
<div style>future. Also, for objects &gt; PAGESIZE/2, failing over to zspag=
e</div><div style>of just PAGESIZE is not going to help either.</div><div s=
tyle>=A0<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .=
8ex;border-left:1px #ccc solid;padding-left:1ex">
=A0<br></blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div class=3D"im">
&gt;<br>
&gt;<br>
&gt;&gt; + * =A0page-&gt;lru: links together first pages of various zspages=
.<br>
&gt;&gt; + * =A0 =A0 =A0 =A0 =A0Basically forming list of zspages in a full=
ness group.<br>
&gt;&gt; + * =A0page-&gt;mapping: class index and fullness group of the zsp=
age<br>
&gt;&gt; + *<br>
&gt;&gt; + * Usage of struct page flags:<br>
&gt;&gt; + * =A0PG_private: identifies the first component page<br>
&gt;&gt; + * =A0PG_private2: identifies the last component page<br>
&gt;&gt; + *<br>
</div></blockquote><div style>&lt;snip&gt;</div><div>=A0</div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex"><div class=3D"im">&gt;&gt; + */<br>
<div class=3D"h5">
&gt;&gt; +struct size_class {<br>
&gt;&gt; + =A0 =A0/*<br>
&gt;&gt; + =A0 =A0 * Size of objects stored in this class. Must be multiple=
<br>
&gt;&gt; + =A0 =A0 * of ZS_ALIGN.<br>
&gt;&gt; + =A0 =A0 */<br>
&gt;&gt; + =A0 =A0int size;<br>
&gt;&gt; + =A0 =A0unsigned int index;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0/* Number of PAGE_SIZE sized pages to combine to form a &=
#39;zspage&#39; */<br>
&gt;&gt; + =A0 =A0int pages_per_zspage;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0spinlock_t lock;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0/* stats */<br>
&gt;&gt; + =A0 =A0u64 pages_allocated;<br>
&gt;&gt; +<br>
&gt;&gt; + =A0 =A0struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];<br>
&gt;&gt; +};<br>
&gt;<br>
&gt; Instead of simple pointer, how about using list_head?<br>
&gt; With this, fullness_list management is easily consolidated to<br>
&gt; set_zspage_mapping() and we can remove remove_zspage(), insert_zspage(=
).<br>
<br>
</div></div><br></blockquote><div><br></div><div>=A0<br></div><div>Yes, thi=
s looks like a nice cleanup.</div><div>Still, I would hold such changes til=
l we get out of staging.<br></div><div><br></div></div></div><div class=3D"=
gmail_extra">
<br></div><div class=3D"gmail_extra" style>Thanks for your comments, Kim.</=
div><div class=3D"gmail_extra" style><br></div><div class=3D"gmail_extra" s=
tyle><br></div><div class=3D"gmail_extra" style>Nitin</div><div class=3D"gm=
ail_extra" style>
<br></div></div>

--bcaec5524414fb029f04d61e4c20--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
