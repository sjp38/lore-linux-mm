Message-Id: <20070427042907.759384015@sgi.com>
References: <20070427042655.019305162@sgi.com>
Date: Thu, 26 Apr 2007 21:26:57 -0700
From: clameter@sgi.com
Subject: [patch 02/10] SLUB: Fix sysfs directory handling
Content-Disposition: inline; filename=slub_sysfs_dir_fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This fixes the problem that SLUB does not track the names of aliased
slabs by changing the way that SLUB manages the files in /sys/slab.

If the slab that is being operated on is not mergeable (usually the
case if we are debugging) then do not create any aliases. If an alias
exists that we conflict with then remove it before creating the
directory for the unmergeable slab. If there is a true slab cache there
and not an alias then we fail since there is a true duplication of
slab cache names. So debugging allows the detection of slab name
duplication as usual.

If the slab is mergeable then we create a directory with a unique name
created from the slab size, slab options and the pointer to the kmem_cache
structure (disambiguation). All names referring to the slabs will
then be created as symlinks to that unique name. These symlinks are
not going to be removed on kmem_cache_destroy() since we only carry
a counter for the number of aliases. If a new symlink is created
then it may just replace an existing one. This means that one can create
a gazillion slabs with the same name (if they all refer to mergeable
caches). It will only increase the alias count. So we have the potential
of not detecting duplicate slab names (there is actually no harm
done by doing that....). We will detect the duplications as
as soon as debugging is enabled because we will then no longer
generate symlinks and special unique names.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc7-mm2/mm/slub.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/mm/slub.c	2007-04-26 11:40:52.000000000 -0700
+++ linux-2.6.21-rc7-mm2/mm/slub.c	2007-04-26 11:40:59.000000000 -0700
@@ -3298,16 +3298,68 @@ static struct kset_uevent_ops slab_ueven
 
 decl_subsys(slab, &slab_ktype, &slab_uevent_ops);
 
+#define ID_STR_LENGTH 64
+
+/* Create a unique string id for a slab cache:
+ * format
+ * :[flags-]size:[memory address of kmemcache]
+ */
+static char *create_unique_id(struct kmem_cache *s)
+{
+	char *name = kmalloc(ID_STR_LENGTH, GFP_KERNEL);
+	char *p = name;
+
+	BUG_ON(!name);
+
+	*p++ = ':';
+	/*
+	 * First flags affecting slabcache operations */
+	if (s->flags & SLAB_CACHE_DMA)
+		*p++ = 'd';
+	if (s->flags & SLAB_RECLAIM_ACCOUNT)
+		*p++ = 'a';
+	if (s->flags & SLAB_DESTROY_BY_RCU)
+		*p++ = 'r';\
+	/* Debug flags */
+	if (s->flags & SLAB_RED_ZONE)
+		*p++ = 'Z';
+	if (s->flags & SLAB_POISON)
+		*p++ = 'P';
+	if (s->flags & SLAB_STORE_USER)
+		*p++ = 'U';
+	if (p != name + 1)
+		*p++ = '-';
+	p += sprintf(p,"%07d:0x%p" ,s->size, s);
+	BUG_ON(p > name + ID_STR_LENGTH - 1);
+	return name;
+}
+
 static int sysfs_slab_add(struct kmem_cache *s)
 {
 	int err;
+	const char *name;
 
 	if (slab_state < SYSFS)
 		/* Defer until later */
 		return 0;
 
+	if (s->flags & SLUB_NEVER_MERGE) {
+		/*
+		 * Slabcache can never be merged so we can use the name proper.
+		 * This is typically the case for debug situations. In that
+		 * case we can catch duplicate names easily.
+		 */
+		sysfs_remove_link(&slab_subsys.kset.kobj, s->name);
+		name = s->name;
+	} else
+		/*
+		 * Create a unique name for the slab as a target
+		 * for the symlinks.
+		 */
+		name = create_unique_id(s);
+
 	kobj_set_kset_s(s, slab_subsys);
-	kobject_set_name(&s->kobj, s->name);
+	kobject_set_name(&s->kobj, name);
 	kobject_init(&s->kobj);
 	err = kobject_add(&s->kobj);
 	if (err)
@@ -3317,6 +3369,10 @@ static int sysfs_slab_add(struct kmem_ca
 	if (err)
 		return err;
 	kobject_uevent(&s->kobj, KOBJ_ADD);
+	if (!(s->flags & SLUB_NEVER_MERGE)) {
+		sysfs_slab_alias(s, s->name);
+		kfree(name);
+	}
 	return 0;
 }
 
@@ -3342,9 +3398,14 @@ static int sysfs_slab_alias(struct kmem_
 {
 	struct saved_alias *al;
 
-	if (slab_state == SYSFS)
+	if (slab_state == SYSFS) {
+		/*
+		 * If we have a leftover link then remove it.
+		 */
+		sysfs_remove_link(&slab_subsys.kset.kobj, name);
 		return sysfs_create_link(&slab_subsys.kset.kobj,
 						&s->kobj, name);
+	}
 
 	al = kmalloc(sizeof(struct saved_alias), GFP_KERNEL);
 	if (!al)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
