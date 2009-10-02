Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1D74560021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:19:38 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n92MGIjt015590
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 23:16:18 +0100
Received: from pzk10 (pzk10.prod.google.com [10.243.19.138])
	by zps37.corp.google.com with ESMTP id n92MGFbQ032283
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 15:16:15 -0700
Received: by pzk10 with SMTP id 10so1500219pzk.19
        for <linux-mm@kvack.org>; Fri, 02 Oct 2009 15:16:15 -0700 (PDT)
Date: Fri, 2 Oct 2009 15:16:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/10] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <20091001165832.32248.32725.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910021513090.18180@chino.kir.corp.google.com>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain> <20091001165832.32248.32725.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009, Lee Schermerhorn wrote:

> Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-09-30 12:48:45.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-10-01 12:13:25.000000000 -0400
> @@ -1334,29 +1334,71 @@ static struct hstate *kobj_to_hstate(str
>  	return NULL;
>  }
>  
> -static ssize_t nr_hugepages_show(struct kobject *kobj,
> +static ssize_t nr_hugepages_show_common(struct kobject *kobj,
>  					struct kobj_attribute *attr, char *buf)
>  {
>  	struct hstate *h = kobj_to_hstate(kobj);
>  	return sprintf(buf, "%lu\n", h->nr_huge_pages);
>  }
> -static ssize_t nr_hugepages_store(struct kobject *kobj,
> -		struct kobj_attribute *attr, const char *buf, size_t count)
> +static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
> +			struct kobject *kobj, struct kobj_attribute *attr,
> +			const char *buf, size_t len)
>  {
>  	int err;
> -	unsigned long input;
> +	unsigned long count;
>  	struct hstate *h = kobj_to_hstate(kobj);
> +	NODEMASK_ALLOC(nodemask, nodes_allowed);
>  

 [ FYI: I'm not sure clameter@sgi.com still works, you may want to try
   cl@linux-foundation.org. ]


mm/hugetlb.c: In function 'nr_hugepages_store_common':
mm/hugetlb.c:1368: error: storage size of '_m' isn't known
mm/hugetlb.c:1380: warning: passing argument 1 of 'init_nodemask_of_mempolicy' from incompatible pointer type
mm/hugetlb.c:1382: warning: assignment from incompatible pointer type
mm/hugetlb.c:1390: warning: passing argument 1 of 'init_nodemask_of_node' from incompatible pointer type
mm/hugetlb.c:1392: warning: passing argument 3 of 'set_max_huge_pages' from incompatible pointer type
mm/hugetlb.c:1394: warning: comparison of distinct pointer types lacks a cast
mm/hugetlb.c:1368: warning: unused variable '_m'
mm/hugetlb.c: In function 'hugetlb_sysctl_handler_common':
mm/hugetlb.c:1862: error: storage size of '_m' isn't known
mm/hugetlb.c:1864: warning: passing argument 1 of 'init_nodemask_of_mempolicy' from incompatible pointer type
mm/hugetlb.c:1866: warning: assignment from incompatible pointer type
mm/hugetlb.c:1868: warning: passing argument 3 of 'set_max_huge_pages' from incompatible pointer type
mm/hugetlb.c:1870: warning: comparison of distinct pointer types lacks a cast
mm/hugetlb.c:1862: warning: unused variable '_m'

This can be fixed after my "nodemask: make NODEMASK_ALLOC more general" 
patch is merged and the following is applied as I suggested in 
http://marc.info/?l=linux-mm&m=125270872312494:

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/hugetlb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1365,7 +1365,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 	int nid;
 	unsigned long count;
 	struct hstate *h;
-	NODEMASK_ALLOC(nodemask, nodes_allowed);
+	NODEMASK_ALLOC(nodemask_t, nodes_allowed);
 
 	err = strict_strtoul(buf, 10, &count);
 	if (err)
@@ -1859,7 +1859,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 	proc_doulongvec_minmax(table, write, buffer, length, ppos);
 
 	if (write) {
-		NODEMASK_ALLOC(nodemask, nodes_allowed);
+		NODEMASK_ALLOC(nodemask_t, nodes_allowed);
 		if (!(obey_mempolicy &&
 			       init_nodemask_of_mempolicy(nodes_allowed))) {
 			NODEMASK_FREE(nodes_allowed);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
