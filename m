Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A71E6B02F4
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 17:52:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j79so14645289pfj.9
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 14:52:50 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r9si736092pfe.5.2017.07.06.14.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 14:52:49 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC v2 4/5] sysfs: add sysfs_add_group_link()
Date: Thu,  6 Jul 2017 15:52:32 -0600
Message-Id: <20170706215233.11329-5-ross.zwisler@linux.intel.com>
In-Reply-To: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

The current __compat_only_sysfs_link_entry_to_kobj() code allows us to
create symbolic links in sysfs to groups or attributes.  Something like:

/sys/.../entry1/groupA -> /sys/.../entry2/groupA

This patch extends this functionality with a new sysfs_add_group_link()
call that allows the link to have a different name than the group or
attribute, so:

/sys/.../entry1/link_name -> /sys/.../entry2/groupA

__compat_only_sysfs_link_entry_to_kobj() now just calls
sysfs_add_group_link(), passing in the same name for both the
group/attribute and for the link name.

This is needed by the ACPI HMAT enabling work because we want to have a
group of performance attributes that live in a memory target.  This group
represents the performance between a memory target and its local
inititator.  In the target the attribute group is named "local_init":

  # tree mem_tgt2/local_init/
  mem_tgt2/local_init/
  a??a??a?? mem_init0 -> ../../mem_init0
  a??a??a?? mem_tgt2 -> ../../mem_tgt2
  a??a??a?? read_bw_MBps
  a??a??a?? read_lat_nsec
  a??a??a?? write_bw_MBps
  a??a??a?? write_lat_nsec

We then want to link to this attribute group from the initiator, but change
the name of the link to "mem_tgtX" since we're now looking at it from the
initiator's perspective, and because a given initiator can have multiple
local memory targets:

  # ls -l mem_init0/mem_tgt2
  lrwxrwxrwx. 1 root root 0 Jul  5 14:38 mem_init0/mem_tgt2 ->
  ../mem_tgt2/local_init

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/sysfs/group.c      | 30 +++++++++++++++++++++++-------
 include/linux/sysfs.h |  2 ++
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/fs/sysfs/group.c b/fs/sysfs/group.c
index ac2de0e..19db57c8 100644
--- a/fs/sysfs/group.c
+++ b/fs/sysfs/group.c
@@ -367,15 +367,15 @@ void sysfs_remove_link_from_group(struct kobject *kobj, const char *group_name,
 EXPORT_SYMBOL_GPL(sysfs_remove_link_from_group);
 
 /**
- * __compat_only_sysfs_link_entry_to_kobj - add a symlink to a kobject pointing
- * to a group or an attribute
+ * sysfs_add_group_link - add a symlink to a kobject pointing to a group or
+ * an attribute
  * @kobj:		The kobject containing the group.
  * @target_kobj:	The target kobject.
  * @target_name:	The name of the target group or attribute.
+ * @link_name:		The name of the link to the target group or attribute.
  */
-int __compat_only_sysfs_link_entry_to_kobj(struct kobject *kobj,
-				      struct kobject *target_kobj,
-				      const char *target_name)
+int sysfs_add_group_link(struct kobject *kobj, struct kobject *target_kobj,
+		const char *target_name, const char *link_name)
 {
 	struct kernfs_node *target;
 	struct kernfs_node *entry;
@@ -400,12 +400,28 @@ int __compat_only_sysfs_link_entry_to_kobj(struct kobject *kobj,
 		return -ENOENT;
 	}
 
-	link = kernfs_create_link(kobj->sd, target_name, entry);
+	link = kernfs_create_link(kobj->sd, link_name, entry);
 	if (IS_ERR(link) && PTR_ERR(link) == -EEXIST)
-		sysfs_warn_dup(kobj->sd, target_name);
+		sysfs_warn_dup(kobj->sd, link_name);
 
 	kernfs_put(entry);
 	kernfs_put(target);
 	return IS_ERR(link) ? PTR_ERR(link) : 0;
 }
+EXPORT_SYMBOL_GPL(sysfs_add_group_link);
+
+/**
+ * __compat_only_sysfs_link_entry_to_kobj - add a symlink to a kobject pointing
+ * to a group or an attribute
+ * @kobj:		The kobject containing the group.
+ * @target_kobj:	The target kobject.
+ * @target_name:	The name of the target group or attribute.
+ */
+int __compat_only_sysfs_link_entry_to_kobj(struct kobject *kobj,
+				      struct kobject *target_kobj,
+				      const char *target_name)
+{
+	return sysfs_add_group_link(kobj, target_kobj, target_name,
+			target_name);
+}
 EXPORT_SYMBOL_GPL(__compat_only_sysfs_link_entry_to_kobj);
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index c6f0f0d..865f499 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -278,6 +278,8 @@ int sysfs_add_link_to_group(struct kobject *kobj, const char *group_name,
 			    struct kobject *target, const char *link_name);
 void sysfs_remove_link_from_group(struct kobject *kobj, const char *group_name,
 				  const char *link_name);
+int sysfs_add_group_link(struct kobject *kobj, struct kobject *target_kobj,
+		const char *target_name, const char *link_name);
 int __compat_only_sysfs_link_entry_to_kobj(struct kobject *kobj,
 				      struct kobject *target_kobj,
 				      const char *target_name);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
