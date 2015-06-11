Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8156B006C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 04:19:33 -0400 (EDT)
Received: by payr10 with SMTP id r10so49425646pay.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 01:19:33 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ra5si17972323pbb.209.2015.06.11.01.19.31
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 01:19:32 -0700 (PDT)
From: "Liu, XinwuX" <xinwux.liu@intel.com>
Subject: RE: [PATCH] slub/slab: fix kmemleak didn't work on some case
Date: Thu, 11 Jun 2015 08:18:06 +0000
Message-ID: <99C214DF91337140A8D774E25DF6CD5FC92E95@shsmsx102.ccr.corp.intel.com>
References: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com>
 <alpine.DEB.2.11.1506080425350.10651@east.gentwo.org>
 <20150608101302.GB31349@e104818-lin.cambridge.arm.com>
 <55769F85.5060909@linux.intel.com>
 <20150609150303.GB4808@e104818-lin.cambridge.arm.com>
 <5577EB2E.8090505@linux.intel.com>
 <20150610094846.GD4808@e104818-lin.cambridge.arm.com>
In-Reply-To: <20150610094846.GD4808@e104818-lin.cambridge.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "He, Bo" <bo.he@intel.com>, "Chen, Lin Z" <lin.z.chen@intel.com>

when kernel uses kmalloc to allocate memory, slub/slab will find
a suitable kmem_cache.=A0The cache's object size is often greater than
requested size. There=A0is unused space which contains dirty data. These
dirty data might have=A0pointers pointing to=A0a block of=A0leaked=A0memory=
.
Kernel wouldn't consider this=A0memory as leaked when scanning kmemleak obj=
ect.

The patch fixes it by updating kmemleak object size with requested size,
so kmemleak won't scan the unused space.

Signed-off-by: Chen Lin Z <lin.z.chen@intel.com>
Signed-off-by: Liu, XinwuX <xinwux.liu@intel.com>
---
 include/linux/kmemleak.h |  4 ++++
 mm/kmemleak.c            | 40 +++++++++++++++++++++++++++++++++++++++-
 mm/slab.c                | 11 ++++++++++-
 mm/slub.c                | 12 ++++++++++++
 4 files changed, 65 insertions(+), 2 deletions(-)

diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index e705467..cc35a2f 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -37,6 +37,7 @@ extern void kmemleak_not_leak(const void *ptr) __ref;
 extern void kmemleak_ignore(const void *ptr) __ref;
 extern void kmemleak_scan_area(const void *ptr, size_t size, gfp_t gfp) __=
ref;
 extern void kmemleak_no_scan(const void *ptr) __ref;
+extern void kmemleak_set_size(const void *ptr, size_t size) __ref;
=20
 static inline void kmemleak_alloc_recursive(const void *ptr, size_t size,
 					    int min_count, unsigned long flags,
@@ -104,6 +105,9 @@ static inline void kmemleak_erase(void **ptr)
 static inline void kmemleak_no_scan(const void *ptr)
 {
 }
+static inline void kmemleak_set_size(const void *ptr, size_t size)
+{
+}
=20
 #endif	/* CONFIG_DEBUG_KMEMLEAK */
=20
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f0fe4f2..487086e 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -241,7 +241,8 @@ enum {
 	KMEMLEAK_NOT_LEAK,
 	KMEMLEAK_IGNORE,
 	KMEMLEAK_SCAN_AREA,
-	KMEMLEAK_NO_SCAN
+	KMEMLEAK_NO_SCAN,
+	KMEMLEAK_SET_SIZE
 };
=20
 /*
@@ -799,6 +800,23 @@ static void object_no_scan(unsigned long ptr)
 }
=20
 /*
+ * Set the size for an allocated object.
+ */
+static void __object_set_size(unsigned long ptr, size_t size)
+{
+	unsigned long flags;
+	struct kmemleak_object *object;
+
+	object =3D find_and_get_object(ptr, 0);
+	if (!object) {
+		kmemleak_warn("Try to set unknown object at 0x%08lx\n", ptr);
+		return;
+	}
+	object->size =3D size;
+	put_object(object);
+}
+
+/*
  * Log an early kmemleak_* call to the early_log buffer. These calls will =
be
  * processed later once kmemleak is fully initialized.
  */
@@ -1105,6 +1123,23 @@ void __ref kmemleak_no_scan(const void *ptr)
 }
 EXPORT_SYMBOL(kmemleak_no_scan);
=20
+/**
+ * kmemleak_set_size - set an allocated object's size
+ * @ptr:	pointer to beginning of the object
+ * @size:	the new size of the allocated object
+ *
+ * The function need to be called before allocation function returns.
+ */
+void __ref kmemleak_set_size(const void *ptr, size_t size)
+{
+
+	if (kmemleak_enabled && ptr && !IS_ERR(ptr))
+		__object_set_size((unsigned long)ptr, size);
+	else if (kmemleak_early_log)
+		log_early(KMEMLEAK_SET_SIZE, ptr, size, 0);
+}
+EXPORT_SYMBOL(kmemleak_set_size);
+
 /*
  * Update an object's checksum and return true if it was modified.
  */
@@ -1880,6 +1915,9 @@ void __init kmemleak_init(void)
 		case KMEMLEAK_NO_SCAN:
 			kmemleak_no_scan(log->ptr);
 			break;
+		case KMEMLEAK_SET_SIZE:
+			kmemleak_set_size(log->ptr, log->size);
+			break;
 		default:
 			kmemleak_warn("Unknown early log operation: %d\n",
 				      log->op_type);
