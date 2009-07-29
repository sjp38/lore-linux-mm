Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D173D6B0096
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 14:09:45 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 29 Jul 2009 14:11:58 -0400
Message-Id: <20090729181158.23716.41437.sendpatchset@localhost.localdomain>
In-Reply-To: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
Subject: [PATCH 3/4] hugetlb:  add private bit-field to kobject structure
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Greg KH <gregkh@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 3/4 hugetlb:  add private bitfield to struct kobject

Against: 2.6.31-rc3-mmotm-090716-1432
atop the previously posted alloc_bootmem_hugepages fix.
[http://marc.info/?l=linux-mm&m=124775468226290&w=4]

For the per node huge page attributes, we want to share
as much code as possible with the global huge page attributes,
including the show/store functions.  To do this, we'll need a
way to back translate from the kobj argument to the show/store
function to the node id, when entered via that path.  This
patch adds a subsystem/sysdev private bitfield to the kobject
structure.  The bitfield uses unused bits in the same unsigned
int as the various kobject flags so as not to increase the size
of the structure. 

Currently, the bit field is the minimum required for the huge
pages per node attributes [plus one extra bit].  The field could
be expanded for other usage, should such arise.

Note that this is not absolutely required.  However, using this
private field eliminates an inner loop to scan the per node
hstate kobjects and eliminates scanning entirely for the global
hstate kobjects.


Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

---
 include/linux/kobject.h |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6.31-rc3-mmotm-090716-1432/include/linux/kobject.h
===================================================================
--- linux-2.6.31-rc3-mmotm-090716-1432.orig/include/linux/kobject.h	2009-07-24 10:01:27.000000000 -0400
+++ linux-2.6.31-rc3-mmotm-090716-1432/include/linux/kobject.h	2009-07-24 10:04:34.000000000 -0400
@@ -56,6 +56,8 @@ enum kobject_action {
 	KOBJ_MAX
 };
 
+#define KOBJ_PRIVATE_BITS 3	/* subsystem/sysdev private */
+
 struct kobject {
 	const char		*name;
 	struct list_head	entry;
@@ -69,6 +71,7 @@ struct kobject {
 	unsigned int state_add_uevent_sent:1;
 	unsigned int state_remove_uevent_sent:1;
 	unsigned int uevent_suppress:1;
+	unsigned int private:KOBJ_PRIVATE_BITS;
 };
 
 extern int kobject_set_name(struct kobject *kobj, const char *name, ...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
