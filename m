Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3581F6B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:26:38 -0400 (EDT)
Date: Thu, 10 Sep 2009 13:26:42 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for
	mempolicy based management.
Message-ID: <20090910122641.GA31153@csn.ul.ie>
References: <1252012158.6029.215.camel@useless.americas.hpqcorp.net> <alpine.DEB.1.00.0909031416310.1459@chino.kir.corp.google.com> <20090908104409.GB28127@csn.ul.ie> <alpine.DEB.1.00.0909081241530.10542@chino.kir.corp.google.com> <20090908200451.GA6481@csn.ul.ie> <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com> <20090908214109.GB6481@csn.ul.ie> <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com> <20090909081631.GB24614@csn.ul.ie> <alpine.DEB.1.00.0909091335050.7764@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0909091335050.7764@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 09, 2009 at 01:44:28PM -0700, David Rientjes wrote:
> On Wed, 9 Sep 2009, Mel Gorman wrote:
> 
> > And to beat a dead horse, it does make sense that an application
> > allocating hugepages obey memory policies. It does with dynamic hugepage
> > resizing for example. It should have been done years ago and
> > unfortunately wasn't but it's not the first time that the behaviour of
> > hugepages differed from the core VM.
> > 
> 
> I agree completely, I'm certainly not defending the current implementation 
> as a sound design and I too would have preferred that it have done the 
> same as Lee's patchset from the very beginning.  The issue I'm raising is 
> that while we both agree the current behavior is suboptimal and confusing, 
> it is the long-standing kernel behavior.  There are applications out there 
> that are written to allocate and free hugepages and now changing the pool 
> from which they can allocate or free to could be problematic.
> 

While I doubt there are many, the counter-example of one is not
something I can wish or wave away.

> I'm personally fine with the breakage since I'm aware of this discussion 
> and can easily fix it in userspace.  I'm more concerned about others 
> leaking hugepages or having their boot scripts break because they are 
> allocating far fewer hugepages than before. 

I just find it very improbably that system-wide maintenance or boot-up
processes are running within restricted environments that then expect to
have system-wide capabilities but it wouldn't be the first time something
unusual was implemented.

> The documentation 
> (Documentation/vm/hugetlbpage.txt) has always said 
> /proc/sys/vm/nr_hugepaegs affects hugepages on a system level and now that 
> it's changed, I think it should be done explicitly with a new flag than 
> implicitly.
> 
> Would you explain why introducing a new mempolicy flag, MPOL_F_HUGEPAGES, 
> and only using the new behavior when this is set would be inconsistent or 
> inadvisible?

I already explained this. The interface in numactl would look weird. There
would be an --interleave switch and a --hugepages-interleave that only
applies to nr_hugepages. The smarts could be in hugeadm to apply the mask
when --pool-pages-min is specified but that wouldn't help scripts that are
still using echo.

> Since this is a new behavior that will differ from the 
> long-standing default, it seems like it warrants a new mempolicy flag to 
> avoid all userspace breakage and make hugepage allocation and freeing with 
> an underlying mempolicy explicit.
> 
> This would address your audience that have been (privately) emailing you 
> while confused about why the hugepages being allocated from a global 
> tunable wouldn't be confined to their mempolicy.
> 

I hate to have to do this, but how about nr_hugepages which acts
system-wide as it did traditionally and nr_hugepages_mempolicy that obeys
policies? Something like the following untested patch. It would be fairly
trivial for me to implement a --obey-mempolicies switch for hugeadm which
works in conjunction with --pool--pages-min and less likely to cause confusion
than --hugepages-interleave in numactl.

Sorry the patch is untested. I can't hold of a NUMA machine at the moment
and fake NUMA support sucks far worse than I expected it to.

==== BEGIN PATCH ====

[PATCH] Optionally use a memory policy when tuning the size of the static hugepage pool

Patch "derive huge pages nodes allowed from task mempolicy" brought
huge page support more in line with the core VM in that tuning the size
of the static huge page pool would obey memory policies. Using this,
administrators could interleave allocation of huge pages from a subset
of nodes. This is consistent with how dynamic hugepage pool resizing
works and how hugepages get allocated to applications at run-time.

However, it was pointed out that scripts may exist that depend on being
able to drain all hugepages via /proc/sys/vm/nr_hugepages from processes
that are running within a memory policy. This patch adds
/proc/sys/vm/nr_hugepages_mempolicy which when written to will obey
memory policies. /proc/sys/vm/nr_hugepages continues then to be a
system-wide tunable regardless of memory policy.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 include/linux/hugetlb.h |    1 +
 kernel/sysctl.c         |   11 +++++++++++
 mm/hugetlb.c            |   35 ++++++++++++++++++++++++++++++++---
 3 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index fcb1677..fc3a659 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -21,6 +21,7 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8bac3f5..0637655 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1171,6 +1171,17 @@ static struct ctl_table vm_table[] = {
 		.extra1		= (void *)&hugetlb_zero,
 		.extra2		= (void *)&hugetlb_infinity,
 	 },
+#ifdef CONFIG_NUMA
+	 {
+		.procname	= "nr_hugepages_mempolicy",
+		.data		= NULL,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= &hugetlb_mempolicy_sysctl_handler,
+		.extra1		= (void *)&hugetlb_zero,
+		.extra2		= (void *)&hugetlb_infinity,
+	 },
+#endif
 	 {
 		.ctl_name	= VM_HUGETLB_GROUP,
 		.procname	= "hugetlb_shm_group",
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 83decd6..68abef0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1244,6 +1244,7 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
 	return ret;
 }
 
+#define NUMA_NO_NODE_OBEY_MEMPOLICY (-2)
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
 static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 								int nid)
@@ -1254,9 +1255,14 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	if (h->order >= MAX_ORDER)
 		return h->max_huge_pages;
 
-	if (nid == NUMA_NO_NODE) {
+	switch (nid) {
+	case NUMA_NO_NODE_OBEY_MEMPOLICY:
 		nodes_allowed = alloc_nodemask_of_mempolicy();
-	} else {
+		break;
+	case NUMA_NO_NODE:
+		nodes_allowed = NULL;
+		break;
+	default:
 		/*
 		 * incoming 'count' is for node 'nid' only, so
 		 * adjust count to global, but restrict alloc/free
@@ -1265,7 +1271,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
 		nodes_allowed = alloc_nodemask_of_node(nid);
 	}
-	if (!nodes_allowed) {
+	if (!nodes_allowed && nid != NUMA_NO_NODE) {
 		printk(KERN_WARNING "%s unable to allocate nodes allowed mask "
 			"for huge page allocation.  Falling back to default.\n",
 			current->comm);
@@ -1796,6 +1802,29 @@ int hugetlb_sysctl_handler(struct ctl_table *table, int write,
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
+int hugetlb_mempolicy_sysctl_handler(struct ctl_table *table, int write,
+			   void __user *buffer,
+			   size_t *length, loff_t *ppos)
+{
+	struct hstate *h = &default_hstate;
+	unsigned long tmp;
+
+	if (!write)
+		tmp = h->max_huge_pages;
+
+	table->data = &tmp;
+	table->maxlen = sizeof(unsigned long);
+	proc_doulongvec_minmax(table, write, buffer, length, ppos);
+
+	if (write)
+		h->max_huge_pages = set_max_huge_pages(h, tmp,
+					NUMA_NO_NODE_OBEY_MEMPOLICY);
+
+	return 0;
+}
+#endif /* CONFIG_NUMA */
+
 int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
 			void __user *buffer,
 			size_t *length, loff_t *ppos)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
