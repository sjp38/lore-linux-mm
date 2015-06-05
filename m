Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f48.google.com (mail-vn0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 72B26900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 16:15:31 -0400 (EDT)
Received: by vnbg190 with SMTP id g190so6500304vnb.8
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 13:15:31 -0700 (PDT)
Received: from mail-vn0-x229.google.com (mail-vn0-x229.google.com. [2607:f8b0:400c:c0f::229])
        by mx.google.com with ESMTPS id h8si15155278vda.25.2015.06.05.13.15.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 13:15:23 -0700 (PDT)
Received: by vnbf190 with SMTP id f190so10497524vnb.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 13:15:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5571DF9C.4030404@redhat.com>
References: <5571BFBE.3070209@redhat.com>
	<CA+pa1O2xTnWdP6bbPNnBM=P2oMAaLJf9hWZd+KOL12BJp4R-3Q@mail.gmail.com>
	<5571DF9C.4030404@redhat.com>
Date: Sat, 6 Jun 2015 05:15:22 +0900
Message-ID: <CA+pa1O1Uxb1sPUR0u06ON9=dN9B_2RVdMqfFU2HV68goTWs-Pw@mail.gmail.com>
Subject: Re: [PATCH] cma: allow concurrent cma pages allocation for multi-cma areas
From: =?UTF-8?Q?Micha=C5=82_Nazarewicz?= <mina86@mina86.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, iamjoonsoo.kim@lge.com, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Weijie Yang <weijie.yang.kh@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jun 05 2015, Laura Abbott wrote:
> but can we put a comment explaining this here too?

Sounds good to me.  I would even document why we have two locks in case
someone decides to merge them.  Perhaps something like (haven=E2=80=99t tes=
ted
or even compiled):

-------- >8 ------------------------------------------------------------
Subject: cma: allow concurrent allocation for different CMA regions

Currently we have to hold a single cma_mutex when allocating CMA areas.
When there are multiple CMA regions, the single cma_mutex prevents
concurrent CMA allocation.

This patch replaces the single cma_mutex with a per-CMA region
alloc_lock.  This allows concurrent CMA allocation for different CMA
regions while protects access to the same pageblocks.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
Signed-off-by: Michal Nazarewiz <mina86@mina86.com>
[mina86: renamed cma->lock to cma->bitmap_lock, added locks documentation]
---
 mm/cma.c | 18 +++++++++---------
 mm/cma.h | 16 +++++++++++++++-
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 3a7a67b..841fe07 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -41,7 +41,6 @@

 struct cma cma_areas[MAX_CMA_AREAS];
 unsigned cma_area_count;
-static DEFINE_MUTEX(cma_mutex);

 phys_addr_t cma_get_base(const struct cma *cma)
 {
@@ -89,9 +88,9 @@ static void cma_clear_bitmap(struct cma *cma,
unsigned long pfn,
     bitmap_no =3D (pfn - cma->base_pfn) >> cma->order_per_bit;
     bitmap_count =3D cma_bitmap_pages_to_bits(cma, count);

-    mutex_lock(&cma->lock);
+    mutex_lock(&cma->bitmap_lock);
     bitmap_clear(cma->bitmap, bitmap_no, bitmap_count);
-    mutex_unlock(&cma->lock);
+    mutex_unlock(&cma->bitmap_lock);
 }

 static int __init cma_activate_area(struct cma *cma)
@@ -127,7 +126,8 @@ static int __init cma_activate_area(struct cma *cma)
         init_cma_reserved_pageblock(pfn_to_page(base_pfn));
     } while (--i);

-    mutex_init(&cma->lock);
+    mutex_init(&cma->alloc_lock);
+    mutex_init(&cma->bitmap_lock);

 #ifdef CONFIG_CMA_DEBUGFS
     INIT_HLIST_HEAD(&cma->mem_head);
@@ -381,12 +381,12 @@ struct page *cma_alloc(struct cma *cma, unsigned
int count, unsigned int align)
     bitmap_count =3D cma_bitmap_pages_to_bits(cma, count);

     for (;;) {
-        mutex_lock(&cma->lock);
+        mutex_lock(&cma->bitmap_lock);
         bitmap_no =3D bitmap_find_next_zero_area_off(cma->bitmap,
                 bitmap_maxno, start, bitmap_count, mask,
                 offset);
         if (bitmap_no >=3D bitmap_maxno) {
-            mutex_unlock(&cma->lock);
+            mutex_unlock(&cma->bitmap_lock);
             break;
         }
         bitmap_set(cma->bitmap, bitmap_no, bitmap_count);
@@ -395,12 +395,12 @@ struct page *cma_alloc(struct cma *cma, unsigned
int count, unsigned int align)
          * our exclusive use. If the migration fails we will take the
          * lock again and unmark it.
          */
-        mutex_unlock(&cma->lock);
+        mutex_unlock(&cma->bitmap_lock);

         pfn =3D cma->base_pfn + (bitmap_no << cma->order_per_bit);
-        mutex_lock(&cma_mutex);
+        mutex_lock(&cma->alloc_lock);
         ret =3D alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
-        mutex_unlock(&cma_mutex);
+        mutex_unlock(&cma->alloc_lock);
         if (ret =3D=3D 0) {
             page =3D pfn_to_page(pfn);
             break;
diff --git a/mm/cma.h b/mm/cma.h
index 1132d73..b585ba1 100644
--- a/mm/cma.h
+++ b/mm/cma.h
@@ -6,7 +6,21 @@ struct cma {
     unsigned long   count;
     unsigned long   *bitmap;
     unsigned int order_per_bit; /* Order of pages represented by one bit *=
/
-    struct mutex    lock;
+    /*
+     * alloc_lock protects calls to alloc_contig_range.  The function must
+     * not be called concurrently on the same pageblock which is why it ha=
s
+     * to be synchronised.  On the other hand, because each CMA region is
+     * pageblock-aligned we can have per-region alloc_locks since they nev=
er
+     * share a pageblock.
+     */
+    struct mutex    alloc_lock;
+    /*
+     * As the name suggests, bitmap_lock protects the bitmap.  It has to b=
e
+     * a separate lock from alloc_lock so that we can free CMA areas (whic=
h
+     * only requires bitmap_lock) while allocating pages (which requires
+     * alloc_lock) is ongoing.
+     */
+    struct mutex    bitmap_lock;
 #ifdef CONFIG_CMA_DEBUGFS
     struct hlist_head mem_head;
     spinlock_t mem_head_lock;

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
