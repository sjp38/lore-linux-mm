Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 4120B6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 10:22:19 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so5791090qcs.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 07:22:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120518161927.549888128@linux.com>
References: <20120518161906.207356777@linux.com>
	<20120518161927.549888128@linux.com>
Date: Tue, 22 May 2012 23:22:18 +0900
Message-ID: <CAAmzW4O2zk5K3StnGXcQmvDqfSDQbmezoVLYsH-3s4mE9WaEBA@mail.gmail.com>
Subject: Re: [RFC] Common code 01/12] [slob] define page struct fields used in mm_types.h
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

2012/5/19 Christoph Lameter <cl@linux.com>:

> -/*
> =A0* free_slob_page: call before a slob_page is returned to the page allo=
cator.
> =A0*/
> -static inline void free_slob_page(struct slob_page *sp)
> +static inline void free_slob_page(struct page *sp)
> =A0{
> - =A0 =A0 =A0 reset_page_mapcount(&sp->page);
> - =A0 =A0 =A0 sp->page.mapping =3D NULL;
> + =A0 =A0 =A0 reset_page_mapcount(sp);
> + =A0 =A0 =A0 sp->mapping =3D NULL;
> =A0}

Currently, sp->mapping =3D NULL is useless, because Slob doesn't touch
this field anymore.

> =A0/*
> @@ -133,44 +112,44 @@ static LIST_HEAD(free_slob_large);
> =A0/*
> =A0* is_slob_page: True for all slob pages (false for bigblock pages)
> =A0*/
> -static inline int is_slob_page(struct slob_page *sp)
> +static inline int is_slob_page(struct page *sp)
> =A0{
> - =A0 =A0 =A0 return PageSlab((struct page *)sp);
> + =A0 =A0 =A0 return PageSlab(sp);
> =A0}
>
> -static inline void set_slob_page(struct slob_page *sp)
> +static inline void set_slob_page(struct page *sp)
> =A0{
> - =A0 =A0 =A0 __SetPageSlab((struct page *)sp);
> + =A0 =A0 =A0 __SetPageSlab(sp);
> =A0}
>
> -static inline void clear_slob_page(struct slob_page *sp)
> +static inline void clear_slob_page(struct page *sp)
> =A0{
> - =A0 =A0 =A0 __ClearPageSlab((struct page *)sp);
> + =A0 =A0 =A0 __ClearPageSlab(sp);
> =A0}

Now, type casting is useless, so using __SetPageSlab() is possible.
If we use __SetPageSlab() directly, we lose some readability.
Which one is preferable?

> -static inline struct slob_page *slob_page(const void *addr)
> +static inline struct page *slob_page(const void *addr)
> =A0{
> - =A0 =A0 =A0 return (struct slob_page *)virt_to_page(addr);
> + =A0 =A0 =A0 return virt_to_page(addr);
> =A0}

It is redundant, just using virt_to_page(addr) directly is more preferable

> =A0/*
> =A0* slob_page_free: true for pages on free_slob_pages list.
> =A0*/
> -static inline int slob_page_free(struct slob_page *sp)
> +static inline int slob_page_free(struct page *sp)
> =A0{
> - =A0 =A0 =A0 return PageSlobFree((struct page *)sp);
> + =A0 =A0 =A0 return PageSlobFree(sp);
> =A0}
>
> -static void set_slob_page_free(struct slob_page *sp, struct list_head *l=
ist)
> +static void set_slob_page_free(struct page *sp, struct list_head *list)
> =A0{
> =A0 =A0 =A0 =A0list_add(&sp->list, list);
> - =A0 =A0 =A0 __SetPageSlobFree((struct page *)sp);
> + =A0 =A0 =A0 __SetPageSlobFree(sp);
> =A0}
>
> -static inline void clear_slob_page_free(struct slob_page *sp)
> +static inline void clear_slob_page_free(struct page *sp)
> =A0{
> =A0 =A0 =A0 =A0list_del(&sp->list);
> - =A0 =A0 =A0 __ClearPageSlobFree((struct page *)sp);
> + =A0 =A0 =A0 __ClearPageSlobFree(sp);
> =A0}

I think we shouldn't use __ClearPageSlobFree anymore.
Before this patch, list_del affect page->private,
so when we manipulate slob list,
using PageSlobFree overloaded with PagePrivate is reasonable.
But, after this patch is applied, list_del doesn't touch page->private,
so manipulate PageSlobFree is not reasonable.
We would use another method for checking slob_page_free without
PageSlobFree flag.

> Index: linux-2.6/include/linux/mm_types.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/include/linux/mm_types.h =A0 =A0 2012-05-16 04:38:50.1=
31864458 -0500
> +++ linux-2.6/include/linux/mm_types.h =A02012-05-17 03:28:03.630162187 -=
0500
> @@ -52,7 +52,7 @@ struct page {
> =A0 =A0 =A0 =A0struct {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0union {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgoff_t index; =A0 =A0 =A0=
 =A0 =A0/* Our offset within mapping. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *freelist; =A0 =A0 =A0=
 =A0 /* slub first free object */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *freelist; =A0 =A0 =A0=
 =A0 /* slub/slob first free object */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0union {
> @@ -80,11 +80,12 @@ struct page {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0atomic_t _mapcount;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct { /* SLUB */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0unsigned inuse:16;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0unsigned objects:15;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0unsigned frozen:1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0};
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int units; =A0 =A0 =A0/* SLOB */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_t _=
count; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Usage count, see below. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> @@ -96,6 +97,7 @@ struct page {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct list_head lru; =A0 /* Pageout list,=
 eg. active_list
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 * protected by zone->lru_lock !
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head list; =A0/* slobs list of =
pages */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*=
 slub per cpu partial pages */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *next; =A0 =A0=
 =A0/* Next partial slab */
> =A0#ifdef CONFIG_64BIT
>

When we define field in mm_types.h for slauob,
sorted order between these is good for readability.
For example, in case of lru, list for slob is first,
but in case of _mapcount, field for slub is first.
Consistent ordering is more preferable I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