diff --git a/mm/slab.c b/mm/slab.c
index 7eb38dd..90bc4fe 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3476,11 +3476,17 @@ static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller=
)
 {
 	struct kmem_cache *cachep;
+	void *ret;
=20
 	cachep =3D kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	return kmem_cache_alloc_node_trace(cachep, flags, node, size);
+	ret =3D kmem_cache_alloc_node_trace(cachep, flags, node, size);
+
+	if (size < cachep->object_size)
+		kmemleak_set_size(ret, size);
+
+	return ret;
 }
=20
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
@@ -3517,6 +3523,9 @@ static __always_inline void *__do_kmalloc(size_t size=
, gfp_t flags,
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
=20
+	if (size < cachep->object_size)
+		kmemleak_set_size(ret, size);
+
 	return ret;
 }
=20
diff --git a/mm/slub.c b/mm/slub.c
index 54c0876..4ef17e5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3321,6 +3321,9 @@ void *__kmalloc(size_t size, gfp_t flags)
=20
 	kasan_kmalloc(s, ret, size);
=20
+	if (size < s->object_size)
+		kmemleak_set_size(ret, size);
+
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc);
@@ -3366,6 +3369,9 @@ void *__kmalloc_node(size_t size, gfp_t flags, int no=
de)
=20
 	kasan_kmalloc(s, ret, size);
=20
+	if (size < s->object_size)
+		kmemleak_set_size(ret, size);
+
 	return ret;
 }
 EXPORT_SYMBOL(__kmalloc_node);
@@ -3823,6 +3829,9 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpfl=
ags, unsigned long caller)
 	/* Honor the call site pointer we received. */
 	trace_kmalloc(caller, ret, size, s->size, gfpflags);
=20
+	if (size < s->object_size)
+		kmemleak_set_size(ret, size);
+
 	return ret;
 }
=20
@@ -3853,6 +3862,9 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t =
gfpflags,
 	/* Honor the call site pointer we received. */
 	trace_kmalloc_node(caller, ret, size, s->size, gfpflags, node);
=20
+	if (size < s->object_size)
+		kmemleak_set_size(ret, size);
+
 	return ret;
 }
 #endif
--=20
1.9.1


-----Original Message-----
From: Catalin Marinas [mailto:catalin.marinas@arm.com]=20
Sent: Wednesday, June 10, 2015 5:49 PM
To: Zhang, Yanmin
Cc: Christoph Lameter; Liu, XinwuX; penberg@kernel.org; mpm@selenic.com; li=
nux-mm@kvack.org; linux-kernel@vger.kernel.org; He, Bo; Chen, Lin Z
Subject: Re: [PATCH] slub/slab: fix kmemleak didn't work on some case

On Wed, Jun 10, 2015 at 08:45:50AM +0100, Zhang, Yanmin wrote:
> On 2015/6/9 23:03, Catalin Marinas wrote:
> > On Tue, Jun 09, 2015 at 09:10:45AM +0100, Zhang, Yanmin wrote:
> >> On 2015/6/8 18:13, Catalin Marinas wrote:
> >>> As I replied already, I don't think this is that bad, or at least=20
> >>> not worse than what kmemleak already does (looking at all data=20
> >>> whether it's pointer or not).
> >> It depends. As for memleak, developers prefers there are false=20
> >> alarms instead of missing some leaked memory.
> > Lots of false positives aren't that nice, you spend a lot of time=20
> > debugging them (I've been there in the early kmemleak days). Anyway,=20
> > your use case is not about false positives vs. negatives but just=20
> > false negatives.
> >
> > My point is that there is a lot of random, pointer-like data read by=20
> > kmemleak even without this memset (e.g. thread stacks, non-pointer=20
> > data in kmalloc'ed structures, data/bss sections). Just doing this=20
> > memset may reduce the chance of false negatives a bit but I don't=20
> > think it would be noticeable.
> >
> > If there is some serious memory leak (lots of objects), they would=20
> > likely show up at some point. Even if it's a one-off leak, it's=20
> > possible that it shows up after some time (e.g. the object pointing=20
> > to this memory block is freed).
> >
> >>>  It also doesn't solve the kmem_cache_alloc() case where the=20
> >>> original object size is no longer available.
> >> Such issue around kmem_cache_alloc() case happens only when the=20
> >> caller doesn't initialize or use the full object, so the object=20
> >> keeps old dirty data.
> > The kmem_cache blocks size would be aligned to a cache line, so you=20
> > still have some extra bytes never touched by the caller.
> >
> >> This patch is to resolve the redundant unused space (more than=20
> >> object size) although the full object is used by kernel.
> > So this solves only the cases where the original object size is=20
> > still known (e.g. kmalloc). It could also be solved by telling=20
> > kmemleak the actual object size.
>=20
> Your explanation is reasonable. The patch is for debug purpose.
> Maintainers can make decision based on balance.

The patch, as it stands, should not go in:

- too much code duplication (I already commented that a function
  similar to kmemleak_erase would look much better)
- I don't think there is a noticeable benefit but happy to be proven
  wrong
- there are other ways of achieving the same

> Xinwu is a new developer in kernel community. Accepting the patch into=20
> kernel can encourage him definitely. :)

As would constructive feedback ;)

That said, it would probably be more beneficial to be able to tell kmemleak=
 of the actual object size via another callback. This solves the scanning o=
f the extra data in a slab, restricts pointer values referencing the object=
 and better identification of the leaked objects (by printing its real size=
). Two options:

a) Use the existing kmemleak_free_part() function to free the end of the
   slab. This was originally meant for memblock freeing but can be
   improved slightly to avoid creating a new object and deleting the old
   one when only the last part of the block is freed.

b) Implement a new kmemleak_set_size(const void *ptr, size_t size). All
   it needs to do is update the object->size value, no need for
   re-inserting into the rb-tree.

Option (b) is probably better, especially with the latest patches I posted =
where kmemleak_free*() always deletes the original object.

--
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
