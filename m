Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00ED06B0089
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 15:02:50 -0400 (EDT)
Date: Thu, 1 Oct 2009 12:47:42 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 7/10] hugetlb:  update hugetlb documentation for NUMA
 controls.
Message-Id: <20091001124742.cb6ca371.randy.dunlap@oracle.com>
In-Reply-To: <20091001165851.32248.12538.sendpatchset@localhost.localdomain>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain>
	<20091001165851.32248.12538.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, clameter@sgi.com, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 01 Oct 2009 12:58:51 -0400 Lee Schermerhorn wrote:

> [PATCH 7/10] hugetlb:  update hugetlb documentation for NUMA controls
> 
> Against:  2.6.31-mmotm-090925-1435
> 
> 
> This patch updates the kernel huge tlb documentation to describe the
> numa memory policy based huge page management.  Additionaly, the patch
> includes a fair amount of rework to improve consistency, eliminate
> duplication and set the context for documenting the memory policy
> interaction.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> 
>  Documentation/vm/hugetlbpage.txt |  267 ++++++++++++++++++++++++++-------------
>  1 file changed, 179 insertions(+), 88 deletions(-)
> 
> Index: linux-2.6.31-mmotm-090925-1435/Documentation/vm/hugetlbpage.txt
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/Documentation/vm/hugetlbpage.txt	2009-09-30 15:04:40.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/Documentation/vm/hugetlbpage.txt	2009-09-30 15:05:22.000000000 -0400
> @@ -159,6 +163,101 @@ Inside each of these directories, the sa
>  
>  which function as described above for the default huge page-sized case.
>  
> +
> +Interaction of Task Memory Policy with Huge Page Allocation/Freeing:

Preferable not to end section "title" with a colon.

> +
> +Whether huge pages are allocated and freed via the /proc interface or
> +the /sysfs interface using the nr_hugepages_mempolicy attribute, the NUMA
> +nodes from which huge pages are allocated or freed are controlled by the
> +NUMA memory policy of the task that modifies the nr_hugepages_mempolicy
> +sysctl or attribute.  When the nr_hugepages attribute is used, mempolicy
> +is ignored

      ignored.

> +
> +The recommended method to allocate or free huge pages to/from the kernel
> +huge page pool, using the nr_hugepages example above, is:
> +
> +    numactl --interleave <node-list> echo 20 \
> +				>/proc/sys/vm/nr_hugepages_mempolicy
> +
> +or, more succinctly:
> +
> +    numactl -m <node-list> echo 20 >/proc/sys/vm/nr_hugepages_mempolicy
> +
> +This will allocate or free abs(20 - nr_hugepages) to or from the nodes
> +specified in <node-list>, depending on whether number of persistent huge pages
> +is initially less than or greater than 20, respectively.  No huge pages will be
> +allocated nor freed on any node not included in the specified <node-list>.
> +
> +When adjusting the persistent hugepage count via nr_hugepages_mempolicy, any
> +memory policy mode--bind, preferred, local or interleave--may be used.  The
> +resulting effect on persistent huge page allocation is as follows:
> +
...
> +
> +Per Node Hugepages Attributes
> +
> +A subset of the contents of the root huge page control directory in sysfs,
> +described above, has been replicated under each "node" system device in:
> +
> +	/sys/devices/system/node/node[0-9]*/hugepages/
> +
> +Under this directory, the subdirectory for each supported huge page size
> +contains the following attribute files:
> +
> +	nr_hugepages
> +	free_hugepages
> +	surplus_hugepages
> +
> +The free_' and surplus_' attribute files are read-only.  They return the number
> +of free and surplus [overcommitted] huge pages, respectively, on the parent
> +node.
> +
> +The nr_hugepages attribute will return the total number of huge pages on the

s/will return/returns/  [just a preference]

> +specified node.  When this attribute is written, the number of persistent huge
> +pages on the parent node will be adjusted to the specified value, if sufficient
> +resources exist, regardless of the task's mempolicy or cpuset constraints.
> +
> +Note that the number of overcommit and reserve pages remain global quantities,
> +as we don't know until fault time, when the faulting task's mempolicy is
> +applied, from which node the huge page allocation will be attempted.
> +
> +
> +Using Huge Pages:

Drop ':'.

> +
>  If the user applications are going to request huge pages using mmap system
>  call, then it is required that system administrator mount a file system of
>  type hugetlbfs:


---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
