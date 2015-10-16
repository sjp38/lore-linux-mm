Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id E0D8182F66
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 18:12:35 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so101326661obb.2
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:12:35 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id ik2si11399798obc.15.2015.10.16.15.12.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 15:12:35 -0700 (PDT)
Received: by oiao187 with SMTP id o187so14731247oia.3
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:12:34 -0700 (PDT)
Date: Fri, 16 Oct 2015 15:12:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] memcg: simplify and inline __mem_cgroup_from_kmem
In-Reply-To: <20151016135106.GJ11309@esperanza>
Message-ID: <alpine.LSU.2.11.1510161458280.26747@eggly.anvils>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com> <517ab1701f4b53be8bfd6691a1499598efb358e7.1443996201.git.vdavydov@virtuozzo.com> <20151016131726.GA602@node.shutemov.name> <20151016135106.GJ11309@esperanza>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-3580019-1445033551=:26747"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-3580019-1445033551=:26747
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 16 Oct 2015, Vladimir Davydov wrote:
> On Fri, Oct 16, 2015 at 04:17:26PM +0300, Kirill A. Shutemov wrote:
> > On Mon, Oct 05, 2015 at 01:21:43AM +0300, Vladimir Davydov wrote:
> > > Before the previous patch, __mem_cgroup_from_kmem had to handle two
> > > types of kmem - slab pages and pages allocated with alloc_kmem_pages =
-
> > > differently, because slab pages did not store information about owner
> > > memcg in the page struct. Now we can unify it. Since after it, this
> > > function becomes tiny we can fold it into mem_cgroup_from_kmem.
> > >=20
> > > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> > > ---
> > >  include/linux/memcontrol.h |  7 ++++---
> > >  mm/memcontrol.c            | 18 ------------------
> > >  2 files changed, 4 insertions(+), 21 deletions(-)
> > >=20
> > > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > > index 8a9b7a798f14..0e2e039609d1 100644
> > > --- a/include/linux/memcontrol.h
> > > +++ b/include/linux/memcontrol.h
> > > @@ -769,8 +769,6 @@ static inline int memcg_cache_id(struct mem_cgrou=
p *memcg)
> > >  struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)=
;
> > >  void __memcg_kmem_put_cache(struct kmem_cache *cachep);
> > > =20
> > > -struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr);
> > > -
> > >  static inline bool __memcg_kmem_bypass(gfp_t gfp)
> > >  {
> > >  =09if (!memcg_kmem_enabled())
> > > @@ -832,9 +830,12 @@ static __always_inline void memcg_kmem_put_cache=
(struct kmem_cache *cachep)
> > > =20
> > >  static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void =
*ptr)
> > >  {
> > > +=09struct page *page;
> > > +
> > >  =09if (!memcg_kmem_enabled())
> > >  =09=09return NULL;
> > > -=09return __mem_cgroup_from_kmem(ptr);
> > > +=09page =3D virt_to_head_page(ptr);
> > > +=09return page->mem_cgroup;
> > >  }
> >=20
> > virt_to_head_page() is defined in <linux/mm.h> but you don't include it=
,
> > and the commit breaks build for me (on v4.3-rc5-mmotm-2015-10-15-15-20)=
=2E
> >=20
> >   CC      arch/x86/kernel/asm-offsets.s
> > In file included from /home/kas/linux/mm/include/linux/swap.h:8:0,
> >                  from /home/kas/linux/mm/include/linux/suspend.h:4,
> >                  from /home/kas/linux/mm/arch/x86/kernel/asm-offsets.c:=
12:
> > /home/kas/linux/mm/include/linux/memcontrol.h: In function =E2?~mem_cgr=
oup_from_kmem=E2?T:
> > /home/kas/linux/mm/include/linux/memcontrol.h:841:9: error: implicit de=
claration of function =E2?~virt_to_head_page=E2?T [-Werror=3Dimplicit-funct=
ion-declaration]
> >   page =3D virt_to_head_page(ptr);
> >          ^
> > /home/kas/linux/mm/include/linux/memcontrol.h:841:7: warning: assignmen=
t makes pointer from integer without a cast [-Wint-conversion]
> >   page =3D virt_to_head_page(ptr);
> >        ^
> > In file included from /home/kas/linux/mm/include/linux/suspend.h:8:0,
> >                  from /home/kas/linux/mm/arch/x86/kernel/asm-offsets.c:=
12:
> > /home/kas/linux/mm/include/linux/mm.h: At top level:
> > /home/kas/linux/mm/include/linux/mm.h:452:28: error: conflicting types =
for =E2?~virt_to_head_page=E2?T
> >  static inline struct page *virt_to_head_page(const void *x)
> >                             ^
> > In file included from /home/kas/linux/mm/include/linux/swap.h:8:0,
> >                  from /home/kas/linux/mm/include/linux/suspend.h:4,
> >                  from /home/kas/linux/mm/arch/x86/kernel/asm-offsets.c:=
12:
> > /home/kas/linux/mm/include/linux/memcontrol.h:841:9: note: previous imp=
licit declaration of =E2?~virt_to_head_page=E2?T was here
> >   page =3D virt_to_head_page(ptr);
> >          ^
> > cc1: some warnings being treated as errors
>=20
> Oops, in my config I have CONFIG_CGROUP_WRITEBACK enabled, which results
> in including mm.h to memcontrol.h indirectly:
>=20
>  linux/memcontrol.h
>   linux/writeback.h
>    linux/bio.h
>     linux/highmem.h
>      linux/mm.h
>=20
> That's why I didn't notice this. Sorry about that.
>=20
> >=20
> > The patch below fixes it for me (and for allmodconfig on x86-64), but I=
'm not
> > sure if it have any side effects on other configurations.
>=20
> It should work OK with any config, otherwise CONFIG_CGROUP_WRITEBACK
> would be broken too.
>=20
> Andrew, could you please merge the fix by Kirill into
> memcg-simplify-and-inline-__mem_cgroup_from_kmem.patch
>=20
> Thanks,
> Vladimir
>=20
> >=20
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 47677acb4516..e8e52e502c20 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -26,6 +26,7 @@
> >  #include <linux/page_counter.h>
> >  #include <linux/vmpressure.h>
> >  #include <linux/eventfd.h>
> > +#include <linux/mm.h>
> >  #include <linux/mmzone.h>
> >  #include <linux/writeback.h>
> > =20

