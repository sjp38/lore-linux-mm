Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 700DA6B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 19:32:57 -0400 (EDT)
Date: Thu, 10 Sep 2009 16:31:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] hugetlb:  add per node hstate attributes
Message-Id: <20090910163157.239d8689.akpm@linux-foundation.org>
In-Reply-To: <20090909163158.12963.49725.sendpatchset@localhost.localdomain>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
	<20090909163158.12963.49725.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, mel@csn.ul.ie, randy.dunlap@oracle.com, nacc@us.ibm.com, rientjes@google.com, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 09 Sep 2009 12:31:58 -0400
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> ...
>
> This patch adds the per huge page size control/query attributes
> to the per node sysdevs:
> 
> /sys/devices/system/node/node<ID>/hugepages/hugepages-<size>/
> 	nr_hugepages       - r/w
> 	free_huge_pages    - r/o
> 	surplus_huge_pages - r/o
> 
>
> ...
> 
> Index: linux-2.6.31-rc7-mmotm-090827-1651/drivers/base/node.c
> ===================================================================
> --- linux-2.6.31-rc7-mmotm-090827-1651.orig/drivers/base/node.c	2009-09-09 11:57:26.000000000 -0400
> +++ linux-2.6.31-rc7-mmotm-090827-1651/drivers/base/node.c	2009-09-09 11:57:37.000000000 -0400
> @@ -177,6 +177,37 @@ static ssize_t node_read_distance(struct
>  }
>  static SYSDEV_ATTR(distance, S_IRUGO, node_read_distance, NULL);
>  
> +/*
> + * hugetlbfs per node attributes registration interface:
> + * When/if hugetlb[fs] subsystem initializes [sometime after this module],
> + * it will register it's per node attributes for all nodes on-line at that
> + * point.  It will also call register_hugetlbfs_with_node(), below, to
> + * register it's attribute registration functions with this node driver.
> + * Once these hooks have been initialized, the node driver will call into
> + * the hugetlb module to [un]register attributes for hot-plugged nodes.
> + */
> +NODE_REGISTRATION_FUNC __hugetlb_register_node;
> +NODE_REGISTRATION_FUNC __hugetlb_unregister_node;

WHAT THE HECK IS THAT THING?

Oh.  It's a typedef.  It's not a kernel convention to upper-case those.
it is a kerenl convention to lower-case them and stick a _t at the
end.

There doesn't apepar to have been any reason to make these symbols
global.

>  
> +#ifdef CONFIG_NUMA
> +
> +struct node_hstate {
> +	struct kobject		*hugepages_kobj;
> +	struct kobject		*hstate_kobjs[HUGE_MAX_HSTATE];
> +};
> +struct node_hstate node_hstates[MAX_NUMNODES];
> +
> +static struct attribute *per_node_hstate_attrs[] = {
> +	&nr_hugepages_attr.attr,
> +	&free_hugepages_attr.attr,
> +	&surplus_hugepages_attr.attr,
> +	NULL,
> +};

I assume this interface got documented in patch 6/6.

> +static struct attribute_group per_node_hstate_attr_group = {
> +	.attrs = per_node_hstate_attrs,
> +};
> +
> +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> +{
> +	int nid;
> +
> +	for (nid = 0; nid < nr_node_ids; nid++) {
> +		struct node_hstate *nhs = &node_hstates[nid];
> +		int i;
> +		for (i = 0; i < HUGE_MAX_HSTATE; i++)
> +			if (nhs->hstate_kobjs[i] == kobj) {
> +				if (nidp)
> +					*nidp = nid;

Dammit, another function which has no callers.  How am I supposed
to find out if we really need to test for a NULL nidp?

> +				return &hstates[i];
> +			}
> +	}
> +
> +	BUG();
> +	return NULL;
> +}
>
>
> ...
>
> +static struct hstate *kobj_to_node_hstate(struct kobject *kobj, int *nidp)
> +{
> +	BUG();
> +	if (nidp)
> +		*nidp = -1;
> +	return NULL;
> +}

strange.



fixlets:

 drivers/base/node.c  |   14 +++++++-------
 hugetlb.c            |    0 
 include/linux/node.h |   10 +++++-----
 3 files changed, 12 insertions(+), 12 deletions(-)

diff -puN drivers/base/node.c~hugetlb-add-per-node-hstate-attributes-fix drivers/base/node.c
--- a/drivers/base/node.c~hugetlb-add-per-node-hstate-attributes-fix
+++ a/drivers/base/node.c
@@ -180,14 +180,14 @@ static SYSDEV_ATTR(distance, S_IRUGO, no
 /*
  * hugetlbfs per node attributes registration interface:
  * When/if hugetlb[fs] subsystem initializes [sometime after this module],
- * it will register it's per node attributes for all nodes on-line at that
- * point.  It will also call register_hugetlbfs_with_node(), below, to
- * register it's attribute registration functions with this node driver.
+ * it will register its per node attributes for all nodes online at that
+ * time.  It will also call register_hugetlbfs_with_node(), below, to
+ * register its attribute registration functions with this node driver.
  * Once these hooks have been initialized, the node driver will call into
  * the hugetlb module to [un]register attributes for hot-plugged nodes.
  */
-NODE_REGISTRATION_FUNC __hugetlb_register_node;
-NODE_REGISTRATION_FUNC __hugetlb_unregister_node;
+static node_registration_func_t __hugetlb_register_node;
+static node_registration_func_t __hugetlb_unregister_node;
 
 static inline void hugetlb_register_node(struct node *node)
 {
@@ -201,8 +201,8 @@ static inline void hugetlb_unregister_no
 		__hugetlb_unregister_node(node);
 }
 
-void register_hugetlbfs_with_node(NODE_REGISTRATION_FUNC doregister,
-				  NODE_REGISTRATION_FUNC unregister)
+void register_hugetlbfs_with_node(node_registration_func_t doregister,
+				  node_registration_func_t unregister)
 {
 	__hugetlb_register_node   = doregister;
 	__hugetlb_unregister_node = unregister;
diff -puN include/linux/node.h~hugetlb-add-per-node-hstate-attributes-fix include/linux/node.h
--- a/include/linux/node.h~hugetlb-add-per-node-hstate-attributes-fix
+++ a/include/linux/node.h
@@ -28,7 +28,7 @@ struct node {
 
 struct memory_block;
 extern struct node node_devices[];
-typedef  void (*NODE_REGISTRATION_FUNC)(struct node *);
+typedef  void (*node_registration_func_t)(struct node *);
 
 extern int register_node(struct node *, int, struct node *);
 extern void unregister_node(struct node *node);
@@ -40,8 +40,8 @@ extern int unregister_cpu_under_node(uns
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						int nid);
 extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk);
-extern void register_hugetlbfs_with_node(NODE_REGISTRATION_FUNC doregister,
-					 NODE_REGISTRATION_FUNC unregister);
+extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
+					 node_registration_func_t unregister);
 #else
 static inline int register_one_node(int nid)
 {
@@ -69,8 +69,8 @@ static inline int unregister_mem_sect_un
 	return 0;
 }
 
-static inline void register_hugetlbfs_with_node(NODE_REGISTRATION_FUNC reg,
-						NODE_REGISTRATION_FUNC unreg)
+static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
+						node_registration_func_t unreg)
 {
 }
 #endif
diff -puN mm/hugetlb.c~hugetlb-add-per-node-hstate-attributes-fix mm/hugetlb.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
