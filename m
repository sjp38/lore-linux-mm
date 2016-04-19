Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 653446B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 02:14:32 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id th5so13039803obc.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 23:14:32 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id x7si2590296igg.75.2016.04.18.23.14.30
        for <linux-mm@kvack.org>;
        Mon, 18 Apr 2016 23:14:31 -0700 (PDT)
Date: Tue, 19 Apr 2016 15:15:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 13/16] zsmalloc: migrate head page of zspage
Message-ID: <20160419061529.GA12910@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-14-git-send-email-minchan@kernel.org>
 <5715CB70.70606@samsung.com>
MIME-Version: 1.0
In-Reply-To: <5715CB70.70606@samsung.com>
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, s.suk@samsung.com, sunae.seo@samsung.com

Hello Chulmin,

On Tue, Apr 19, 2016 at 03:08:48PM +0900, Chulmin Kim wrote:
> On 2016=EB=85=84 03=EC=9B=94 30=EC=9D=BC 16:12, Minchan Kim wrote:
> >This patch introduces run-time migration feature for zspage.
> >To begin with, it supports only head page migration for
> >easy review(later patches will support tail page migration).
> >
> >For migration, it supports three functions
> >
> >* zs=5Fpage=5Fisolate
> >
> >It isolates a zspage which includes a subpage VM want to migrate
> >from class so anyone cannot allocate new object from the zspage.
> >IOW, allocation freeze
> >
> >* zs=5Fpage=5Fmigrate
> >
> >First of all, it freezes zspage to prevent zspage destrunction
> >so anyone cannot free object. Then, It copies content from oldpage
> >to newpage and create new page-chain with new page.
> >If it was successful, drop the refcount of old page to free
> >and putback new zspage to right data structure of zsmalloc.
> >Lastly, unfreeze zspages so we allows object allocation/free
> >from now on.
> >
> >* zs=5Fpage=5Fputback
> >
> >It returns isolated zspage to right fullness=5Fgroup list
> >if it fails to migrate a page.
> >
> >NOTE: A hurdle to support migration is that destroying zspage
> >while migration is going on. Once a zspage is isolated,
> >anyone cannot allocate object from the zspage but can deallocate
> >object freely so a zspage could be destroyed until all of objects
> >in zspage are freezed to prevent deallocation. The problem is
> >large window betwwen zs=5Fpage=5Fisolate and freeze=5Fzspage
> >in zs=5Fpage=5Fmigrate so the zspage could be destroyed.
> >
> >A easy approach to solve the problem is that object freezing
> >in zs=5Fpage=5Fisolate but it has a drawback that any object cannot
> >be deallocated until migration fails after isolation. However,
> >There is large time gab between isolation and migration so
> >any object freeing in other CPU should spin by pin=5Ftag which
> >would cause big latency. So, this patch introduces lock=5Fzspage
> >which holds PG=5Flock of all pages in a zspage right before
> >freeing the zspage. VM migration locks the page, too right
> >before calling ->migratepage so such race doesn't exist any more.
> >
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> >---
> >  include/uapi/linux/magic.h |   1 +
> >  mm/zsmalloc.c              | 332 +++++++++++++++++++++++++++++++++++++=
++++++--
> >  2 files changed, 318 insertions(+), 15 deletions(-)
> >
> >diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
> >index e1fbe72c39c0..93b1affe4801 100644
> >--- a/include/uapi/linux/magic.h
> >+++ b/include/uapi/linux/magic.h
> >@@ -79,5 +79,6 @@
> >  #define NSFS=5FMAGIC		0x6e736673
> >  #define BPF=5FFS=5FMAGIC		0xcafe4a11
> >  #define BALLOON=5FKVM=5FMAGIC	0x13661366
> >+#define ZSMALLOC=5FMAGIC		0x58295829
> >
> >  #endif /* =5F=5FLINUX=5FMAGIC=5FH=5F=5F */
> >diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> >index ac8ca7b10720..f6c9138c3be0 100644
> >--- a/mm/zsmalloc.c
> >+++ b/mm/zsmalloc.c
> >@@ -56,6 +56,8 @@
> >  #include <linux/debugfs.h>
> >  #include <linux/zsmalloc.h>
> >  #include <linux/zpool.h>
> >+#include <linux/mount.h>
> >+#include <linux/migrate.h>
> >
> >  /*
> >   * This must be power of 2 and greater than of equal to sizeof(link=5F=
free).
> >@@ -182,6 +184,8 @@ struct zs=5Fsize=5Fstat {
> >  static struct dentry *zs=5Fstat=5Froot;
> >  #endif
> >
> >+static struct vfsmount *zsmalloc=5Fmnt;
> >+
> >  /*
> >   * number of size=5Fclasses
> >   */
> >@@ -263,6 +267,7 @@ struct zs=5Fpool {
> >  #ifdef CONFIG=5FZSMALLOC=5FSTAT
> >  	struct dentry *stat=5Fdentry;
> >  #endif
> >+	struct inode *inode;
> >  };
> >
> >  struct zs=5Fmeta {
> >@@ -412,6 +417,29 @@ static int is=5Flast=5Fpage(struct page *page)
> >  	return PagePrivate2(page);
> >  }
> >
> >+/*
> >+ * Indicate that whether zspage is isolated for page migration.
> >+ * Protected by size=5Fclass lock
> >+ */
> >+static void SetZsPageIsolate(struct page *first=5Fpage)
> >+{
> >+	VM=5FBUG=5FON=5FPAGE(!is=5Ffirst=5Fpage(first=5Fpage), first=5Fpage);
> >+	SetPageUptodate(first=5Fpage);
> >+}
> >+
> >+static int ZsPageIsolate(struct page *first=5Fpage)
> >+{
> >+	VM=5FBUG=5FON=5FPAGE(!is=5Ffirst=5Fpage(first=5Fpage), first=5Fpage);
> >+
> >+	return PageUptodate(first=5Fpage);
> >+}
> >+
> >+static void ClearZsPageIsolate(struct page *first=5Fpage)
> >+{
> >+	VM=5FBUG=5FON=5FPAGE(!is=5Ffirst=5Fpage(first=5Fpage), first=5Fpage);
> >+	ClearPageUptodate(first=5Fpage);
> >+}
> >+
> >  static int get=5Fzspage=5Finuse(struct page *first=5Fpage)
> >  {
> >  	struct zs=5Fmeta *m;
> >@@ -783,8 +811,11 @@ static enum fullness=5Fgroup fix=5Ffullness=5Fgroup=
(struct size=5Fclass *class,
> >  	if (newfg =3D=3D currfg)
> >  		goto out;
> >
> >-	remove=5Fzspage(class, currfg, first=5Fpage);
> >-	insert=5Fzspage(class, newfg, first=5Fpage);
> >+	/* Later, putback will insert page to right list */
> >+	if (!ZsPageIsolate(first=5Fpage)) {
> >+		remove=5Fzspage(class, currfg, first=5Fpage);
> >+		insert=5Fzspage(class, newfg, first=5Fpage);
> >+	}
> >  	set=5Fzspage=5Fmapping(first=5Fpage, class=5Fidx, newfg);
> >
> >  out:
> >@@ -950,12 +981,31 @@ static void unpin=5Ftag(unsigned long handle)
> >
> >  static void reset=5Fpage(struct page *page)
> >  {
> >+	if (!PageIsolated(page))
> >+		=5F=5FClearPageMovable(page);
> >+	ClearPageIsolated(page);
> >  	clear=5Fbit(PG=5Fprivate, &page->flags);
> >  	clear=5Fbit(PG=5Fprivate=5F2, &page->flags);
> >  	set=5Fpage=5Fprivate(page, 0);
> >  	page->freelist =3D NULL;
> >  }
> >
> >+/**
> >+ * lock=5Fzspage - lock all pages in the zspage
> >+ * @first=5Fpage: head page of the zspage
> >+ *
> >+ * To prevent destroy during migration, zspage freeing should
> >+ * hold locks of all pages in a zspage
> >+ */
> >+void lock=5Fzspage(struct page *first=5Fpage)
> >+{
> >+	struct page *cursor =3D first=5Fpage;
> >+
> >+	do {
> >+		while (!trylock=5Fpage(cursor));
> >+	} while ((cursor =3D get=5Fnext=5Fpage(cursor)) !=3D NULL);
> >+}
> >+
> >  static void free=5Fzspage(struct zs=5Fpool *pool, struct page *first=
=5Fpage)
> >  {
> >  	struct page *nextp, *tmp, *head=5Fextra;
> >@@ -963,26 +1013,31 @@ static void free=5Fzspage(struct zs=5Fpool *pool,=
 struct page *first=5Fpage)
> >  	VM=5FBUG=5FON=5FPAGE(!is=5Ffirst=5Fpage(first=5Fpage), first=5Fpage);
> >  	VM=5FBUG=5FON=5FPAGE(get=5Fzspage=5Finuse(first=5Fpage), first=5Fpage=
);
> >
> >+	lock=5Fzspage(first=5Fpage);
> >  	head=5Fextra =3D (struct page *)page=5Fprivate(first=5Fpage);
> >
> >-	reset=5Fpage(first=5Fpage);
> >-	=5F=5Ffree=5Fpage(first=5Fpage);
> >-
> >  	/* zspage with only 1 system page */
> >  	if (!head=5Fextra)
> >-		return;
> >+		goto out;
> >
> >  	list=5Ffor=5Feach=5Fentry=5Fsafe(nextp, tmp, &head=5Fextra->lru, lru)=
 {
> >  		list=5Fdel(&nextp->lru);
> >  		reset=5Fpage(nextp);
> >-		=5F=5Ffree=5Fpage(nextp);
> >+		unlock=5Fpage(nextp);
> >+		put=5Fpage(nextp);
> >  	}
> >  	reset=5Fpage(head=5Fextra);
> >-	=5F=5Ffree=5Fpage(head=5Fextra);
> >+	unlock=5Fpage(head=5Fextra);
> >+	put=5Fpage(head=5Fextra);
> >+out:
> >+	reset=5Fpage(first=5Fpage);
> >+	unlock=5Fpage(first=5Fpage);
> >+	put=5Fpage(first=5Fpage);
> >  }
> >
> >  /* Initialize a newly allocated zspage */
> >-static void init=5Fzspage(struct size=5Fclass *class, struct page *firs=
t=5Fpage)
> >+static void init=5Fzspage(struct size=5Fclass *class, struct page *firs=
t=5Fpage,
> >+			struct address=5Fspace *mapping)
> >  {
> >  	int freeobj =3D 1;
> >  	unsigned long off =3D 0;
> >@@ -991,6 +1046,9 @@ static void init=5Fzspage(struct size=5Fclass *clas=
s, struct page *first=5Fpage)
> >  	first=5Fpage->freelist =3D NULL;
> >  	INIT=5FLIST=5FHEAD(&first=5Fpage->lru);
> >  	set=5Fzspage=5Finuse(first=5Fpage, 0);
> >+	BUG=5FON(!trylock=5Fpage(first=5Fpage));
> >+	=5F=5FSetPageMovable(first=5Fpage, mapping);
> >+	unlock=5Fpage(first=5Fpage);
> >
> >  	while (page) {
> >  		struct page *next=5Fpage;
> >@@ -1065,10 +1123,45 @@ static void create=5Fpage=5Fchain(struct page *p=
ages[], int nr=5Fpages)
> >  	}
> >  }
> >
> >+static void replace=5Fsub=5Fpage(struct size=5Fclass *class, struct pag=
e *first=5Fpage,
> >+		struct page *newpage, struct page *oldpage)
> >+{
> >+	struct page *page;
> >+	struct page *pages[ZS=5FMAX=5FPAGES=5FPER=5FZSPAGE] =3D {NULL,};
> >+	int idx =3D 0;
> >+
> >+	page =3D first=5Fpage;
> >+	do {
> >+		if (page =3D=3D oldpage)
> >+			pages[idx] =3D newpage;
> >+		else
> >+			pages[idx] =3D page;
> >+		idx++;
> >+	} while ((page =3D get=5Fnext=5Fpage(page)) !=3D NULL);
> >+
> >+	create=5Fpage=5Fchain(pages, class->pages=5Fper=5Fzspage);
> >+
> >+	if (is=5Ffirst=5Fpage(oldpage)) {
> >+		enum fullness=5Fgroup fg;
> >+		int class=5Fidx;
> >+
> >+		SetZsPageIsolate(newpage);
> >+		get=5Fzspage=5Fmapping(oldpage, &class=5Fidx, &fg);
> >+		set=5Fzspage=5Fmapping(newpage, class=5Fidx, fg);
> >+		set=5Ffreeobj(newpage, get=5Ffreeobj(oldpage));
> >+		set=5Fzspage=5Finuse(newpage, get=5Fzspage=5Finuse(oldpage));
> >+		if (class->huge)
> >+			set=5Fpage=5Fprivate(newpage,  page=5Fprivate(oldpage));
> >+	}
> >+
> >+	=5F=5FSetPageMovable(newpage, oldpage->mapping);
> >+}
> >+
> >  /*
> >   * Allocate a zspage for the given size class
> >   */
> >-static struct page *alloc=5Fzspage(struct size=5Fclass *class, gfp=5Ft =
flags)
> >+static struct page *alloc=5Fzspage(struct zs=5Fpool *pool,
> >+				struct size=5Fclass *class)
> >  {
> >  	int i;
> >  	struct page *first=5Fpage =3D NULL;
> >@@ -1088,7 +1181,7 @@ static struct page *alloc=5Fzspage(struct size=5Fc=
lass *class, gfp=5Ft flags)
> >  	for (i =3D 0; i < class->pages=5Fper=5Fzspage; i++) {
> >  		struct page *page;
> >
> >-		page =3D alloc=5Fpage(flags);
> >+		page =3D alloc=5Fpage(pool->flags);
> >  		if (!page) {
> >  			while (--i >=3D 0)
> >  				=5F=5Ffree=5Fpage(pages[i]);
> >@@ -1100,7 +1193,7 @@ static struct page *alloc=5Fzspage(struct size=5Fc=
lass *class, gfp=5Ft flags)
> >
> >  	create=5Fpage=5Fchain(pages, class->pages=5Fper=5Fzspage);
> >  	first=5Fpage =3D pages[0];
> >-	init=5Fzspage(class, first=5Fpage);
> >+	init=5Fzspage(class, first=5Fpage, pool->inode->i=5Fmapping);
> >
> >  	return first=5Fpage;
> >  }
> >@@ -1499,7 +1592,7 @@ unsigned long zs=5Fmalloc(struct zs=5Fpool *pool, =
size=5Ft size)
> >
> >  	if (!first=5Fpage) {
> >  		spin=5Funlock(&class->lock);
> >-		first=5Fpage =3D alloc=5Fzspage(class, pool->flags);
> >+		first=5Fpage =3D alloc=5Fzspage(pool, class);
> >  		if (unlikely(!first=5Fpage)) {
> >  			free=5Fhandle(pool, handle);
> >  			return 0;
> >@@ -1559,6 +1652,7 @@ void zs=5Ffree(struct zs=5Fpool *pool, unsigned lo=
ng handle)
> >  	if (unlikely(!handle))
> >  		return;
> >
> >+	/* Once handle is pinned, page|object migration cannot work */
> >  	pin=5Ftag(handle);
> >  	obj =3D handle=5Fto=5Fobj(handle);
> >  	obj=5Fto=5Flocation(obj, &f=5Fpage, &f=5Fobjidx);
> >@@ -1714,6 +1808,9 @@ static enum fullness=5Fgroup putback=5Fzspage(stru=
ct size=5Fclass *class,
> >  {
> >  	enum fullness=5Fgroup fullness;
> >
> >+	VM=5FBUG=5FON=5FPAGE(!list=5Fempty(&first=5Fpage->lru), first=5Fpage);
> >+	VM=5FBUG=5FON=5FPAGE(ZsPageIsolate(first=5Fpage), first=5Fpage);
> >+
> >  	fullness =3D get=5Ffullness=5Fgroup(class, first=5Fpage);
> >  	insert=5Fzspage(class, fullness, first=5Fpage);
> >  	set=5Fzspage=5Fmapping(first=5Fpage, class->index, fullness);
> >@@ -2059,6 +2156,173 @@ static int zs=5Fregister=5Fshrinker(struct zs=5F=
pool *pool)
> >  	return register=5Fshrinker(&pool->shrinker);
> >  }
> >
> >+bool zs=5Fpage=5Fisolate(struct page *page, isolate=5Fmode=5Ft mode)
> >+{
> >+	struct zs=5Fpool *pool;
> >+	struct size=5Fclass *class;
> >+	int class=5Fidx;
> >+	enum fullness=5Fgroup fullness;
> >+	struct page *first=5Fpage;
> >+
> >+	/*
> >+	 * The page is locked so it couldn't be destroyed.
> >+	 * For detail, look at lock=5Fzspage in free=5Fzspage.
> >+	 */
> >+	VM=5FBUG=5FON=5FPAGE(!PageLocked(page), page);
> >+	VM=5FBUG=5FON=5FPAGE(PageIsolated(page), page);
> >+	/*
> >+	 * In this implementation, it allows only first page migration.
> >+	 */
> >+	VM=5FBUG=5FON=5FPAGE(!is=5Ffirst=5Fpage(page), page);
> >+	first=5Fpage =3D page;
> >+
> >+	/*
> >+	 * Without class lock, fullness is meaningless while constant
> >+	 * class=5Fidx is okay. We will get it under class lock at below,
> >+	 * again.
> >+	 */
> >+	get=5Fzspage=5Fmapping(first=5Fpage, &class=5Fidx, &fullness);
> >+	pool =3D page->mapping->private=5Fdata;
> >+	class =3D pool->size=5Fclass[class=5Fidx];
> >+
> >+	if (!spin=5Ftrylock(&class->lock))
> >+		return false;
> >+
> >+	get=5Fzspage=5Fmapping(first=5Fpage, &class=5Fidx, &fullness);
> >+	remove=5Fzspage(class, fullness, first=5Fpage);
> >+	SetZsPageIsolate(first=5Fpage);
> >+	SetPageIsolated(page);
> >+	spin=5Funlock(&class->lock);
> >+
> >+	return true;
> >+}
>=20
> Hello, Minchan.
>=20
> We found another race condition.
>=20
> When there is alloc=5Fzspage(), which is not protected by any lock, in-fl=
ight,
> a migrate context can isolate the zs subpage which is being
> initiated by alloc=5Fzspage().
>=20
> We detected VM=5FBUG=5FON during remove=5Fzspage() above in consequence of
> "page->index" being set to NULL wrongly. (seems uninitialized yet)
>=20
> Though it is a real problem,
> as this race issue is somewhat similar with the one we detected last time,
> this seems to be fixed in the next version hopefully.
>=20
> I report this just for note.


I found problem you reported and already fixed it in my WIP version.
With your report, I am convinced my analysis was right, too. :)

Thanks for the analysis and reporting.
I really apprecaite your help, Chulmin!
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
