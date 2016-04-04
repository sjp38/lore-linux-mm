Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 030406B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 05:01:10 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id gy3so8903531igb.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 02:01:09 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c16si7124278igo.104.2016.04.04.02.01.08
        for <linux-mm@kvack.org>;
        Mon, 04 Apr 2016 02:01:09 -0700 (PDT)
Date: Mon, 4 Apr 2016 18:01:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 12/16] zsmalloc: zs_compact refactoring
Message-ID: <20160404090114.GA12898@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-13-git-send-email-minchan@kernel.org>
 <57022000.9030705@samsung.com>
MIME-Version: 1.0
In-Reply-To: <57022000.9030705@samsung.com>
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Chulmin,

On Mon, Apr 04, 2016 at 05:04:16PM +0900, Chulmin Kim wrote:
> On 2016=EB=85=84 03=EC=9B=94 30=EC=9D=BC 16:12, Minchan Kim wrote:
> >Currently, we rely on class->lock to prevent zspage destruction.
> >It was okay until now because the critical section is short but
> >with run-time migration, it could be long so class->lock is not
> >a good apporach any more.
> >
> >So, this patch introduces [un]freeze=5Fzspage functions which
> >freeze allocated objects in the zspage with pinning tag so
> >user cannot free using object. With those functions, this patch
> >redesign compaction.
> >
> >Those functions will be used for implementing zspage runtime
> >migrations, too.
> >
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> >---
> >  mm/zsmalloc.c | 393 ++++++++++++++++++++++++++++++++++++++------------=
--------
> >  1 file changed, 257 insertions(+), 136 deletions(-)
> >
> >diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> >index b11dcd718502..ac8ca7b10720 100644
> >--- a/mm/zsmalloc.c
> >+++ b/mm/zsmalloc.c
> >@@ -922,6 +922,13 @@ static unsigned long obj=5Fto=5Fhead(struct size=5F=
class *class, struct page *page,
> >  		return *(unsigned long *)obj;
> >  }
> >
> >+static inline int testpin=5Ftag(unsigned long handle)
> >+{
> >+	unsigned long *ptr =3D (unsigned long *)handle;
> >+
> >+	return test=5Fbit(HANDLE=5FPIN=5FBIT, ptr);
> >+}
> >+
> >  static inline int trypin=5Ftag(unsigned long handle)
> >  {
> >  	unsigned long *ptr =3D (unsigned long *)handle;
> >@@ -949,8 +956,7 @@ static void reset=5Fpage(struct page *page)
> >  	page->freelist =3D NULL;
> >  }
> >
> >-static void free=5Fzspage(struct zs=5Fpool *pool, struct size=5Fclass *=
class,
> >-			struct page *first=5Fpage)
> >+static void free=5Fzspage(struct zs=5Fpool *pool, struct page *first=5F=
page)
> >  {
> >  	struct page *nextp, *tmp, *head=5Fextra;
> >
> >@@ -973,11 +979,6 @@ static void free=5Fzspage(struct zs=5Fpool *pool, s=
truct size=5Fclass *class,
> >  	}
> >  	reset=5Fpage(head=5Fextra);
> >  	=5F=5Ffree=5Fpage(head=5Fextra);
> >-
> >-	zs=5Fstat=5Fdec(class, OBJ=5FALLOCATED, get=5Fmaxobj=5Fper=5Fzspage(
> >-			class->size, class->pages=5Fper=5Fzspage));
> >-	atomic=5Flong=5Fsub(class->pages=5Fper=5Fzspage,
> >-				&pool->pages=5Fallocated);
> >  }
> >
> >  /* Initialize a newly allocated zspage */
> >@@ -1325,6 +1326,11 @@ static bool zspage=5Ffull(struct size=5Fclass *cl=
ass, struct page *first=5Fpage)
> >  	return get=5Fzspage=5Finuse(first=5Fpage) =3D=3D class->objs=5Fper=5F=
zspage;
> >  }
> >
> >+static bool zspage=5Fempty(struct size=5Fclass *class, struct page *fir=
st=5Fpage)
> >+{
> >+	return get=5Fzspage=5Finuse(first=5Fpage) =3D=3D 0;
> >+}
> >+
> >  unsigned long zs=5Fget=5Ftotal=5Fpages(struct zs=5Fpool *pool)
> >  {
> >  	return atomic=5Flong=5Fread(&pool->pages=5Fallocated);
> >@@ -1455,7 +1461,6 @@ static unsigned long obj=5Fmalloc(struct size=5Fcl=
ass *class,
> >  		set=5Fpage=5Fprivate(first=5Fpage, handle | OBJ=5FALLOCATED=5FTAG);
> >  	kunmap=5Fatomic(vaddr);
> >  	mod=5Fzspage=5Finuse(first=5Fpage, 1);
> >-	zs=5Fstat=5Finc(class, OBJ=5FUSED, 1);
> >
> >  	obj =3D location=5Fto=5Fobj(m=5Fpage, obj);
> >
> >@@ -1510,6 +1515,7 @@ unsigned long zs=5Fmalloc(struct zs=5Fpool *pool, =
size=5Ft size)
> >  	}
> >
> >  	obj =3D obj=5Fmalloc(class, first=5Fpage, handle);
> >+	zs=5Fstat=5Finc(class, OBJ=5FUSED, 1);
> >  	/* Now move the zspage to another fullness group, if required */
> >  	fix=5Ffullness=5Fgroup(class, first=5Fpage);
> >  	record=5Fobj(handle, obj);
> >@@ -1540,7 +1546,6 @@ static void obj=5Ffree(struct size=5Fclass *class,=
 unsigned long obj)
> >  	kunmap=5Fatomic(vaddr);
> >  	set=5Ffreeobj(first=5Fpage, f=5Fobjidx);
> >  	mod=5Fzspage=5Finuse(first=5Fpage, -1);
> >-	zs=5Fstat=5Fdec(class, OBJ=5FUSED, 1);
> >  }
> >
> >  void zs=5Ffree(struct zs=5Fpool *pool, unsigned long handle)
> >@@ -1564,10 +1569,19 @@ void zs=5Ffree(struct zs=5Fpool *pool, unsigned =
long handle)
> >
> >  	spin=5Flock(&class->lock);
> >  	obj=5Ffree(class, obj);
> >+	zs=5Fstat=5Fdec(class, OBJ=5FUSED, 1);
> >  	fullness =3D fix=5Ffullness=5Fgroup(class, first=5Fpage);
> >-	if (fullness =3D=3D ZS=5FEMPTY)
> >-		free=5Fzspage(pool, class, first=5Fpage);
> >+	if (fullness =3D=3D ZS=5FEMPTY) {
> >+		zs=5Fstat=5Fdec(class, OBJ=5FALLOCATED, get=5Fmaxobj=5Fper=5Fzspage(
> >+				class->size, class->pages=5Fper=5Fzspage));
> >+		spin=5Funlock(&class->lock);
> >+		atomic=5Flong=5Fsub(class->pages=5Fper=5Fzspage,
> >+					&pool->pages=5Fallocated);
> >+		free=5Fzspage(pool, first=5Fpage);
> >+		goto out;
> >+	}
> >  	spin=5Funlock(&class->lock);
> >+out:
> >  	unpin=5Ftag(handle);
> >
> >  	free=5Fhandle(pool, handle);
> >@@ -1637,127 +1651,66 @@ static void zs=5Fobject=5Fcopy(struct size=5Fcl=
ass *class, unsigned long dst,
> >  	kunmap=5Fatomic(s=5Faddr);
> >  }
> >
> >-/*
> >- * Find alloced object in zspage from index object and
> >- * return handle.
> >- */
> >-static unsigned long find=5Falloced=5Fobj(struct size=5Fclass *class,
> >-					struct page *page, int index)
> >+static unsigned long handle=5Ffrom=5Fobj(struct size=5Fclass *class,
> >+				struct page *first=5Fpage, int obj=5Fidx)
> >  {
> >-	unsigned long head;
> >-	int offset =3D 0;
> >-	unsigned long handle =3D 0;
> >-	void *addr =3D kmap=5Fatomic(page);
> >-
> >-	if (!is=5Ffirst=5Fpage(page))
> >-		offset =3D page->index;
> >-	offset +=3D class->size * index;
> >-
> >-	while (offset < PAGE=5FSIZE) {
> >-		head =3D obj=5Fto=5Fhead(class, page, addr + offset);
> >-		if (head & OBJ=5FALLOCATED=5FTAG) {
> >-			handle =3D head & ~OBJ=5FALLOCATED=5FTAG;
> >-			if (trypin=5Ftag(handle))
> >-				break;
> >-			handle =3D 0;
> >-		}
> >+	struct page *page;
> >+	unsigned long offset=5Fin=5Fpage;
> >+	void *addr;
> >+	unsigned long head, handle =3D 0;
> >
> >-		offset +=3D class->size;
> >-		index++;
> >-	}
> >+	objidx=5Fto=5Fpage=5Fand=5Foffset(class, first=5Fpage, obj=5Fidx,
> >+			&page, &offset=5Fin=5Fpage);
> >
> >+	addr =3D kmap=5Fatomic(page);
> >+	head =3D obj=5Fto=5Fhead(class, page, addr + offset=5Fin=5Fpage);
> >+	if (head & OBJ=5FALLOCATED=5FTAG)
> >+		handle =3D head & ~OBJ=5FALLOCATED=5FTAG;
> >  	kunmap=5Fatomic(addr);
> >+
> >  	return handle;
> >  }
> >
> >-struct zs=5Fcompact=5Fcontrol {
> >-	/* Source page for migration which could be a subpage of zspage. */
> >-	struct page *s=5Fpage;
> >-	/* Destination page for migration which should be a first page
> >-	 * of zspage. */
> >-	struct page *d=5Fpage;
> >-	 /* Starting object index within @s=5Fpage which used for live object
> >-	  * in the subpage. */
> >-	int index;
> >-};
> >-
> >-static int migrate=5Fzspage(struct zs=5Fpool *pool, struct size=5Fclass=
 *class,
> >-				struct zs=5Fcompact=5Fcontrol *cc)
> >+static int migrate=5Fzspage(struct size=5Fclass *class, struct page *ds=
t=5Fpage,
> >+				struct page *src=5Fpage)
> >  {
> >-	unsigned long used=5Fobj, free=5Fobj;
> >  	unsigned long handle;
> >-	struct page *s=5Fpage =3D cc->s=5Fpage;
> >-	struct page *d=5Fpage =3D cc->d=5Fpage;
> >-	unsigned long index =3D cc->index;
> >-	int ret =3D 0;
> >+	unsigned long old=5Fobj, new=5Fobj;
> >+	int i;
> >+	int nr=5Fmigrated =3D 0;
> >
> >-	while (1) {
> >-		handle =3D find=5Falloced=5Fobj(class, s=5Fpage, index);
> >-		if (!handle) {
> >-			s=5Fpage =3D get=5Fnext=5Fpage(s=5Fpage);
> >-			if (!s=5Fpage)
> >-				break;
> >-			index =3D 0;
> >+	for (i =3D 0; i < class->objs=5Fper=5Fzspage; i++) {
> >+		handle =3D handle=5Ffrom=5Fobj(class, src=5Fpage, i);
> >+		if (!handle)
> >  			continue;
> >-		}
> >-
> >-		/* Stop if there is no more space */
> >-		if (zspage=5Ffull(class, d=5Fpage)) {
> >-			unpin=5Ftag(handle);
> >-			ret =3D -ENOMEM;
> >+		if (zspage=5Ffull(class, dst=5Fpage))
> >  			break;
> >-		}
> >-
> >-		used=5Fobj =3D handle=5Fto=5Fobj(handle);
> >-		free=5Fobj =3D obj=5Fmalloc(class, d=5Fpage, handle);
> >-		zs=5Fobject=5Fcopy(class, free=5Fobj, used=5Fobj);
> >-		index++;
> >+		old=5Fobj =3D handle=5Fto=5Fobj(handle);
> >+		new=5Fobj =3D obj=5Fmalloc(class, dst=5Fpage, handle);
> >+		zs=5Fobject=5Fcopy(class, new=5Fobj, old=5Fobj);
> >+		nr=5Fmigrated++;
> >  		/*
> >  		 * record=5Fobj updates handle's value to free=5Fobj and it will
> >  		 * invalidate lock bit(ie, HANDLE=5FPIN=5FBIT) of handle, which
> >  		 * breaks synchronization using pin=5Ftag(e,g, zs=5Ffree) so
> >  		 * let's keep the lock bit.
> >  		 */
> >-		free=5Fobj |=3D BIT(HANDLE=5FPIN=5FBIT);
> >-		record=5Fobj(handle, free=5Fobj);
> >-		unpin=5Ftag(handle);
> >-		obj=5Ffree(class, used=5Fobj);
> >+		new=5Fobj |=3D BIT(HANDLE=5FPIN=5FBIT);
> >+		record=5Fobj(handle, new=5Fobj);
> >+		obj=5Ffree(class, old=5Fobj);
> >  	}
> >-
> >-	/* Remember last position in this iteration */
> >-	cc->s=5Fpage =3D s=5Fpage;
> >-	cc->index =3D index;
> >-
> >-	return ret;
> >-}
> >-
> >-static struct page *isolate=5Ftarget=5Fpage(struct size=5Fclass *class)
> >-{
> >-	int i;
> >-	struct page *page;
> >-
> >-	for (i =3D 0; i < =5FZS=5FNR=5FFULLNESS=5FGROUPS; i++) {
> >-		page =3D class->fullness=5Flist[i];
> >-		if (page) {
> >-			remove=5Fzspage(class, i, page);
> >-			break;
> >-		}
> >-	}
> >-
> >-	return page;
> >+	return nr=5Fmigrated;
> >  }
> >
> >  /*
> >   * putback=5Fzspage - add @first=5Fpage into right class's fullness li=
st
> >- * @pool: target pool
> >   * @class: destination class
> >   * @first=5Fpage: target page
> >   *
> >   * Return @first=5Fpage's updated fullness=5Fgroup
> >   */
> >-static enum fullness=5Fgroup putback=5Fzspage(struct zs=5Fpool *pool,
> >-			struct size=5Fclass *class,
> >-			struct page *first=5Fpage)
> >+static enum fullness=5Fgroup putback=5Fzspage(struct size=5Fclass *clas=
s,
> >+					struct page *first=5Fpage)
> >  {
> >  	enum fullness=5Fgroup fullness;
> >
> >@@ -1768,17 +1721,155 @@ static enum fullness=5Fgroup putback=5Fzspage(s=
truct zs=5Fpool *pool,
> >  	return fullness;
> >  }
> >
> >+/*
> >+ * freeze=5Fzspage - freeze all objects in a zspage
> >+ * @class: size class of the page
> >+ * @first=5Fpage: first page of zspage
> >+ *
> >+ * Freeze all allocated objects in a zspage so objects couldn't be
> >+ * freed until unfreeze objects. It should be called under class->lock.
> >+ *
> >+ * RETURNS:
> >+ * the number of pinned objects
> >+ */
> >+static int freeze=5Fzspage(struct size=5Fclass *class, struct page *fir=
st=5Fpage)
> >+{
> >+	unsigned long obj=5Fidx;
> >+	struct page *obj=5Fpage;
> >+	unsigned long offset;
> >+	void *addr;
> >+	int nr=5Ffreeze =3D 0;
> >+
> >+	for (obj=5Fidx =3D 0; obj=5Fidx < class->objs=5Fper=5Fzspage; obj=5Fid=
x++) {
> >+		unsigned long head;
> >+
> >+		objidx=5Fto=5Fpage=5Fand=5Foffset(class, first=5Fpage, obj=5Fidx,
> >+					&obj=5Fpage, &offset);
> >+		addr =3D kmap=5Fatomic(obj=5Fpage);
> >+		head =3D obj=5Fto=5Fhead(class, obj=5Fpage, addr + offset);
> >+		if (head & OBJ=5FALLOCATED=5FTAG) {
> >+			unsigned long handle =3D head & ~OBJ=5FALLOCATED=5FTAG;
> >+
> >+			if (!trypin=5Ftag(handle)) {
> >+				kunmap=5Fatomic(addr);
> >+				break;
> >+			}
> >+			nr=5Ffreeze++;
> >+		}
> >+		kunmap=5Fatomic(addr);
> >+	}
> >+
> >+	return nr=5Ffreeze;
> >+}
> >+
> >+/*
> >+ * unfreeze=5Fpage - unfreeze objects freezed by freeze=5Fzspage in a z=
spage
> >+ * @class: size class of the page
> >+ * @first=5Fpage: freezed zspage to unfreeze
> >+ * @nr=5Fobj: the number of objects to unfreeze
> >+ *
> >+ * unfreeze objects in a zspage.
> >+ */
> >+static void unfreeze=5Fzspage(struct size=5Fclass *class, struct page *=
first=5Fpage,
> >+			int nr=5Fobj)
> >+{
> >+	unsigned long obj=5Fidx;
> >+	struct page *obj=5Fpage;
> >+	unsigned long offset;
> >+	void *addr;
> >+	int nr=5Funfreeze =3D 0;
> >+
> >+	for (obj=5Fidx =3D 0; obj=5Fidx < class->objs=5Fper=5Fzspage &&
> >+			nr=5Funfreeze < nr=5Fobj; obj=5Fidx++) {
> >+		unsigned long head;
> >+
> >+		objidx=5Fto=5Fpage=5Fand=5Foffset(class, first=5Fpage, obj=5Fidx,
> >+					&obj=5Fpage, &offset);
> >+		addr =3D kmap=5Fatomic(obj=5Fpage);
> >+		head =3D obj=5Fto=5Fhead(class, obj=5Fpage, addr + offset);
> >+		if (head & OBJ=5FALLOCATED=5FTAG) {
> >+			unsigned long handle =3D head & ~OBJ=5FALLOCATED=5FTAG;
> >+
> >+			VM=5FBUG=5FON(!testpin=5Ftag(handle));
> >+			unpin=5Ftag(handle);
> >+			nr=5Funfreeze++;
> >+		}
> >+		kunmap=5Fatomic(addr);
> >+	}
> >+}
> >+
> >+/*
> >+ * isolate=5Fsource=5Fpage - isolate a zspage for migration source
> >+ * @class: size class of zspage for isolation
> >+ *
> >+ * Returns a zspage which are isolated from list so anyone can
> >+ * allocate a object from that page. As well, freeze all objects
> >+ * allocated in the zspage so anyone cannot access that objects
> >+ * (e.g., zs=5Fmap=5Fobject, zs=5Ffree).
> >+ */
> >  static struct page *isolate=5Fsource=5Fpage(struct size=5Fclass *class)
> >  {
> >  	int i;
> >  	struct page *page =3D NULL;
> >
> >  	for (i =3D ZS=5FALMOST=5FEMPTY; i >=3D ZS=5FALMOST=5FFULL; i--) {
> >+		int inuse, freezed;
> >+
> >  		page =3D class->fullness=5Flist[i];
> >  		if (!page)
> >  			continue;
> >
> >  		remove=5Fzspage(class, i, page);
> >+
> >+		inuse =3D get=5Fzspage=5Finuse(page);
> >+		freezed =3D freeze=5Fzspage(class, page);
> >+
> >+		if (inuse !=3D freezed) {
> >+			unfreeze=5Fzspage(class, page, freezed);
> >+			putback=5Fzspage(class, page);
> >+			page =3D NULL;
> >+			continue;
> >+		}
> >+
> >+		break;
> >+	}
> >+
> >+	return page;
> >+}
> >+
> >+/*
> >+ * isolate=5Ftarget=5Fpage - isolate a zspage for migration target
> >+ * @class: size class of zspage for isolation
> >+ *
> >+ * Returns a zspage which are isolated from list so anyone can
> >+ * allocate a object from that page. As well, freeze all objects
> >+ * allocated in the zspage so anyone cannot access that objects
> >+ * (e.g., zs=5Fmap=5Fobject, zs=5Ffree).
> >+ */
> >+static struct page *isolate=5Ftarget=5Fpage(struct size=5Fclass *class)
> >+{
> >+	int i;
> >+	struct page *page;
> >+
> >+	for (i =3D 0; i < =5FZS=5FNR=5FFULLNESS=5FGROUPS; i++) {
> >+		int inuse, freezed;
> >+
> >+		page =3D class->fullness=5Flist[i];
> >+		if (!page)
> >+			continue;
> >+
> >+		remove=5Fzspage(class, i, page);
> >+
> >+		inuse =3D get=5Fzspage=5Finuse(page);
> >+		freezed =3D freeze=5Fzspage(class, page);
> >+
> >+		if (inuse !=3D freezed) {
> >+			unfreeze=5Fzspage(class, page, freezed);
> >+			putback=5Fzspage(class, page);
> >+			page =3D NULL;
> >+			continue;
> >+		}
> >+
> >  		break;
> >  	}
> >
> >@@ -1793,9 +1884,11 @@ static struct page *isolate=5Fsource=5Fpage(struc=
t size=5Fclass *class)
> >  static unsigned long zs=5Fcan=5Fcompact(struct size=5Fclass *class)
> >  {
> >  	unsigned long obj=5Fwasted;
> >+	unsigned long obj=5Fallocated, obj=5Fused;
> >
> >-	obj=5Fwasted =3D zs=5Fstat=5Fget(class, OBJ=5FALLOCATED) -
> >-		zs=5Fstat=5Fget(class, OBJ=5FUSED);
> >+	obj=5Fallocated =3D zs=5Fstat=5Fget(class, OBJ=5FALLOCATED);
> >+	obj=5Fused =3D zs=5Fstat=5Fget(class, OBJ=5FUSED);
> >+	obj=5Fwasted =3D obj=5Fallocated - obj=5Fused;
> >
> >  	obj=5Fwasted /=3D get=5Fmaxobj=5Fper=5Fzspage(class->size,
> >  			class->pages=5Fper=5Fzspage);
> >@@ -1805,53 +1898,81 @@ static unsigned long zs=5Fcan=5Fcompact(struct s=
ize=5Fclass *class)
> >
> >  static void =5F=5Fzs=5Fcompact(struct zs=5Fpool *pool, struct size=5Fc=
lass *class)
> >  {
> >-	struct zs=5Fcompact=5Fcontrol cc;
> >-	struct page *src=5Fpage;
> >+	struct page *src=5Fpage =3D NULL;
> >  	struct page *dst=5Fpage =3D NULL;
> >
> >-	spin=5Flock(&class->lock);
> >-	while ((src=5Fpage =3D isolate=5Fsource=5Fpage(class))) {
> >+	while (1) {
> >+		int nr=5Fmigrated;
> >
> >-		if (!zs=5Fcan=5Fcompact(class))
> >+		spin=5Flock(&class->lock);
> >+		if (!zs=5Fcan=5Fcompact(class)) {
> >+			spin=5Funlock(&class->lock);
> >  			break;
> >+		}
> >
> >-		cc.index =3D 0;
> >-		cc.s=5Fpage =3D src=5Fpage;
> >+		/*
> >+		 * Isolate source page and freeze all objects in a zspage
> >+		 * to prevent zspage destroying.
> >+		 */
> >+		if (!src=5Fpage) {
> >+			src=5Fpage =3D isolate=5Fsource=5Fpage(class);
> >+			if (!src=5Fpage) {
> >+				spin=5Funlock(&class->lock);
> >+				break;
> >+			}
> >+		}
> >
> >-		while ((dst=5Fpage =3D isolate=5Ftarget=5Fpage(class))) {
> >-			cc.d=5Fpage =3D dst=5Fpage;
> >-			/*
> >-			 * If there is no more space in dst=5Fpage, resched
> >-			 * and see if anyone had allocated another zspage.
> >-			 */
> >-			if (!migrate=5Fzspage(pool, class, &cc))
> >+		/* Isolate target page and freeze all objects in the zspage */
> >+		if (!dst=5Fpage) {
> >+			dst=5Fpage =3D isolate=5Ftarget=5Fpage(class);
> >+			if (!dst=5Fpage) {
> >+				spin=5Funlock(&class->lock);
> >  				break;
> >+			}
> >+		}
> >+		spin=5Funlock(&class->lock);
>=20
> (Sorry to delete individual recipients due to my compliance issues.)
>=20
> Hello, Minchan.
>=20
>=20
> Is it safe to unlock?
>=20
>=20
> (I assume that the system has 2 cores
> and a swap device is using zsmalloc pool.)
> If a zs compact context scheduled out after this "spin=5Funlock" line,
>=20
>=20
>    CPU A (Swap In)                CPU B (zs=5Ffree by process killed)
> ---------------------           -------------------------
>                                 ...
>                                 spin=5Flock(&si->lock)
>                                 ...
>                                # assume it is pinned by zs=5Fcompact cont=
ext.
>                                 pin=5Ftag(handle) --> block
>=20
> ...
> spin=5Flock(&si->lock) --> block
>=20
>=20
> I think CPU A and CPU B may not be released forever.
> Am I missing something?

You didn't miss anything. It could be dead locked.
The swap=5Fslot=5Ffree=5Fnotify is always really problem. :(
That's why I want to remove it.
I will think over how to handle it and send fix in next revision.

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
