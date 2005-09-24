Date: Sat, 24 Sep 2005 11:22:01 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Use node macros for memory policies
In-Reply-To: <20050923145746.77a846b7.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0509241119490.29070@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0509231109001.22542@schroedinger.engr.sgi.com>
 <20050923145746.77a846b7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: ak@suse.de, pj@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Sep 2005, Andrew Morton wrote:

> There's already a patch in -mm which does this.  There are differences, 
> so please review 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.14-rc2/2.6.14-rc2-mm1/broken-out/convert-mempolicies-to-nodemask_t.patch
> 
> Which typedef weenie inflicted nodemask_t upon us anyway?

Not me.

One hunk is missing in Andi's patchset. This covers the cpuset->mempolicy 
interface.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc2/kernel/cpuset.c
===================================================================
--- linux-2.6.14-rc2.orig/kernel/cpuset.c	2005-09-19 20:00:41.000000000 -0700
+++ linux-2.6.14-rc2/kernel/cpuset.c	2005-09-23 11:08:38.000000000 -0700
@@ -1603,10 +1603,9 @@ void cpuset_update_current_mems_allowed(
  * cpuset_restrict_to_mems_allowed - limit nodes to current mems_allowed
  * @nodes: pointer to a node bitmap that is and-ed with mems_allowed
  */
-void cpuset_restrict_to_mems_allowed(unsigned long *nodes)
+void cpuset_restrict_to_mems_allowed(nodemask_t *nodes)
 {
-	bitmap_and(nodes, nodes, nodes_addr(current->mems_allowed),
-							MAX_NUMNODES);
+	nodes_and(*nodes, *nodes, current->mems_allowed);
 }
 
 /**
Index: linux-2.6.14-rc2/include/linux/cpuset.h
===================================================================
--- linux-2.6.14-rc2.orig/include/linux/cpuset.h	2005-09-19 20:00:41.000000000 -0700
+++ linux-2.6.14-rc2/include/linux/cpuset.h	2005-09-23 11:08:38.000000000 -0700
@@ -21,7 +21,7 @@ extern void cpuset_exit(struct task_stru
 extern cpumask_t cpuset_cpus_allowed(const struct task_struct *p);
 void cpuset_init_current_mems_allowed(void);
 void cpuset_update_current_mems_allowed(void);
-void cpuset_restrict_to_mems_allowed(unsigned long *nodes);
+void cpuset_restrict_to_mems_allowed(nodemask_t *nodes);
 int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl);
 extern int cpuset_zone_allowed(struct zone *z, unsigned int __nocast gfp_mask);
 extern int cpuset_excl_nodes_overlap(const struct task_struct *p);
@@ -42,7 +42,7 @@ static inline cpumask_t cpuset_cpus_allo
 
 static inline void cpuset_init_current_mems_allowed(void) {}
 static inline void cpuset_update_current_mems_allowed(void) {}
-static inline void cpuset_restrict_to_mems_allowed(unsigned long *nodes) {}
+static inline void cpuset_restrict_to_mems_allowed(nodemask_t *nodes) {}
 
 static inline int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
