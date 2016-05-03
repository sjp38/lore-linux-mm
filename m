Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 574E46B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 21:43:11 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id fn8so20377943igb.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 18:43:11 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id oo7si1215277igb.67.2016.05.02.18.43.08
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 18:43:09 -0700 (PDT)
Date: Tue, 3 May 2016 10:43:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 11/12] zsmalloc: page migration support
Message-ID: <20160503014305.GC2272@bbox>
References: <1461743305-19970-1-git-send-email-minchan@kernel.org>
 <1461743305-19970-12-git-send-email-minchan@kernel.org>
 <5727E3BC.8070308@samsung.com>
 <20160503004359.GA2272@bbox>
MIME-Version: 1.0
In-Reply-To: <20160503004359.GA2272@bbox>
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, May 03, 2016 at 09:43:59AM +0900, Minchan Kim wrote:
> Good morning, Chulmin
>=20
> On Tue, May 03, 2016 at 08:33:16AM +0900, Chulmin Kim wrote:
> > Hello, Minchan!
> >=20
> > On 2016=EB=85=84 04=EC=9B=94 27=EC=9D=BC 16:48, Minchan Kim wrote:
> > >This patch introduces run-time migration feature for zspage.
> > >
> > >For migration, VM uses page.lru field so it would be better to not use
> > >page.next field for own purpose. For that, firstly, we can get first
> > >object offset of the page via runtime calculation instead of
> > >page->index so we can use page->index as link for page chaining.
> > >In case of huge object, it stores handle rather than page chaining.
> > >To identify huge object, we uses PG=5Fowner=5Fpriv=5F1 flag.
> > >
> > >For migration, it supports three functions
> > >
> > >* zs=5Fpage=5Fisolate
> > >
> > >It isolates a zspage which includes a subpage VM want to migrate from
> > >class so anyone cannot allocate new object from the zspage if it's fir=
st
> > >isolation on subpages of zspage. Thus, further isolation on other
> > >subpages cannot isolate zspage from class list.
> > >
> > >* zs=5Fpage=5Fmigrate
> > >
> > >First of all, it holds write-side zspage->lock to prevent migrate other
> > >subpage in zspage. Then, lock all objects in the page VM want to migra=
te.
> > >The reason we should lock all objects in the page is due to race betwe=
en
> > >zs=5Fmap=5Fobject and zs=5Fpage=5Fmigrate.
> > >
> > >zs=5Fmap=5Fobject				zs=5Fpage=5Fmigrate
> > >
> > >pin=5Ftag(handle)
> > >obj =3D handle=5Fto=5Fobj(handle)
> > >obj=5Fto=5Flocation(obj, &page, &obj=5Fidx);
> > >
> > >					write=5Flock(&zspage->lock)
> > >					if (!trypin=5Ftag(handle))
> > >						goto unpin=5Fobject
> > >
> > >zspage =3D get=5Fzspage(page);
> > >read=5Flock(&zspage->lock);
> > >
> > >If zs=5Fpage=5Fmigrate doesn't do trypin=5Ftag, zs=5Fmap=5Fobject's pa=
ge can
> > >be stale so go crash.
> > >
> > >If it locks all of objects successfully, it copies content from old pa=
ge
> > >create new one, finally, create new page chain with new page.
> > >If it's last isolated page in the zspage, put the zspage back to class.
> > >
> > >* zs=5Fpage=5Fputback
> > >
> > >It returns isolated zspage to right fullness=5Fgroup list if it fails =
to
> > >migrate a page.
> > >
> > >Lastly, this patch introduces asynchronous zspage free. The reason
> > >we need it is we need page=5Flock to clear PG=5Fmovable but unfortunat=
ely,
> > >zs=5Ffree path should be atomic so the apporach is try to grab page=5F=
lock
> > >with preemption disabled. If it got page=5Flock of all of pages
> > >successfully, it can free zspage in the context. Otherwise, it queues
> > >the free request and free zspage via workqueue in process context.
> > >
> > >Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > >Signed-off-by: Minchan Kim <minchan@kernel.org>
> > >---
> > >  include/uapi/linux/magic.h |   1 +
> > >  mm/zsmalloc.c              | 552 +++++++++++++++++++++++++++++++++++=
++++------
> > >  2 files changed, 487 insertions(+), 66 deletions(-)
> > >
> > >diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
> > >index e1fbe72c39c0..93b1affe4801 100644
> > >--- a/include/uapi/linux/magic.h
> > >+++ b/include/uapi/linux/magic.h
> > >@@ -79,5 +79,6 @@
> > >  #define NSFS=5FMAGIC		0x6e736673
> > >  #define BPF=5FFS=5FMAGIC		0xcafe4a11
> > >  #define BALLOON=5FKVM=5FMAGIC	0x13661366
> > >+#define ZSMALLOC=5FMAGIC		0x58295829
> > >
> > >  #endif /* =5F=5FLINUX=5FMAGIC=5FH=5F=5F */
> > >diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > >index 8d82e44c4644..042793015ecf 100644
> > >--- a/mm/zsmalloc.c
> > >+++ b/mm/zsmalloc.c
> > >@@ -17,15 +17,14 @@
> > >   *
> > >   * Usage of struct page fields:
> > >   *	page->private: points to zspage
> > >- *	page->index: offset of the first object starting in this page.
> > >- *		For the first page, this is always 0, so we use this field
> > >- *		to store handle for huge object.
> > >- *	page->next: links together all component pages of a zspage
> > >+ *	page->freelist: links together all component pages of a zspage
> > >+ *		For the huge page, this is always 0, so we use this field
> > >+ *		to store handle.
> > >   *
> > >   * Usage of struct page flags:
> > >   *	PG=5Fprivate: identifies the first component page
> > >   *	PG=5Fprivate2: identifies the last component page
> > >- *
> > >+ *	PG=5Fowner=5Fpriv=5F1: indentifies the huge component page
> > >   */
> > >
> > >  #include <linux/module.h>
> > >@@ -47,6 +46,10 @@
> > >  #include <linux/debugfs.h>
> > >  #include <linux/zsmalloc.h>
> > >  #include <linux/zpool.h>
> > >+#include <linux/mount.h>
> > >+#include <linux/migrate.h>
> > >+
> > >+#define ZSPAGE=5FMAGIC	0x58
> > >
> > >  /*
> > >   * This must be power of 2 and greater than of equal to sizeof(link=
=5Ffree).
> > >@@ -128,8 +131,33 @@
> > >   *  ZS=5FMIN=5FALLOC=5FSIZE and ZS=5FSIZE=5FCLASS=5FDELTA must be mu=
ltiple of ZS=5FALIGN
> > >   *  (reason above)
> > >   */
> > >+
> > >+/*
> > >+ * A zspage's class index and fullness group
> > >+ * are encoded in its (first)page->mapping
> > >+ */
> > >+#define FULLNESS=5FBITS	2
> > >+#define CLASS=5FBITS	8
> > >+#define ISOLATED=5FBITS	3
> > >+#define MAGIC=5FVAL=5FBITS	8
> > >+
> > >+
> > >  #define ZS=5FSIZE=5FCLASS=5FDELTA	(PAGE=5FSIZE >> CLASS=5FBITS)
> > >
> > >+struct zspage {
> > >+	struct {
> > >+		unsigned int fullness:FULLNESS=5FBITS;
> > >+		unsigned int class:CLASS=5FBITS;
> > >+		unsigned int isolated:ISOLATED=5FBITS;
> > >+		unsigned int magic:MAGIC=5FVAL=5FBITS;
> > >+	};
> > >+	unsigned int inuse;
> > >+	unsigned int freeobj;
> > >+	struct page *first=5Fpage;
> > >+	struct list=5Fhead list; /* fullness list */
> > >+	rwlock=5Ft lock;
> > >+};
> > >+
> > >  /*
> > >   * We do not maintain any list for completely empty or full pages
> > >   */
> > >@@ -161,6 +189,8 @@ struct zs=5Fsize=5Fstat {
> > >  static struct dentry *zs=5Fstat=5Froot;
> > >  #endif
> > >
> > >+static struct vfsmount *zsmalloc=5Fmnt;
> > >+
> > >  /*
> > >   * number of size=5Fclasses
> > >   */
> > >@@ -243,24 +273,10 @@ struct zs=5Fpool {
> > >  #ifdef CONFIG=5FZSMALLOC=5FSTAT
> > >  	struct dentry *stat=5Fdentry;
> > >  #endif
> > >-};
> > >-
> > >-/*
> > >- * A zspage's class index and fullness group
> > >- * are encoded in its (first)page->mapping
> > >- */
> > >-#define FULLNESS=5FBITS	2
> > >-#define CLASS=5FBITS	8
> > >-
> > >-struct zspage {
> > >-	struct {
> > >-		unsigned int fullness:FULLNESS=5FBITS;
> > >-		unsigned int class:CLASS=5FBITS;
> > >-	};
> > >-	unsigned int inuse;
> > >-	unsigned int freeobj;
> > >-	struct page *first=5Fpage;
> > >-	struct list=5Fhead list; /* fullness list */
> > >+	struct inode *inode;
> > >+	spinlock=5Ft free=5Flock;
> > >+	struct work=5Fstruct free=5Fwork;
> > >+	struct list=5Fhead free=5Fzspage;
> > >  };
> > >
> > >  struct mapping=5Farea {
> > >@@ -312,8 +328,11 @@ static struct zspage *cache=5Falloc=5Fzspage(stru=
ct zs=5Fpool *pool, gfp=5Ft flags)
> > >  	struct zspage *zspage;
> > >
> > >  	zspage =3D kmem=5Fcache=5Falloc(pool->zspage=5Fcachep, flags & ~=5F=
=5FGFP=5FHIGHMEM);
> > >-	if (zspage)
> > >+	if (zspage) {
> > >  		memset(zspage, 0, sizeof(struct zspage));
> > >+		zspage->magic =3D ZSPAGE=5FMAGIC;
> > >+		rwlock=5Finit(&zspage->lock);
> >=20
> > +              INIT=5FLIST=5FHEAD(&zspage->list);
> >=20
> > If there is no special intention here,
> > I think we need the list initialization.
>=20
> Intention was that I just watned to add unncessary instruction there

                     I just don't want to add unnecessary instruction there
Typo. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
