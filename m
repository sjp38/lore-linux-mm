Date: Tue, 5 Apr 2005 21:16:44 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050406041644.25060.37619.68257@jackhammer.engr.sgi.com>
In-Reply-To: <20050406041633.25060.64831.21849@jackhammer.engr.sgi.com>
References: <20050406041633.25060.64831.21849@jackhammer.engr.sgi.com>
Subject: [PATCH_FOR_REVIEW 2.6.12-rc1 1/3] fs: manual page migration-rc1 -- extended attribute system.migration for XFS
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcello@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>
Cc: Ray Bryant <raybry@sgi.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch is from Nathan Scott of SGI and adds the extended
attribute system.migration for xfs.  At the moment, there is
no protection checking being done here (according to Nathan),
so this would have to be added if we finally agree to go this
way.  However, since there are currently alternative proposals
(e. g. Christoph Hellwig's suggestion of modifying the dynamic
loader) this is good enough for now.

Signed-off-by: Ray Bryant <raybry@sgi.com>

Index: linux/fs/xfs/xfs_attr.c
===================================================================
--- linux/fs/xfs.orig/xfs_attr.c
+++ linux/fs/xfs/xfs_attr.c
@@ -2398,7 +2398,53 @@
 	return xfs_acl_vhasacl_default(vp);
 }
 
-struct attrnames posix_acl_access = {
+#define _MIGRATE	"SGI_NUMA_MIGRATE"
+
+STATIC int
+numa_migration_set(
+	vnode_t	*vp, char *name, void *data, size_t size, int xflags)
+{
+	int error;
+
+	VOP_ATTR_SET(vp, _MIGRATE, data, size, ATTR_ROOT, sys_cred, error);
+	return -error;
+}
+
+STATIC int
+numa_migration_get(
+	vnode_t *vp, char *name, void *data, size_t size, int xflags)
+{
+	int error, flags = ATTR_ROOT;
+
+	if (!size)
+		flags |= ATTR_KERNOVAL;
+	VOP_ATTR_GET(vp, _MIGRATE, data, &size, flags, sys_cred, error);
+	if (!error)
+		return size;
+	return -error;
+}
+
+STATIC int
+numa_migration_remove(
+	struct vnode *vp, char *name, int xflags)
+{
+	int error;
+
+	VOP_ATTR_REMOVE(vp, _MIGRATE, ATTR_ROOT, sys_cred, error);
+	return (error == ENOATTR) ? 0 : -error;
+}
+
+STATIC int
+numa_migration_exists(
+	vnode_t *vp)
+{
+	int	error, len, flags = ATTR_ROOT|ATTR_KERNOVAL;
+
+	VOP_ATTR_GET(vp, _MIGRATE, NULL, &len, flags, sys_cred, error);
+	return (error == 0);
+}
+
+STATIC struct attrnames posix_acl_access = {
 	.attr_name	= "posix_acl_access",
 	.attr_namelen	= sizeof("posix_acl_access") - 1,
 	.attr_get	= posix_acl_access_get,
@@ -2407,7 +2453,7 @@
 	.attr_exists	= posix_acl_access_exists,
 };
 
-struct attrnames posix_acl_default = {
+STATIC struct attrnames posix_acl_default = {
 	.attr_name	= "posix_acl_default",
 	.attr_namelen	= sizeof("posix_acl_default") - 1,
 	.attr_get	= posix_acl_default_get,
@@ -2416,8 +2462,19 @@
 	.attr_exists	= posix_acl_default_exists,
 };
 
-struct attrnames *attr_system_names[] =
-	{ &posix_acl_access, &posix_acl_default };
+STATIC struct attrnames numa_migration = {
+	.attr_name	= "migration",
+	.attr_namelen	= sizeof("migration") - 1,
+	.attr_get	= numa_migration_get,
+	.attr_set	= numa_migration_set,
+	.attr_remove	= numa_migration_remove,
+	.attr_exists	= numa_migration_exists,
+};
+
+struct attrnames *attr_system_names[] = {
+	&posix_acl_access, &posix_acl_default,
+	&numa_migration,
+};
 
 
 /*========================================================================
Index: linux/fs/xfs/xfs_attr.h
===================================================================
--- linux/fs/xfs.orig/xfs_attr.h
+++ linux/fs/xfs/xfs_attr.h
@@ -76,9 +76,7 @@
 extern struct attrnames attr_trusted;
 extern struct attrnames *attr_namespaces[ATTR_NAMECOUNT];
 
-#define ATTR_SYSCOUNT	2
-extern struct attrnames posix_acl_access;
-extern struct attrnames posix_acl_default;
+#define ATTR_SYSCOUNT	3
 extern struct attrnames *attr_system_names[ATTR_SYSCOUNT];
 
 extern attrnames_t *attr_lookup_namespace(char *, attrnames_t **, int);


-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
