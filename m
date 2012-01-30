Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 8F4836B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 17:03:44 -0500 (EST)
MIME-Version: 1.0
Message-ID: <72823e35-1ecb-45ce-b9ca-4f6fb3cdaaa6@default>
Date: Mon, 30 Jan 2012 14:03:38 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
 <4F218D36.2060308@linux.vnet.ibm.com>
 <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
 <20120126163150.31a8688f.akpm@linux-foundation.org>
 <ccb76a4d-d453-4faa-93a9-d1ce015255c0@default>
 <20120126171548.2c85dd44.akpm@linux-foundation.org>
 <7198bfb3-1e32-40d3-8601-d88aed7aabd8@default> <4F221AFE.6070108@redhat.com>
 <22f6781b-9cc4-4857-b3e1-e2d9f595f64d@default>
 <20120130175730.de654d9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120130175730.de654d9c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, Chris Mason <chris.mason@oracle.com>

> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Subject: Re: [PATCH] mm: implement WasActive page flag (for improving cle=
ancache)
>=20
> On Thu, 26 Jan 2012 21:15:16 -0800 (PST)
> Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
>=20
> > > From: Rik van Riel [mailto:riel@redhat.com]
> > > Subject: Re: [PATCH] mm: implement WasActive page flag (for improving=
 cleancache)
> > >
> > > On 01/26/2012 09:43 PM, Dan Magenheimer wrote:
> > >
> > > > Maybe the Active page bit could be overloaded with some minor
> > > > rewriting?  IOW, perhaps the Active bit could be ignored when
> > > > the page is moved to the inactive LRU?  (Confusing I know, but I am
> > > > just brainstorming...)
> > >
> > > The PG_referenced bit is already overloaded.  We keep
> > > the bit set when we move a page from the active to the
> > > inactive list, so a page that was previously active
> > > only needs to be referenced once to become active again.
> > >
> > > The LRU bits (PG_lru, PG_active, etc) are needed to
> > > figure out which LRU list the page is on.  I don't
> > > think we can overload those...
> >
> > I suspected that was true, but was just brainstorming.
> > Thanks for confirming.
> >
> > Are there any other page bits that are dont-care when
> > a page is on an LRU list?
>=20
> How about replacing PG_slab ?
>=20
> I think  PageSlab(page) be implemented as
>=20
> #define SLABMAGIC=09=09(some value)
> #define PageSlab(page)=09=09(page->mapping =3D=3D SLABMAGIC)
>=20
> or some...

Hi Kame --

Sounds like a great idea!  It looks like the PG_slab bit is part
of the kernel<->user ABI (see fs/proc/page.c: stable_page_flags())
but I think it can be simulated without actually using the physical
bit in struct pageflags.  If so, PG_slab is completely free
to be used/overloaded!

Here's a possible patch... compile/boot tested but nothing else (and
memory-failure.c isn't even compiled and may need more work):

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index dee29fa..ef8498e 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -80,7 +80,7 @@ enum pageflags {
 =09PG_dirty,
 =09PG_lru,
 =09PG_active,
-=09PG_slab,
+=09PG_slab,=09=09/* for legacy kernel<->user ABI only */
 =09PG_owner_priv_1,=09/* Owner use. If pagecache, fs may use*/
 =09PG_arch_1,
 =09PG_reserved,
@@ -206,7 +206,6 @@ PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEAR=
PAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
 =09TESTCLEARFLAG(Active, active)
-__PAGEFLAG(Slab, slab)
 PAGEFLAG(Checked, checked)=09=09/* Used by some filesystems */
 PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned)=09/* Xen */
 PAGEFLAG(SavePinned, savepinned);=09=09=09/* Xen */
@@ -220,6 +219,28 @@ PAGEFLAG(WasActive, was_active)
 #endif
=20
 /*
+ * for legacy ABI purposes, PG_slab remains defined but all attempted
+ * uses of the bit are now simulated without using the actual page-flag bi=
t
+ */
+struct address_space;
+#define SLAB_MAGIC ((struct address_space *)0x80758075)
+static inline bool PageSlab(struct page *page)
+{
+=09return page->mapping =3D=3D SLAB_MAGIC;
+}
+
+static inline void __SetPageSlab(struct page *page)
+{
+=09page->mapping =3D SLAB_MAGIC;
+}
+
+static inline void __ClearPageSlab(struct page *page)
+{
+=09page->mapping =3D NULL;
+}
+
+
+/*
  * Private page markings that may be used by the filesystem that owns the =
page
  * for its own purposes.
  * - PG_private and PG_private_2 cause releasepage() and co to be invoked
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 06d3479..b4dde77 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -742,7 +742,6 @@ static int me_huge_page(struct page *p, unsigned long p=
fn)
 #define head=09=09(1UL << PG_head)
 #define tail=09=09(1UL << PG_tail)
 #define compound=09(1UL << PG_compound)
-#define slab=09=09(1UL << PG_slab)
 #define reserved=09(1UL << PG_reserved)
=20
 static struct page_state {
@@ -757,13 +756,6 @@ static struct page_state {
 =09 * PG_buddy pages only make a small fraction of all free pages.
 =09 */
=20
-=09/*
-=09 * Could in theory check if slab page is free or if we can drop
-=09 * currently unused objects without touching them. But just
-=09 * treat it as standard kernel for now.
-=09 */
-=09{ slab,=09=09slab,=09=09"kernel slab",=09me_kernel },
-
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
 =09{ head,=09=09head,=09=09"huge",=09=09me_huge_page },
 =09{ tail,=09=09tail,=09=09"huge",=09=09me_huge_page },
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b8ba3a..48451a5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5787,11 +5787,12 @@ static struct trace_print_flags pageflag_names[] =
=3D {
 =09{-1UL,=09=09=09=09NULL=09=09},
 };
=20
-static void dump_page_flags(unsigned long flags)
+static void dump_page_flags(struct page *page)
 {
 =09const char *delim =3D "";
 =09unsigned long mask;
 =09int i;
+=09unsigned long flags =3D page->flags;
=20
 =09printk(KERN_ALERT "page flags: %#lx(", flags);
=20
@@ -5801,7 +5802,10 @@ static void dump_page_flags(unsigned long flags)
 =09for (i =3D 0; pageflag_names[i].name && flags; i++) {
=20
 =09=09mask =3D pageflag_names[i].mask;
-=09=09if ((flags & mask) !=3D mask)
+=09=09if (mask =3D=3D PG_slab) {
+=09=09=09if (!PageSlab(page))
+=09=09=09=09continue;
+=09=09} else if ((flags & mask) !=3D mask)
 =09=09=09continue;
=20
 =09=09flags &=3D ~mask;
@@ -5822,6 +5826,6 @@ void dump_page(struct page *page)
 =09       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
 =09=09page, atomic_read(&page->_count), page_mapcount(page),
 =09=09page->mapping, page->index);
-=09dump_page_flags(page->flags);
+=09dump_page_flags(page);
 =09mem_cgroup_print_bad_page(page);
 }
diff --git a/mm/slub.c b/mm/slub.c
index ed3334d..a0fdca1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1361,7 +1361,7 @@ static struct page *new_slab(struct kmem_cache *s, gf=
p_t flags, int node)
=20
 =09inc_slabs_node(s, page_to_nid(page), page->objects);
 =09page->slab =3D s;
-=09page->flags |=3D 1 << PG_slab;
+=09page->mapping =3D SLAB_MAGIC;
=20
 =09start =3D page_address(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