Are you expecting to use mem_cgroup_from_kmem() from other places
in future?  Seems possible; but at present it's called from only
one place, and (given how memcontrol.h has somehow managed to avoid
including mm.h all these years), I thought it would be nice to avoid
it for just this; and fixed my build with the patch below last night.
Whatever you all think best: just wanted to point out an alternative.

Hugh

--- 4035m/include/linux/memcontrol.h=092015-10-15 15:26:59.503568644 -0700
+++ 4035M/include/linux/memcontrol.h=092015-10-16 03:09:10.000000000 -0700
@@ -831,16 +831,6 @@ static __always_inline void memcg_kmem_p
 =09if (memcg_kmem_enabled())
 =09=09__memcg_kmem_put_cache(cachep);
 }
-
-static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
-{
-=09struct page *page;
-
-=09if (!memcg_kmem_enabled())
-=09=09return NULL;
-=09page =3D virt_to_head_page(ptr);
-=09return page->mem_cgroup;
-}
 #else
 #define for_each_memcg_cache_index(_idx)=09\
 =09for (; NULL; )
@@ -886,11 +876,5 @@ memcg_kmem_get_cache(struct kmem_cache *
 static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 }
-
-static inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
-{
-=09return NULL;
-}
 #endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
-
--- 4035m/mm/list_lru.c=092015-10-15 15:26:59.835572128 -0700
+++ 4035M/mm/list_lru.c=092015-10-16 03:11:51.000000000 -0700
@@ -63,6 +63,16 @@ list_lru_from_memcg_idx(struct list_lru_
 =09return &nlru->lru;
 }
=20
+static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
+{
+=09struct page *page;
+
+=09if (!memcg_kmem_enabled())
+=09=09return NULL;
+=09page =3D virt_to_head_page(ptr);
+=09return page->mem_cgroup;
+}
+
 static inline struct list_lru_one *
 list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
 {
--0-3580019-1445033551=:26747--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
